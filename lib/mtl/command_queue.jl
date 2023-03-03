export MtlCommandQueue

const MTLCommandQueue = Ptr{MtCommandQueue}

"""
    MtlCommandQueue(dev::MTLDevice)

A queue that organizes command buffers to be executed by the GPU `MTLDevice`.

A MTLCommandQueue object is used to queue an ordered list of command buffers for a
MTLDevice to execute. Command queues are thread-safe and allow multiple outstanding
command buffers to be encoded simultaneously.

[Metal Docs](https://developer.apple.com/documentation/metal/mtlcommandqueue?language=objc)
"""
mutable struct MtlCommandQueue
    handle::MTLCommandQueue
    device::MTLDevice
end

Base.unsafe_convert(::Type{MTLCommandQueue}, q::MtlCommandQueue) = q.handle

Base.:(==)(a::MtlCommandQueue, b::MtlCommandQueue) = a.handle == b.handle
Base.hash(q::MtlCommandQueue, h::UInt) = hash(q.handle, h)

function MtlCommandQueue(dev::MTLDevice)
    queue = mtNewCommandQueue(dev)
    obj = MtlCommandQueue(queue, dev)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(queue::MtlCommandQueue)
    mtRelease(queue.handle)
end


## properties

Base.propertynames(::MtlCommandQueue) = (:device, :label)

function Base.getproperty(o::MtlCommandQueue, f::Symbol)
    if f === :device
        MTLDevice(mtCommandQueueDevice(o))
    elseif f === :label
        ptr = mtCommandQueueLabel(o)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    else
        getfield(o, f)
    end
end

function Base.setproperty!(o::MtlCommandQueue, f::Symbol, val)
    if f === :label
		mtCommandQueueLabelSet(o, val)
    else
        setfield!(o, f, val)
    end
end


## display

function show(io::IO, ::MIME"text/plain", q::MtlCommandQueue)
    println(io, "MtlCommandQueue:")
    print(io,   " device: ", q.device)
end
