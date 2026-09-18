export synchronize, device_synchronize, CommandBufferError

# whether to wait on the Julia scheduler instead of parking the calling thread
# inside Metal's blocking `waitUntilCompleted`. opt-out via Preferences for
# bisection or to compare against the blocking baseline.
const use_nonblocking_synchronization =
    @load_preference("nonblocking_synchronization", true)

is_completed(cmdbuf::MTL.MTLCommandBufferLike) =
    cmdbuf.status >= MTL.MTLCommandBufferStatusCompleted

# fast-path spin-wait
function spinning_synchronization(cmdbuf::MTL.MTLCommandBufferLike)
    is_completed(cmdbuf) && return true

    # initially pause without yielding to keep latency low; switch to yield
    # after a few dozen spins so other tasks aren't starved.
    spins = 0
    while spins < 256
        if spins < 32
            ccall(:jl_cpu_pause, Cvoid, ())
            ccall(:jl_gc_safepoint, Cvoid, ())
        else
            yield()
        end
        is_completed(cmdbuf) && return true
        spins += 1
    end

    return false
end

function yielding_synchronization(cmdbuf::MTL.MTLCommandBufferLike)
    while !is_completed(cmdbuf)
        yield()
    end
    return
end

# slow-path wakeup: commit a fresh empty sentinel cmdbuf and wait on it
function nonblocking_synchronization(cmdbuf::MTL.MTLCommandBufferLike)

    # libdispatch's thread-switch-from-a-foreign-callback doesn't work while
    # a precompile worker is generating output, hanging image serialization,
    # so fall back to blocking sync in that context.
    precompiling = ccall(:jl_generating_output, Cint, ()) != 0
    if precompiling
        wait_completed(cmdbuf)
        return
    end

    sentinel = MTLCommandBuffer(cmdbuf.commandQueue)
    done = Base.AsyncCondition()
    on_completed(sentinel, done)
    # Private sentinel: do not store it in last_committed before releasing it.
    @objc [sentinel::id{MTLCommandBuffer} commit]::Nothing
    try
        wait(done)
    finally
        close(done)
        release(sentinel)
    end
    return
end

function wait_cmdbuf!(cmdbuf::MTL.MTLCommandBufferLike)
    is_completed(cmdbuf) && return

    precompiling = ccall(:jl_generating_output, Cint, ()) != 0
    if use_nonblocking_synchronization && !precompiling
        spinning_synchronization(cmdbuf) || yielding_synchronization(cmdbuf)
    else
        wait_completed(cmdbuf)
    end
    return
end

function command_buffer_errors(state::Union{Nothing,MTL.QueueSubmissionState})
    state === nothing && return nothing
    return MTL.finish_submissions!(state)
end

command_buffer_errors(errors::Vector{MTL.CommandBufferErrorInfo}) = errors

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

function check_synchronization_errors(states...)
    errors = nothing
    for state in states
        state_errors = command_buffer_errors(state)
        state_errors === nothing && continue
        if errors === nothing
            errors = state_errors
        else
            append!(errors, state_errors)
        end
    end

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

Wait for currently committed GPU work on `queue` to finish.
"""
@autoreleasepool function synchronize(queue = global_queue(device()))
    bq = batched_queue(queue)
    flush!(bq)
    queue = bq.queue
    maybe_collect(bq.device; will_block=true)

    # flush any pending log handlers from logging-enabled kernels on this queue
    # (Metal delivers logs asynchronously; `wait_completed` on the specific cmdbuf
    # is what processes its `addLogHandler:` blocks)
    drain_logging_submissions!(bq)

    # Metal 3 command buffers derived from this queue (MPS, user code)
    last, submissions = MTL.take_queue_submissions(queue)
    # Handles the already-completed fast path internally.
    last === nothing || wait_cmdbuf!(last)

    # batched Metal 4 work
    wait_submissions!(bq)

    drain_cleanups!(bq; force=true)

    # Surface Metal runtime failures and device-side Julia exceptions together,
    # after cleanup has released all Julia roots held by completed work.
    check_synchronization_errors(submissions, take_errors!(bq))
    return
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

    for bq in active_batched_queues()
        drain_logging_submissions!(bq)
    end

    cmdbufs, submissions = MTL.take_all_submissions()

    for cmdbuf in cmdbufs
        if !is_completed(cmdbuf)
            if use_nonblocking_synchronization
                spinning_synchronization(cmdbuf) || nonblocking_synchronization(cmdbuf)
            else
                wait_completed(cmdbuf)
            end
        end
    end

    errors = nothing
    for bq in active_batched_queues()
        wait_submissions!(bq)
        drain_cleanups!(bq; force=true)
        bq_errors = take_errors!(bq)
        bq_errors === nothing && continue
        errors = errors === nothing ? bq_errors : append!(errors, bq_errors)
    end

    check_synchronization_errors(submissions, errors)
    return
end
