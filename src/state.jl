export global_queue, synchronize

# Context management and global state
function global_queue(dev::MtlDevice)
    get!(task_local_storage(), (:MtlCommandQueue, dev)) do
        MtlCommandQueue(dev)
    end::MtlCommandQueue
end

function MTL.device()
    get!(task_local_storage(), :MtlDevice) do
        MtlDevice(1)
    end::MtlDevice
end

# TODO: Increase performance (currently ~15us)
"""
    synchronize()

Wait for currently committed GPU work to finish.
"""
function synchronize()
    cmdbuf = MtlCommandBuffer(global_queue(device()))
    commit!(cmdbuf)
    wait_completed(cmdbuf)
end