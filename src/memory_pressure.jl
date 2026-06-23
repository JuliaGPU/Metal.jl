export free_memory, total_memory

"""
    working_set_size(dev=device())

Return Metal's recommended maximum working set size for `dev`.
"""
function working_set_size(dev::MTLDevice=device())
    @memoize key=pointer(dev)::id{MTLDevice} begin
        Int(dev.recommendedMaxWorkingSetSize)
    end::Int
end

"""
    total_memory(dev=device())

Return Metal's recommended maximum working set size for `dev`.
"""
total_memory(dev::MTLDevice=device()) = working_set_size(dev)

"""
    free_memory(dev=device())

Return the remaining bytes in Metal's recommended working set for `dev`.
"""
function free_memory(dev::MTLDevice=device())
    total = total_memory(dev)
    allocated = Int(dev.currentAllocatedSize)
    return max(total - allocated, 0)
end

# Per-device bookkeeping for the early-GC rate limiter (see `maybe_collect`). These are
# heuristic stats only, so racy updates from concurrent tasks are harmless (and GC itself
# is globally serialized by Julia anyway).
mutable struct MemoryPressureStats
    Base.@atomic last_time::Float64     # wall-clock time of the last GC we triggered
    Base.@atomic last_gc_time::Float64  # exponentially-smoothed duration of those GCs
    Base.@atomic last_freed::Int        # bytes reclaimed by the last GC (see caveat in `maybe_collect`)
end

MemoryPressureStats() = MemoryPressureStats(0.0, 0.0, 0)

const _memory_pressure_stats = Dict{UInt,MemoryPressureStats}()
const memory_pressure_stats_lock = ReentrantLock()

function memory_pressure_stats(dev::MTLDevice)
    key = UInt(pointer(dev))
    Base.@lock memory_pressure_stats_lock begin
        get!(_memory_pressure_stats, key) do
            MemoryPressureStats()
        end
    end::MemoryPressureStats
end

memory_pressure_device(dev::MTLDevice) = dev
memory_pressure_device(heap::MTLHeap) = heap.device

"""
    maybe_collect(dev=device(); will_block=false)

Run a garbage collection if `dev` is under memory pressure.

`MtlArray` buffers are allocated by Metal, not by Julia, so Julia's GC has no insight into
how much GPU/unified memory is outstanding and won't collect until its own (CPU-heap-based)
heuristics fire — typically long after the GPU is full. On unified-memory hardware that
means the system pages out and freezes instead of returning an out-of-memory error we could
react to (issue #524). To avoid that we proactively collect here, from the allocation and
synchronization paths, once usage gets high.

Pressure is read straight from Metal's own counters (`currentAllocatedSize` vs.
`recommendedMaxWorkingSetSize`) rather than a tally we keep ourselves: it is the ground
truth, includes Metal's internal overhead, and cannot drift out of sync with reality.

Pass `will_block=true` on synchronization paths: we are about to wait for the GPU regardless,
so a collection pause is comparatively cheap there and we lower the threshold to take it.
"""
function maybe_collect(dev::Union{MTLDevice,MTLHeap}=device(); will_block::Bool=false)
    dev = memory_pressure_device(dev)
    working_set = working_set_size(dev)
    # some (e.g. paravirtual) devices don't report a working set; we have nothing to gauge
    # pressure against, so leave collection to Julia's own heuristics.
    working_set == 0 && return

    # fraction of the recommended working set currently allocated on the device.
    allocated = Int(dev.currentAllocatedSize)
    pressure = allocated / working_set
    # only bother once we're actually filling up. when we're about to block anyway, lower
    # the bar: the GC pause hides behind a wait we were going to perform regardless.
    min_pressure = will_block ? 0.50 : 0.75
    pressure < min_pressure && return

    # we're under pressure — but collecting on every allocation would thrash, so rate-limit
    # ourselves to spending at most a small fraction of wall-clock time in GC.
    stats = memory_pressure_stats(dev)
    current_time = time()
    elapsed = current_time - stats.last_time
    gc_rate = elapsed > 0 ? stats.last_gc_time / elapsed : Inf

    # tolerate 5% of time in GC, relaxed when a collection is likely to pay off or is urgent:
    max_gc_rate = 0.05
    ## ...the previous collection reclaimed a meaningful chunk, so another should too.
    #  NOTE: on Metal `last_freed` is usually ~0, because buffers are released by MtlArray
    #  finalizers that run *after* `GC.gc` returns, so the post-GC reading below misses them.
    #  this multiplier is therefore largely inactive today; the ones below do the real work.
    if stats.last_freed > 0.1 * working_set
        max_gc_rate *= 2
    end
    ## ...we're about to block, so we can afford to collect more eagerly.
    if will_block
        max_gc_rate *= 2
    end
    ## ...we're genuinely running low; escalate further as pressure climbs.
    if pressure > 0.90
        max_gc_rate *= 2
    end
    if pressure > 0.95
        max_gc_rate *= 2
    end
    gc_rate > max_gc_rate && return

    Base.@atomic stats.last_time = current_time

    # an incremental collection suffices for the short-lived temporaries that dominate GPU
    # pressure (e.g. fused-broadcast results); the full-GC fallback for an actual allocation
    # failure lives in the retry path (`alloc_buffer_with_retry`).
    pre_allocated = allocated
    gc_time = Base.@elapsed GC.gc(false)
    post_allocated = Int(dev.currentAllocatedSize)

    # refresh the rate-limiter stats; smooth the duration so a single slow (or fast) GC
    # doesn't swing how eager we are next time.
    Base.@atomic stats.last_freed = max(pre_allocated - post_allocated, 0)
    Base.@atomic stats.last_gc_time = 0.75 * stats.last_gc_time + 0.25 * gc_time

    return
end
