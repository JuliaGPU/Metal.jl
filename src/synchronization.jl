export synchronize, device_synchronize


# whether to wait on the Julia scheduler instead of parking the calling thread
# inside Metal's blocking `waitUntilCompleted`. opt-out via Preferences for
# bisection or to compare against the blocking baseline.
const use_nonblocking_synchronization =
    @load_preference("nonblocking_synchronization", true)


#
# nonblocking sync
#

"""
    synchronize(cmdbuf::MTLCommandBufferLike)

Commit `cmdbuf` and wait for it to finish executing.

`cmdbuf` must not have been committed already: nonblocking synchronization
requires registering a completion handler, which Metal only permits before
commit. After the handler is in place, `cmdbuf` is committed and the calling
task waits on an `Event` that the handler notifies on completion, keeping the
Julia scheduler live on the calling thread instead of parking it inside
Metal's blocking `waitUntilCompleted`.
"""
@autoreleasepool function synchronize(cmdbuf::MTL.MTLCommandBufferLike)
    # Nonblocking sync wakes the calling task from the command buffer's
    # completion handler, which Metal fires on a libdispatch thread. That
    # thread-switch-from-a-foreign-callback doesn't work while a precompile
    # worker is generating output, hanging image serialization, so fall back
    # to blocking sync in that context.
    precompiling = ccall(:jl_generating_output, Cint, ()) != 0
    if use_nonblocking_synchronization && !precompiling
        # Metal adopts the libdispatch thread into the Julia runtime when the
        # callback enters it (JuliaLang/julia#49934, 1.9+), so the handler can
        # notify an ordinary `Event` and let the scheduler resume us — keeping
        # the calling thread in the Julia scheduler rather than parked inside
        # Metal's blocking `waitUntilCompleted`.
        done = Base.Event()
        on_completed(cmdbuf) do _
            notify(done)
        end
        commit!(cmdbuf)
        wait(done)
    else
        commit!(cmdbuf)
        wait_completed(cmdbuf)
    end
    return
end


#
# queue / device sync
#

"""
    synchronize(queue::MTLCommandQueue=global_queue(device()))

Wait for currently committed GPU work on `queue` to finish.

Commits an empty command buffer to the queue and waits for it to complete.
Since command buffers execute in submission order, this synchronizes the queue.
"""
synchronize(queue::MTLCommandQueue=global_queue(device())) =
    synchronize(MTLCommandBuffer(queue))

"""
    device_synchronize()

Synchronize all committed GPU work across all global queues.
"""
function device_synchronize()
    for queue in keys(global_queues)
        synchronize(queue)
    end
end
