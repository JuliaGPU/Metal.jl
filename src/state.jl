export device, device!, global_queue, synchronize, device_synchronize

log_compiler()          = OSLog("org.juliagpu.metal", "Compiler")
log_compiler(args...)   = log_compiler()(args...)
log_array()             = OSLog("org.juliagpu.metal", "Array")
log_array(args...)      = log_array()(args...)

"""
    device()::MTLDevice

Return the Metal GPU device associated with the current Julia task.

Since all M-series systems currently only externally show a single GPU, this function
effectively returns the only system GPU.
"""
function device()
    get!(task_local_storage(), :MTLDevice) do
        dev = MTLDevice(1)
        if !supports_family(dev, MTL.MTLGPUFamilyApple7)
            @warn """Metal.jl is only supported on non-virtualized Apple Silicon, you may run into issues.
                     See https://github.com/JuliaGPU/Metal.jl/issues/22 for more details.""" maxlog=1
        end
        if !supports_family(dev, MTL.MTLGPUFamilyMetal3)
            @warn """Metal.jl is only supported on Metal 3-capable devices, you may run into issues.
                     See https://github.com/JuliaGPU/Metal.jl/issues/22 for more details.""" maxlog=1
        end
        return dev
    end::MTLDevice
end

"""
    device!(dev::MTLDevice)

Sets the Metal GPU device associated with the current Julia task.
"""
device!(dev::MTLDevice) = task_local_storage(:MTLDevice, dev)

const global_queues = WeakKeyDict{MTLCommandQueue,Nothing}()
const global_queues4 = WeakKeyDict{MTL4CommandQueue,Tuple{MTL4CommandBuffer, MTL4CommandAllocator}}()

"""
    global_queue(dev::MTLDevice)::MTLCommandQueue

Return the Metal 3 command queue associated with the current Julia thread.
"""
function global_queue(dev::MTLDevice)
    get!(task_local_storage(), (:MTLCommandQueue, dev)) do
        @autoreleasepool begin
            # NOTE: MTLCommandQueue itself is manually reference-counted,
            #       the release pool is for resources used during its construction.
            queue = MTLCommandQueue(dev)
            queue.label = "global_queue($(current_task()))"
            global_queues[queue] = nothing
            queue
        end
    end::MTLCommandQueue
end

"""
    global_queue4(dev::MTLDevice)::MTL4CommandQueue

Return the Metal 4 command queue associated with the current Julia thread.
"""
function global_queue4(dev::MTLDevice)
    get!(task_local_storage(), (:MTL4CommandQueue, dev)) do
        @autoreleasepool begin
            desc = MTL4CommandQueueDescriptor("global_queue4($(current_task()))")

            # NOTE: MTL4CommandQueue itself is manually reference-counted,
            #       the release pool is for resources used during its construction.
            queue = MTL4CommandQueue(dev, desc)


            global_queues4[queue] = (MTL4CommandBuffer(dev, "sync_buffer($(current_task()))"), MTL4CommandAllocator(dev, "sync_allocater($(current_task()))"))
            queue
        end
    end::MTL4CommandQueue
end

# TODO: Increase performance (currently ~15us)
"""
    synchronize(queue)

Wait for currently committed GPU work on this queue to finish.

Create a new MTLCommandBuffer from the global command queue, commit it to the queue,
and simply wait for it to be completed. Since command buffers *should* execute in a
First-In-First-Out manner, this synchronizes the GPU.
"""
@autoreleasepool function synchronize(queue::MTLCommandQueue)
    cmdbuf = MTLCommandBuffer(queue)
    commit!(cmdbuf)
    wait_completed(cmdbuf)
    return
end
@autoreleasepool function synchronize(queue::MTL4CommandQueue)
    cmdbuf, allocator = get(global_queues4, queue) do
        dev = queue.device
        MTL4CommandBuffer(dev), MTL4CommandAllocator(dev)
    end

    cmdbuf = commit!(cmdbuf, queue, allocator) do cmdbuf
        MTL4ComputeCommandEncoder(identity, cmdbuf, #=sync=#true)
    end
    return
end
function synchronize()
    dev = device()
    tlskeys = keys(task_local_storage())
    # hasmtl3key = (:MTLCommandQueue, dev) in tlskeys
    # hasmtl4key = use_metal4() && (:MTL4CommandQueue, dev) in tlskeys
    if (:MTLCommandQueue, dev) in tlskeys
        synchronize(global_queue(dev))
    end
    if use_metal4() && (:MTL4CommandQueue, dev) in tlskeys
        synchronize(global_queue4(dev))
    end
    return
end

"""
    device_synchronize()

Synchronize all committed GPU work across all global queues
"""
function device_synchronize()
    for queue in keys(global_queues)
        synchronize(queue)
    end
    for queue in keys(global_queues4)
        synchronize(queue)
    end
end
