#
# command buffer descriptor
#

export MtlCommandBufferDescriptor

const MTLCommandBufferDescriptor = Ptr{MTL.MtCommandBufferDescriptor}

mutable struct MtlCommandBufferDescriptor
    handle::MTLCommandBufferDescriptor
end

Base.unsafe_convert(::Type{MTLCommandBufferDescriptor}, q::MtlCommandBufferDescriptor) =
    q.handle

function MtlCommandBufferDescriptor()
    handle = mtNewCommandBufferDescriptor()
    obj = MtlCommandBufferDescriptor(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(desc::MtlCommandBufferDescriptor)
    mtRelease(desc.handle)
end


## properties

Base.propertynames(::MtlCommandBufferDescriptor) = (
    :retainedReferences, :errorOptions
)

function Base.getproperty(o::MtlCommandBufferDescriptor, f::Symbol)
    if f === :errorOptions
        mtCommandBufferDescriptorErrorOptions(o)
    elseif f === :retainedReferences
        mtCommandBufferDescriptorRetainedReferences(o)
    else
        getfield(o, f)
    end
end

function Base.setproperty!(o::MtlCommandBufferDescriptor, f::Symbol, val)
    if f === :errorOptions
        mtCommandBufferDescriptorErrorOptionsSet(o, val)
    elseif f === :retainedReferences
        mtCommandBufferDescriptorRetainedReferencesSet(o, val)
    else
        setfield!(o, f, val)
    end
end


## display

function Base.show(io::IO, desc::MtlCommandBufferDescriptor)
    print(io, "MtlCommandBufferDescriptor(...)")
end

function show(io::IO, ::MIME"text/plain", q::MtlCommandBufferDescriptor)
    println(io, "MtlCommandBufferDescriptor:")
    println(io, " retainReferences:  ", q.retainReferences)
    print(io,   " errorOption: ", q.errorOption)
end


#
# command buffer
#

export MtlCommandBuffer, enqueue!, wait_scheduled, wait_completed, encode_signal!,
       encode_wait!, commit!, on_scheduled, on_completed

const MTLCommandBuffer = Ptr{MtCommandBuffer}

"""
    MtlCommandBuffer(queue::MtlCommandQueue, [desc::MtlCommandBufferDescriptor])

A container that stores encoded commands for the GPU to execute.
"""
mutable struct MtlCommandBuffer
    handle::MTLCommandBuffer
    queue::MtlCommandQueue
    desc::Union{Nothing, MtlCommandBufferDescriptor}
end

Base.unsafe_convert(::Type{MTLCommandBuffer}, q::MtlCommandBuffer) = q.handle

Base.:(==)(a::MtlCommandBuffer, b::MtlCommandBuffer) = a.handle == b.handle
Base.hash(q::MtlCommandBuffer, h::UInt) = hash(q.handle, h)

function MtlCommandBuffer(queue::MtlCommandQueue,
                          desc::MtlCommandBufferDescriptor=MtlCommandBufferDescriptor())
    handle = mtNewCommandBufferWithDescriptor(queue, desc)
    obj = MtlCommandBuffer(handle, queue, desc)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(cmdbuf::MtlCommandBuffer)
    mtRelease(cmdbuf.handle)
end


## properties

Base.propertynames(::MtlCommandBuffer) = (
    :device, :commandQueue, :label,
    :status, :errorOptions, :error,
    #=:logs,=#
    :kernelStartTime, :kernelEndTime, :gpuStartTime, :gpuEndTime,
    :retainedReferences, :encoderInfo
)

function Base.getproperty(o::MtlCommandBuffer, f::Symbol)
    if f === :device
        MtlDevice(mtCommandBufferDevice(o))
    elseif f === :commandQueue
        MtlCommandQueue(mtCommandBufferCommandQueue(o), o.device)
    elseif f === :label
        ptr = mtCommandBufferLabel(o)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    elseif f === :status
        mtCommandBufferStatus(o)
    elseif f === :error
        ptr = mtCommandBufferError(o)
        ptr == C_NULL ? nothing : MtlError(ptr)
    elseif f === :errorOptions
        mtCommandBufferErrorOptions(o)
    elseif f === :kernelStartTime
        mtCommandBufferKernelStartTime(o)
    elseif f === :kernelEndTime
        mtCommandBufferKernelEndTime(o)
    elseif f === :gpuStartTime
        mtCommandBufferGPUStartTime(o)
    elseif f === :gpuEndTime
        mtCommandBufferGPUEndTime(o)
    elseif f === :retainedReferences
        mtCommandBufferRetainedReferences(o)
    elseif f === :encoderInfo
        mtCommandBufferEncoderInfo(o)
    else
        getfield(o, f)
    end
end

function Base.setproperty!(o::MtlCommandBuffer, f::Symbol, val)
    if f === :label
		mtCommandBufferLabelSet(o, val)
    else
        setfield!(o, f, val)
    end
end


## display

function Base.show(io::IO, q::MtlCommandBuffer)
    print(io, "MtlCommandBuffer(...)")
end

function show(io::IO, ::MIME"text/plain", q::MtlCommandBuffer)
    println(io, "MtlCommandBuffer:")
    println(io, " queue:  ", q.commandQueue)
    print(io,   " status: ", q.status)
end


## operations

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
function enqueue!(q::MtlCommandBuffer)
    q.status in [MtCommandBufferStatusCompleted, MtCommandBufferStatusEnqueued] && error("Cannot enqueue an already enqueued command buffer")
    mtCommandBufferEnqueue(q)
end

function commit!(q::MtlCommandBuffer)
    q.status in [MtCommandBufferStatusCompleted, MtCommandBufferStatusCommitted] && error("Cannot commit an already committed/completed command buffer")
    mtCommandBufferCommit(q)
end

"""
    wait_scheduled(commandBuffer)

Blocks execution of the current thread until the command buffer is scheduled.
This method returns after the command buffer has been scheduled and all code
blocks registered by addScheduledHandler: have been invoked. A command buffer
is considered scheduled after all its dependencies are resolved, and it is sent
to the GPU for execution.
"""
wait_scheduled(q::MtlCommandBuffer) = mtCommandBufferWaitUntilScheduled(q)

"""
    wait_completed(cmdbuf::MtlCommandBuffer)

Blocks execution of the current thread until execution of the command
buffer is completed.
This method returns after the command buffer is completed and all code
blocks registered by addCompletedHandler: are invoked.
"""
wait_completed(q::MtlCommandBuffer) = mtCommandBufferWaitUntilCompleted(q)

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
encode_signal!(buf::MtlCommandBuffer, ev::MtlAbstractEvent, val::Integer) =
    mtCommandBufferEncodeSignalEvent(buf, ev, val)

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
encode_wait!(buf::MtlCommandBuffer, ev::MtlAbstractEvent, val::Integer) =
    mtCommandBufferEncodeWaitForEvent(buf, ev, val)

function _command_buffer_async_callback(handle, data)
    # we don't care about the buffer (handle), the user can capture it if needed
    ccall(:uv_async_send, Cint, (Ptr{Cvoid},), data)
    return
end

function _command_buffer_callback(f::Base.Callable, buf::MtlCommandBuffer)
    cond = Base.AsyncCondition() do async_cond
        f()
        close(async_cond)
    end

    # the condition object is embedded in a task, so the Julia scheduler keeps it alive

    handler = @cfunction(_command_buffer_async_callback, Nothing,
                         (MTL.MTLCommandBufferDescriptor, Ptr{Cvoid}))

    return handler, cond
end

"""
    on_scheduled(buf::MtlCommandBuffer) do buf
        ...
    end

Execute a block of code when execution of the command buffer is scheduled.
"""
function on_scheduled(f::Base.Callable, buf::MtlCommandBuffer)
    handler, data = _command_buffer_callback(f, buf)
    MTL.mtCommandBufferOnScheduled(buf, data, handler)
end

"""
    on_completed(buf::MtlCommandBuffer) do buf
        ...
    end

Execute a block of code when execution of the command buffer is completed.
"""
function on_completed(f::Base.Callable, buf::MtlCommandBuffer)
    handler, data = _command_buffer_callback(f, buf)
    MTL.mtCommandBufferOnCompleted(buf, data, handler)
end

