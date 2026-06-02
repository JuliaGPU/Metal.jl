# Benchmark the native :Julia GEMM against MPS and MPSGraph.
# Run: julia --project=. bin/gemm/benchmark.jl [sizes...]
using Metal, LinearAlgebra, Printf
using ScopedValues: with

function gflops(alg, C, A, B; iters=20)
    M, N = size(C); K = size(A, 2)
    flop = 2.0 * M * N * K
    with(Metal.matmul_alg => alg) do
        mul!(C, A, B)            # warmup / compile
        Metal.synchronize()
        best = Inf
        for _ in 1:iters
            t = @elapsed begin
                mul!(C, A, B)
                Metal.synchronize()
            end
            best = min(best, t)
        end
        flop / best / 1e9
    end
end

const ALGS = (:Julia, :MPS, :MPSGraph)

function bench(T, M, N, K)
    A = MtlArray(rand(T, M, K)); B = MtlArray(rand(T, K, N))
    C = MtlArray(zeros(T, M, N))
    res = map(ALGS) do alg
        try
            gflops(alg, C, A, B)
        catch
            NaN
        end
    end
    @printf("%-9s %5d x %5d x %5d | Julia %8.1f  MPS %8.1f  MPSGraph %8.1f GFLOP/s\n",
            string(T), M, N, K, res...)
    return res
end

sizes = isempty(ARGS) ? [256, 512, 1024, 2048, 4096] : parse.(Int, ARGS)
println("== square GEMM (GFLOP/s, higher is better) ==")
for T in (Float32, Float16)
    for n in sizes
        bench(T, n, n, n)
    end
    println()
end
