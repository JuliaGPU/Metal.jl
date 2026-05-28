export synchronize, device_synchronize


# whether to wait on the Julia scheduler instead of parking the calling thread
# inside Metal's blocking `waitUntilCompleted`. opt-out via Preferences for
# bisection or to compare against the blocking baseline.
const use_nonblocking_synchronization =
    @load_preference("nonblocking_synchronization", true)


#
# fast-path synchronization
#

# before paying the cost of a completion handler + scheduler wakeup, busy-poll
# the command buffer's status. for empty / very short work, this lets us skip
# the libdispatch-to-Julia thread switch entirely. mirrors CUDA.jl's
# `spinning_synchronization`.

is_completed(cmdbuf::MTL.MTLCommandBufferLike) =
    cmdbuf.status >= MTL.MTLCommandBufferStatusCompleted

function spinning_synchronization(f, obj)
    f(obj) && return true

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
        f(obj) && return true
        spins += 1
    end

    return false
end


#
# queue / device sync
#

"""
    synchronize(queue::MTLCommandQueue=global_queue(device()))

Wait for currently committed GPU work on `queue` to finish.
"""
@autoreleasepool function synchronize(queue::MTLCommandQueue=global_queue(device()))
    # Nonblocking sync wakes the calling task from the command buffer's
    # completion handler, which Metal fires on a libdispatch thread. That
    # thread-switch-from-a-foreign-callback doesn't work while a precompile
    # worker is generating output, hanging image serialization, so fall back
    # to blocking sync in that context.
    precompiling = ccall(:jl_generating_output, Cint, ()) != 0

    sentinel = MTLCommandBuffer(queue)
    if use_nonblocking_synchronization && !precompiling
        # Metal adopts the libdispatch thread into the Julia runtime when the
        # callback enters it (JuliaLang/julia#49934, 1.9+), so the handler can
        # notify an ordinary `Event` and let the scheduler resume us, keeping
        # the calling thread in the Julia scheduler rather than parked inside
        # Metal's blocking `waitUntilCompleted`.
        done = Base.Event()
        on_completed(sentinel) do _
            notify(done)
        end
        commit!(sentinel)
        # spin briefly first: for empty queues / short kernels this avoids
        # the libdispatch → Julia scheduler wakeup entirely. if the handler
        # fired during the spin, `wait` returns immediately.
        spinning_synchronization(is_completed, sentinel) || wait(done)
    else
        commit!(sentinel)
        wait_completed(sentinel)
    end
    return
end

"""
    synchronize(cmdbuf::MTLCommandBufferLike)

Wait for `cmdbuf` (which must already have been committed) and all preceding
work on the same queue to complete. Equivalent to `synchronize(cmdbuf.commandQueue)`.
"""
synchronize(cmdbuf::MTL.MTLCommandBufferLike) = synchronize(cmdbuf.commandQueue)

"""
    device_synchronize()

Synchronize all committed GPU work across all global queues.
"""
function device_synchronize()
    for queue in keys(global_queues)
        synchronize(queue)
    end
end
