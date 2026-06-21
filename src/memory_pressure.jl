export free_memory, total_memory

"""
    working_set_size(dev=device())

Return Metal's recommended maximum working set size for `dev`.
"""
function working_set_size(dev::MTLDevice=device())
    key = UInt(pointer(dev))
    @memoize key::UInt begin
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

mutable struct MemoryPressureStats
    Base.@atomic last_time::Float64
    Base.@atomic last_gc_time::Float64
    Base.@atomic last_freed::Int
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

function maybe_collect(dev::Union{MTLDevice,MTLHeap}=device(); will_block::Bool=false)
    dev = memory_pressure_device(dev)
    working_set = working_set_size(dev)
    working_set == 0 && return

    allocated = Int(dev.currentAllocatedSize)
    pressure = allocated / working_set
    min_pressure = will_block ? 0.50 : 0.75
    pressure < min_pressure && return

    stats = memory_pressure_stats(dev)
    current_time = time()

    elapsed = current_time - stats.last_time
    gc_rate = elapsed > 0 ? stats.last_gc_time / elapsed : Inf

    max_gc_rate = 0.05
    if stats.last_freed > 0.1 * working_set
        max_gc_rate *= 2
    end
    if will_block
        max_gc_rate *= 2
    end
    if pressure > 0.90
        max_gc_rate *= 2
    end
    if pressure > 0.95
        max_gc_rate *= 2
    end
    gc_rate > max_gc_rate && return

    Base.@atomic stats.last_time = current_time

    pre_allocated = allocated
    gc_time = Base.@elapsed GC.gc(false)
    post_allocated = Int(dev.currentAllocatedSize)

    Base.@atomic stats.last_freed = max(pre_allocated - post_allocated, 0)
    Base.@atomic stats.last_gc_time = 0.75 * stats.last_gc_time + 0.25 * gc_time

    return
end
