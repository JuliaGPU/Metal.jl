#
# tracked Metal 4 submissions
#
# Metal 4 command buffers carry no completion state. To take part in the same per-queue
# error accounting and synchronization as Metal 3 command buffers, a submission is
# represented by an `MTL4Submission`, which is completed by the commit feedback, and by a
# shared event that the queue signals after the command buffers.

export commit_tracked!

is_completed(sub::MTL4Submission) =
    sub.feedback ? (Base.@atomic :acquire sub.completed) :
                   sub.event.signaledValue >= sub.value

# only valid once the submission has completed
error_info(sub::MTL4Submission) = Base.@atomic sub.error

function gpu_time_range(sub::MTL4Submission)
    is_completed(sub) || return nothing
    return (Base.@atomic sub.gpu_start), (Base.@atomic sub.gpu_end)
end
function gpu_time_range(cmdbuf::MTLCommandBufferLike)
    cmdbuf.status == MTLCommandBufferStatusCompleted || return nothing
    return cmdbuf.GPUStartTime, cmdbuf.GPUEndTime
end

# runs on one of Metal's threads, so only copies out of the feedback object (which is only
# valid during the call) and publishes the result
function _submission_feedback(sub::MTL4Submission)
    function handler(feedback)
        try
            if feedback !== nothing
                Base.@atomic sub.gpu_start = feedback.GPUStartTime
                Base.@atomic sub.gpu_end = feedback.GPUEndTime
                err = feedback.error
                if err !== nothing
                    Base.@atomic sub.error = CommandBufferErrorInfo(
                        String(err.domain), Int(err.code), String(err.localizedDescription),
                        sub.label, sub.queue_label)
                end
            end
        finally
            # waiters rely on this being set, also if reading the feedback failed
            Base.@atomic :release sub.completed = true
        end
        return
    end
end

function MTL4Submission(event::MTLSharedEvent, value::Integer;
                        label::Union{Nothing,String}=nothing,
                        queue_label::Union{Nothing,String}=nothing)
    # Metal's feedback threads can't run Julia code while generating output
    feedback = ccall(:jl_generating_output, Cint, ()) == 0
    MTL4Submission(event, value, label, queue_label, feedback, false, nothing, 0.0, 0.0)
end

"""
    commit_tracked!(queue::MTL4CommandQueue, cmdbuf::MTL4CommandBuffer,
                    sub::MTL4Submission, key::id{MTLCommandQueue})

Commit `cmdbuf` to `queue`, and complete `sub` once it has executed: the queue signals
`sub.event` to `sub.value`, which has to exceed the values the event was signalled to
before. The submission is recorded under the Metal 3 queue `key` for error accounting and
synchronization (see `take_queue_submissions`), and passed to the profiling hook.
"""
function commit_tracked!(queue::MTL4CommandQueue, cmdbuf::MTL4CommandBuffer,
                         sub::MTL4Submission, key::id{MTLCommandQueue})
    if sub.feedback
        commit!(queue, cmdbuf, MTL4CommitOptions(_submission_feedback(sub)))
    else
        commit!(queue, cmdbuf)
    end
    signal_event!(queue, sub.event, sub.value)

    record_committed!(sub, key)
    hook = profile_hook[]
    hook === nothing || hook(sub)
    return sub
end

"""
    wait_completed(sub::MTL4Submission)

Block the current thread until `sub` has completed, and its feedback has been processed.
"""
function wait_completed(sub::MTL4Submission)
    while !is_completed(sub)
        # the feedback, which also reports failures that may keep the event from being
        # signalled, follows the event: wait for the latter, but re-check regularly
        if !waitUntilSignaledValue(sub.event, sub.value, 10)
            continue
        end
        is_completed(sub) && break
        ccall(:usleep, Cint, (Cuint,), 20)
    end
    return
end
