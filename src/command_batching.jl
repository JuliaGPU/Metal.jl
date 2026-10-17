@enum EncoderKind NoEncoder ComputeEncoder BlitEncoder

# Tunables for command batching (see `BatchedCommandQueue`), read once per
# process. Numeric tuning knobs can also be set for one run via the matching
# JULIA_METAL_* env var (read once at startup), which is convenient for
# benchmarking. The `command_batching` policy switch is preference-only so a
# compiled preference image has one stable behavior.
const COMMAND_BATCHING = @load_preference("command_batching", true)

@inline command_batching() = COMMAND_BATCHING

function load_command_batching_tunable(name::String, env::String, pref)
    s = get(ENV, env, nothing)
    value = s === nothing ? pref : parse(Int, s)
    source = s === nothing ? "preference `$name`" : "environment variable `$env`"
    value isa Integer ||
        throw(ArgumentError("$source must be a positive integer, got $(repr(value))"))
    value = Int(value)
    value > 0 ||
        throw(ArgumentError("$source must be a positive integer, got $value"))
    return value
end

command_batching_ops() = @memoize begin
    load_command_batching_tunable("command_batching_ops",
                                  "JULIA_METAL_COMMAND_BATCHING_OPS",
                                  @load_preference("command_batching_ops", 32))
end::Int

command_batching_bytes() = @memoize begin
    load_command_batching_tunable("command_batching_bytes",
                                  "JULIA_METAL_COMMAND_BATCHING_BYTES",
                                  @load_preference("command_batching_bytes", 64 * 1024 * 1024))
end::Int

command_batching_inflight() = @memoize begin
    load_command_batching_tunable("command_batching_inflight",
                                  "JULIA_METAL_COMMAND_BATCHING_INFLIGHT",
                                  @load_preference("command_batching_inflight", 3))
end::Int

# Completion handlers run on libdispatch worker threads, where compiling or
# running Julia code can overflow the small foreign stack. Keep command buffers
# alive and drain Julia roots from normal managed threads instead.
struct PendingCommand{T}
    # what the backend reports the command's completion on
    token::T
    roots::Vector{Any}
end

"""
    CommandBackend

The Metal API that a [`BatchedCommandQueue`](@ref) encodes and submits its work with. The
batching itself (recording operations and their roots, deciding when to flush, limiting
the work in flight, ownership of managed memory) is shared; a backend implements the
following for `BatchedCommandQueue{B}`. The encoding and submission functions are called
while holding `submission_lock`:

- `has_open_batch(bq)`: whether there is uncommitted work;
- `kernel_encoder!(bq, pipeline)`: return an encoding context for a kernel launch using
  `pipeline`, opening the batch if needed (and then calling `register_queue!(bq)`, so that
  other tasks can flush it). The context supports
  `bind_buffer!(ctx, buf, offset, index)`, `bind_bytes!(ctx, ptr, length, index)` (which
  must copy the bytes before returning), `make_resident!(ctx, buf, usage)` for buffers
  that are only reachable through a GPU address, and `dispatch!(ctx, groups, threads)`;
- `blit_encoder(bq)`: return a context supporting `append_copy!` and `append_fillbuffer!`;
- `encode_event_wait!(bq, event, value)`: make subsequent work wait for `event`;
- `end_encoder!(bq)`: close the current encoder, if any;
- `commit_open_batch!(bq)`: submit the open batch, returning a completion token, and
  forget about it (`has_open_batch` becomes false). Profiling metadata recorded with the
  batch's operations must be attached before submitting;
- `discard_open_batch!(bq)`: drop and release the open batch without submitting it, then
  call `reset_open_batch!(bq)`;
- `abandon_open_batch!(bq)`: at exit, close the open batch without submitting or waiting
  for it, then call `reset_open_batch!(bq)`;
- `pending_commands(bq)`: the mutable vector of `PendingCommand`s for submitted work whose
  roots are still alive, in submission order;
- `take_submissions!(bq)` and `last_submission(bq)`: the most recent submission to wait
  for, the former together with the errors reported since it was last called.

`device_synchronize` and the error reporting still rely on the per-queue submission
tracking in `MTL` that Metal 3 command buffers feed.

Completion tokens support `is_completed(token)` and `wait_completed!(token)`.
"""
abstract type CommandBackend end

"""
    Metal3Backend

Encodes into a single `MTLCommandBuffer` per batch, using compute and blit encoders.
Arguments are bound with `setBuffer:`/`setBytes:` and other buffers declared with
`useResource:`; Metal 3 orders the commands of a compute encoder by itself.
"""
mutable struct Metal3Backend <: CommandBackend
    cmdbuf::Union{Nothing,MTLCommandBuffer}
    encoder::Union{Nothing,MTLComputeCommandEncoder,MTLBlitCommandEncoder}
    kind::EncoderKind
    last_pipeline::Union{Nothing,MTLComputePipelineState}
    cleanups::Vector{PendingCommand{MTL.MTLCommandBufferLike}}
end

Metal3Backend() = Metal3Backend(nothing, nothing, NoEncoder, nothing,
                                PendingCommand{MTL.MTLCommandBufferLike}[])

"""
    BatchedCommandQueue

A command queue that batches GPU work to amortize Metal's per-command-buffer
submission latency. Kernel launches (`@metal`) and GPU-side blit operations
(`copyto!`, `fill!`) are encoded into a single open command buffer and committed
lazily, instead of one command buffer per operation.

It wraps, and is a drop-in for, the `MTLCommandQueue` it batches: properties that
aren't its own (e.g. `label`) forward to the underlying queue.

How the work is encoded and submitted is up to its `CommandBackend` type parameter;
currently, that's always `Metal3Backend`, using the Metal 3 command API.

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

`BatchedCommandQueue`s are task-local, but are only mutated while holding a global lock,
so that other tasks can flush them too. Sharing a raw `MTLCommandQueue` across tasks is
unsupported. Once the owning task has finished, any task's [`synchronize`](@ref) flushes
and waits for the work it left behind, so results of a task are visible after `wait`ing
for it. [`device_synchronize`](@ref) flushes the batches of all tasks, which supports
`@async` work and the REPL synchronization hook.
"""
mutable struct BatchedCommandQueue{B<:CommandBackend}
    # the Metal 3 queue that this one batches for, and that work submitted outside of the
    # batch (e.g. by MPS) is ordered against
    queue::MTLCommandQueue
    device::MTLDevice
    owner::Task
    backend::B
    roots::Vector{Any}
    nops::Int
    nbytes::Int
    pending_ops::Vector{Any}
end

const Metal3Queue = BatchedCommandQueue{Metal3Backend}

# The concrete queue types, one per backend. Containers and fields that hold queues use
# this instead of the abstract `BatchedCommandQueue`, to keep dispatch on them static.
const ConcreteBatchedQueue = Metal3Queue

function BatchedCommandQueue(queue::MTLCommandQueue)
    dev = queue.device
    can_use_residency_sets(dev) && install_queue_residency!(queue, dev)
    BatchedCommandQueue(queue, dev, current_task(), Metal3Backend(), Any[], 0, 0, Any[])
end

# Properties that aren't our own fields (e.g. `label`) forward to the wrapped
# queue, so a BatchedCommandQueue is a drop-in for the MTLCommandQueue it batches.
@inline function Base.getproperty(bq::BatchedCommandQueue, name::Symbol)
    hasfield(typeof(bq), name) && return getfield(bq, name)
    return getproperty(getfield(bq, :queue), name)
end

@inline function Base.setproperty!(bq::BatchedCommandQueue, name::Symbol, value)
    hasfield(typeof(bq), name) && return setfield!(bq, name, value)
    return setproperty!(getfield(bq, :queue), name, value)
end

const batched_queues = IdDict{ConcreteBatchedQueue,Nothing}()
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
    (!has_open_batch(bq) && isempty(pending_commands(bq))) || return
    Base.@lock batched_queues_lock begin
        if !has_open_batch(bq) && isempty(pending_commands(bq))
            delete!(batched_queues, bq)
        end
    end
    return
end

function active_batched_queues()
    Base.@lock batched_queues_lock collect(keys(batched_queues))
end

has_active_batched_queues() =
    Base.@lock batched_queues_lock !isempty(batched_queues)

# batched queues are mutated (e.g., encoding operations or committing the open batch), and
# managed buffers change ownership, only while holding this lock. that makes it possible
# for any task to flush any queue, e.g., to wait for the work of another task before
# accessing memory it uses. waiting for the GPU should happen without holding this lock.
const submission_lock = ReentrantLock()

# batched queues whose owning task has finished, but that still have an open batch or
# in-flight work. nobody else will ever flush or synchronize these, so `synchronize`
# adopts them.

function orphaned_batched_queues()
    Base.@lock batched_queues_lock begin
        bqs = nothing
        for bq in keys(batched_queues)
            istaskdone(bq.owner) || continue
            bqs === nothing && (bqs = ConcreteBatchedQueue[])
            push!(bqs, bq)
        end
        bqs
    end
end

batched_queue(bq::BatchedCommandQueue) = bq

function batched_queue(queue::MTLCommandQueue)
    get!(task_local_storage(), batched_queue_key(queue)) do
        BatchedCommandQueue(queue)
    end::ConcreteBatchedQueue
end

raw_queue(bq::BatchedCommandQueue) = bq.queue
raw_queue(queue::MTLCommandQueue) = queue

profiling_command_buffers() =
    MTL.profile_hook[] !== nothing || MTL.profile_metadata[] !== nothing

function Base.cconvert(::Type{<:id{MTLCommandQueue}}, bq::BatchedCommandQueue)
    flush!(bq)
    return bq.queue
end

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

# submit a command buffer that was encoded outside of the batch (e.g., by MPS). this first
# commits the open batch, preserving program order, and registers the use of buffers that
# were passed to Metal since the previous submission.
function submit_command_buffer(f, cmdbuf)
    queue = cmdbuf.commandQueue
    bq = get(task_local_storage(), batched_queue_key(queue), nothing)
    bq === nothing || flush!(bq)

    pending = pending_ownership()
    # creating a batched queue takes the autorelease pool lock, so do so before locking
    owner = isempty(pending) || bq !== nothing ? bq : batched_queue(queue)
    while true
        conflict = Base.@lock submission_lock begin
            if isempty(pending)
                f()
                return
            end
            i = findfirst(managed -> !can_take_ownership(managed, owner), pending)
            if i === nothing
                foreach(managed -> take_ownership!(managed, owner), pending)
                empty!(pending)
                f()
                return
            end
            pending[i]
        end
        # another queue started using the buffer since it was passed to Metal
        synchronize(conflict)
    end
end

# buffers that were passed to Metal by the current task, and will be used by the next
# command buffer it submits
pending_ownership() =
    get!(() -> Managed[], task_local_storage(), :MetalPendingOwnership)::Vector{Managed}

# for operations that use the buffers passed to Metal, but are submitted and completed by
# Metal itself: wait for other queues that may still be using those buffers instead.
function synchronize_pending!()
    pending = pending_ownership()
    foreach(synchronize, pending)
    empty!(pending)
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

## Metal 3 backend

has_open_batch(bq::Metal3Queue) = bq.backend.cmdbuf !== nothing

pending_commands(bq::Metal3Queue) = bq.backend.cleanups

function ensure_cmdbuf!(bq::Metal3Queue)
    be = bq.backend
    cmdbuf = be.cmdbuf
    if cmdbuf === nothing
        cmdbuf = MTLCommandBuffer(bq.queue)
        @label! cmdbuf "MTLCommandBuffer(batched queue)"
        be.cmdbuf = cmdbuf
        register_queue!(bq)
    end
    return cmdbuf::MTLCommandBuffer
end

function end_encoder!(bq::Metal3Queue)
    be = bq.backend
    enc = be.encoder
    enc === nothing && return

    be.encoder = nothing
    be.kind = NoEncoder
    be.last_pipeline = nothing
    close(enc)
    return
end

function compute_encoder(bq::Metal3Queue)
    be = bq.backend
    if be.kind == ComputeEncoder
        return be.encoder::MTLComputeCommandEncoder
    end

    end_encoder!(bq)
    enc = MTLComputeCommandEncoder(ensure_cmdbuf!(bq))
    be.encoder = enc
    be.kind = ComputeEncoder
    return enc
end

function blit_encoder(bq::Metal3Queue)
    be = bq.backend
    if be.kind == BlitEncoder
        return be.encoder::MTLBlitCommandEncoder
    end

    end_encoder!(bq)
    enc = MTLBlitCommandEncoder(ensure_cmdbuf!(bq))
    be.encoder = enc
    be.kind = BlitEncoder
    return enc
end

function kernel_encoder!(bq::Metal3Queue, pipeline::MTLComputePipelineState)
    cce = compute_encoder(bq)
    be = bq.backend
    if be.last_pipeline !== pipeline
        MTL.set_function!(cce, pipeline)
        be.last_pipeline = pipeline
    end
    return cce
end

@inline bind_buffer!(cce::MTLComputeCommandEncoder, buf::MTLBuffer, offset, index) =
    set_buffer!(cce, buf, offset, index)
@inline bind_bytes!(cce::MTLComputeCommandEncoder, ptr::Ptr, len::Integer, index::Integer) =
    set_bytes!(cce, ptr, len, index)
@inline make_resident!(cce::MTLComputeCommandEncoder, buf::MTLBuffer, usage) =
    MTL.use!(cce, buf, usage)
@inline dispatch!(cce::MTLComputeCommandEncoder, groups::MTLSize, threads::MTLSize) =
    MTL.append_current_function!(cce, groups, threads)

function encode_event_wait!(bq::Metal3Queue, event, value)
    end_encoder!(bq)
    encode_wait!(ensure_cmdbuf!(bq), event, value)
    return
end

function commit_open_batch!(bq::Metal3Queue)
    end_encoder!(bq)
    cmdbuf = bq.backend.cmdbuf::MTLCommandBuffer
    register_operations!(bq, cmdbuf)
    MTL.commit_with_queue_key!(cmdbuf, pointer(bq.queue))
    bq.backend.cmdbuf = nothing
    return cmdbuf
end

function discard_open_batch!(bq::Metal3Queue)
    cmdbuf = bq.backend.cmdbuf
    cmdbuf === nothing && return
    bq.backend.cmdbuf = nothing
    reset_open_batch!(bq)
    release(cmdbuf)
    return
end

# at exit, an open encoder must be ended before it's released, but the command buffer
# must not be committed or waited on
function abandon_open_batch!(bq::Metal3Queue)
    end_encoder!(bq)
    bq.backend.cmdbuf === nothing && return
    bq.backend.cmdbuf = nothing
    reset_open_batch!(bq)
    return
end

take_submissions!(bq::Metal3Queue) = MTL.take_queue_submissions(bq.queue)
last_submission(bq::Metal3Queue) = MTL.last_committed(bq.queue)

function note_operation!(bq::BatchedCommandQueue, op)
    MTL.profile_metadata[] === nothing && return
    push!(bq.pending_ops, op)
    return
end

# `roots` are pushed one by one: `append!`ing the tuple would compile `copyto!` for every
# combination of root types, i.e., for every kernel signature.
Base.@nospecializeinfer function record_operation!(bq::BatchedCommandQueue,
                                                   @nospecialize(roots...);
                                                   bytes::Integer=0, op=nothing)
    for root in roots
        push!(bq.roots, root)
    end
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

function defer_cleanup!(bq::BatchedCommandQueue, token, roots::Vector{Any})
    Base.@lock submission_lock begin
        cleanups = pending_commands(bq)
        push!(cleanups, eltype(cleanups)(token, roots))
        register_queue!(bq)
    end
    return
end

# release the roots of completed command buffers. `until` treats the entries up to and
# including it as completed, e.g., because a command buffer committed later has completed.
function drain_cleanups!(bq::BatchedCommandQueue;
                         until::Union{Nothing,PendingCommand}=nothing)
    Base.@lock submission_lock begin
        cleanups = pending_commands(bq)
        nforced = until === nothing ? 0 :
                  something(findfirst(cleanup -> cleanup === until, cleanups), 0)
        n = 0
        for cleanup in cleanups
            if !(n < nforced || is_completed(cleanup.token))
                break
            end
            n += 1
        end
        n == 0 && return

        completed = cleanups[1:n]
        deleteat!(cleanups, 1:n)

        for cleanup in completed
            empty!(cleanup.roots)
        end

        unregister_queue_if_idle!(bq)
    end
    return
end

function drain_cleanups!(queue)
    queue = raw_queue(queue)
    for bq in active_batched_queues()
        bq.queue === queue || continue
        drain_cleanups!(bq)
    end
    return
end

function pending_cleanup_count(bq::BatchedCommandQueue)
    return length(pending_commands(bq))
end

# wait until fewer than `command_batching_inflight()` command buffers are in flight
function limit_inflight!(bq::BatchedCommandQueue)
    while true
        token = Base.@lock submission_lock begin
            drain_cleanups!(bq)
            pending_cleanup_count(bq) < command_batching_inflight() && return
            first(pending_commands(bq)).token
        end
        wait_completed!(token)
    end
end

# forget the operations recorded for the open batch, once the backend has submitted or
# dropped it
function reset_open_batch!(bq::BatchedCommandQueue)
    bq.roots = Any[]
    bq.pending_ops = Any[]
    bq.nops = 0
    bq.nbytes = 0
    unregister_queue_if_idle!(bq)
    return
end

function flush!(bq::BatchedCommandQueue)
    commit_batch!(bq)
    limit_inflight!(bq)
    return
end

# commit the open batch, if any. this may be another task's queue.
function commit_batch!(bq::BatchedCommandQueue)
    Base.@lock submission_lock begin
        has_open_batch(bq) || return

        roots = bq.roots
        token = commit_open_batch!(bq)
        defer_cleanup!(bq, token, roots)
        reset_open_batch!(bq)
    end
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
