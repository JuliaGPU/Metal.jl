export
    MtlCommandBuffer, commit!

const MTLCommandBuffer = Ptr{MtCommandBuffer}

"""
    MtlCommandBuffer(queue::MtlCommandQueue; unretained_references=false)

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
function MtlCommandBuffer(queue::MtlCommandQueue; retain_references = true)
    if retain_references
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
        mtRelease(cmdbuf)
    end
end

## Properties
device(l::MtlCommandBuffer) = MtlDevice(mtCommandBufferDevice(l))
queue(l::MtlCommandBuffer) = l.queue
retained_references(l::MtlCommandBuffer) = mtCommandBufferRetainedReferences(l)
label(l::MtlCommandBuffer) = unsafe_string_maybe(mtCommandBufferLabel(l))

##STATUS
status(q::MtlCommandBuffer) = mtCommandBufferStatus(q)
kernel_start_time(q::MtlCommandBuffer) = mtCommandBufferKernelStartTime(q)
kernel_end_time(q::MtlCommandBuffer) = mtCommandBufferKernelEndTime(q)
gpu_start_time(q::MtlCommandBuffer) = mtCommandBufferGPUStartTime(q)
gpu_end_time(q::MtlCommandBuffer) = mtCommandBufferGPUEndTime(q)
execution_error(q::MtlCommandBuffer) = NsError_maybe(mtCommandBufferError(q))

# Operations
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

"""
    waitUntilScheduled(commandBuffer)

Blocks execution of the current thread until the command buffer is scheduled.
This method returns after the command buffer has been scheduled and all code
blocks registered by addScheduledHandler: have been invoked. A command buffer
is considered scheduled after all its dependencies are resolved, and it is sent
to the GPU for execution.
"""
waitUntilScheduled(q::MtlCommandBuffer) = mtCommandBufferWaitUntilScheduled(q)

"""
    waitUntilCompleted(cmdbuf::MtlCommandBuffer)
    Base.wait(cmdbuf::MtlCommandBuffer)

Blocks execution of the current thread until execution of the command
buffer is completed.
This method returns after the command buffer is completed and all code
blocks registered by addCompletedHandler: are invoked.
"""
waitUntilCompleted(q::MtlCommandBuffer) = mtCommandBufferWaitUntilCompleted(q)
Base.wait(q::MtlCommandBuffer) = waitUntilCompleted(q)

function show(io::IO, ::MIME"text/plain", q::MtlCommandBuffer)
    println(io, "MtlCommandBuffer:")
    println(io, " handle  : ", q.handle)
    println(io, " queue   : ", q.queue)
    print(io, "  status : ", status(q))
end

## One-Api like stuff
"""
    encode_signal!(buf::MtlCommandBuffer, ev::MtlEvent, val::UInt)

Encodes a command that signals the given event, updating it to a new value.

You can't encode a signal event if the command buffer has an active command encoder.
Metal signals the event after all commands scheduled prior to this command
have finished executing. If the new event value is greater than the event's
current value, Metal updates the event's value to the new value. Commands
waiting on the event are allowed to run if the new value is equal to or
greater than the value for which they are waiting. For shared events, this
update similarly triggers notification handlers waiting on the event.
"""
append_signal!(buf::MtlCommandBuffer, ev::MtlEvent, val::UInt) =
    mtEncodeSignalEvent(buf, ev, val)

"""
    encode_wait!(buf::MtlCommandBuffer, ev::MtlEvent, val::UInt)

Encodes a command that blocks the execution of the command buffer
until the given event reaches the given value.

You can't encode a signal event if the command buffer has an active command encoder.
When the device object reaches the command for the wait event, the
device object waits until the event is signaled with a value
equal to or larger than the provided value. While waiting, the
GPU executes commands that appear earlier than the wait command,
but doesn't start any commands that appear after it. Execution continues
immediately if the event already has an equal or larger value.
"""
append_wait!(buf::MtlCommandBuffer, ev::MtlEvent, val::UInt) =
    mtEncodeWaitForEvent(buf, ev, val)

##

commit!(q::MtlCommandBuffer) = mtCommandBufferCommit(q)
commit!(q::Vector{MtlCommandBuffer}) = map(mtCommandBufferCommit, q)

function commit!(f::Base.Callable, queue::MtlCommandQueue; kwargs...)
    cmdbuf = MtlCommandBuffer(f, queue; kwargs...)
    commit!(cmdbuf)
    return cmdbuf
end

function MtlCommandBuffer(f::Base.Callable, queue::MtlCommandQueue; kwargs...)
    cmdbuf = MtlCommandBuffer(queue; kwargs...)
    f(cmdbuf)
    return cmdbuf
end
