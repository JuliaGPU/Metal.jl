using Metal, GPUArrays, LinearAlgebra, Printf#, AppleAccelerate

testing = (@isdefined TESTING) && TESTING

@static if !testing
    using Plots
    using Plots.Measures
end

Ts=[
    (Int8, Float16),
    (Int8, Float32),
    (Int16, Float32),
    (Float16, Float16),
    (Float16, Float32),
    (Float32, Float32),
]
DEFAULT_NS = [50, 64, 100, 128, 250, 256, 500, 512, 1000, 1024, 1500, 2000, 2048, 2500, 3000, 4000, 4096, 5000, 6000, 6144, 8000, 8192]

n_gpu_cores = Metal.num_gpu_cores()

PLOT_TITLE = "Matmul peakflops for $(device().name) ($n_gpu_cores GPU cores)"

function cpupeakflops(; n::Integer=4096,
                        n_batch::Integer=1,
                        inT::DataType=Float32,
                        outT::DataType=inT,
                        ntrials::Integer=4,
                        verify=true)
    t = Base.zeros(Float64, ntrials)
    n_batch == 1 || @warn "n_batch > 1 not supported for `mul!`, running with n_batch=1"
    n_batch = 1
    shape = (n, n)
    for i=1:ntrials
        c = zeros(outT, shape...)
        a = ones(inT, shape...)
        b = ones(inT, shape...)
        t[i] = @elapsed mul!(c, a, b)
        verify && @assert only(unique(Array(c))) == n
    end

    return n_batch*2*Float64(n)^3 / minimum(t)
end
function _peakflops(f, n, n_batch, inT, outT, ntrials; verify=true)
    t = Base.zeros(Float64, ntrials)
    shape = n_batch == 1 ? (n, n) : (n, n, n_batch)
    for i=1:ntrials
        c = mtl(zeros(outT, shape...))
        a = mtl(ones(inT, shape...))
        b = mtl(ones(inT, shape...))
        t[i] = @elapsed Metal.@sync f(c, a, b)
        verify && @assert only(unique(Array(c))) == n
    end

    return n_batch*2*Float64(n)^3 / minimum(t)
end
function gpuarrpeakflops(; n::Integer=4096,
                           n_batch::Integer=1,
                           inT::DataType=Float32,
                           outT::DataType=inT,
                           ntrials::Integer=3,
                           verify=true)
    n_batch == 1 || @warn "n_batch > 1 not supported for `GPUArrays.generic_matmatmul!`, running with n_batch=1"
    _peakflops(n, 1, inT, outT, ntrials; verify) do c, a, b
        GPUArrays.generic_matmatmul!(c, LinearAlgebra.wrap(a, 'N'), LinearAlgebra.wrap(b, 'N'), 1, 0)
    end
end
function defaultpeakflops(; n::Integer=4096,
                           n_batch::Integer=1,
                           inT::DataType=Float32,
                           outT::DataType=inT,
                           ntrials::Integer=3,
                           verify=true)
    _peakflops(n, 1, inT, outT, ntrials; verify) do c, a, b
        LinearAlgebra.generic_matmatmul!(c, 'N', 'N', a, b, 1, 0)
    end
end
function mpspeakflops(; n::Integer=4096,
                        n_batch::Integer=1,
                        inT::DataType=Float32,
                        outT::DataType=inT,
                        ntrials::Integer=3,
                        verify=true)
    _peakflops(MPS.matmul!, n, n_batch, inT, outT, ntrials; verify)
end
function graphpeakflops(; n::Integer=4096,
                          n_batch::Integer=1,
                          inT::DataType=Float32,
                          outT::DataType=inT,
                          ntrials::Integer=3,
                          verify=true)
    _peakflops(MPSGraphs.graph_matmul!, n, n_batch, inT, outT, ntrials; verify)
end
function anepeakflops(; kwargs...)
    # VERY HACKY
    newDesc = MPSGraphs.MPSGraphCompilationDescriptor()
    # Use optimization level 0 to avoid operations being moved to the neural engine
    newDesc.optimizationLevel = MPSGraphs.MPSGraphOptimizationLevel1

    oldDesc = MPSGraphs._default_exec_desc[].compilationDescriptor

    MPSGraphs._default_exec_desc[].compilationDescriptor = newDesc
    res = graphpeakflops(; kwargs...)
    MPSGraphs._default_exec_desc[].compilationDescriptor = oldDesc

    return res
end

function compare(Ns, Fs, inT, outT=inT; n_batch=1, ntrials)
    results = Dict()

    newFs = if (outT == Float16 || (outT == Float32 && inT == Float16))
        Fs
    else
        filter(x -> !occursin("ANE", x[2]),Fs)
    end

    for (_, info_str) in newFs
        results[info_str] = Float64[]
    end

    prefixstr = "\33[2K\r($inT, $outT) "
    @time "$((inT, outT))" begin
        for n in Ns
            verify = (n < maxintfloat(outT) && (inT != Float16 || (n < maxintfloat(inT))))
            n_str = "$n: "
            for (f, info_str) in newFs
                print(prefixstr, n_str, info_str)
                push!(results[info_str], f(; inT, outT, n, n_batch, ntrials, verify))
                GC.gc()
            end
        end
        print("\33[2K\r")
    end
    return results
end

DEFAULT_FS = [
    (mpspeakflops, "MPS"),
    (graphpeakflops, "MPSGraph"),
    (defaultpeakflops, "Default"),
    # (anepeakflops, "MPSGraph (ANE)"),
    # (gpuarrpeakflops, "GPUArrays"),
    # (cpupeakflops, "CPU (AppleAccelerate)"), # Uncomment to test CPU performance
]

function runcomparison(; Ns=DEFAULT_NS, Fs=DEFAULT_FS, n_batch=1, ntrials=5)
    res = Dict()
    for (inT, outT) in Ts
        res[(inT,outT)] = (n_batch, Ns, compare(Ns, Fs, inT, outT; n_batch, ntrials))
    end
    return res
end

function plot_results(res, Fs=DEFAULT_FS; outpath=nothing, outtype="svg", plt_title=PLOT_TITLE)
    Fs = get.(Fs, 2, "You shouldn't be reading this")
    ylim_upper = 9e12
    resplts = []

    n_batches = []

    for (inT, outT) in Ts
        n_batch, Ns, tmpres = res[(inT,outT)]

        plt = plot(xlabel="N, n_batch=$(n_batch)", legendtitle="($inT, $outT)")
        for info_str in Fs
            haskey(tmpres, info_str) || continue

            flops = tmpres[info_str]
            peakf = @sprintf("%.3e", maximum(flops))
            if maximum(flops) > ylim_upper
                ylim_upper = maximum(flops) * 1.02
            end
            plot!(plt, Ns, tmpres[info_str]; linewidth=1.5, label="$(peakf) peak: $info_str", α=0.8)
        end
        push!(resplts, plt)
        push!(n_batches, n_batch)
    end

    finalplot = plot(resplts...; layout=(2,3),
                     ylim=(0,ylim_upper),
                     plot_title=plt_title,
                     tickfonthalign=:left,
                     bottommargin=15pt,
                     size=(2000,1200))
    if !isnothing(outpath)
        savefig(plot(finalplot, dpi=500), joinpath(outpath, "bench_all_$(first(n_batches)).$outtype"))
    end
    return finalplot
end

if testing
    runcomparison(Ns=[50, 64, 100, 128, 250, 256, 500, 512])
elseif abspath(PROGRAM_FILE) == @__FILE__
    res = runcomparison()
    plot_results(res; outpath=".")
end
