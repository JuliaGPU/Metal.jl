export synchronize, device_synchronize, CommandBufferError

# whether to wait without blocking the calling thread, instead of parking it inside Metal's
# blocking `waitUntilCompleted`. opt-out via Preferences for bisection or to compare
# against the blocking baseline.
const use_nonblocking_synchronization =
    @load_preference("nonblocking_synchronization", true)

is_completed(cmdbuf::MTL.MTLCommandBufferLike) =
    cmdbuf.status >= MTL.MTLCommandBufferStatusCompleted

# blocking wait, performed on a worker thread by `cooperative_wait`. `@objc` calls are
# GC-safe, but the worker has no autorelease pool of its own, so set one up. it cannot be an
# `@autoreleasepool`, whose global lock may be held by the waiting task.
function blocking_wait(cmdbuf::MTL.MTLCommandBufferLike)
    pool = ccall(:objc_autoreleasePoolPush, Ptr{Cvoid}, ())
    try
        wait_completed(cmdbuf)
    finally
        ccall(:objc_autoreleasePoolPop, Cvoid, (Ptr{Cvoid},), pool)
    end
    return
end

# wait for a committed command buffer to complete, without blocking the calling thread so
# that other tasks can run in the meantime. pass `handlers=true` to also wait for its
# completion handlers to have run (e.g., to flush `addLogHandler:` output); otherwise, this
# may or may not return before they have run.
#
# note that long waits use `waitUntilCompleted`, which waits for the completion handlers, so
# these must not depend on the waiting task, e.g., on locks it holds (like the global lock
# taken by `@autoreleasepool`).
function wait_cmdbuf!(cmdbuf::MTL.MTLCommandBufferLike; handlers::Bool=false)
    !handlers && is_completed(cmdbuf) && return

    if use_nonblocking_synchronization
        cooperative_wait(blocking_wait, cmdbuf; isdone=handlers ? nothing : is_completed)
    else
        wait_completed(cmdbuf)
    end
    return
end

function command_buffer_errors(state::Union{Nothing,MTL.QueueSubmissionState})
    state === nothing && return nothing
    return MTL.finish_submissions!(state)
end

function command_buffer_errors(states::AbstractVector{MTL.QueueSubmissionState})
    errors = nothing
    for state in states
        state_errors = MTL.finish_submissions!(state)
        state_errors === nothing && continue
        if errors === nothing
            errors = state_errors
        else
            append!(errors, state_errors)
        end
    end
    return errors
end

function check_synchronization_errors(states)
    errors = command_buffer_errors(states)

    kernel_error = try
        check_exceptions()
        nothing
    catch err
        err
    end

    command_buffer_error = errors === nothing ? nothing : CommandBufferError(errors)
    if command_buffer_error !== nothing && kernel_error !== nothing
        throw(CompositeException(Any[command_buffer_error, kernel_error]))
    elseif command_buffer_error !== nothing
        throw(command_buffer_error)
    elseif kernel_error !== nothing
        throw(kernel_error)
    end
    return
end


#
# public API
#

"""
    synchronize(queue=global_queue(device()))

Wait for currently committed GPU work on `queue` to finish. This includes work left
behind by tasks that have finished, so that their results are visible after `wait`ing
for them.
"""
function synchronize(queue = global_queue(device()))
    # an `@autoreleasepool` takes a global lock, so don't hold one while waiting, or other
    # tasks would not be able to use Metal in the meantime.
    bq, orphans = @autoreleasepool begin
        b = batched_queue(queue)
        flush!(b)
        o = flush_orphaned_queues!()
        maybe_collect(b.queue.device; will_block=true)
        b, o
    end
    queue = bq.queue

    # flush any pending log handlers from logging-enabled kernels on this queue
    # (Metal delivers logs asynchronously; waiting for the specific cmdbuf's
    # completion handlers is what processes its `addLogHandler:` blocks)
    drain_logging_cmdbufs!(queue)

    last, submissions = MTL.take_queue_submissions(queue)

    # Handles the already-completed fast path internally.
    last === nothing || wait_cmdbuf!(last)

    if orphans !== nothing
        submissions = wait_orphaned_queues!(orphans, submissions)
    end

    @autoreleasepool begin
        drain_cleanups!(bq; force=true)
        if orphans !== nothing
            Base.@lock orphaned_queues_lock foreach(drain_cleanups!, orphans)
        end

        # Surface Metal runtime failures and device-side Julia exceptions together,
        # after cleanup has released all Julia roots held by completed work.
        check_synchronization_errors(submissions)
    end
    return
end

# commit the open batches of queues whose owning task has finished. their owner will
# not touch them again, so we can, but other tasks synchronizing may do so concurrently.
function flush_orphaned_queues!()
    orphans = orphaned_batched_queues()
    orphans === nothing && return nothing
    Base.@lock orphaned_queues_lock foreach(flush!, orphans)
    return orphans
end

function wait_orphaned_queues!(orphans, submissions)
    states = MTL.QueueSubmissionState[]
    submissions === nothing || push!(states, submissions)
    for bq in orphans
        drain_logging_cmdbufs!(bq.queue)
        last, state = MTL.take_queue_submissions(bq.queue)
        last === nothing || wait_cmdbuf!(last)
        state === nothing || push!(states, state)
    end
    return states
end

"""
    synchronize(cmdbuf::MTLCommandBufferLike)

Wait for `cmdbuf` (which must already have been committed) and all preceding
work on the same queue to complete.
"""
synchronize(cmdbuf::MTL.MTLCommandBufferLike) = synchronize(cmdbuf.commandQueue)

"""
    device_synchronize()

Synchronize all committed GPU work across all global queues.
"""
function device_synchronize()
    flush_batched_queues!()
    maybe_collect(device(); will_block=true)

    queues = active_global_queues()
    append!(queues, active_batched_queues())
    for queue in unique!(queues)
        drain_logging_cmdbufs!(raw_queue(queue))
    end

    cmdbufs, submissions = MTL.take_all_submissions()

    # the last command buffer committed to each queue completes after the earlier ones
    for cmdbuf in cmdbufs
        wait_cmdbuf!(cmdbuf)
    end

    # other tasks may have committed work while we were waiting, so only clean up after
    # command buffers that have completed
    for bq in active_batched_queues()
        drain_cleanups!(bq)
    end

    check_synchronization_errors(submissions)
    return
end
