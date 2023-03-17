#
# commannd buffer enums
#

@cenum MTLCommandBufferErrorOption::NSUInteger begin
    MTLCommandBufferErrorOptionNone = 0
    MTLCommandBufferErrorOptionEncoderExecutionStatus = 1
end

@cenum MTLCommandBufferStatus::NSUInteger begin
    MTLCommandBufferStatusNotEnqueued = 0
    MTLCommandBufferStatusEnqueued = 1
    MTLCommandBufferStatusCommitted = 2
    MTLCommandBufferStatusScheduled = 3
    MTLCommandBufferStatusCompleted = 4
    MTLCommandBufferStatusError = 5
end


#
# command buffer descriptor
#

export MTLCommandBufferDescriptor

@objcwrapper immutable=false MTLCommandBufferDescriptor <: NSObject

@objcproperties MTLCommandBufferDescriptor begin
    @autoproperty retainedReferences::Bool setter=setRetainedReferences
    @autoproperty errorOptions::MTLCommandBufferErrorOption setter=setErrorOptions
end

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

@objcwrapper MTLCommandBuffer <: NSObject

@objcproperties MTLCommandBuffer begin
    # Identifying the Command Buffer
    @autoproperty commandQueue::id{MTLCommandQueue}
    @autoproperty label::id{NSString} setter=setLabel
    @autoproperty device::id{MTLDevice}
    @autoproperty status::MTLCommandBufferStatus

    # Getting Error Details
    @autoproperty error::id{NSError}
    @autoproperty errorOptions::MTLCommandBufferErrorOption

    # Reading the Runtime Message Logs
    #@autoproperty logs::id{NSArray} type=Vector{MTLCommandBufferLogEntry}

    # Checking Scheduling Times on the CPU
    @autoproperty kernelStartTime::Cdouble
    @autoproperty kernelEndTime::Cdouble

    # Checking Execution Times on the GPU
    @autoproperty GPUStartTime::Cdouble
    @autoproperty GPUEndTime::Cdouble

    # Determining Whether to Maintain Strong References
    @autoproperty retainedReferences::Bool
end

function MTLCommandBuffer(queue::MTLCommandQueue,
                          desc::MTLCommandBufferDescriptor=MTLCommandBufferDescriptor())
    handle = @objc [queue::id{MTLCommandQueue} commandBufferWithDescriptor:desc::id{MTLCommandBufferDescriptor}]::id{MTLCommandBuffer}
    obj = MTLCommandBuffer(handle)
    # command buffers are part of the queue, so we don't need to manage memory
    return obj
end

"""
    enqueue!(q::MTLCommandBuffer)

Enqueueing a command buffer reserves a place for the command buffer on the command
queue without committing the command buffer for execution. When this command buffer
is later committed, it keeps its position in the queue. You enqueue command buffers
so that you can create multiple command buffers with a fixed order of execution without
encoding the command buffers serially. You can use other threads to encode commands
into the command buffers and those threads can complete in any order.

[enqueue](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443019-enqueue?language=objc)
"""
function enqueue!(q::MTLCommandBuffer)
    q.status in [MTLCommandBufferStatusCompleted, MTLCommandBufferStatusEnqueued] &&
        error("Cannot enqueue an already enqueued command buffer")
    @objc [q::id{MTLCommandBuffer} enqueue]::Nothing
end

function commit!(q::MTLCommandBuffer)
    q.status in [MTLCommandBufferStatusCompleted, MTLCommandBufferStatusCommitted] &&
        error("Cannot commit an already committed/completed command buffer")
    @objc [q::id{MTLCommandBuffer} commit]::Nothing
end

"""
    wait_scheduled(commandBuffer)

Blocks execution of the current thread until the command buffer is scheduled.
This method returns after the command buffer has been scheduled and all code
blocks registered by addScheduledHandler: have been invoked. A command buffer
is considered scheduled after all its dependencies are resolved, and it is sent
to the GPU for execution.
"""
function wait_scheduled(q::MTLCommandBuffer)
    @objc [q::id{MTLCommandBuffer} waitUntilScheduled]::Nothing
end

"""
    wait_completed(cmdbuf::MTLCommandBuffer)

Blocks execution of the current thread until execution of the command
buffer is completed.
This method returns after the command buffer is completed and all code
blocks registered by addCompletedHandler: are invoked.
"""
function wait_completed(q::MTLCommandBuffer)
    @objc [q::id{MTLCommandBuffer} waitUntilCompleted]::Nothing
end

"""
    encode_signal!(buf::MTLCommandBuffer, ev::MTLEvent, val::UInt)

Encodes a command that signals the given event, updating it to a new value.

You can't encode a signal event if the command buffer has an active command encoder.
Metal signals the event after all commands scheduled prior to this command
have finished executing. If the new event value is greater than the event's
current value, Metal updates the event's value to the new value. Commands
waiting on the event are allowed to run if the new value is equal to or
greater than the value for which they are waiting. For shared events, this
update similarly triggers notification handlers waiting on the event.
"""
function encode_signal!(buf::MTLCommandBuffer, ev::MTLEvent, val::Integer)
    @objc [buf::id{MTLCommandBuffer} encodeSignalEvent:ev::id{MTLEvent}
                                     value:val::UInt64]::Nothing
end

"""
    encode_wait!(buf::MTLCommandBuffer, ev::MTLEvent, val::UInt)

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
function encode_wait!(buf::MTLCommandBuffer, ev::MTLEvent, val::Integer)
    @objc [buf::id{MTLCommandBuffer} encodeWaitForEvent:ev::id{MTLEvent}
                                     value:val::UInt64]::Nothing
end

if VERSION >= v"1.9-"

# on 1.9, we can just have Metal call back into Julia regardless of the thread it's on.
# this means we can have Metal pass us the buffer, and don't need any additional capture.
function _command_buffer_callback(f, _)
    # convert the incoming pointer, and discard any return value
    function g(_buf)
        try
            f(_buf == nil ? nothing : MTLCommandBuffer(_buf))
        catch err
            # we might be on an unmanaged thread here, so display the error
            # (otherwise it may get lost, or worse, crash Julia)
            @error "Command buffer callback encountered an error: " * sprint(showerror, err)
        end
        return
    end
    @objcblock(g, Nothing, (id{MTLCommandBuffer},))
end

else

# on 1.8 and earlier, we cannot have Metal call into Julia because it may happen from an
# unmanaged thread. instead, we use uv_async_send to notify the libuv event loop, but
# that doesn't take any arguments so we have to capture the buffer in the callback.
# we also cannot return any values, but that isn't needed for these handlers.
function _command_buffer_callback(f, buf)
    cond = Base.AsyncCondition() do async_cond
        try
            f(buf)
        catch err
            # although we're on a managed thread here, so can just throw the error,
            # let's report it similarly to how we do in the 1.9+ case.
            @error "Command buffer callback encountered an error: " * sprint(showerror, err)
        end
        close(async_cond)
    end
    @objcasyncblock(cond)
end

end

"""
    on_scheduled(buf::MTLCommandBuffer) do buf
        ...
        return
    end

Execute a block of code when execution of the command buffer is scheduled.
"""
function on_scheduled(f::Base.Callable, buf::MTLCommandBuffer)
    block = _command_buffer_callback(f, buf)
    @objc [buf::id{MTLCommandBuffer} addScheduledHandler:block::id{NSBlock}]::Nothing
end

"""
    on_completed(buf::MTLCommandBuffer) do buf
        ...
        return
    end

Execute a block of code when execution of the command buffer is completed.
"""
function on_completed(f::Base.Callable, buf::MTLCommandBuffer)
    block = _command_buffer_callback(f, buf)
    @objc [buf::id{MTLCommandBuffer} addCompletedHandler:block::id{NSBlock}]::Nothing
end

