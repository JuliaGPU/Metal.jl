# benchmark suite execution and codespeed submission

using Metal

using BenchmarkTools

using StableRNGs
rng = StableRNG(123)

# to find untuned benchmarks
BenchmarkTools.DEFAULT_PARAMETERS.evals = 0

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

# NOTE: don't use spaces in benchmark names (tobami/codespeed#256)

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

println(results)


## comparison

# write out the results
BenchmarkTools.save("benchmarkresults.json", median(results))

# compare against previous results
# TODO: store these results so that we can compare when benchmarking PRs
reference_path = joinpath(@__DIR__, "reference.json")
if ispath(reference_path)
    reference = BenchmarkTools.load(reference_path)[1]
    comparison = judge(minimum(results), minimum(reference))

    println("Improvements:")
    println(improvements(comparison))

    println("Regressions:")
    println(regressions(comparison))
end
