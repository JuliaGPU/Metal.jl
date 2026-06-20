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


#
# public API
#

"""
    synchronize(queue::MTLCommandQueue=global_queue(device()))

Wait for currently committed GPU work on `queue` to finish.
"""
@autoreleasepool function synchronize(queue::MTLCommandQueue = global_queue(device()))
    flush_command_streams!(queue)

    # flush any pending log handlers from logging-enabled kernels on this queue
    # (Metal delivers logs asynchronously; `wait_completed` on the specific cmdbuf
    # is what processes its `addLogHandler:` blocks)
    drain_logging_cmdbufs!(queue)

    last = MTL.last_committed(queue)
    last === nothing && return

    retain(last)
    try
        # Fast path: cmdbuf has already completed; queue is drained.
        if !is_completed(last)
            if use_nonblocking_synchronization
                spinning_synchronization(last) || nonblocking_synchronization(last)
            else
                wait_completed(last)
            end
        end
    finally
        release(last)
    end

    drain_cleanups!(queue; force=true)

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
    flush_command_streams!()
    for queue in keys(global_queues)
        synchronize(queue)
    end
    for s in active_command_streams()
        synchronize(s.queue)
    end
end
