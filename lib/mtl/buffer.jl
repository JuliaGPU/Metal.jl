export MTLBuffer, device, contents, handle

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
                   storage=Private, hazard_tracking=DefaultTracking,
                   cache_mode=DefaultCPUCache)
    opts = convert(MTLResourceOptions, storage) | hazard_tracking | cache_mode

    @assert 0 < bytesize <= dev.maxBufferLength # XXX: not supported by MTLHeap
    ptr = alloc_buffer(dev, bytesize, opts)

    return MTLBuffer(ptr)
end

function MTLBuffer(dev::MTLDevice, bytesize::Integer, ptr::Ptr;
                   nocopy = false, storage=Shared, hazard_tracking=DefaultTracking,
                   cache_mode=DefaultCPUCache)
    storage == Private && error(LazyString("Cannot create a Private ", (nocopy ? "buffer that shares memory with an Array" : "copy-allocated buffer.")))
    opts =  convert(MTLResourceOptions, storage) | hazard_tracking | cache_mode

    @assert 0 < bytesize <= dev.maxBufferLength
    alloc_f = nocopy ? alloc_buffer_nocopy : alloc_buffer
    ptr = alloc_f(dev, bytesize, opts, ptr)

    return MTLBuffer(ptr)
end

# from device
alloc_buffer(dev::MTLDevice, bytesize, opts) =
    @objc [dev::id{MTLDevice} newBufferWithLength:bytesize::NSUInteger
                              options:opts::MTLResourceOptions]::id{MTLBuffer}
alloc_buffer(dev::MTLDevice, bytesize, opts, ptr::Ptr) =
    @objc [dev::id{MTLDevice} newBufferWithBytes:ptr::Ptr{Cvoid}
                              length:bytesize::NSUInteger
                              options:opts::MTLResourceOptions]::id{MTLBuffer}
alloc_buffer_nocopy(dev::MTLDevice, bytesize, opts, ptr::Ptr) = # ptr MUST be page-aligned
    @objc [dev::id{MTLDevice} newBufferWithBytesNoCopy:ptr::Ptr{Cvoid}
                              length:bytesize::NSUInteger
                              options:opts::MTLResourceOptions
                              deallocator:nil::id{Object}]::id{MTLBuffer}

# from heap
alloc_buffer(dev::MTLHeap, bytesize, opts) =
    @objc [dev::id{MTLHeap} newBufferWithLength:bytesize::NSUInteger
                            options:opts::MTLResourceOptions]::id{MTLBuffer}

"""
    DidModifyRange!(buf::MTLBuffer, range::UnitRange)

Notifies the GPU that the range of bytes specified by `range` have been modified on the CPU,
and that they should be transferred to the device before executing any following command.

Only valid for `Managed` buffers.
"""
function DidModifyRange!(buf::MTLBuffer, range)
    @objc [buf::id{MTLBuffer} didModifyRange:range::NSRange]::Nothing
end
