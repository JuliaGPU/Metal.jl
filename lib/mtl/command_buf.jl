#
# command buffer descriptor
#

export MTLCommandBufferDescriptor

# @objcwrapper immutable=false MTLCommandBufferDescriptor <: NSObject

function MTLCommandBufferDescriptor()
    handle = @objc [MTLCommandBufferDescriptor new]::id{MTLCommandBufferDescriptor}
    obj = MTLCommandBufferDescriptor(handle)
    finalizer(release, obj)
    return obj
end



#
# command buffer
#

export MTLCommandBuffer, enqueue!, wait_scheduled, wait_completed, encode_signal!,
       encode_wait!, commit!, on_scheduled, on_completed

# @objcwrapper MTLCommandBuffer <: NSObject

function MTLCommandBuffer(queue::MTLCommandQueue,
                          desc::MTLCommandBufferDescriptor=MTLCommandBufferDescriptor())
    handle = @objc [queue::id{MTLCommandQueue} commandBufferWithDescriptor:desc::id{MTLCommandBufferDescriptor}]::id{MTLCommandBuffer}
    MTLCommandBuffer(handle)
end

function MTLCommandBuffer(f::Base.Callable, queue::MTLCommandQueue,
                          desc::MTLCommandBufferDescriptor=MTLCommandBufferDescriptor())
    cmdbuf = MTLCommandBuffer(queue, desc)
    commit!(f, cmdbuf)
    return cmdbuf
end

"""
    enqueue!(cmdbuf::MTLCommandBuffer)

Enqueueing a command buffer reserves a place for the command buffer on the command
queue without committing the command buffer for execution. When this command buffer
is later committed, it keeps its position in the queue. You enqueue command buffers
so that you can create multiple command buffers with a fixed order of execution without
encoding the command buffers serially. You can use other threads to encode commands
into the command buffers and those threads can complete in any order.

[enqueue](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443019-enqueue?language=objc)
"""
function enqueue!(cmdbuf::MTLCommandBuffer)
    cmdbuf.status in [MTLCommandBufferStatusCompleted, MTLCommandBufferStatusEnqueued] &&
        error("Cannot enqueue an already enqueued command buffer")
    @objc [cmdbuf::id{MTLCommandBuffer} enqueue]::Nothing
end

function commit!(cmdbuf::MTLCommandBuffer)
    cmdbuf.status in [MTLCommandBufferStatusCompleted, MTLCommandBufferStatusCommitted] &&
        error("Cannot commit an already committed/completed command buffer")
    @objc [cmdbuf::id{MTLCommandBuffer} commit]::Nothing
end

function commit!(f::Base.Callable, cmdbuf::MTLCommandBuffer)
    enqueue!(cmdbuf)
    ret = f(cmdbuf)
    commit!(cmdbuf)
    return ret
end

"""
    wait_scheduled(commandBuffer)

Blocks execution of the current thread until the command buffer is scheduled.
This method returns after the command buffer has been scheduled and all code
blocks registered by addScheduledHandler: have been invoked. A command buffer
is considered scheduled after all its dependencies are resolved, and it is sent
to the GPU for execution.
"""
function wait_scheduled(cmdbuf::MTLCommandBuffer)
    @objc [cmdbuf::id{MTLCommandBuffer} waitUntilScheduled]::Nothing
end

"""
    wait_completed(cmdbuf::MTLCommandBuffer)

Blocks execution of the current thread until execution of the command
buffer is completed.
This method returns after the command buffer is completed and all code
blocks registered by addCompletedHandler: are invoked.
"""
function wait_completed(cmdbuf::MTLCommandBuffer)
    @objc [cmdbuf::id{MTLCommandBuffer} waitUntilCompleted]::Nothing
end

"""
    encode_signal!(cmdbuf::MTLCommandBuffer, ev::MTLEvent, val::UInt)

Encodes a command that signals the given event, updating it to a new value.

You can't encode a signal event if the command buffer has an active command encoder.
Metal signals the event after all commands scheduled prior to this command
have finished executing. If the new event value is greater than the event's
current value, Metal updates the event's value to the new value. Commands
waiting on the event are allowed to run if the new value is equal to or
greater than the value for which they are waiting. For shared events, this
update similarly triggers notification handlers waiting on the event.
"""
function encode_signal!(cmdbuf::MTLCommandBuffer, ev::MTLEvent, val::Integer)
    @objc [cmdbuf::id{MTLCommandBuffer} encodeSignalEvent:ev::id{MTLEvent}
                                     value:val::UInt64]::Nothing
end

"""
    encode_wait!(cmdbuf::MTLCommandBuffer, ev::MTLEvent, val::UInt)

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
function encode_wait!(cmdbuf::MTLCommandBuffer, ev::MTLEvent, val::Integer)
    @objc [cmdbuf::id{MTLCommandBuffer} encodeWaitForEvent:ev::id{MTLEvent}
                                     value:val::UInt64]::Nothing
end

function _command_buffer_callback(f)
    # convert the incoming pointer, and discard any return value
    function wrapper(ptr)
        try
            f(ptr == nil ? nothing : MTLCommandBuffer(ptr))
        catch err
            # we might be on an unmanaged thread here, so display the error
            # (otherwise it may get lost, or worse, crash Julia)
            @error "Command buffer callback encountered an error: " * sprint(showerror, err)
        end
        return
    end
    @objcblock(wrapper, Nothing, (id{MTLCommandBuffer},))
end

"""
    on_scheduled(cmdbuf::MTLCommandBuffer) do cbuf
        ...
        return
    end

Execute a block of code when execution of the command buffer is scheduled.
"""
function on_scheduled(f::Base.Callable, cmdbuf::MTLCommandBuffer)
    block = _command_buffer_callback(f)
    @objc [cmdbuf::id{MTLCommandBuffer} addScheduledHandler:block::id{NSBlock}]::Nothing
end

"""
    on_completed(cmdbuf::MTLCommandBuffer) do cbuf
        ...
        return
    end

Execute a block of code when execution of the command buffer is completed.
"""
function on_completed(f::Base.Callable, cmdbuf::MTLCommandBuffer)
    block = _command_buffer_callback(f)
    @objc [cmdbuf::id{MTLCommandBuffer} addCompletedHandler:block::id{NSBlock}]::Nothing
end
