export alloc, free

using Printf

# allocation statistics

mutable struct AllocStats
    Base.@atomic alloc_count::Int
    Base.@atomic alloc_bytes::Int

    Base.@atomic free_count::Int
    Base.@atomic free_bytes::Int

    Base.@atomic total_time::Float64
end

AllocStats() = AllocStats(0, 0, 0, 0, 0.0)

Base.copy(alloc_stats::AllocStats) =
    AllocStats(alloc_stats.alloc_count, alloc_stats.alloc_bytes,
               alloc_stats.free_count, alloc_stats.free_bytes,
               alloc_stats.total_time)

Base.:(-)(a::AllocStats, b::AllocStats) = (;
    alloc_count = a.alloc_count - b.alloc_count,
    alloc_bytes = a.alloc_bytes - b.alloc_bytes,
    free_count  = a.free_count  - b.free_count,
    free_bytes  = a.free_bytes  - b.free_bytes,
    total_time  = a.total_time  - b.total_time)

const alloc_stats = AllocStats()


"""
    alloc(device, bytesize, [ptr=nothing];
          storage=Default, hazard_tracking=Default, cache_mode=Default)

Allocates a Metal buffer on `device` of`bytesize` bytes. If a CPU-pointer is passed as last
argument, then the buffer is initialized with the content of the memory starting at `ptr`,
otherwise it's zero-initialized.

! Note: You are responsible for freeing the returned buffer

The storage kwarg controls where the buffer is stored. Possible values are:
 - PrivateStorage : Residing on the device
 - SharedStorage  : Residing on the host
 - ManagedStorage : Keeps two copies of the buffer, on device and on host. Explicit calls must be
   given to syncronize the two
 - Memoryless : an iOS specific thing that won't work on Mac.

Note that `PrivateStorage` buffers can't be directly accessed from the CPU, therefore you cannot
use this option if you pass a ptr to initialize the memory.
"""
function alloc(dev::Union{MTLDevice,MTLHeap}, sz::Integer, args...; kwargs...)
    @signpost_event log=log_array() "Allocate" "Size=$(Base.format_bytes(sz))"

    time = Base.@elapsed begin
        buf = @autoreleasepool MTLBuffer(dev, sz, args...; kwargs...)
    end

    Base.@atomic alloc_stats.alloc_count + 1
    Base.@atomic alloc_stats.alloc_bytes + sz
    Base.@atomic alloc_stats.total_time + time

    return buf
end

"""
    free(buffer::MTLBuffer)

Frees the buffer if the handle is valid.
This does not protect against double-freeing of the same buffer!
"""
function free(buf::MTLBuffer)
    sz::Int = buf.length
    @signpost_event log=log_array() "Free" "Size=$(Base.format_bytes(sz))"

    time = Base.@elapsed begin
        @autoreleasepool unsafe=true release(buf)
    end

    Base.@atomic alloc_stats.free_count + 1
    Base.@atomic alloc_stats.free_bytes + sz
    Base.@atomic alloc_stats.total_time + time
    return
end


## utilities

"""
    @allocated

A macro to evaluate an expression, discarding the resulting value, instead returning the
total number of bytes allocated during evaluation of the expression.
"""
macro allocated(ex)
    quote
        let
            local f
            function f()
                b0 = alloc_stats.alloc_bytes[]
                $(esc(ex))
                alloc_stats.alloc_bytes[] - b0
            end
            f()
        end
    end
end

"""
    @time ex

Run expression `ex` and report on execution time and GPU/CPU memory behavior. The GPU is
synchronized right before and after executing `ex` to exclude any external effects.

"""
macro time(ex)
    quote
        local val, cpu_time,
            cpu_alloc_size, cpu_gc_time, cpu_mem_stats,
            gpu_alloc_size, gpu_mem_time, gpu_mem_stats = @timed $(esc(ex))

        local cpu_alloc_count = Base.gc_alloc_count(cpu_mem_stats)
        local gpu_alloc_count = gpu_mem_stats.alloc_count

        Printf.@printf("%10.6f seconds", cpu_time)
        for (typ, gctime, memtime, bytes, allocs) in
            (("CPU", cpu_gc_time, 0, cpu_alloc_size, cpu_alloc_count),
             ("GPU", 0, gpu_mem_time, gpu_alloc_size, gpu_alloc_count))
            if bytes != 0 || allocs != 0
                allocs, ma = Base.prettyprint_getunits(allocs, length(Base._cnt_units), Int64(1000))
                if ma == 1
                    Printf.@printf(" (%d%s %s allocation%s: ", allocs, Base._cnt_units[ma], typ, allocs==1 ? "" : "s")
                else
                    Printf.@printf(" (%.2f%s %s allocations: ", allocs, Base._cnt_units[ma], typ)
                end
                print(Base.format_bytes(bytes))
                if gctime > 0
                    Printf.@printf(", %.2f%% gc time", 100*gctime/cpu_time)
                end
                if memtime > 0
                    Printf.@printf(", %.2f%% memmgmt time", 100*memtime/cpu_time)
                end
                print(")")
            else
                if gctime > 0
                    Printf.@printf(", %.2f%% %s gc time", 100*gctime/cpu_time, typ)
                end
                if memtime > 0
                    Printf.@printf(", %.2f%% %s memmgmt time", 100*memtime/cpu_time, typ)
                end
            end
        end
        println()

        val
    end
end

macro timed(ex)
    quote
        while false; end # compiler heuristic: compile this block (alter this if the heuristic changes)

        # coarse synchronization to exclude effects from previously-executed code
        synchronize()

        local gpu_mem_stats0 = copy(alloc_stats)
        local cpu_mem_stats0 = Base.gc_num()
        local cpu_time0 = time_ns()

        # fine-grained synchronization of the code under analysis
        local val = @sync $(esc(ex))

        local cpu_time1 = time_ns()
        local cpu_mem_stats1 = Base.gc_num()
        local gpu_mem_stats1 = copy(alloc_stats)

        local cpu_time = (cpu_time1 - cpu_time0) / 1e9

        local cpu_mem_stats = Base.GC_Diff(cpu_mem_stats1, cpu_mem_stats0)
        local gpu_mem_stats = gpu_mem_stats1 - gpu_mem_stats0

        (value=val, time=cpu_time,
         cpu_bytes=cpu_mem_stats.allocd, cpu_gctime=cpu_mem_stats.total_time / 1e9, cpu_gcstats=cpu_mem_stats,
         gpu_bytes=gpu_mem_stats.alloc_bytes, gpu_memtime=gpu_mem_stats.total_time, gpu_memstats=gpu_mem_stats)
    end
end
