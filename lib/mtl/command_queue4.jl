#
# command queue descriptor
#

export MTL4CommandQueueDescriptor

# @objcwrapper managed = true MTL4CommandQueueDescriptor <: NSObject

function MTL4CommandQueueDescriptor()
    return @objc [MTL4CommandQueueDescriptor new]::MTL4CommandQueueDescriptor
end

function MTL4CommandQueueDescriptor(label)
    desc = MTL4CommandQueueDescriptor()
    desc.label = label
    return desc
end


#
# commit options
#

export MTL4CommitOptions

# @objcwrapper managed = true MTL4CommitOptions <: NSObject

function MTL4CommitOptions()
    return @objc [MTL4CommitOptions new]::MTL4CommitOptions
end

function MTL4CommitOptions(f::Base.Callable)
    options = MTL4CommitOptions()
    add_feedback_handler!(f, options)
    return options
end

function _commit_feedback_callback(f)
    # convert the incoming pointer, and discard any return value
    function wrapper(ptr)
        try
            f(ptr == nil ? nothing : MTL4CommitFeedback(ptr))
        catch err
            # we might be on an unmanaged thread here, so display the error
            # (otherwise it may get lost, or worse, crash Julia)
            @error "Commit feedback handler encountered an error: " * sprint(showerror, err)
        end
        return
    end
    @objcblock(wrapper, Nothing, (id{MTL4CommitFeedback},))
end

"""
    add_feedback_handler!(options::MTL4CommitOptions) do feedback
        ...
        return
    end

Register a block that Metal invokes once the GPU finishes executing the command buffers
committed with `options`. Unlike Metal 3's `addCompletedHandler:`, the handler receives an
`MTL4CommitFeedback` rather than the command buffer, since Metal 4 command buffers are
recycled as soon as they are committed.
"""
function add_feedback_handler!(f::Base.Callable, options::MTL4CommitOptions)
    block = _commit_feedback_callback(f)
    @objc [options::id{MTL4CommitOptions} addFeedbackHandler:block::id{NSBlock}]::Nothing
end

"""
    add_feedback_handler!(options::MTL4CommitOptions, cond::Base.AsyncCondition)

Signal `cond` once the GPU finishes executing the command buffers committed with `options`,
without running Julia code on Metal's feedback thread.
"""
function add_feedback_handler!(options::MTL4CommitOptions, cond::Base.AsyncCondition)
    block = @objcasyncblock(cond)
    @objc [options::id{MTL4CommitOptions} addFeedbackHandler:block::id{NSBlock}]::Nothing
end


#
# command queue
#

export MTL4CommandQueue

# @objcwrapper managed = true MTL4CommandQueue <: NSObject

function MTL4CommandQueue(dev::MTLDevice)
    return @objc [dev::id{MTLDevice} newMTL4CommandQueue]::MTL4CommandQueue
end

function MTL4CommandQueue(dev::MTLDevice, desc::MTL4CommandQueueDescriptor)
    err = Ref{id{NSError}}(nil)
    queue = @objc [dev::id{MTLDevice} newMTL4CommandQueueWithDescriptor:desc::id{MTL4CommandQueueDescriptor}
                                                                   error:err::Ptr{id{NSError}}]::Union{Nothing,MTL4CommandQueue}
    queue === nothing && throw_error(err[])
    return queue
end

function add_residency_set!(queue::MTL4CommandQueue, resset::MTLResidencySet)
    @objc [queue::id{MTL4CommandQueue} addResidencySet:resset::id{MTLResidencySet}]::Nothing
end

function remove_residency_set!(queue::MTL4CommandQueue, resset::MTLResidencySet)
    @objc [queue::id{MTL4CommandQueue} removeResidencySet:resset::id{MTLResidencySet}]::Nothing
end

"""
    commit!(queue::MTL4CommandQueue, cmdbuf::MTL4CommandBuffer, [options])

Submit `cmdbuf` for execution on `queue`. The command buffer must have been ended with
[`endCommandBuffer!`](@ref); it may be reused for encoding as soon as this returns, but its
allocator may only be reset once the GPU signals completion (see `MTL4CommitOptions`).
"""
function commit!(queue::MTL4CommandQueue, cmdbuf::MTL4CommandBuffer)
    ref = Ref(pointer(cmdbuf))
    GC.@preserve cmdbuf begin
        @objc [queue::id{MTL4CommandQueue} commit:ref::Ptr{id{MTL4CommandBuffer}}
                                            count:1::NSUInteger]::Nothing
    end
    return
end

function commit!(queue::MTL4CommandQueue, cmdbuf::MTL4CommandBuffer,
                 options::MTL4CommitOptions)
    ref = Ref(pointer(cmdbuf))
    GC.@preserve cmdbuf begin
        @objc [queue::id{MTL4CommandQueue} commit:ref::Ptr{id{MTL4CommandBuffer}}
                                            count:1::NSUInteger
                                          options:options::id{MTL4CommitOptions}]::Nothing
    end
    return
end

function commit!(queue::MTL4CommandQueue, cmdbufs::Vector{MTL4CommandBuffer})
    ptrs = map(pointer, cmdbufs)
    GC.@preserve cmdbufs ptrs begin
        @objc [queue::id{MTL4CommandQueue} commit:ptrs::Ptr{id{MTL4CommandBuffer}}
                                            count:length(ptrs)::NSUInteger]::Nothing
    end
    return
end

function commit!(queue::MTL4CommandQueue, cmdbufs::Vector{MTL4CommandBuffer},
                 options::MTL4CommitOptions)
    ptrs = map(pointer, cmdbufs)
    GC.@preserve cmdbufs ptrs begin
        @objc [queue::id{MTL4CommandQueue} commit:ptrs::Ptr{id{MTL4CommandBuffer}}
                                            count:length(ptrs)::NSUInteger
                                          options:options::id{MTL4CommitOptions}]::Nothing
    end
    return
end

"""
    signal_event!(queue::MTL4CommandQueue, ev::MTLEvent, val::Integer)

Enqueue an update of `ev` to `val` once all previously committed work on `queue` completes.
"""
function signal_event!(queue::MTL4CommandQueue, ev::MTLEventLike, val::Integer)
    @objc [queue::id{MTL4CommandQueue} signalEvent:ev::id{MTLEvent}
                                           value:val::UInt64]::Nothing
end

"""
    wait_event!(queue::MTL4CommandQueue, ev::MTLEvent, val::Integer)

Block subsequently committed work on `queue` until `ev` reaches `val`.
"""
function wait_event!(queue::MTL4CommandQueue, ev::MTLEventLike, val::Integer)
    @objc [queue::id{MTL4CommandQueue} waitForEvent:ev::id{MTLEvent}
                                            value:val::UInt64]::Nothing
end
