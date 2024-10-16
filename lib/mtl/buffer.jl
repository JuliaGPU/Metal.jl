export MTLBuffer

# From docs: "MSL implements a buffer as a pointer to a built-in or user defined data type described in the
# device, constant, or threadgroup address space.
@objcwrapper MTLBuffer <: MTLResource

@objcproperties MTLBuffer begin
    @autoproperty length::NSUInteger # In bytes
    @autoproperty device::id{MTLDevice}
    @autoproperty contents::Ptr{Cvoid}
    @autoproperty remoteStorageBuffer::id{MTLBuffer}
    @autoproperty gpuAddress::UInt64 type=Ptr{Cvoid}
end

Base.sizeof(buf::MTLBuffer) = Int(buf.length)

function Base.convert(::Type{Ptr{T}}, buf::MTLBuffer) where {T}
    buf.storageMode == MTLStorageModePrivate && error("Cannot access the contents of a private buffer")
    convert(Ptr{T}, buf.contents)
end


## allocation

function MTLBuffer(dev::Union{MTLDevice,MTLHeap}, bytesize::Integer;
                   storage=PrivateStorage, hazard_tracking=DefaultTracking,
                   cache_mode=DefaultCPUCache)
    opts = convert(MTLResourceOptions, storage) | hazard_tracking | cache_mode

    @assert 0 < bytesize <= dev.maxBufferLength # XXX: not supported by MTLHeap
    ptr = alloc_buffer(dev, bytesize, opts)

    return MTLBuffer(ptr)
end

function MTLBuffer(dev::MTLDevice, bytesize::Integer, ptr::Ptr;
                   nocopy=false, storage=SharedStorage, hazard_tracking=DefaultTracking,
                   cache_mode=DefaultCPUCache)
    storage == PrivateStorage && error("Cannot allocate-and-initialize a PrivateStorage buffer")
    opts =  convert(MTLResourceOptions, storage) | hazard_tracking | cache_mode

    @assert 0 < bytesize <= dev.maxBufferLength
    ptr = if nocopy
        alloc_buffer_nocopy(dev, bytesize, opts, ptr)
    else
        alloc_buffer(dev, bytesize, opts, ptr)
    end

    return MTLBuffer(ptr)
end

const _page_size::Ref{Int} = Ref{Int}(0)
function page_size()
    if _page_size[] == 0
        _page_size[] = Int(ccall(:getpagesize, Cint, ()))
    end
    _page_size[]
end

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
