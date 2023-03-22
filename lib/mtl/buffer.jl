export MTLBuffer, device, contents, alloc, free, handle

# From docs: "MSL implements a buffer as a pointer to a built-in or user defined data type described in the
# device, constant, or threadgroup address space.
@objcwrapper MTLBuffer <: MTLResource

@objcproperties MTLBuffer begin
    @autoproperty length::NSUInteger
    @autoproperty device::id{MTLDevice}
    @autoproperty contents::Ptr{Cvoid}
    @autoproperty remoteStorageBuffer::id{MTLBuffer}
    @autoproperty gpuAddress::UInt64 type=Ptr{Cvoid}
end

Base.sizeof(buf::MTLBuffer) = Int(buf.length)

function contents(buf::MTLBuffer)
    buf.storageMode == Private && error("Cannot access the contents of a private buffer")
    ptr = @objc [buf::id{MTLBuffer} contents]::Ptr{Cvoid}
    return ptr
end


## allocation

# from device
alloc_buffer(dev::MTLDevice, bytesize, opts::MTLResourceOptions) =
    @objc [dev::id{MTLDevice} newBufferWithLength:bytesize::NSUInteger
                              options:opts::MTLResourceOptions]::id{MTLBuffer}
alloc_buffer(dev::MTLDevice, bytesize, opts::MTLResourceOptions, ptr::Ptr) =
    @objc [dev::id{MTLDevice} newBufferWithBytes:ptr::Ptr{Cvoid}
                              length:bytesize::NSUInteger
                              options:opts::MTLResourceOptions]::id{MTLBuffer}

# from heap
alloc_buffer(dev::MTLHeap, bytesize, opts::MTLResourceOptions) =
    @objc [dev::id{MTLHeap} newBufferWithLength:bytesize::NSUInteger
                            options:opts::MTLResourceOptions]::id{MTLBuffer}
alloc_buffer(dev::MTLHeap, bytesize, opts::MTLResourceOptions, ptr::Ptr) =
    @objc [dev::id{MTLHeap} newBufferWithBytes:ptr::Ptr{Cvoid}
                            length:bytesize::NSUInteger
                            options:opts::MTLResourceOptions]::id{MTLBuffer}

alloc_buffer(dev, bytesize, opts::Integer) =
    alloc_buffer(dev, bytesize, MTLResourceOptions(opts))
alloc_buffer(dev, bytesize, opts::Integer, ptr) =
    alloc_buffer(dev, bytesize, MTLResourceOptions(opts), ptr)

function MTLBuffer(dev::Union{MTLDevice,MTLHeap},
                   bytesize::Integer;
                   storage = Private,
                   hazard_tracking = DefaultTracking,
                   cache_mode = DefaultCPUCache)
    opts = storage | hazard_tracking | cache_mode

    @assert 0 < bytesize <= dev.maxBufferLength # XXX: not supported by MTLHeap
    ptr = alloc_buffer(dev, bytesize, opts)

    return MTLBuffer(ptr)
end

function MTLBuffer(dev::Union{MTLDevice,MTLHeap},
                   bytesize::Integer,
                   ptr::Ptr;
                   storage = Managed,
                   hazard_tracking = DefaultTracking,
                   cache_mode = DefaultCPUCache)
    storage == Private && error("Can't create a Private copy-allocated buffer.")
    opts =  storage | hazard_tracking | cache_mode

    @assert 0 < bytesize <= dev.maxBufferLength # XXX: not supported by MTLHeap
    ptr = alloc_buffer(dev, bytesize, opts, ptr)

    return MTLBuffer(ptr)
end

"""
    alloc(device, bytesize, [ptr=nothing]; storage=Default, hazard_tracking=Default, cache_mode=Default)
    MTLBuffer(device, bytesize...)

Allocates a Metal buffer on `device` of`bytesize` bytes. If a CPU-pointer is passed as last
argument, then the buffer is initialized with the content of the memory starting at `ptr`,
otherwise it's zero-initialized.

! Note: You are responsible for freeing the returned buffer

The storage kwarg controls where the buffer is stored. Possible values are:
 - Private : Residing on the device
 - Shared  : Residing on the host
 - Managed : Keeps two copies of the buffer, on device and on host. Explicit calls must be
   given to syncronize the two
 - Memoryless : an iOS specific thing that won't work on Mac.

Note that `Private` buffers can't be directly accessed from the CPU, therefore you cannot
use this option if you pass a ptr to initialize the memory.
"""
alloc(args...; kwargs...) = MTLBuffer(args...; kwargs...)

"""
    free(buffer::MTLBuffer)

Frees the buffer if the handle is valid.
This does not protect against double-freeing of the same buffer!
"""
free(buf::MTLBuffer) = release(buf)

"""
    DidModifyRange!(buf::MTLBuffer, range::UnitRange)

Notifies the GPU that the range of bytes specified by `range` have been modified on the CPU,
and that they should be transferred to the device before executing any following command.

Only valid for `Managed` buffers.
"""
function DidModifyRange!(buf::MTLBuffer, range)
    @objc [buf::id{MTLBuffer} didModifyRange:range::NSRange]::Nothing
end
