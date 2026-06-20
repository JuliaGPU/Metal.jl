export synchronize, device_synchronize

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
    commit!(sentinel)
    try
        wait(done)
    finally
        close(done)
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

    # flush any pending log handlers from logging-enabled kernels on this queue
    # (Metal delivers logs asynchronously; `wait_completed` on the specific cmdbuf
    # is what processes its `addLogHandler:` blocks)
    drain_logging_cmdbufs!(queue)

    last = MTL.last_committed(queue)
    last === nothing && return

    # Handles the already-completed fast path internally.
    wait_cmdbuf!(last)

    drain_cleanups!(bq; force=true)

    # surface any device-side exception thrown by the work we just waited on
    check_exceptions()
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

    for queue in keys(global_queues)
        drain_logging_cmdbufs!(raw_queue(queue))
    end
    for bq in active_batched_queues()
        drain_logging_cmdbufs!(bq.queue)
    end

    cmdbufs = Base.@lock MTL.last_committed_lock begin
        collect(values(MTL.last_committed_per_queue))
    end

    for cmdbuf in cmdbufs
        if !is_completed(cmdbuf)
            if use_nonblocking_synchronization
                spinning_synchronization(cmdbuf) || nonblocking_synchronization(cmdbuf)
            else
                wait_completed(cmdbuf)
            end
        end
    end

    for bq in active_batched_queues()
        drain_cleanups!(bq; force=true)
    end

    check_exceptions()
    return
end
