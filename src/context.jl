# Context management and global state
function global_queue(dev::MtlDevice)
    get!(task_local_storage(), (:MtlCommandQueue, dev)) do
        MtlCommandQueue(dev)
    end
end
