using Metal, GPUArrays, LinearAlgebra, Printf, AppleAccelerate
using ScopedValues: with
using Plots
using Plots.Measures
using BFloat16s

Ts=[(Int8, Float16), (Int8, Float32), (Int16, Float32),
    (Float16, Float16), (Float16, Float32), (Float32, Float32),
    (Float16, ComplexF16), (Float16, ComplexF32), (Float32, ComplexF32),
    (ComplexF16, ComplexF16), (ComplexF16, ComplexF32), (ComplexF32, ComplexF32),
    (BFloat16, BFloat16)
]

testing = get(ENV, "TESTING", "false") == "true"
DEFAULT_NS = if testing
    [50, 64, 100, 128, 250, 256, 500, 512]
else
    [50, 64, 100, 128, 250, 256, 500, 512, 1000, 1024, 1500, 2000, 2048, 2500, 3000, 4000, 4096, 5000, 6000, 6144, 8000, 8192]
end

n_gpu_cores = Metal.num_gpu_cores()

PLOT_TITLE = "Matmul peakflops for $(device().name) ($n_gpu_cores GPU cores)"

function cpupeakflops(; n::Integer=4096,
                        inT::DataType=Float32,
                        outT::DataType=inT,
                        ntrials::Integer=4,
                        verify=true)
    t = Base.zeros(Float64, ntrials)
    shape = (n, n)
    for i=1:ntrials
        c = zeros(outT, shape...)
        a = ones(inT, shape...)
        b = ones(inT, shape...)
        t[i] = @elapsed mul!(c, a, b)
        verify && @assert only(unique(Array(c))) == n
    end

    return 2*Float64(n)^3 / minimum(t)
end
function _peakflops(f, n, inT, outT, ntrials; verify=true)
    t = Base.zeros(Float64, ntrials)
    for i=1:ntrials
        c = mtl(zeros(outT, n, n))
        a = mtl(ones(inT, n, n))
        b = mtl(ones(inT, n, n))
        t[i] = @elapsed Metal.@sync f(c, a, b)
        verify && @assert only(unique(Array(c))) == n
    end

    return 2*Float64(n)^3 / minimum(t)
end
function gpupeakflops(alg)
    (;  n::Integer=4096,
        inT::DataType=Float32,
        outT::DataType=inT,
        ntrials::Integer=3,
        verify=true) -> _peakflops(n, inT, outT, ntrials; verify) do c, a, b
        with(() -> LinearAlgebra.generic_matmatmul!(c, 'N', 'N', a, b, 1, 0), Metal.matmul_alg => alg)
    end
end
function anepeakflops(; kwargs...)
    # VERY HACKY
    newDesc = MPSGraphs.MPSGraphCompilationDescriptor()
    # Use optimization level 0 to avoid operations being moved to the neural engine
    newDesc.optimizationLevel = MPSGraphs.MPSGraphOptimizationLevel1

    oldDesc = MPSGraphs._default_exec_desc[].compilationDescriptor

    MPSGraphs._default_exec_desc[].compilationDescriptor = newDesc
    res = gpupeakflops(:MPSGraph)(; kwargs...)
    MPSGraphs._default_exec_desc[].compilationDescriptor = oldDesc

    return res
end

function compare(Ns, Fs, inT, outT=inT; ntrials, verbose=!testing)
    results = Dict()

    newFs = let
        # Apple Neural Engine only used with some types
        _newFs = if (outT == Float16 || (outT == Float32 && inT == Float16))
            Fs
        else
            filter(x -> !occursin("ANE", x[2]), Fs)
        end

        # MPS doesn't support complex values
        if (outT <: Complex || inT <: Complex)
            filter(x -> x[2] != "MPS", _newFs)
        else
            _newFs
        end
    end

    for (_, info_str) in newFs
        results[info_str] = Float64[]
    end

    prefixstr = "\33[2K\r($inT, $outT) "
    @time "$((inT, outT))" begin
        for n in Ns
            verify = ((inT <: Integer ? typemax : maxintfloat)(real(inT)) > n < maxintfloat(real(outT)) && (inT != Float16 || (n < maxintfloat(real(inT)))))
            n_str = "$n: "
            for (f, info_str) in newFs
                verbose && print(prefixstr, n_str, info_str)
                push!(results[info_str], f(; inT, outT, n, ntrials, verify=(verify && (info_str != "MPS"))))
                GC.gc(false)
            end
        end
        verbose && print("\33[2K\r")
    end
    return results
end

DEFAULT_FS = [
    (gpupeakflops(:MPSGraph), "MPSGraph"),
    (gpupeakflops(:auto), "Default"),
    (gpupeakflops(:native), "Native"),
    (gpupeakflops(:GPUArrays), "GPUArrays"),
    (cpupeakflops, "CPU (AppleAccelerate)"),
    # (gpupeakflops(:MPS), "MPS"), # Run last to prevent different line colours
    # (anepeakflops, "MPSGraph (ANE)"), # Run last to prevent different line colours
]

function runcomparison(; Ns=DEFAULT_NS, Fs=DEFAULT_FS, ntrials=5, verbose=true)
    res = Dict()
    for (inT, outT) in Ts
        res[(inT,outT)] = (Ns, compare(Ns, Fs, inT, outT; ntrials, verbose))
    end
    return res
end

function plot_results(res, Fs=DEFAULT_FS; outpath=nothing, fileext="svg", plt_title=PLOT_TITLE, plot_width=3)
    Fs = get.(Fs, 2, "You shouldn't be reading this")
    ylim_upper = 9e12
    resplts = []

    for (inT, outT) in Ts
        Ns, tmpres = res[(inT,outT)]

        plt = plot(xlabel="N", legendtitle="($inT, $outT)")
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
    end

    layout = (cld(length(Ts), plot_width), plot_width)
    finalplot = plot(resplts...; layout,
                     ylim=(0,ylim_upper),
                     plot_title=plt_title,
                     tickfonthalign=:left,
                     bottommargin=15pt,
                     size=(500*layout[2],500*layout[1]))
    if !isnothing(outpath)
        savefig(plot(finalplot, dpi=500), joinpath(outpath, "bench_all.$fileext"))
    end
    return finalplot
end

res = runcomparison()
plot_results(res; outpath=testing ? nothing : ".")
