export MTLBuffer, device, contents, alloc, free, handle

# From docs: "MSL implements a buffer as a pointer to a built-in or user defined data type described in the
# device, constant, or threadgroup address space.
@objcwrapper MTLBuffer <: MTLResource

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtBuffer}}, obj::MTLBuffer) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLBuffer(ptr::Ptr{MtBuffer}) = MTLBuffer(reinterpret(id, ptr))

# TODO: here


## properties

const buffer_properties = [
    (:contents,             Ptr{Cvoid}),
    (:length,               NSUInteger),
    (:remoteStorageBuffer,  :(id{MTLBuffer})),
    (:gpuAddress,           UInt64 => Ptr{Cvoid}),
]

Base.propertynames(::MTLBuffer) = map(first, buffer_properties)

@eval Base.getproperty(obj::MTLBuffer, f::Symbol) =
    $(emit_getproperties(:obj, MTLBuffer, :f, buffer_properties))

@eval Base.setproperty!(obj::MTLBuffer, f::Symbol, val) =
    $(emit_setproperties(:obj, MTLBuffer, :f, :val, buffer_properties))

Base.sizeof(buf::MTLBuffer) = Int(buf.length)

# TODO: remove this
function contents(buf::MTLBuffer)
    ptr = @objc [buf::id{MTLBuffer} contents]::Ptr{Cvoid}
    ptr == C_NULL && error("Cannot access the contents of a private buffer")
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
alloc_buffer(dev::MtlHeap, bytesize, opts::MTLResourceOptions) =
    @objc [dev::id{MTLHeap} newBufferWithLength:bytesize::NSUInteger
                            options:opts::MTLResourceOptions]::id{MTLBuffer}
alloc_buffer(dev::MtlHeap, bytesize, opts::MTLResourceOptions, ptr::Ptr) =
    @objc [dev::id{MTLHeap} newBufferWithBytes:ptr::Ptr{Cvoid}
                            length:bytesize::NSUInteger
                            options:opts::MTLResourceOptions]::id{MTLBuffer}

alloc_buffer(dev, bytesize, opts::Integer) =
    alloc_buffer(dev, bytesize, MTLResourceOptions(opts))
alloc_buffer(dev, bytesize, opts::Integer, ptr) =
    alloc_buffer(dev, bytesize, MTLResourceOptions(opts), ptr)

function MTLBuffer(dev::Union{MTLDevice,MtlHeap},
                   bytesize::Integer;
                   storage = Private,
                   hazard_tracking = DefaultTracking,
                   cache_mode = DefaultCPUCache)
    opts = storage | hazard_tracking | cache_mode

    @assert 0 < bytesize <= dev.maxBufferLength # XXX: not supported by MtlHeap
    ptr = alloc_buffer(dev, bytesize, opts)

    return MTLBuffer(ptr)
end

function MTLBuffer(dev::Union{MTLDevice,MtlHeap},
                   bytesize::Integer,
                   ptr::Ptr;
                   storage = Managed,
                   hazard_tracking = DefaultTracking,
                   cache_mode = DefaultCPUCache)
    storage == Private && error("Can't create a Private copy-allocated buffer.")
    opts =  storage | hazard_tracking | cache_mode

    @assert 0 < bytesize <= dev.maxBufferLength # XXX: not supported by MtlHeap
    ptr = alloc_buffer(dev, bytesize, opts, ptr)

    return MTLBuffer(ptr)
end

"""
    alloc(device, bytesize, [ptr=nothing]; storage=Default, hazard_tracking=Default, chache_mode=Default)
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
 - Memoryless : an iOs specific thing that won't work on Mac.

Note that `Private` buffers can't be directly accessed from the CPU, therefore you cannot
use this option if you pass a ptr to initialize the memory.
"""
alloc(args...; kwargs...) = MTLBuffer(args...; kwargs...)

"""
    free(buffer::MTLBuffer)

Frees the buffer if the handle is valid.
This does not protect against double-freeing of the same buffer!
"""
free(buf::MTLBuffer) = @objc [buf::id{MTLBuffer} release]::Nothing

"""
    DidModifyRange!(buf::MTLBuffer, range::UnitRange)

Notifies the GPU that the range of bytes specified by `range` have been modified on the CPU,
and that they should be transferred to the device before executing any following command.

Only valid for `Managed` buffers.
"""
function DidModifyRange!(buf::MTLBuffer, range)
    @objc [buf::id{MTLBuffer} didModifyRange:range::NSRange]::Nothing
end

# Views on different device
NewBuffer(buf::MTLBuffer, d::MTLDevice) =
    @objc [buf::id{MTLBuffer} newRemoteBufferViewForDevice:d::id{MTLDevice}]::id{MTLBuffer}

# TODO: remove this
ParentBuffer(buf::MTLBuffer) = buf.remoteStorageBuffer

handle_array(vec::Vector{<:MTLBuffer}) = [buf.handle for buf in vec]
