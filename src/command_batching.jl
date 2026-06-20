@enum EncoderKind NoEncoder ComputeEncoder BlitEncoder

# Tunables for command batching (see `BatchedCommandQueue`), read once per
# process. Numeric tuning knobs can also be set for one run via the matching
# JULIA_METAL_* env var (read once at startup), which is convenient for
# benchmarking. The `command_batching` policy switch is preference-only so a
# compiled preference image has one stable behavior.
const COMMAND_BATCHING = @load_preference("command_batching", true)

@inline command_batching() = COMMAND_BATCHING

command_batching_ops() = @memoize begin
    s = get(ENV, "JULIA_METAL_COMMAND_BATCHING_OPS", nothing)
    s === nothing ? @load_preference("command_batching_ops", 32) : parse(Int, s)
end::Int

command_batching_bytes() = @memoize begin
    s = get(ENV, "JULIA_METAL_COMMAND_BATCHING_BYTES", nothing)
    s === nothing ? @load_preference("command_batching_bytes", 64 * 1024 * 1024) : parse(Int, s)
end::Int

command_batching_inflight() = @memoize begin
    s = get(ENV, "JULIA_METAL_COMMAND_BATCHING_INFLIGHT", nothing)
    s === nothing ? @load_preference("command_batching_inflight", 3) : parse(Int, s)
end::Int

# Completion handlers run on libdispatch worker threads, where compiling or
# running Julia code can overflow the small foreign stack. Keep command buffers
# alive and drain Julia roots from normal managed threads instead.
struct PendingCommand
    cmdbuf::MTL.MTLCommandBufferLike
    roots::Vector{Any}
end

"""
    BatchedCommandQueue

A command queue that batches GPU work to amortize Metal's per-command-buffer
submission latency. Kernel launches (`@metal`) and GPU-side blit operations
(`copyto!`, `fill!`) are encoded into a single open command buffer and committed
lazily, instead of one command buffer per operation.

It wraps, and is a drop-in for, the `MTLCommandQueue` it batches: properties that
aren't its own (e.g. `label`) forward to the underlying queue.

The open batch is committed ("flushed") when any of the following happens:

  * [`synchronize`](@ref) is called on the queue (or on one of its command buffers);
  * a command buffer derived from the queue is enqueued or committed;
  * command batching is disabled with the `command_batching = false` preference;
  * the batch reaches `command_batching_ops()` operations or
    `command_batching_bytes()` of blit traffic;
  * a GPU profiler is attached, in which case batching is disabled (each operation
    gets its own command buffer) so per-operation GPU timing is preserved;
  * an immediate submission is requested via `@metal ... submit=true`, or
    `Metal.flush!` is called explicitly.

Program order is preserved across flushes: command buffers execute in commit order
and dispatches within an encoder run serially. At most `command_batching_inflight()`
command buffers are kept in flight; further submissions block until the GPU drains
one. Obtain the current task's batched queue with [`global_queue`](@ref).
"""
mutable struct BatchedCommandQueue
    queue::MTLCommandQueue
    device::MTLDevice
    cmdbuf::Union{Nothing,MTLCommandBuffer}
    encoder::Union{Nothing,MTLComputeCommandEncoder,MTLBlitCommandEncoder}
    kind::EncoderKind
    roots::Vector{Any}
    last_pipeline::Union{Nothing,MTLComputePipelineState}
    nops::Int
    nbytes::Int
    pending_ops::Vector{Any}
    cleanups::Vector{PendingCommand}
end

function BatchedCommandQueue(queue::MTLCommandQueue)
    dev = queue.device
    can_use_residency_sets(dev) && install_queue_residency!(queue, dev)
    BatchedCommandQueue(queue, dev, nothing, nothing, NoEncoder,
                        Any[], nothing, 0, 0, Any[], PendingCommand[])
end

# Properties that aren't our own fields (e.g. `label`) forward to the wrapped
# queue, so a BatchedCommandQueue is a drop-in for the MTLCommandQueue it batches.
@inline function Base.getproperty(bq::BatchedCommandQueue, name::Symbol)
    hasfield(BatchedCommandQueue, name) && return getfield(bq, name)
    return getproperty(getfield(bq, :queue), name)
end

@inline function Base.setproperty!(bq::BatchedCommandQueue, name::Symbol, value)
    hasfield(BatchedCommandQueue, name) && return setfield!(bq, name, value)
    return setproperty!(getfield(bq, :queue), name, value)
end

const batched_queues = IdDict{BatchedCommandQueue,Nothing}()
const batched_queues_lock = ReentrantLock()

@inline batched_queue_key(queue::MTLCommandQueue) =
    (:BatchedCommandQueue, pointer(queue))

function register_queue!(bq::BatchedCommandQueue)
    Base.@lock batched_queues_lock begin
        batched_queues[bq] = nothing
    end
    return
end

function unregister_queue_if_idle!(bq::BatchedCommandQueue)
    (bq.cmdbuf === nothing && isempty(bq.cleanups)) || return
    Base.@lock batched_queues_lock begin
        if bq.cmdbuf === nothing && isempty(bq.cleanups)
            delete!(batched_queues, bq)
        end
    end
    return
end

function active_batched_queues()
    Base.@lock batched_queues_lock collect(keys(batched_queues))
end

batched_queue(bq::BatchedCommandQueue) = bq

function batched_queue(queue::MTLCommandQueue)
    get!(task_local_storage(), batched_queue_key(queue)) do
        BatchedCommandQueue(queue)
    end::BatchedCommandQueue
end

raw_queue(bq::BatchedCommandQueue) = bq.queue
raw_queue(queue::MTLCommandQueue) = queue

profiling_command_buffers() =
    MTL.profile_hook[] !== nothing || MTL.profile_metadata[] !== nothing

Base.:(==)(bq::BatchedCommandQueue, queue::MTLCommandQueue) = bq.queue == queue
Base.:(==)(queue::MTLCommandQueue, bq::BatchedCommandQueue) = queue == bq.queue
Base.:(==)(bq::BatchedCommandQueue, obj::NSObject) = bq.queue == obj
Base.:(==)(obj::NSObject, bq::BatchedCommandQueue) = obj == bq.queue

function MTL.MTLCommandBuffer(bq::BatchedCommandQueue)
    return MTLCommandBuffer(bq.queue)
end

function MTL.MTLCommandBuffer(bq::BatchedCommandQueue, desc::MTLCommandBufferDescriptor)
    return MTLCommandBuffer(bq.queue, desc)
end

function MTL.MTLCommandBuffer(f::Base.Callable, bq::BatchedCommandQueue,
                              desc::MTLCommandBufferDescriptor=MTLCommandBufferDescriptor())
    cmdbuf = MTLCommandBuffer(bq, desc)
    commit!(f, cmdbuf)
    return cmdbuf
end

function flush_open_batch(cmdbuf)
    queue = cmdbuf.commandQueue
    bq = get(task_local_storage(), batched_queue_key(queue), nothing)
    bq === nothing || flush!(bq)
    return
end

function MTL.MTLCaptureScope(bq::BatchedCommandQueue, manager=MTLCaptureManager())
    flush!(bq)
    return MTLCaptureScope(bq.queue, manager)
end

function Base.setproperty!(desc::MTLCaptureDescriptor, name::Symbol, bq::BatchedCommandQueue)
    name === :captureObject && return setproperty!(desc, name, bq.queue)
    return invoke(Base.setproperty!, Tuple{MTLCaptureDescriptor, Symbol, Any},
                  desc, name, bq)
end

function MTL.MTLCaptureDescriptor(bq::BatchedCommandQueue,
                                  destination::MTL.MTLCaptureDestination;
                                  folder::String=nothing)
    return MTLCaptureDescriptor(bq.queue, destination; folder)
end

function MTL.startCapture(bq::BatchedCommandQueue,
                          destination::MTL.MTLCaptureDestination=MTL.MTLCaptureDestinationGPUTraceDocument;
                          folder::String=nothing)
    flush!(bq)
    return MTL.startCapture(bq.queue, destination; folder)
end

function ensure_cmdbuf!(bq::BatchedCommandQueue)
    cmdbuf = bq.cmdbuf
    if cmdbuf === nothing
        cmdbuf = MTLCommandBuffer(bq.queue)
        # `commandBuffer` and command encoders are autoreleased. A batched
        # queue can outlive the surrounding autorelease pool, so hold explicit
        # references while they are open.
        retain(cmdbuf)
        @label! cmdbuf "MTLCommandBuffer(batched queue)"
        bq.cmdbuf = cmdbuf
        register_queue!(bq)
    end
    return cmdbuf::MTLCommandBuffer
end

function end_encoder!(bq::BatchedCommandQueue)
    enc = bq.encoder
    enc === nothing && return

    bq.encoder = nothing
    bq.kind = NoEncoder
    bq.last_pipeline = nothing
    try
        close(enc)
    finally
        release(enc)
    end
    return
end

function compute_encoder(bq::BatchedCommandQueue)
    if bq.kind == ComputeEncoder
        return bq.encoder::MTLComputeCommandEncoder
    end

    end_encoder!(bq)
    enc = MTLComputeCommandEncoder(ensure_cmdbuf!(bq))
    retain(enc)
    bq.encoder = enc
    bq.kind = ComputeEncoder
    return enc
end

function blit_encoder(bq::BatchedCommandQueue)
    if bq.kind == BlitEncoder
        return bq.encoder::MTLBlitCommandEncoder
    end

    end_encoder!(bq)
    enc = MTLBlitCommandEncoder(ensure_cmdbuf!(bq))
    retain(enc)
    bq.encoder = enc
    bq.kind = BlitEncoder
    return enc
end

function set_pipeline!(bq::BatchedCommandQueue, cce::MTLComputeCommandEncoder,
                       pipeline::MTLComputePipelineState)
    if bq.last_pipeline !== pipeline
        MTL.set_function!(cce, pipeline)
        bq.last_pipeline = pipeline
    end
    return
end

function note_operation!(bq::BatchedCommandQueue, op)
    MTL.profile_metadata[] === nothing && return
    push!(bq.pending_ops, op)
    return
end

function record_operation!(bq::BatchedCommandQueue, roots...; bytes::Integer=0, op=nothing)
    append!(bq.roots, roots)
    op === nothing || note_operation!(bq, op)
    bq.nops += 1
    bq.nbytes += bytes
    return
end

function register_operations!(bq::BatchedCommandQueue, cmdbuf)
    md = MTL.profile_metadata[]
    md === nothing && return
    for op in bq.pending_ops
        MTL.note_operation!(md, cmdbuf, op)
    end
    return
end

function defer_cleanup!(bq::BatchedCommandQueue, cmdbuf::MTL.MTLCommandBufferLike,
                        roots::Vector{Any})
    retain(cmdbuf)
    push!(bq.cleanups, PendingCommand(cmdbuf, roots))
    register_queue!(bq)
    return
end

defer_cleanup!(queue, cmdbuf::MTL.MTLCommandBufferLike, roots::Vector{Any}) =
    defer_cleanup!(batched_queue(queue), cmdbuf, roots)

function drain_cleanups!(bq::BatchedCommandQueue; force::Bool=false)
    n = 0
    for cleanup in bq.cleanups
        if !(force || cleanup.cmdbuf.status >= MTL.MTLCommandBufferStatusCompleted)
            break
        end
        n += 1
    end
    n == 0 && return

    completed = bq.cleanups[1:n]
    deleteat!(bq.cleanups, 1:n)

    for cleanup in completed
        if cleanup.cmdbuf.status == MTL.MTLCommandBufferStatusError
            @error "Command buffer failed" reason=cleanup.cmdbuf.error.localizedDescription
        end
        empty!(cleanup.roots)
        release(cleanup.cmdbuf)
    end

    unregister_queue_if_idle!(bq)
    return
end

function drain_cleanups!(queue; force::Bool=false)
    queue = raw_queue(queue)
    for bq in active_batched_queues()
        bq.queue === queue || continue
        drain_cleanups!(bq; force)
    end
    return
end

function pending_cleanup_count(bq::BatchedCommandQueue)
    return length(bq.cleanups)
end

function wait_oldest_cleanup!(bq::BatchedCommandQueue)
    isempty(bq.cleanups) && return
    cmdbuf = first(bq.cleanups).cmdbuf
    retain(cmdbuf)
    try
        wait_completed(cmdbuf)
    finally
        release(cmdbuf)
    end
    drain_cleanups!(bq)
    return
end

function limit_inflight!(bq::BatchedCommandQueue)
    drain_cleanups!(bq)
    while pending_cleanup_count(bq) >= command_batching_inflight()
        wait_oldest_cleanup!(bq)
    end
    return
end

function reset_open_cmdbuf!(bq::BatchedCommandQueue, cmdbuf)
    bq.cmdbuf = nothing
    bq.roots = Any[]
    bq.pending_ops = Any[]
    bq.nops = 0
    bq.nbytes = 0
    release(cmdbuf)
    unregister_queue_if_idle!(bq)
    return
end

function flush!(bq::BatchedCommandQueue)
    cmdbuf = bq.cmdbuf
    cmdbuf === nothing && return

    end_encoder!(bq)
    register_operations!(bq, cmdbuf)
    roots = bq.roots
    MTL.commit_with_queue_key!(cmdbuf, pointer(bq.queue))
    defer_cleanup!(bq, cmdbuf, roots)
    reset_open_cmdbuf!(bq, cmdbuf)
    limit_inflight!(bq)
    return
end

flush!() = flush!(global_queue(device()))

function flush!(queue)
    flush_batched_queues!(queue)
    return
end

function flush_batched_queues!(queue=nothing)
    queue = queue === nothing ? nothing : raw_queue(queue)
    for bq in active_batched_queues()
        queue === nothing || bq.queue === queue || continue
        flush!(bq)
    end
    return
end

function maybe_autoflush!(bq::BatchedCommandQueue)
    if !command_batching() ||
       profiling_command_buffers() ||
       bq.nops >= command_batching_ops() ||
       bq.nbytes >= command_batching_bytes()
        flush!(bq)
    end
    return
end
