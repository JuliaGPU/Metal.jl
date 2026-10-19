# The Metal 4 command backend (see `Metal4Backend`), selected with the `command_api`
# preference.

const METAL4_BATCH_LABEL = "MTL4CommandBuffer(batched queue)"

# Metal 4 argument tables have at most 31 buffer bindings, which matches the Metal 3 limit
# that kernels are compiled against.
const MAX_BUFFER_BINDINGS = 31

const ARGUMENT_SCRATCH_SIZE = 64 * 1024
const ARGUMENT_ALIGNMENT = 64


## device residency

const device_residencies = Dict{MTLDevice,DeviceResidency}()
const device_residencies_lock = ReentrantLock()

function device_residency(dev::MTLDevice)
    res = Base.@lock device_residencies_lock get(device_residencies, dev, nothing)
    res === nothing || return res

    desc = MTLResidencySetDescriptor()
    desc.initialCapacity = 256
    @label! desc "Metal.jl allocations"
    res = DeviceResidency(MTLResidencySet(dev, desc), ReentrantLock(), Set{UInt}(), false,
                          ArgumentScratch[])
    # the per-device scratch buffers, which kernels access through their address. added
    # before publishing the set, as kernels rely on them being resident.
    add_resident!(res, malloc_buffer(dev))
    add_resident!(res, exception_info_buffer(dev))
    commit_residency!(res)

    Base.@lock device_residencies_lock begin
        get!(device_residencies, dev, res)
    end
end

function add_resident!(res::DeviceResidency, buf::MTLBuffer)
    Base.@lock res.lock begin
        if !(UInt(pointer(buf)) in res.members)
            push!(res.members, UInt(pointer(buf)))
            MTL.add_allocation!(res.set, buf)
            res.dirty = true
        end
    end
    return
end

function remove_resident!(res::DeviceResidency, buf::MTLBuffer)
    Base.@lock res.lock begin
        delete!(res.members, UInt(pointer(buf)))
        MTL.remove_allocation!(res.set, buf)
        res.dirty = true
    end
    return
end

is_resident(res::DeviceResidency, buf::MTLBuffer) =
    Base.@lock res.lock UInt(pointer(buf)) in res.members

function commit_residency!(res::DeviceResidency)
    Base.@lock res.lock begin
        if res.dirty
            MTL.commit!(res.set)
            res.dirty = false
        end
    end
    return
end

# called by `alloc`: make buffers allocated by Metal.jl resident on every Metal 4 queue
track_allocation!(buf::MTLBuffer) = add_resident!(device_residency(buf.device), buf)

# The buffers freed by `free`, which still have to be released. This can happen in
# finalizers, where we can't take locks, so the buffers are pushed onto a lock-free list
# and released (or scheduled for removal from their residency set) by `process_freed!`.
mutable struct FreedBuffers
    Base.@atomic head::Union{Nothing,FreedBuffer}
end
const freed_buffers = FreedBuffers(nothing)

function defer_release!(buf::MTLBuffer)
    head = Base.@atomic freed_buffers.head
    while true
        head, ok = Base.@atomicreplace freed_buffers.head head => FreedBuffer(buf, head)
        ok && return
    end
end

has_freed_buffers() = (Base.@atomic freed_buffers.head) !== nothing

# Release the buffers that were freed. Those in a residency set have to stay there until
# the Metal 4 work that may use them has completed: the open batches of all queues, or
# their latest submission. Must be called while holding the `submission_lock`.
function process_freed!()
    has_freed_buffers() || return
    node = Base.@atomicswap freed_buffers.head = nothing

    queues = nothing
    while node !== nothing
        buf = node.buffer
        node = node.next

        res = Base.@lock device_residencies_lock get(device_residencies, buf.device, nothing)
        if res !== nothing && is_resident(res, buf)
            queues === nothing && (queues = active_batched_queues())
            removal = PendingRemoval(buf, 0)
            for bq in queues
                bq isa Metal4Queue && bq.backend.residency === res || continue
                attach_removal!(bq.backend, removal)
            end
            if removal.count == 0
                remove_resident!(res, buf)
                commit_residency!(res)
            end
        end

        # the residency set holds a reference of its own while the removal is pending
        release(buf)
    end
    return
end

function attach_removal!(be::Metal4Backend, removal::PendingRemoval)
    if be.cmdbuf !== nothing
        push!(be.removals, removal)
        removal.count += 1
        return
    end
    for i in length(be.cleanups):-1:1
        token = be.cleanups[i].token
        if token isa Metal4Batch
            push!(token.removals, removal)
            removal.count += 1
            return
        end
    end
    return
end

function complete_removals!(be::Metal4Backend, removals::Vector{PendingRemoval})
    isempty(removals) && return
    for removal in removals
        removal.count -= 1
        removal.count == 0 && remove_resident!(be.residency, removal.buffer)
    end
    empty!(removals)
    # removals only take effect, and release the buffers, once committed
    commit_residency!(be.residency)
    return
end


## queue construction

function Metal4Backend(queue::MTLCommandQueue, dev::MTLDevice)
    reason = metal4_unsupported_reason(dev)
    reason === nothing ||
        error("Cannot use the Metal 4 command API, as selected by the `command_api` preference: $reason.")

    label = let label = queue.label
        label === nothing ? nothing : String(label)
    end
    desc = MTL4CommandQueueDescriptor()
    label === nothing || (desc.label = label)
    queue4 = MTL4CommandQueue(dev, desc)

    residency = device_residency(dev)
    MTL.add_residency_set!(queue4, residency.set)

    # (an argument table's label is read-only, so it has to be set on the descriptor)
    argtable = MTL4ArgumentTable(dev; buffers=MAX_BUFFER_BINDINGS,
                                 label=label_resources() ? "batched queue arguments" : nothing)

    event4 = MTLSharedEvent(dev)
    @label! event4 "batched queue completion"
    event3 = MTLSharedEvent(dev)
    @label! event3 "batched queue interop ordering"

    # the Metal 3 queue may already have been used (e.g., wrapped by this queue only after
    # submitting a command buffer to it), so have the first batch wait for it
    metal3_dirty = true

    Metal4Backend(queue4, argtable, residency, label,
                  nothing, nothing, nothing, nothing, ArgumentScratch[], PendingRemoval[],
                  nothing, false,
                  event4, UInt64(0), UInt64(0), event3, UInt64(0), UInt64(0), metal3_dirty,
                  PendingCommand{Metal4Token}[],
                  MTL4CommandBuffer[], MTL4CommandAllocator[], MTLResidencySet[])
end


## encoding

has_open_batch(bq::Metal4Queue) = bq.backend.cmdbuf !== nothing

pending_commands(bq::Metal4Queue) = bq.backend.cleanups

function ensure_cmdbuf!(bq::Metal4Queue)
    be = bq.backend
    cmdbuf = be.cmdbuf
    cmdbuf === nothing || return cmdbuf::MTL4CommandBuffer

    cmdbuf = isempty(be.free_cmdbufs) ? MTL4CommandBuffer(bq.device) : pop!(be.free_cmdbufs)
    @label! cmdbuf METAL4_BATCH_LABEL
    allocator = isempty(be.free_allocators) ? MTL4CommandAllocator(bq.device) :
                                              pop!(be.free_allocators)
    MTL.beginCommandBuffer!(cmdbuf, allocator)
    be.cmdbuf = cmdbuf
    be.allocator = allocator
    register_queue!(bq)
    return cmdbuf
end

# Metal 4 encodes dispatches, copies and fills with the same encoder. Its commands run
# concurrently, and so do the command buffers of a queue, so every operation is ordered
# after the ones before it with a barrier: an encoder barrier between operations, and a
# queue barrier (covering the earlier encoders and batches) when opening the encoder.
function batch_encoder!(bq::Metal4Queue)
    be = bq.backend
    enc = be.encoder
    if enc === nothing
        enc = MTL4ComputeCommandEncoder(ensure_cmdbuf!(bq))
        MTL.set_argument_table!(enc, be.argtable)
        MTL.barrierAfterQueueStages!(enc)
        be.encoder = enc
    elseif be.needs_barrier
        MTL.barrierAfterEncoderStages!(enc)
    end
    be.needs_barrier = true
    # the backend is the encoding context: it holds the encoder and the binding state
    return be
end

function end_encoder!(bq::Metal4Queue)
    be = bq.backend
    enc = be.encoder
    enc === nothing && return

    be.encoder = nothing
    be.last_pipeline = nothing
    be.needs_barrier = false
    close(enc)
    return
end

function kernel_encoder!(bq::Metal4Queue, pipeline::MTLComputePipelineState)
    be = batch_encoder!(bq)
    if be.last_pipeline !== pipeline
        MTL.set_function!(be.encoder::MTL4ComputeCommandEncoder, pipeline)
        be.last_pipeline = pipeline
    end
    return be
end

blit_encoder(bq::Metal4Queue) = batch_encoder!(bq)

# Metal 4 command buffers do not make the buffers they use resident: those Metal.jl
# allocated are in the device's residency set, others are added to one for the batch.
function make_resident!(be::Metal4Backend, buf::MTLBuffer, usage=nothing)
    is_resident(be.residency, buf) && return
    resset = be.resset
    if resset === nothing
        resset = if isempty(be.free_ressets)
            desc = MTLResidencySetDescriptor()
            desc.initialCapacity = 16
            @label! desc "batched queue residency"
            MTLResidencySet(buf.device, desc)
        else
            pop!(be.free_ressets)
        end
        be.resset = resset
    end
    MTL.add_allocation!(resset, buf)
    return
end

@inline function bind_buffer!(be::Metal4Backend, buf::MTLBuffer, offset, index)
    make_resident!(be, buf)
    MTL.set_buffer!(be.argtable, buf, offset, index)
    return
end

# Metal 4 has no `setBytes:`, so copy the argument to the batch's scratch buffer
@inline function bind_bytes!(be::Metal4Backend, ptr::Ptr, len::Integer, index::Integer)
    dst, addr = reserve_argument!(be, Int(len))
    unsafe_copyto!(dst, reinterpret(Ptr{UInt8}, ptr), len)
    MTL.set_address!(be.argtable, addr, index)
    return
end

@inline dispatch!(be::Metal4Backend, groups::MTLSize, threads::MTLSize) =
    MTL.dispatchThreadgroups!(be.encoder::MTL4ComputeCommandEncoder, groups, threads)

function MTL.append_copy!(be::Metal4Backend, dst::MTLBuffer, doff, src::MTLBuffer, soff, len)
    make_resident!(be, dst)
    make_resident!(be, src)
    MTL.append_copy!(be.encoder::MTL4ComputeCommandEncoder, dst, doff, src, soff, len)
end

function MTL.append_fillbuffer!(be::Metal4Backend, buf::MTLBuffer, value, bytesize, offset=0)
    make_resident!(be, buf)
    MTL.append_fillbuffer!(be.encoder::MTL4ComputeCommandEncoder, buf, value, bytesize,
                           offset)
end

function ArgumentScratch(dev::MTLDevice, capacity::Integer)
    buf = MTLBuffer(dev, capacity; storage=SharedStorage)
    @label! buf "kernel argument scratch"
    add_resident!(device_residency(dev), buf)
    ArgumentScratch(buf, convert(Ptr{UInt8}, MTL.contents(buf)), UInt64(buf.gpuAddress), 0)
end

# reserve `len` bytes of argument storage, returning the CPU pointer to write them to and
# the GPU address to bind
function reserve_argument!(be::Metal4Backend, len::Int)
    if !isempty(be.scratch)
        scratch = last(be.scratch)
        offset = cld(scratch.offset, ARGUMENT_ALIGNMENT) * ARGUMENT_ALIGNMENT
        if offset + len <= sizeof(scratch.buf)
            scratch.offset = offset + len
            return scratch.ptr + offset, scratch.addr + offset
        end
    end

    free = be.residency.free_scratch
    scratch = if len <= ARGUMENT_SCRATCH_SIZE && !isempty(free)
        pop!(free)
    else
        ArgumentScratch(be.residency.set.device, max(len, ARGUMENT_SCRATCH_SIZE))
    end
    scratch.offset = len
    push!(be.scratch, scratch)
    return scratch.ptr, scratch.addr
end

# Metal 4 queues wait for events themselves, so commit the work encoded so far, and make
# the work committed next wait. that's at least the batch opened here, so that waiting for
# the queue waits for the event, as with Metal 3 where the wait is part of the batch.
function encode_event_wait!(bq::Metal4Queue, event, value)
    commit_batch!(bq)
    MTL.wait_event!(bq.backend.queue4, event, value)
    ensure_cmdbuf!(bq)
    return
end


## submission

function commit_open_batch!(bq::Metal4Queue)
    end_encoder!(bq)
    be = bq.backend
    cmdbuf = be.cmdbuf::MTL4CommandBuffer
    process_freed!()

    # order the batch after the Metal 3 work that was submitted before it
    be.metal3_dirty && signal_metal3!(bq)
    if be.waited3 < be.seq3
        MTL.wait_event!(be.queue4, be.event3, be.seq3)
        be.waited3 = be.seq3
    end

    commit_residency!(be.residency)
    resset = be.resset
    if resset !== nothing
        MTL.commit!(resset)
        MTL.use_residency_set!(cmdbuf, resset)
    end
    MTL.endCommandBuffer!(cmdbuf)

    value = be.seq4 + 1
    sub = MTL.MTL4Submission(be.event4, value; label=METAL4_BATCH_LABEL,
                             queue_label=be.label)
    register_operations!(bq, sub)
    MTL.commit_tracked!(be.queue4, cmdbuf, sub, pointer(bq.queue))
    be.seq4 = value

    batch = Metal4Batch(sub, be.allocator::MTL4CommandAllocator, resset, be.scratch,
                        be.removals)
    # the command buffer can be reused right away, unlike its allocator
    push!(be.free_cmdbufs, cmdbuf)
    reset_backend_batch!(be)
    return batch
end

function reset_backend_batch!(be::Metal4Backend)
    be.cmdbuf = nothing
    be.allocator = nothing
    be.resset = nothing
    be.scratch = ArgumentScratch[]
    be.removals = PendingRemoval[]
    return
end

# recycle what a completed batch used. called while holding the `submission_lock`.
function retire!(bq::Metal4Queue, batch::Metal4Batch)
    be = bq.backend
    MTL.reset!(batch.allocator)
    push!(be.free_allocators, batch.allocator)
    recycle_resources!(be, batch.resset, batch.scratch)
    complete_removals!(be, batch.removals)
    return
end
retire!(::Metal4Queue, ::MTL.MTLCommandBufferLike) = nothing

# batches may complete after work committed later (see `last_submission`), and recycling
# their allocator before they did is invalid
can_force(::Metal4Batch) = false

function recycle_resources!(be::Metal4Backend, resset, scratch)
    if resset !== nothing
        MTL.remove_all_allocations!(resset)
        MTL.commit!(resset)
        push!(be.free_ressets, resset)
    end
    for s in scratch
        if sizeof(s.buf) == ARGUMENT_SCRATCH_SIZE
            push!(be.residency.free_scratch, s)
        else
            # oversized ones aren't recycled
            remove_resident!(be.residency, s.buf)
            commit_residency!(be.residency)
            release(s.buf)
        end
    end
    return
end

function discard_open_batch!(bq::Metal4Queue)
    end_encoder!(bq)
    be = bq.backend
    cmdbuf = be.cmdbuf
    cmdbuf === nothing && return

    MTL.endCommandBuffer!(cmdbuf)
    push!(be.free_cmdbufs, cmdbuf)
    allocator = be.allocator::MTL4CommandAllocator
    MTL.reset!(allocator)
    push!(be.free_allocators, allocator)
    recycle_resources!(be, be.resset, be.scratch)

    # the removals that waited for this batch now only wait for the earlier ones
    removals = be.removals
    reset_backend_batch!(be)
    foreach(removal -> attach_removal!(be, removal), removals)
    complete_removals!(be, removals)

    reset_open_batch!(bq)
    return
end

function abandon_open_batch!(bq::Metal4Queue)
    end_encoder!(bq)
    be = bq.backend
    be.cmdbuf === nothing && return
    MTL.endCommandBuffer!(be.cmdbuf)
    reset_backend_batch!(be)
    reset_open_batch!(bq)
    return
end

take_submissions!(bq::Metal4Queue) = MTL.take_queue_submissions(bq.queue)

# a batch can complete after Metal 3 work committed later, when it was ordered after a
# Metal 3 command buffer that had been enqueued before (see `submit_external!`)
function last_submission(bq::Metal4Queue)
    last = MTL.last_committed(bq.queue)
    be = bq.backend
    for i in length(be.cleanups):-1:1
        token = be.cleanups[i].token
        if token isa Metal4Batch
            token.submission === last && return last
            return last === nothing ? token.submission : (last, token.submission)
        end
    end
    return last
end

is_completed(batch::Metal4Batch) = MTL.is_completed(batch.submission)
is_completed(sub::MTL.MTL4Submission) = MTL.is_completed(sub)

wait_completed!(batch::Metal4Batch) = wait_completed!(batch.submission)
function wait_completed!(sub::MTL.MTL4Submission)
    MTL.is_completed(sub) && return
    if use_nonblocking_synchronization
        cooperative_wait(MTL.wait_completed, sub; isdone=MTL.is_completed)
    else
        MTL.wait_completed(sub)
    end
    return
end
wait_completed!(subs::Tuple) = foreach(wait_completed!, subs)


## interoperability with the Metal 3 queue
#
# Command buffers committed to the Metal 3 queue that a Metal 4 queue batches for (by MPS,
# or derived from the queue by users) are ordered with the batches as if those were
# committed to the Metal 3 queue too: batches committed before a command buffer takes its
# place in the queue (by being enqueued or committed) execute before it, those committed
# afterwards execute after it. Metal 3 queues execute command buffers in order, also when
# one of them waits for an event, so:
#
# - before a command buffer takes its place, a "gate" command buffer is committed that
#   waits for the batches committed so far;
# - before committing a batch that follows Metal 3 work, a command buffer is committed
#   to the Metal 3 queue that signals an event once the work before it completes, and the
#   batch waits for that.

# commit a command buffer to the Metal 3 queue, bypassing the submission hook
function commit_metal3!(f, bq::Metal4Queue)
    cmdbuf = MTLCommandBuffer(bq.queue)
    f(cmdbuf)
    MTL.commit_with_queue_key!(cmdbuf, pointer(bq.queue))
    return
end

function gate_metal3!(bq::Metal4Queue)
    be = bq.backend
    be.gated4 < be.seq4 || return
    commit_metal3!(cmdbuf -> MTL.encode_wait!(cmdbuf, be.event4, be.seq4), bq)
    be.gated4 = be.seq4
    return
end

function signal_metal3!(bq::Metal4Queue)
    be = bq.backend
    value = be.seq3 + 1
    commit_metal3!(cmdbuf -> MTL.encode_signal!(cmdbuf, be.event3, value), bq)
    be.seq3 = value
    be.metal3_dirty = false
    return
end

# called while holding the `submission_lock`, before a command buffer takes its place on
# the Metal 3 queue that `bq` batches for
function order_external!(bq::Metal4Queue)
    commit_batch!(bq)
    gate_metal3!(bq)
    # the next batch has to wait for the command buffer, also if MPS commits it internally
    bq.backend.metal3_dirty = true
    return
end
