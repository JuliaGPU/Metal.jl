export MTLBuffer, contents

# From docs: "MSL implements a buffer as a pointer to a built-in or user defined data type described in the
# device, constant, or threadgroup address space.

# @objcwrapper MTLBuffer <: MTLResource

# MTLBuffer is deliberately unmanaged: buffer lifetime is owned by the pool/DataRef
# layer, so wrappers stay cheap isbits handles that can be shared by views.
Base.sizeof(buf::MTLBuffer) = Int(buf.length)

contents(buf::MTLBuffer) = @objc [buf::id{MTLBuffer} contents]::Ptr{Cvoid}

function Base.convert(::Type{Ptr{T}}, buf::MTLBuffer) where {T}
    buf.storageMode == MTLStorageModePrivate && error("Cannot access the contents of a private buffer")
    return convert(Ptr{T}, contents(buf))
end


## allocation

function max_buffer_length(dev::MTLDevice)
    @memoize key=pointer(dev)::id{MTLDevice} begin
        Int(dev.maxBufferLength)
    end::Int
end

max_buffer_length(heap::MTLHeap) = max_buffer_length(heap.device)

function MTLBuffer(dev::Union{MTLDevice,MTLHeap}, bytesize::Integer;
                   storage::Type{<:StorageMode}=PrivateStorage, hazard_tracking=DefaultTracking,
                   cache_mode=DefaultCPUCache)
    opts = convert(MTLResourceOptions, storage) | hazard_tracking | cache_mode

    @assert 0 < bytesize <= max_buffer_length(dev)
    ptr = alloc_buffer(dev, bytesize, opts)
    # Metal signals allocation failure by returning nil
    iszero(UInt(ptr)) && throw(OutOfMemoryError())

    return MTLBuffer(ptr)
end

function MTLBuffer(dev::MTLDevice, bytesize::Integer, ptr::Ptr;
                   nocopy=false, storage::Type{<:StorageMode}=SharedStorage, hazard_tracking=DefaultTracking,
                   cache_mode=DefaultCPUCache)
    storage == PrivateStorage && error("Cannot allocate-and-initialize a PrivateStorage buffer")
    opts =  convert(MTLResourceOptions, storage) | hazard_tracking | cache_mode

    @assert 0 < bytesize <= max_buffer_length(dev)
    ptr = if nocopy
        alloc_buffer_nocopy(dev, bytesize, opts, ptr)
    else
        alloc_buffer(dev, bytesize, opts, ptr)
    end
    # Metal signals allocation failure by returning nil
    iszero(UInt(ptr)) && throw(OutOfMemoryError())

    return MTLBuffer(ptr)
end

page_size() = @memoize begin
    Int(ccall(:getpagesize, Cint, ()))
end::Int

function can_alloc_nocopy(ptr::Ptr, bytesize::Integer)
    # newBufferWithBytesNoCopy has several restrictions:
    ## the pointer has to be page-aligned
    if Int(ptr) % page_size() != 0
        return false
    end
    ## the new buffer needs to be page-aligned
    ## XXX: on macOS 14, this doesn't seem required; is this a documentation issue?
    if bytesize % page_size() != 0
        return false
    end
    return true
end

# from device
alloc_buffer(dev::MTLDevice, bytesize, opts) =
    @objc [dev::id{MTLDevice} newBufferWithLength:bytesize::NSUInteger
                              options:opts::MTLResourceOptions]::id{MTLBuffer}
alloc_buffer(dev::MTLDevice, bytesize, opts, ptr::Ptr) =
    @objc [dev::id{MTLDevice} newBufferWithBytes:ptr::Ptr{Cvoid}
                              length:bytesize::NSUInteger
                              options:opts::MTLResourceOptions]::id{MTLBuffer}
function alloc_buffer_nocopy(dev::MTLDevice, bytesize, opts, ptr::Ptr)
    can_alloc_nocopy(ptr, bytesize) ||
        throw(ArgumentError("Cannot allocate nocopy buffer from non-aligned memory"))
    @objc [dev::id{MTLDevice} newBufferWithBytesNoCopy:ptr::Ptr{Cvoid}
                              length:bytesize::NSUInteger
                              options:opts::MTLResourceOptions
                              deallocator:nil::id{Object}]::id{MTLBuffer}
end

# from heap
alloc_buffer(dev::MTLHeap, bytesize, opts) =
    @objc [dev::id{MTLHeap} newBufferWithLength:bytesize::NSUInteger
                            options:opts::MTLResourceOptions]::id{MTLBuffer}

"""
    DidModifyRange!(buf::MTLBuffer, range::UnitRange)

Notifies the GPU that the range of bytes specified by `range` have been modified on the CPU,
and that they should be transferred to the device before executing any following command.

Only valid for `ManagedStorage` buffers.
"""
function DidModifyRange!(buf::MTLBuffer, range)
    @objc [buf::id{MTLBuffer} didModifyRange:range::NSRange]::Nothing
end
