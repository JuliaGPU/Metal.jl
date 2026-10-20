# benchmark suite execution and codespeed submission

using Metal

using BenchmarkTools

using StableRNGs
rng = StableRNG(123)

# print system information
@info "System information:\n" * sprint(io->Metal.versioninfo(io))

# convenience macro to create a benchmark that requires synchronizing the GPU
macro async_benchmarkable(ex...)
    quote
        @benchmarkable Metal.@sync $(ex...)
    end
end

# before anything else, run latency benchmarks. these spawn subprocesses, so we don't want
# to do so after regular benchmarks have caused the memory allocator to reserve memory.
@info "Running latency benchmarks"
latency_results = include("latency.jl")

SUITE = BenchmarkGroup()

include("metal.jl")
include("kernel.jl")
include("array.jl")

@info "Preparing main benchmarks"
warmup(SUITE; verbose=false)
tune!(SUITE)

# reclaim memory that might have been used by the tuning process
GC.gc(true)
GC.gc(true)
GC.gc(true)

# benchmark groups that aren't part of the suite
addgroup!(SUITE, "integration")

@info "Running main benchmarks"
results = run(SUITE, verbose=true)

# integration tests (that do nasty things, so need to be run last)
@info "Running integration benchmarks"
integration_results = BenchmarkGroup()
# integration_results["volumerhs"] = include("volumerhs.jl")
integration_results["byval"] = include("byval.jl")
integration_results["metaldevrt"] = include("metaldevrt.jl")

results["latency"] = latency_results
results["integration"] = integration_results

# write out the results
# We report the minimum rather than the median: at the sub-microsecond scale of many
# of these benchmarks, OS scheduler jitter dominates the median and produces 5-15%
# trial-to-trial variance, while the minimum reflects the un-preempted code path
# and is stable to <1% across trials. Real regressions still show up in the minimum.
result_file = length(ARGS) >= 1 ? ARGS[1] : "benchmarkresults.json"
BenchmarkTools.save(result_file, minimum(results))

# The suite keeps less than 100 MiB of arrays alive, so device memory that is still in use
# after collecting garbage was leaked. Leaks put Metal.jl under memory pressure, making
# allocations and synchronizations trigger collections that inflate unrelated results,
# so fail instead of publishing them.
GC.gc(true)
Metal.device_synchronize()  # releases collected buffers with the Metal 4 command API
let dev = Metal.device(), allocated = Int(dev.currentAllocatedSize)
    budget = Metal.working_set_size(dev) ÷ 8
    if budget > 0 && allocated > budget
        error("Benchmarks left $(Base.format_bytes(allocated)) of device memory allocated, " *
              "which indicates a memory leak; results are not representative.")
    end
end
