export MtlCommandQueue

const MTLCommandQueue = Ptr{MtCommandQueue} 

"""
    MtlCommandQueue(dev::MtlDevice)

A queue that organizes command buffers to be executed by the GPU `MtlDevice`.

A MTLCommandQueue object is used to queue an ordered list of command buffers for a 
MTLDevice to execute. Command queues are thread-safe and allow multiple outstanding 
command buffers to be encoded simultaneously.

[Metal Docs](https://developer.apple.com/documentation/metal/mtlcommandqueue?language=objc)
"""
mutable struct MtlCommandQueue
    handle::MTLCommandQueue
    device::MtlDevice
end

Base.convert(::Type{MTLCommandQueue}, q::MtlCommandQueue) = q.handle
Base.unsafe_convert(::Type{MTLCommandQueue}, q::MtlCommandQueue) = convert(MTLCommandQueue, q.handle) 

Base.:(==)(a::MtlCommandQueue, b::MtlCommandQueue) = a.handle == b.handle
Base.hash(q::MtlCommandQueue, h::UInt) = hash(q.handle, h)

function MtlCommandQueue(dev::MtlDevice) 
	queue = mtNewCommandQueue(dev)
	obj = MtlCommandQueue(queue, dev)
	finalizer(unsafe_destroy!, obj)
	return obj
end

function unsafe_destroy!(queue::MtlCommandQueue)
	if queue.handle !== C_NULL
		mtCommandQueueRelease(queue)
	end
end

function label(l::MtlCommandQueue)
	ptr = mtCommandQueueLabel(l)
	return ptr == C_NULL ? "" : unsafe_string(ptr) 
end

function show(io::IO, ::MIME"text/plain", q::MtlCommandQueue)
	println(io, "MtlCommandQueue:")
	println(io, " handle  : ", q.handle)
	  print(io, " device  : ", q.device)
end