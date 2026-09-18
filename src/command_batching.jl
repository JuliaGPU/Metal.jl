# Metal 4 command batching.
#
# Metal.jl submits its own GPU work -- kernel launches, buffer copies and fills -- through
# Metal 4. A `BatchedCommandQueue` owns an `MTL4CommandQueue` and encodes operations into a
# single open `MTL4CommandBuffer`, backed by a recycled `MTL4CommandAllocator` and bound
# through a shared `MTL4ArgumentTable`, committing lazily.
#
# Three Metal 4 differences drive the design:
#
#  * command buffers carry no completion state, so a committed batch is tracked by an
#    `MTL4Submission` that a commit-feedback handler marks completed (and annotates with
#    GPU timings and any error);
#  * commands in an encoder run concurrently unless separated by a barrier, so every
#    operation but the first in a batch is preceded by one, reproducing the serial
#    semantics of Metal 3's compute encoder;
#  * binding a buffer no longer makes it resident, so every buffer an operation touches is
#    added to the batch's residency set.
#
# The queue also keeps an `MTLCommandQueue` for interoperability -- MPS, MPSGraph, and any
# command buffer derived from the queue by user code. The two are ordered against each
# other with a pair of shared events: a flushed Metal 4 batch signals `event`, which is
# also what tracks its completion and what a Metal 3 command buffer derived from the queue
# waits on; that buffer in turn signals `event3` when committed, which the next Metal 4
# batch waits on.

@enum EncoderKind NoEncoder ComputeEncoder BlitEncoder

# The stage mask used for the barriers that reimpose program order. `MTL4CommandEncoder`'s
# own `stages` property reports 0 on current drivers, so ask for a full barrier rather than
# narrowing it to the dispatch and blit stages a compute encoder actually uses.
const BARRIER_STAGES = MTL.MTLStageAll

# Label of every batched command buffer (only applied when `label_resources()`), and the
# name a submission reports under in profiles and errors either way.
const BATCH_LABEL = "MTL4CommandBuffer(batched queue)"

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


## by-value argument storage

# Metal 4 argument tables bind GPU addresses only; there is no `setBytes:`. Arguments that
# are passed by value are therefore bump-allocated out of a shared-storage scratch buffer,
# whose address is bound instead. A scratch buffer belongs to the batch that filled it and
# is recycled once that batch completes.

const ARGUMENT_SCRATCH_SIZE = 1024 * 1024
const ARGUMENT_ALIGNMENT = 64

mutable struct ArgumentScratch
    const buf::MTLBuffer
    const ptr::Ptr{UInt8}
    const addr::UInt64
    const capacity::Int
    offset::Int
end

function ArgumentScratch(dev::MTLDevice, capacity::Integer=ARGUMENT_SCRATCH_SIZE)
    buf = @autoreleasepool MTLBuffer(dev, capacity; storage=SharedStorage)
    @label! buf "argument scratch"
    ArgumentScratch(buf, convert(Ptr{UInt8}, MTL.contents(buf)),
                    UInt64(buf.gpuAddress), Int(capacity), 0)
end

# Reserve `nbytes` of aligned storage, returning the CPU pointer to write through and the
# GPU address to bind, or `nothing` when this scratch buffer is full.
@inline function reserve!(scratch::ArgumentScratch, nbytes::Int)
    offset = (scratch.offset + ARGUMENT_ALIGNMENT - 1) & ~(ARGUMENT_ALIGNMENT - 1)
    offset + nbytes > scratch.capacity && return nothing
    scratch.offset = offset + nbytes
    return (scratch.ptr + offset, scratch.addr + offset)
end

reset!(scratch::ArgumentScratch) = (scratch.offset = 0; scratch)


## committed batches

# Metal 4 recycles command buffers on commit and reports completion out-of-band, so the
# per-batch state that Metal 3 would hang off an `MTLCommandBuffer` lives here instead.
# `completed` is set by the commit-feedback handler *after* the error and timings have been
# recorded, so observing it is enough to safely read the rest.
mutable struct MTL4Submission
    const label::String
    const cmdbuf::MTL4CommandBuffer
    const allocator::MTL4CommandAllocator
    const resset::MTLResidencySet
    const scratch::Vector{ArgumentScratch}
    # value the queue's ordering event reaches once the GPU is done with this batch
    const event::MTLSharedEvent
    const seq::UInt64
    # whether a commit-feedback handler was registered for this batch (see `commit_options`)
    const expect_feedback::Bool
    roots::Vector{Any}
    @atomic completed::Bool
    @atomic gpu_start::Float64
    @atomic gpu_end::Float64
    @atomic error::Union{Nothing,MTL.CommandBufferErrorInfo}
end

# The ordering event is the authoritative completion signal: unlike the commit-feedback
# handler it needs no callback into Julia, which a precompilation worker cannot service.
# `diagnosed` additionally reports whether the handler has run and filled in the timings
# and error, which callers wait for on a bounded basis only.
is_completed(sub::MTL4Submission) =
    (@atomic sub.completed) || sub.event.signaledValue >= sub.seq

diagnosed(sub::MTL4Submission) = !sub.expect_feedback || (@atomic sub.completed)

gpu_time_range(sub::MTL4Submission) =
    diagnosed(sub) ? ((@atomic sub.gpu_start), (@atomic sub.gpu_end)) : nothing

function gpu_time_range(cmdbuf::MTL.MTLCommandBufferLike)
    cmdbuf.status == MTL.MTLCommandBufferStatusCompleted || return nothing
    return (cmdbuf.GPUStartTime, cmdbuf.GPUEndTime)
end

# Runs on one of Metal's feedback threads: keep it to Objective-C property reads and field
# stores, and never touch the Julia roots (`drain_cleanups!` releases those from the owning
# task instead).
#
# Metal invokes the handler on a libdispatch worker, which a precompilation worker cannot
# adopt without hanging image serialization, so `flush!` registers no handler there.
# Completion is tracked by the ordering event either way; only the timings and error are
# lost.
function commit_options(sub::MTL4Submission, queue_label::Union{Nothing,String})
    return MTL.MTL4CommitOptions() do feedback
        if feedback !== nothing
            @atomic sub.gpu_start = feedback.GPUStartTime
            @atomic sub.gpu_end = feedback.GPUEndTime
            err = feedback.error
            if err !== nothing
                @atomic sub.error = MTL.CommandBufferErrorInfo(
                    String(err.domain), Int(err.code), String(err.localizedDescription),
                    sub.label, queue_label)
            end
        end
        @atomic sub.completed = true
        return
    end
end


"""
    BatchedCommandQueue

A command queue that batches GPU work to amortize Metal's per-command-buffer
submission latency. Kernel launches (`@metal`) and GPU-side copy and fill operations
(`copyto!`, `fill!`) are encoded into a single open Metal 4 command buffer and committed
lazily, instead of one command buffer per operation.

It wraps, and is a drop-in for, an `MTLCommandQueue`: properties that aren't its own
(e.g. `label`) forward to that queue, and command buffers derived from it interoperate with
the batched Metal 4 work in program order.

The open batch is committed ("flushed") when any of the following happens:

  * [`synchronize`](@ref) is called on the queue (or on one of its command buffers);
  * a command buffer derived from the queue is enqueued or committed;
  * command batching is disabled with the `command_batching = false` preference;
  * the batch reaches `command_batching_ops()` operations or
    `command_batching_bytes()` of copy traffic;
  * a GPU profiler is attached, in which case batching is disabled (each operation
    gets its own command buffer) so per-operation GPU timing is preserved;
  * an immediate submission is requested via `@metal ... submit=true`, or
    `Metal.flush!` is called explicitly.

Program order is preserved across flushes: command buffers execute in commit order, and
operations within a batch are separated by encoder barriers. At most
`command_batching_inflight()` command buffers are kept in flight; further submissions block
until the GPU drains one. Obtain the current task's batched queue with [`global_queue`](@ref).

`BatchedCommandQueue`s are task-local and mutated lock-free by their owning task.
Sharing a raw `MTLCommandQueue` across tasks is unsupported. [`device_synchronize`](@ref)
may flush batches owned by other tasks after those tasks have yielded or completed,
which supports `@async` work and the REPL synchronization hook.
"""
mutable struct BatchedCommandQueue
    # Metal 3 queue, kept for interoperability and as this queue's identity
    queue::MTLCommandQueue
    # Metal 4 queue, carrying all of Metal.jl's own work
    queue4::MTL4CommandQueue
    device::MTLDevice

    # open batch
    cmdbuf::Union{Nothing,MTL4CommandBuffer}
    allocator::Union{Nothing,MTL4CommandAllocator}
    encoder::Union{Nothing,MTL4ComputeCommandEncoder}
    resset::Union{Nothing,MTLResidencySet}
    scratch::Vector{ArgumentScratch}
    kind::EncoderKind
    needs_barrier::Bool
    roots::Vector{Any}
    last_pipeline::Union{Nothing,MTLComputePipelineState}
    nops::Int
    nbytes::Int
    pending_ops::Vector{Any}

    # argument binding
    argtable::MTL4ArgumentTable

    # submitted batches awaiting completion, in commit order
    cleanups::Vector{MTL4Submission}
    errors::Union{Nothing,Vector{MTL.CommandBufferErrorInfo}}
    # the queue's label, as reported in `CommandBufferError`s; fixed at construction
    queue_label::Union{Nothing,String}

    # completion of, and ordering against, batched Metal 4 work. `order` is bumped once per
    # flush and is what an `MTL4Submission`'s `seq` refers to, so nothing else may signal
    # this event.
    event::MTLSharedEvent
    order::UInt64
    pending4::UInt64

    # ordering of batched Metal 4 work after Metal 3 work derived from `queue`
    event3::MTLSharedEvent
    order3::UInt64
    pending3::UInt64

    # recycled Metal 4 objects, returned by completed submissions
    free_cmdbufs::Vector{MTL4CommandBuffer}
    free_allocators::Vector{MTL4CommandAllocator}
    free_ressets::Vector{MTLResidencySet}
    free_scratch::Vector{ArgumentScratch}
end

# The largest number of buffer bindings a kernel launch can use. Metal 4 caps argument
# tables at 31 buffer bindings, which matches the Metal 3 buffer-argument limit that
# `mtlfunction` already compiles against.
const MAX_BUFFER_BINDINGS = 31

function BatchedCommandQueue(queue::MTLCommandQueue)
    dev = queue.device
    @autoreleasepool begin
        desc = MTL4CommandQueueDescriptor()
        queue_label = let label = queue.label
            label === nothing ? nothing : String(label)
        end
        queue_label === nothing || (desc.label = queue_label)
        queue4 = MTL4CommandQueue(dev, desc)

        argtable = MTL4ArgumentTable(dev; buffers=MAX_BUFFER_BINDINGS)
        @label! argtable "batched queue arguments"

        event = MTLSharedEvent(dev)
        @label! event "batched queue completion"
        event3 = MTLSharedEvent(dev)
        @label! event3 "batched queue interop ordering"

        bq = BatchedCommandQueue(queue, queue4, dev,
                                 nothing, nothing, nothing, nothing, ArgumentScratch[],
                                 NoEncoder, false,
                                 Any[], nothing, 0, 0, Any[],
                                 argtable,
                                 MTL4Submission[], nothing, queue_label,
                                 event, UInt64(0), UInt64(0),
                                 event3, UInt64(0), UInt64(0),
                                 MTL4CommandBuffer[], MTL4CommandAllocator[],
                                 MTLResidencySet[], ArgumentScratch[])
        install_queue_residency!(bq)
        return bq
    end
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

# Metal 3 command buffers (MPS work, user-derived buffers) still report completion
# themselves; their Julia roots are released by `drain_cleanups!` alongside Metal 4 batches.
struct PendingCommand
    cmdbuf::MTL.MTLCommandBufferLike
    roots::Vector{Any}
end

const pending_commands = IdDict{BatchedCommandQueue,Vector{PendingCommand}}()

@inline batched_queue_key(queue::MTLCommandQueue) =
    (:BatchedCommandQueue, pointer(queue))

function register_queue!(bq::BatchedCommandQueue)
    Base.@lock batched_queues_lock begin
        batched_queues[bq] = nothing
    end
    return
end

# A queue with unreported errors stays registered so `device_synchronize` on another
# task still surfaces them.
queue_is_idle(bq::BatchedCommandQueue) =
    bq.cmdbuf === nothing && isempty(bq.cleanups) && !haskey(pending_commands, bq) &&
    bq.errors === nothing

function unregister_queue_if_idle!(bq::BatchedCommandQueue)
    queue_is_idle(bq) || return
    Base.@lock batched_queues_lock begin
        queue_is_idle(bq) && delete!(batched_queues, bq)
    end
    return
end

function active_batched_queues()
    Base.@lock batched_queues_lock collect(keys(batched_queues))
end

has_active_batched_queues() =
    Base.@lock batched_queues_lock !isempty(batched_queues)

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

# A batched queue stands for both of the Metal queues it owns: the Metal 3 one it wraps,
# and the Metal 4 one it submits its own work to (which is what frame capture sees).
Base.:(==)(bq::BatchedCommandQueue, obj::NSObject) =
    UInt(pointer(obj)) in (UInt(pointer(bq.queue)), UInt(pointer(bq.queue4)))
Base.:(==)(obj::NSObject, bq::BatchedCommandQueue) = bq == obj
Base.:(==)(bq::BatchedCommandQueue, queue::MTLCommandQueue) = bq.queue == queue
Base.:(==)(queue::MTLCommandQueue, bq::BatchedCommandQueue) = queue == bq.queue


## interoperability with Metal 3 command buffers
#
# Handing the raw queue to code that derives a command buffer from it loses the chance to
# encode a GPU-side wait on the pending Metal 4 batch, so pay for a host-side wait instead.
# The constructors below are the fast path, and cover Metal.jl's own MPS use.

function Base.cconvert(::Type{<:id{MTLCommandQueue}}, bq::BatchedCommandQueue)
    flush!(bq)
    wait_submissions!(bq)
    return bq.queue
end

# Order `cmdbuf`, which was just derived from this queue, after the batched Metal 4 work
# committed so far.
function order_after_batch!(bq::BatchedCommandQueue, cmdbuf::MTL.MTLCommandBufferLike)
    flush!(bq)
    bq.pending4 == 0 || MTL.encode_wait!(cmdbuf, bq.event, bq.pending4)
    return cmdbuf
end

function MTL.MTLCommandBuffer(bq::BatchedCommandQueue)
    return order_after_batch!(bq, MTLCommandBuffer(bq.queue))
end

function MTL.MTLCommandBuffer(bq::BatchedCommandQueue, desc::MTLCommandBufferDescriptor)
    return order_after_batch!(bq, MTLCommandBuffer(bq.queue, desc))
end

function MTL.MTLCommandBuffer(f::Base.Callable, bq::BatchedCommandQueue,
                              desc::MTLCommandBufferDescriptor=MTLCommandBufferDescriptor())
    cmdbuf = MTLCommandBuffer(bq, desc)
    commit!(f, cmdbuf)
    return cmdbuf
end

# `MTL.submit_hook`: a Metal 3 command buffer on this queue is about to be enqueued or
# committed, so the open Metal 4 batch has to go out first.
function flush_open_batch(cmdbuf)
    bq = lookup_batched_queue(cmdbuf)
    bq === nothing || flush!(bq)
    return
end

# `MTL.commit_hook`: a Metal 3 command buffer is about to be committed, with all of its
# encoders closed. Have it signal the ordering event so the next Metal 4 batch can wait.
function order_metal4_after(cmdbuf)
    bq = lookup_batched_queue(cmdbuf)
    bq === nothing && return
    value = (bq.order3 += 1)
    MTL.encode_signal!(cmdbuf, bq.event3, value)
    bq.pending3 = value
    return
end

function lookup_batched_queue(cmdbuf)
    queue = cmdbuf.commandQueue
    queue === nothing && return nothing
    return get(task_local_storage(), batched_queue_key(queue), nothing)
end

# Xcode's capture tooling does not accept a scope created from an `MTL4CommandQueue`
# (`startCaptureWithDescriptor:` sends it `traceStream`, which such a scope does not
# implement, aborting the process), so scope-based capture falls back to a device-wide
# scope. That still covers this queue's work, since the device only drives one GPU.
function MTL.MTLCaptureScope(bq::BatchedCommandQueue, manager=MTLCaptureManager())
    flush!(bq)
    return MTLCaptureScope(bq.device, manager)
end

function Base.setproperty!(desc::MTLCaptureDescriptor, name::Symbol, bq::BatchedCommandQueue)
    name === :captureObject && return setproperty!(desc, name, bq.queue4)
    return invoke(Base.setproperty!, Tuple{MTLCaptureDescriptor, Symbol, Any},
                  desc, name, bq)
end

function MTL.MTLCaptureDescriptor(bq::BatchedCommandQueue,
                                  destination::MTL.MTLCaptureDestination;
                                  folder::String=nothing)
    return MTLCaptureDescriptor(bq.queue4, destination; folder)
end

function MTL.startCapture(bq::BatchedCommandQueue,
                          destination::MTL.MTLCaptureDestination=MTL.MTLCaptureDestinationGPUTraceDocument;
                          folder::String=nothing)
    flush!(bq)
    return MTL.startCapture(bq.queue4, destination; folder)
end


## the open batch

function ensure_cmdbuf!(bq::BatchedCommandQueue,
                        options::Union{Nothing,MTL.MTL4CommandBufferOptions}=nothing)
    cmdbuf = bq.cmdbuf
    cmdbuf === nothing || return cmdbuf::MTL4CommandBuffer

    # order this batch after any Metal 3 work committed on the interop queue
    if bq.pending3 != 0
        MTL.wait_event!(bq.queue4, bq.event3, bq.pending3)
        bq.pending3 = UInt64(0)
    end

    cmdbuf = isempty(bq.free_cmdbufs) ? MTL4CommandBuffer(bq.device) : pop!(bq.free_cmdbufs)
    @label! cmdbuf BATCH_LABEL
    allocator = isempty(bq.free_allocators) ? MTL4CommandAllocator(bq.device) :
                                              pop!(bq.free_allocators)
    resset = if isempty(bq.free_ressets)
        desc = MTLResidencySetDescriptor()
        desc.initialCapacity = 16
        @label! desc "batched queue residency"
        MTLResidencySet(bq.device, desc)
    else
        pop!(bq.free_ressets)
    end

    if options === nothing
        MTL.beginCommandBuffer!(cmdbuf, allocator)
    else
        MTL.beginCommandBuffer!(cmdbuf, allocator, options)
    end
    bq.cmdbuf = cmdbuf
    bq.allocator = allocator
    bq.resset = resset
    bq.needs_barrier = false
    register_queue!(bq)
    return cmdbuf
end

function end_encoder!(bq::BatchedCommandQueue)
    enc = bq.encoder
    enc === nothing && return

    bq.encoder = nothing
    bq.kind = NoEncoder
    bq.last_pipeline = nothing
    bq.needs_barrier = false
    close(enc)
    return
end

# Metal 4 encodes dispatches and buffer copies through the same encoder, so the two
# accessors below hand out the same one, and `kind` only records what it was last used for.
function batch_encoder!(bq::BatchedCommandQueue, kind::EncoderKind)
    enc = bq.encoder
    if enc === nothing
        enc = MTL4ComputeCommandEncoder(ensure_cmdbuf!(bq))
        MTL.set_argument_table!(enc, bq.argtable)
        bq.encoder = enc
        # Metal 4 makes no ordering promise between command buffers either, so fence this
        # batch against everything already committed to the queue.
        MTL.barrierAfterQueueStages!(enc, BARRIER_STAGES, BARRIER_STAGES,
                                     MTL.MTL4VisibilityOptionDevice)
        bq.needs_barrier = false
    elseif bq.needs_barrier
        # Metal 4 encoders run their commands concurrently; keep Metal.jl's program-order
        # guarantee by fencing every operation against the ones already encoded.
        MTL.barrierAfterEncoderStages!(enc, BARRIER_STAGES, BARRIER_STAGES,
                                       MTL.MTL4VisibilityOptionDevice)
        bq.needs_barrier = false
    end
    bq.kind = kind
    return enc::MTL4ComputeCommandEncoder
end

compute_encoder(bq::BatchedCommandQueue) = batch_encoder!(bq, ComputeEncoder)
blit_encoder(bq::BatchedCommandQueue) = batch_encoder!(bq, BlitEncoder)

# Start a batch of this operation's own, with command-buffer options that cannot be shared
# with unrelated work (currently only the `MTLLogState` of a logging-enabled kernel).
function begin_batch!(bq::BatchedCommandQueue;
                      options::Union{Nothing,MTL.MTL4CommandBufferOptions}=nothing)
    flush!(bq)
    ensure_cmdbuf!(bq, options)
    return compute_encoder(bq)
end

# Throw away a partially encoded batch, keeping the queue usable.
function abort_batch!(bq::BatchedCommandQueue)
    end_encoder!(bq)
    cmdbuf = bq.cmdbuf
    cmdbuf === nothing || discard_open_cmdbuf!(bq, cmdbuf)
    return
end

function set_pipeline!(bq::BatchedCommandQueue, cce::MTL4ComputeCommandEncoder,
                       pipeline::MTLComputePipelineState)
    if bq.last_pipeline !== pipeline
        MTL.set_function!(cce, pipeline)
        bq.last_pipeline = pipeline
    end
    return
end

# Declare `buf` resident for the open batch. Metal 4 argument tables bind bare GPU
# addresses, so nothing is made resident implicitly.
@inline function make_resident!(bq::BatchedCommandQueue, buf::MTLBuffer)
    bq.resset === nothing && ensure_cmdbuf!(bq)
    MTL.add_allocation!(bq.resset::MTLResidencySet, buf)
    return
end

@inline function bind_buffer!(bq::BatchedCommandQueue, buf::MTLBuffer, offset::Integer,
                              index::Integer)
    make_resident!(bq, buf)
    MTL.set_buffer!(bq.argtable, buf, offset, index)
    return
end

# Bind an `isbits` value by copying it into the batch's argument scratch buffer, Metal 4
# having no equivalent of `setBytes:`.
@inline function bind_bytes!(bq::BatchedCommandQueue, ptr::Ptr{Cvoid}, nbytes::Int,
                             index::Integer)
    addr = reserve_arguments!(bq, nbytes)
    unsafe_copyto!(reinterpret(Ptr{UInt8}, addr[1]), reinterpret(Ptr{UInt8}, ptr), nbytes)
    MTL.set_address!(bq.argtable, addr[2], index)
    return
end

function reserve_arguments!(bq::BatchedCommandQueue, nbytes::Int)
    nbytes <= ARGUMENT_SCRATCH_SIZE ||
        throw(ArgumentError("Kernel argument of $nbytes bytes exceeds the $(ARGUMENT_SCRATCH_SIZE)-byte argument buffer"))

    scratch = isempty(bq.scratch) ? nothing : last(bq.scratch)
    if scratch !== nothing
        res = reserve!(scratch, nbytes)
        res === nothing || return res
    end

    scratch = isempty(bq.free_scratch) ? ArgumentScratch(bq.device) :
                                         reset!(pop!(bq.free_scratch))
    push!(bq.scratch, scratch)
    make_resident!(bq, scratch.buf)
    return reserve!(scratch, nbytes)::Tuple{Ptr{UInt8},UInt64}
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
    bq.needs_barrier = true
    return
end

function register_operations!(bq::BatchedCommandQueue, sub)
    md = MTL.profile_metadata[]
    md === nothing && return
    for op in bq.pending_ops
        MTL.note_operation!(md, sub, op)
    end
    return
end


## completion tracking

function defer_cleanup!(bq::BatchedCommandQueue, sub::MTL4Submission)
    push!(bq.cleanups, sub)
    register_queue!(bq)
    return
end

function defer_cleanup!(bq::BatchedCommandQueue, cmdbuf::MTL.MTLCommandBufferLike,
                        roots::Vector{Any})
    push!(get!(() -> PendingCommand[], pending_commands, bq),
          PendingCommand(cmdbuf, roots))
    register_queue!(bq)
    return
end

defer_cleanup!(queue, cmdbuf::MTL.MTLCommandBufferLike, roots::Vector{Any}) =
    defer_cleanup!(batched_queue(queue), cmdbuf, roots)

function recycle!(bq::BatchedCommandQueue, sub::MTL4Submission)
    empty!(sub.roots)

    err = @atomic sub.error
    if err !== nothing
        errors = bq.errors
        if errors === nothing
            bq.errors = MTL.CommandBufferErrorInfo[err]
        else
            push!(errors, err)
        end
    end

    # Resetting the allocator invalidates the batch's commands, which is only legal now
    # that the GPU is done with them.
    MTL.reset!(sub.allocator)
    push!(bq.free_allocators, sub.allocator)
    push!(bq.free_cmdbufs, sub.cmdbuf)

    MTL.remove_all_allocations!(sub.resset)
    MTL.commit!(sub.resset)
    push!(bq.free_ressets, sub.resset)

    for scratch in sub.scratch
        push!(bq.free_scratch, reset!(scratch))
    end
    return
end

# A submission is only recycled once the GPU is done with it *and* its commit-feedback
# handler has recorded the timings and error; recycling on completion alone would let a
# late handler write its error into an already-forgotten object. Forcing waits for both.
recyclable(sub::MTL4Submission) = is_completed(sub) && diagnosed(sub)

function drain_cleanups!(bq::BatchedCommandQueue; force::Bool=false)
    n = 0
    for sub in bq.cleanups
        if force
            wait_diagnosed!(sub)
        elseif !recyclable(sub)
            break
        end
        n += 1
    end
    if n > 0
        completed = bq.cleanups[1:n]
        deleteat!(bq.cleanups, 1:n)
        for sub in completed
            recycle!(bq, sub)
        end
    end

    pending = get(pending_commands, bq, nothing)
    if pending !== nothing && !isempty(pending)
        m = 0
        for cleanup in pending
            (force || cleanup.cmdbuf.status >= MTL.MTLCommandBufferStatusCompleted) || break
            m += 1
        end
        if m > 0
            for cleanup in view(pending, 1:m)
                empty!(cleanup.roots)
            end
            deleteat!(pending, 1:m)
        end
        isempty(pending) && delete!(pending_commands, bq)
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

pending_cleanup_count(bq::BatchedCommandQueue) = length(bq.cleanups)

# Metal 4 has no pollable command-buffer status, so completion is observed through the
# queue's ordering event; the commit-feedback handler is then given a bounded chance to
# record the batch's timings and error before the submission is recycled.
#
# Like `wait_cmdbuf!`, this polls from the Julia scheduler unless the
# `nonblocking_synchronization` preference is off or a precompilation worker is running,
# in which case it parks the thread in Metal's blocking event wait instead.
function wait_submission!(sub::MTL4Submission)
    if !is_completed(sub)
        precompiling = ccall(:jl_generating_output, Cint, ()) != 0
        if use_nonblocking_synchronization && !precompiling
            spins = 0
            while spins < 256
                if spins < 32
                    ccall(:jl_cpu_pause, Cvoid, ())
                    ccall(:jl_gc_safepoint, Cvoid, ())
                else
                    yield()
                end
                is_completed(sub) && break
                spins += 1
            end

            while !is_completed(sub)
                yield()
            end
        else
            MTL.waitUntilSignaledValue(sub.event, sub.seq)
        end
    end

    spins = 0
    while !diagnosed(sub) && spins < 1024
        ccall(:jl_cpu_pause, Cvoid, ())
        ccall(:jl_gc_safepoint, Cvoid, ())
        spins += 1
    end
    return
end

# Wait until the commit-feedback handler for `sub` has run. Metal delivers a command
# buffer's `MTLLogState` blocks on the same feedback path, so this is what flushes the
# output of a logging-enabled kernel.
function wait_diagnosed!(sub::MTL4Submission)
    wait_submission!(sub)
    while !diagnosed(sub)
        yield()
    end
    return
end

function wait_submissions!(bq::BatchedCommandQueue)
    isempty(bq.cleanups) || wait_submission!(last(bq.cleanups))
    return
end

function wait_oldest_cleanup!(bq::BatchedCommandQueue)
    isempty(bq.cleanups) && return
    wait_diagnosed!(first(bq.cleanups))
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

function take_errors!(bq::BatchedCommandQueue)
    errors = bq.errors
    bq.errors = nothing
    return errors
end


## flushing

function reset_open_cmdbuf!(bq::BatchedCommandQueue, cmdbuf)
    bq.cmdbuf = nothing
    bq.allocator = nothing
    bq.resset = nothing
    bq.scratch = ArgumentScratch[]
    bq.roots = Any[]
    bq.pending_ops = Any[]
    bq.nops = 0
    bq.nbytes = 0
    bq.needs_barrier = false
    unregister_queue_if_idle!(bq)
    return
end

# Abandon the open batch without committing it. The allocator was never submitted, so it
# can be reset and recycled right away.
function discard_open_cmdbuf!(bq::BatchedCommandQueue, cmdbuf::MTL4CommandBuffer)
    allocator = bq.allocator
    resset = bq.resset
    scratch = bq.scratch
    reset_open_cmdbuf!(bq, cmdbuf)

    MTL.endCommandBuffer!(cmdbuf)
    push!(bq.free_cmdbufs, cmdbuf)
    if allocator !== nothing
        MTL.reset!(allocator)
        push!(bq.free_allocators, allocator)
    end
    if resset !== nothing
        MTL.remove_all_allocations!(resset)
        MTL.commit!(resset)
        push!(bq.free_ressets, resset)
    end
    for s in scratch
        push!(bq.free_scratch, reset!(s))
    end
    return
end

# Commit the open batch, returning its `MTL4Submission` (or `nothing` if there was none).
# The submission may already have been drained by `limit_inflight!` on return; waiting on
# it stays valid either way, since recycling does not touch its completion state.
function flush_batch!(bq::BatchedCommandQueue)
    cmdbuf = bq.cmdbuf
    cmdbuf === nothing && return nothing

    end_encoder!(bq)

    allocator = bq.allocator::MTL4CommandAllocator
    resset = bq.resset::MTLResidencySet
    scratch = bq.scratch
    roots = bq.roots

    MTL.commit!(resset)
    MTL.use_residency_set!(cmdbuf, resset)
    MTL.endCommandBuffer!(cmdbuf)

    value = bq.order + 1
    feedback = ccall(:jl_generating_output, Cint, ()) == 0
    sub = MTL4Submission(BATCH_LABEL, cmdbuf, allocator, resset, scratch, bq.event, value,
                         feedback, roots, false, 0.0, 0.0, nothing)

    register_operations!(bq, sub)
    reset_open_cmdbuf!(bq, cmdbuf)

    if feedback
        MTL.commit!(bq.queue4, cmdbuf, commit_options(sub, bq.queue_label))
    else
        MTL.commit!(bq.queue4, cmdbuf)
    end

    # signal completion, which both tracks this batch and lets Metal 3 work derived from
    # this queue order itself after it
    MTL.signal_event!(bq.queue4, bq.event, value)
    bq.order = value
    bq.pending4 = value

    defer_cleanup!(bq, sub)

    hook = MTL.profile_hook[]
    hook === nothing || hook(sub)

    limit_inflight!(bq)
    return sub
end

function flush!(bq::BatchedCommandQueue)
    flush_batch!(bq)
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
