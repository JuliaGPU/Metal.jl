export MtlBuffer, device, contents, alloc, free, handle

const MTLBuffer = Ptr{MtBuffer}

# From docs: "MSL implements a buffer as a pointer to a built-in or user defined data type described in the
# device, constant, or threadgroup address space.
struct MtlBuffer <: MtlResource
    handle::MTLBuffer
end

Base.unsafe_convert(::Type{MTLBuffer}, buf::MtlBuffer) = buf.handle

Base.:(==)(a::MtlBuffer, b::MtlBuffer) = a.handle == b.handle
Base.hash(buf::MtlBuffer, h::UInt) = hash(buf.handle, h)


## properties

Base.propertynames(o::MtlBuffer) = (
    :length,
    invoke(propertynames, Tuple{MtlResource}, o)...
)

function Base.getproperty(o::MtlBuffer, f::Symbol)
    if f === :length
        mtBufferLength(o)
    elseif f === :gpuAddress
        # XXX: even though the gpuAddress property is only documented in Metal 3,
        #      it seems to be present in earlier versions of the API as well.
        #      can we rely on this?
        Base.bitcast(Ptr{Nothing}, mtBufferGPUAddress(o))
    else
        invoke(getproperty, Tuple{MtlResource, Symbol}, o, f)
    end
end

Base.sizeof(buf::MtlBuffer) = Int(buf.length)

function contents(buf::MtlBuffer)
    buf.handle == C_NULL && return C_NULL
    ptr = Base.bitcast(Ptr{Cvoid}, mtBufferContents(buf))
    ptr == C_NULL && error("Cannot access the contents of a private buffer")
    return ptr
end


## allocation

alloc_buffer(dev::MTLDevice, bytesize, opts::MtlResourceOptions) =
    mtDeviceNewBufferWithLength(dev, bytesize, opts)
alloc_buffer(dev::MtlHeap, bytesize, opts::MtlResourceOptions) =
    mtHeapNewBufferWithLength(heap, bytesize, opts)
alloc_buffer(dev::MTLDevice, bytesize, opts::MtlResourceOptions, ptr::Ptr) =
    mtDeviceNewBufferWithBytes(dev, ptr, bytesize, opts)
alloc_buffer(dev::MtlHeap, bytesize, opts::MtlResourceOptions, ptr::Ptr) =
    mtHeapNewBufferWithBytes(heap, ptr, bytesize, opts)

alloc_buffer(dev, bytesize, opts::Integer) =
    alloc_buffer(dev, bytesize, Base.bitcast(MtlResourceOptions, UInt32(opts)))
alloc_buffer(dev, bytesize, opts::Integer, ptr) =
    alloc_buffer(dev, bytesize, Base.bitcast(MtlResourceOptions, UInt32(opts)), ptr)

function MtlBuffer(dev::Union{MTLDevice,MtlHeap},
                   bytesize::Integer;
                   storage = Private,
                   hazard_tracking = DefaultTracking,
                   cache_mode = DefaultCPUCache)
    opts = storage | hazard_tracking | cache_mode

    @assert 0 < bytesize <= dev.maxBufferLength # XXX: not supported by MtlHeap
    ptr = alloc_buffer(dev, bytesize, opts)

    return MtlBuffer(ptr)
end

function MtlBuffer(dev::Union{MTLDevice,MtlHeap},
                   bytesize::Integer,
                   ptr::Ptr;
                   storage = Managed,
                   hazard_tracking = DefaultTracking,
                   cache_mode = DefaultCPUCache)
    storage == Private && error("Can't create a Private copy-allocated buffer.")
    opts =  storage | hazard_tracking | cache_mode

    @assert 0 < bytesize <= dev.maxBufferLength # XXX: not supported by MtlHeap
    ptr = alloc_buffer(dev, bytesize, opts, ptr)

    return MtlBuffer(ptr)
end

"""
    alloc(device, bytesize, [ptr=nothing]; storage=Default, hazard_tracking=Default, chache_mode=Default)
    MtlBuffer(device, bytesize...)

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
alloc(args...; kwargs...) = MtlBuffer(args...; kwargs...)

"""
    free(buffer::MtlBuffer)

Frees the buffer if the handle is valid.
This does not protect against double-freeing of the same buffer!
"""
free(buf::MtlBuffer) = mtRelease(buf.handle)

"""
    DidModifyRange!(buf::MtlBuffer, range::UnitRange)

Notifies the GPU that the range of bytes specified by `range` have been modified on the CPU,
and that they should be transferred to the device before executing any following command.

Only valid for `Managed` buffers.
"""
function DidModifyRange!(buf::MtlBuffer, range::UnitRange)
    mtBufferDidModifyRange(buf, range)
end

# Views on different device
NewBuffer(buf::MtlBuffer, d::MTLDevice) =
    mtBufferNewRemoteBufferViewForDevice(buf, d);

function ParentBuffer(buf::MtlBuffer)
    orig = mtBufferRemoteStorageBuffer(buf);
    if orig == C_NULL
        return nothing
    else
        return MtlBuffer(orig)
    end
end

handle_array(vec::Vector{<:MtlBuffer}) = [buf.handle for buf in vec]
