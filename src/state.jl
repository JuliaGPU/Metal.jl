export device, device!, global_queue

log_compiler()          = OSLog("org.juliagpu.metal", "Compiler")
log_compiler(args...)   = log_compiler()(args...)
log_array()             = OSLog("org.juliagpu.metal", "Array")
log_array(args...)      = log_array()(args...)

const LABEL_RESOURCES = @load_preference("label_resources", nothing)

@inline function label_resources()
    LABEL_RESOURCES === nothing && return Base.JLOptions().debug_level >= 2
    return LABEL_RESOURCES
end

macro label!(obj, str)
    quote
        if label_resources()
            $(esc(obj)).label = $(esc(str))
        end
        nothing
    end
end

"""
    device()::MTLDevice

Return the Metal GPU device associated with the current Julia task.

Since all M-series systems currently only externally show a single GPU, this function
effectively returns the only system GPU.
"""
function device()
    get!(task_local_storage(), :MTLDevice) do
        dev = MTLDevice(1)
        if is_virtual(dev) && macos_version() >= v"15"
            @warn """Metal.jl is running on a virtualized Apple GPU; this is supported on a
                     best-effort basis, so you may run into issues.""" maxlog=1
        elseif is_virtual(dev) && macos_version() < v"15"
            @error "Metal.jl does not support virtualized Apple GPUs below macOS 15." maxlog=1
        elseif !supports_family(dev, MTL.MTLGPUFamilyApple7) ||
               !supports_family(dev, MTL.MTLGPUFamilyMetal3)
            @error "Metal.jl is only supported on Metal 3-capable Apple Silicon (M-series) GPUs." maxlog=1
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
            can_use_residency_sets(dev) && install_queue_residency!(queue, dev)
            queue
        end
    end::MTLCommandQueue
end

# tracks the most recently launched logging-enabled cmdbuf per queue, so that
# `synchronize` can wait on it and thereby drain its `addLogHandler:` blocks
# (Metal dispatches log delivery asynchronously and offers no flush primitive;
# `waitUntilCompleted` on the specific cmdbuf is what processes its pending blocks).
const logging_cmdbufs = IdDict{MTLCommandQueue,MTLCommandBuffer}()
const logging_cmdbufs_lock = ReentrantLock()

function track_logging_cmdbuf!(queue::MTLCommandQueue, cmdbuf::MTLCommandBuffer)
    # the surrounding `@autoreleasepool` in `(::HostKernel)()` will release the
    # caller's reference on return, so retain a fresh one for the tracking slot.
    retain(cmdbuf)
    old = Base.@lock logging_cmdbufs_lock begin
        prev = get(logging_cmdbufs, queue, nothing)
        logging_cmdbufs[queue] = cmdbuf
        prev
    end
    old === nothing || release(old)
    return
end

function drain_logging_cmdbufs!(queue::MTLCommandQueue)
    cmdbuf = Base.@lock logging_cmdbufs_lock begin
        prev = get(logging_cmdbufs, queue, nothing)
        delete!(logging_cmdbufs, queue)
        prev
    end
    if cmdbuf !== nothing
        MTL.wait_completed(cmdbuf)
        release(cmdbuf)
    end
    return
end


## scratch-buffer residency

# Fast residency path; collapse this to `true` when macOS 14 support is dropped.
function can_use_residency_sets(dev::MTLDevice)
    # Avoid serializing process-local Objective-C pointer keys from precompile workloads.
    if ccall(:jl_generating_output, Cint, ()) != 0
        return is_macos(v"15") && !is_virtual(dev)
    end

    key = UInt(pointer(dev))
    @memoize key::UInt begin
        is_macos(v"15") && !is_virtual(dev)
    end::Bool
end

const queue_residency_sets = Dict{UInt,MTLResidencySet}()
const queue_residency_sets_lock = ReentrantLock()

command_queue_key(queue::MTLCommandQueue) = UInt(pointer(queue))

function install_queue_residency!(queue::MTLCommandQueue, dev::MTLDevice)
    key = command_queue_key(queue)
    Base.@lock queue_residency_sets_lock begin
        resset = get(queue_residency_sets, key, nothing)
        resset === nothing || return resset
    end

    malloc_buf = malloc_buffer(dev)
    exc_buf = exception_info_buffer(dev)

    Base.@lock queue_residency_sets_lock begin
        resset = get(queue_residency_sets, key, nothing)
        resset === nothing || return resset

        desc = MTLResidencySetDescriptor()
        desc.initialCapacity = 2
        @label! desc "Metal scratch buffers"

        resset = MTLResidencySet(dev, desc)
        MTL.add_allocation!(resset, malloc_buf)
        MTL.add_allocation!(resset, exc_buf)
        MTL.commit!(resset)
        MTL.add_residency_set!(queue, resset)
        queue_residency_sets[key] = resset
        finalizer(queue) do _
            Base.@lock queue_residency_sets_lock begin
                get(queue_residency_sets, key, nothing) === resset &&
                    delete!(queue_residency_sets, key)
            end
        end
        return resset
    end
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

const device_malloc_bufs = Dict{MTLDevice, Tuple{MTLBuffer, UInt64}}()
const device_malloc_lock = ReentrantLock()

function malloc_buffer_and_gpu_address(dev::MTLDevice)
    Base.@lock device_malloc_lock begin
        get!(device_malloc_bufs, dev) do
            buf = @autoreleasepool MTLBuffer(dev, MALLOC_BUF_SIZE;
                                             storage=SharedStorage)
            # initialize the counter (first 4 bytes) to 4 so the first
            # allocation lands past the counter itself
            unsafe_store!(convert(Ptr{UInt32}, MTL.contents(buf)), UInt32(4))
            (buf, UInt64(buf.gpuAddress))
        end
    end
end

malloc_buffer(dev::MTLDevice) = first(malloc_buffer_and_gpu_address(dev))
