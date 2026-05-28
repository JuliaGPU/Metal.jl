export device, device!, global_queue

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

"""
    global_queue(dev::MTLDevice)::MTLCommandQueue

Return the Metal command queue associated with the current Julia thread.
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

## dynamic-memory allocator buffer
#
# kernels that perform dynamic memory allocations bump-allocate out of a per-
# device scratch buffer. the buffer is allocated lazily on first use, and its
# counter is never reset; allocations are monotonic for the device's lifetime
# (the bump-allocator-style design is intentional, see device/malloc.jl).
#
# 1 MB allows ~65k 16-byte boxes before exhaustion, plenty for the dead
# throw-path boxing that motivates this.

const MALLOC_BUF_SIZE = 1024 * 1024

const device_malloc_bufs = Dict{MTLDevice, MTLBuffer}()
const device_malloc_lock = ReentrantLock()

function malloc_buffer(dev::MTLDevice)
    Base.@lock device_malloc_lock begin
        get!(device_malloc_bufs, dev) do
            buf = @autoreleasepool MTLBuffer(dev, MALLOC_BUF_SIZE;
                                             storage=SharedStorage)
            # initialize the counter (first 4 bytes) to 4 so the first
            # allocation lands past the counter itself
            unsafe_store!(convert(Ptr{UInt32}, MTL.contents(buf)), UInt32(4))
            buf
        end
    end
end
