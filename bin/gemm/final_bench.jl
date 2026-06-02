# Comprehensive native-vs-vendor benchmark across shapes and transpose.
using Metal, LinearAlgebra, Printf
using ScopedValues: with

op(M, t) = t == 'N' ? M : transpose(M)

function gflops(alg, C, opA, opB; iters=20)
    M, N = size(C); K = size(opA, 2)
    with(Metal.matmul_alg => alg) do
        mul!(C, opA, opB); Metal.synchronize()
        best = Inf
        for _ in 1:iters
            t = @elapsed (mul!(C, opA, opB); Metal.synchronize())
            best = min(best, t)
        end
        2.0 * M * N * K / best / 1e9
    end
end

function row(T, M, N, K, tA, tB)
    A = MtlArray(rand(T, tA == 'N' ? (M, K) : (K, M)))
    B = MtlArray(rand(T, tB == 'N' ? (K, N) : (N, K)))
    C = MtlArray(zeros(T, M, N))
    oa = op(A, tA); ob = op(B, tB)
    r = map((:native, :MPS, :MPSGraph)) do alg
        try gflops(alg, C, oa, ob) catch; NaN end
    end
    @printf("%-9s %c%c %5dx%5dx%5d | Julia %7.1f  MPS %7.1f  MPSGraph %7.1f\n",
            string(T), tA, tB, M, N, K, r...)
end

println("== square, transpose variants (GFLOP/s) ==")
for (tA, tB) in (('N','N'), ('N','T'), ('T','N'), ('T','T'))
    row(Float32, 2048, 2048, 2048, tA, tB)
end
println("\n== shapes (F32, NN) ==")
row(Float32, 4096, 4096, 4096, 'N', 'N')
row(Float32, 1024, 1024, 1024, 'N', 'N')
row(Float32, 4096, 4096, 256, 'N', 'N')   # wide/short K
row(Float32, 256, 256, 8192, 'N', 'N')    # tall K
row(Float32, 8192, 512, 512, 'N', 'N')    # skinny
println("\n== Float16 ==")
row(Float16, 2048, 2048, 2048, 'N', 'N')
row(Float16, 4096, 4096, 4096, 'N', 'N')
