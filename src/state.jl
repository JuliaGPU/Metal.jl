export global_queue, synchronize, device_synchronize

const global_queues = WeakKeyDict{MtlCommandQueue,Nothing}()

"""
    global_queue(dev::MtlDevice)::MtlCommandQueue

Return the Metal command queue associated with the current Julia thread.
"""
function global_queue(dev::MtlDevice)
    get!(task_local_storage(), (:MtlCommandQueue, dev)) do
        queue = MtlCommandQueue(dev)
        global_queues[queue] = nothing
        queue
    end::MtlCommandQueue
end

"""
    device()::MtlDevice

Return the (first) Metal GPU device associated with the current Julia thread.

Since all M-series systems currently only externally show a single GPU, this function
effectively returns the only system GPU.
"""
function MTL.device()
    get!(task_local_storage(), :MtlDevice) do
        MtlDevice(1)
    end::MtlDevice
end

# TODO: Increase performance (currently ~15us)
"""
    synchronize(queue)

Wait for currently committed GPU work on this queue to finish.

Create a new MtlCommandBuffer from the global command queue, commit it to the queue,
and simply wait for it to be completed. Since command buffers *should* execute in a
First-In-First-Out manner, this synchronizes the GPU.
"""
function synchronize(queue::MtlCommandQueue=global_queue(device()))
    cmdbuf = MtlCommandBuffer(queue)
    commit!(cmdbuf)
    wait_completed(cmdbuf)
end

function device_synchronize()
    for queue in keys(global_queues)
        synchronize(queue)
    end
end
