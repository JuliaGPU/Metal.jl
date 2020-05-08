export MtlCommandBuffer

const MTLCommandBuffer = Ptr{MtCommandBuffer} 

"""
    MTLCommandBuffer(queue::MtlCommandQueue; unretained_references=false)

A container that stores encoded commands for the GPU to execute.

If `unretained_references=true` it doesn't hold strong references to any objects 
required to execute the command buffer

[Metal Docs](https://developer.apple.com/documentation/metal/mtlcommandbuffer?language=objc)
[Unretained references](https://developer.apple.com/documentation/metal/mtlcommandqueue/1508684-commandbufferwithunretainedrefer?language=objc)
"""
mutable struct MtlCommandBuffer
    handle::MTLCommandBuffer
    queue::MtlCommandQueue
end

Base.convert(::Type{MTLCommandBuffer}, q::MtlCommandBuffer) = q.handle
Base.unsafe_convert(::Type{MTLCommandBuffer}, q::MtlCommandBuffer) = convert(MTLCommandBuffer, q.handle) 

Base.:(==)(a::MtlCommandBuffer, b::MtlCommandBuffer) = a.handle == b.handle
Base.hash(q::MtlCommandBuffer, h::UInt) = hash(q.handle, h)

# Constructor
function MtlCommandBuffer(queue::MtlCommandQueue; unretained_references=true) 
	if unretained_references
		handle = mtNewCommandBuffer(queue)
	else
		handle = mtNewCommandBufferWithUnretainedReferences(queue)
	end

	obj = MtlCommandBuffer(handle, queue)
	finalizer(unsafe_destroy!, obj)
	return obj
end

function unsafe_destroy!(cmdbuf::MtlCommandBuffer)
	if cmdbuf.handle !== C_NULL
		mtlCommandBufferRelease(cmdbuf)
	end
end

# Properties
device(l::MtlCommandBuffer) = mtCommandBufferDevice(l)
queue(l::MtlCommandBuffer) = l.queue
retained_references(l::MtlCommandBuffer) = mtCommandBufferRetainedReferences(l)
function label(l::MtlCommandBuffer)
	ptr = mtCommandBufferLabel(l)
	return ptr == C_NULL ? "" : unsafe_string(ptr) 
end

# Operations
commit!(q::MtlCommandBuffer) = mtCommandBufferCommit(q)

"""
	enqueue!(q::MtlCommandBuffer)

Enqueueing a command buffer reserves a place for the command buffer on the command 
queue without committing the command buffer for execution. When this command buffer 
is later committed, it keeps its position in the queue. You enqueue command buffers 
so that you can create multiple command buffers with a fixed order of execution without 
encoding the command buffers serially. You can use other threads to encode commands 
into the command buffers and those threads can complete in any order.

[enqueue](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443019-enqueue?language=objc)
"""
enqueue!(q::MtlCommandBuffer) = mtCommandBufferEnqueue(q)

# Add scheduled handler! ???

waitUntilScheduled(q::MtlCommandBuffer) = mtCommandBufferWaitUntilScheduled(q)
waitUntilCompleted(q::MtlCommandBuffer) = mtCommandBufferWaitUntilCompleted(q)

##STATUS
status(q::MtlCommandBuffer) = mtCommandBufferStatus(q)
kernel_start_time(q::MtlCommandBuffer) = mtCommandBufferKernelStartTime(q)
kernel_end_time(q::MtlCommandBuffer) = mtCommandBufferKernelEndTime(q)
gpu_start_time(q::MtlCommandBuffer) = mtCommandBufferGPUStartTime(q)
gpu_end_time(q::MtlCommandBuffer) = mtCommandBufferGPUEndTime(q)

function get_error(q::MtlCommandBuffer)
	err = mtCommandBufferError(q)
	if err === C_NULL
		return nothing
	else
		return NsError(err)
	end
end

function show(io::IO, ::MIME"text/plain", q::MtlCommandBuffer)
	println(io, "MtlCommandBuffer:")
	println(io, " handle  : ", q.handle)
	  print(io, " queue   : ", q.queue)
end

