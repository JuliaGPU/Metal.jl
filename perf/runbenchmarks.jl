# benchmark suite execution and codespeed submission

using Metal

using BenchmarkTools, Statistics, JSON

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

@info "Running main benchmarks"
results = run(SUITE, verbose=true)

# integration tests (that do nasty things, so need to be run last)
@info "Running integration benchmarks"
integration_results = BenchmarkGroup()
# integration_results["volumerhs"] = include("volumerhs.jl")
integration_results["byval"] = include("byval.jl")
integration_results["metaldevrt"] = include("metaldevrt.jl")

# the first part of every name is its category in the benchmark history: everything
# compiled (performance), fresh processes (latency), or larger codes (applications).
# see perf/benchmark-config.json
results = BenchmarkGroup("performance" => results, "latency" => latency_results,
                         "applications" => integration_results)

# write out the results
# We report the minimum rather than the median: at the sub-microsecond scale of many
# of these benchmarks, OS scheduler jitter dominates the median and produces 5-15%
# trial-to-trial variance, while the minimum reflects the un-preempted code path
# and is stable to <1% across trials. Real regressions still show up in the minimum.
result_file = length(ARGS) >= 1 ? ARGS[1] : "benchmarkresults.json"
BenchmarkTools.save(result_file, minimum(results))

# every statistic of every benchmark, and the environment they were measured in, for the
# benchmark history at https://juliagpu.org/perf/. times are in nanoseconds.
function export_results(file, results)
    benchmarks = Dict{String,Any}()
    for (keys, trial) in BenchmarkTools.leaves(results)
        times = trial.times
        benchmarks[join(keys, "/")] = Dict(
            "min" => minimum(times), "p25" => quantile(times, 0.25),
            "median" => median(times), "p75" => quantile(times, 0.75),
            "mean" => mean(times), "max" => maximum(times),
            "std" => length(times) > 1 ? std(times) : nothing,
            "gctime" => median(trial.gctimes),
            "memory" => trial.memory, "allocs" => trial.allocs,
            "samples" => length(times), "evals" => trial.params.evals)
    end
    # the versions of every package loaded, to explain changes the commit itself does not
    packages = Dict(id.name => string(pkgversion(mod)) for (id, mod) in Base.loaded_modules
                    if pkgversion(mod) !== nothing)
    dev = Metal.device()
    env = Dict(
        "julia" => string(VERSION),
        "gpu" => String(dev.name),
        "os" => "macOS $(Metal.macos_version())",
        "cpu" => Sys.cpu_info()[1].model,
        "threads" => Threads.nthreads(),
        "agent" => get(ENV, "BUILDKITE_AGENT_NAME", nothing),
        "package" => string(pkgversion(Metal)),
        "packages" => packages)
    open(file, "w") do io
        JSON.print(io, Dict("version" => 2, "env" => env, "benchmarks" => benchmarks))
    end
end
export_results(joinpath(dirname(result_file), "benchmarks.json"), results)

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
