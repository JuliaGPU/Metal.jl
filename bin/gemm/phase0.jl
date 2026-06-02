# Phase 0: validate simdgroup_matrix primitives + transpose flag semantics.
# Run: julia --project=. bin/gemm/phase0.jl
using Metal, LinearAlgebra, Printf

const SG = Metal  # intrinsics live in Metal

println("== transpose flag semantics (8x8 load/store from device) ==")
# Load A with transpose flag t, store to B with transpose flag true (natural col-major).
for tload in (true, false)
    function k(a, b, ::Val{t}) where {t}
        m = SG.simdgroup_load(a, (1, 1), Val(t))
        SG.simdgroup_store(m, b, (1, 1), Val(true))
        return
    end
    a = MtlArray(rand(Float32, 8, 8))
    b = MtlArray(zeros(Float32, 8, 8))
    @metal threads = 32 k(a, b, Val(tload))
    A = Array(a); B = Array(b)
    natural = isapprox(B, A)
    transposed = isapprox(B, permutedims(A))
    @printf("  load transpose=%-5s -> store natural: matches A=%s  A'=%s\n",
            tload, natural, transposed)
end

println("\n== direct-from-device tiled MMA, NN, exact 8-multiples ==")
# Each simdgroup (1 per threadgroup) computes one 8x8 block of C = A*B.
function gemm_nn_simple!(C, A, B, M, N, K)
    bi = SG.threadgroup_position_in_grid().x   # block row (1-based)
    bj = SG.threadgroup_position_in_grid().y   # block col
    row = (bi - 1) * 8 + 1
    col = (bj - 1) * 8 + 1
    acc = ntuple(_ -> VecElement{Float32}(0f0), Val(64))
    k = 1
    while k <= K
        a = SG.simdgroup_load(A, (row, k), Val(true))   # A[row:row+7, k:k+7]
        b = SG.simdgroup_load(B, (k, col), Val(true))   # B[k:k+7, col:col+7]
        acc = SG.simdgroup_multiply_accumulate(a, b, acc)
        k += 8
    end
    SG.simdgroup_store(acc, C, (row, col), Val(true))
    return
end

for (M, N, K) in ((8, 8, 8), (64, 64, 64), (128, 256, 64), (32, 32, 512))
    A = MtlArray(rand(Float32, M, K))
    B = MtlArray(rand(Float32, K, N))
    C = MtlArray(zeros(Float32, M, N))
    @metal threads = 32 groups = (cld(M, 8), cld(N, 8)) gemm_nn_simple!(C, A, B, M, N, K)
    ref = Array(A) * Array(B)
    err = maximum(abs.(Array(C) .- ref)) / max(1f0, maximum(abs.(ref)))
    @printf("  %4dx%4dx%4d  rel.err = %.2e\n", M, N, K, err)
end

println("\n== transpose handling: load A as A' (tA='T') via transpose=false ==")
# To compute A'*B where A is stored K x M (so op gives M x K), we want the
# simdgroup A-tile to be A'[row:row+7, k:k+7] = A[k:k+7, row:row+7]'.
# Loading column-major A with transpose=false yields the transpose of the block.
function gemm_tn!(C, A, B, M, N, K)
    bi = SG.threadgroup_position_in_grid().x
    bj = SG.threadgroup_position_in_grid().y
    row = (bi - 1) * 8 + 1
    col = (bj - 1) * 8 + 1
    acc = ntuple(_ -> VecElement{Float32}(0f0), Val(64))
    k = 1
    while k <= K
        # A is K x M; A'[row:row+7, k:k+7] needs A block at (k_in_K, row_in_M)
        a = SG.simdgroup_load(A, (k, row), Val(false))  # transpose the (K-row, M-col) block
        b = SG.simdgroup_load(B, (k, col), Val(true))
        acc = SG.simdgroup_multiply_accumulate(a, b, acc)
        k += 8
    end
    SG.simdgroup_store(acc, C, (row, col), Val(true))
    return
end

for (M, N, K) in ((64, 64, 64), (128, 64, 256))
    A = MtlArray(rand(Float32, K, M))   # stored transposed
    B = MtlArray(rand(Float32, K, N))
    C = MtlArray(zeros(Float32, M, N))
    @metal threads = 32 groups = (cld(M, 8), cld(N, 8)) gemm_tn!(C, A, B, M, N, K)
    ref = Array(A)' * Array(B)
    err = maximum(abs.(Array(C) .- ref)) / max(1f0, maximum(abs.(ref)))
    @printf("  TN %4dx%4dx%4d  rel.err = %.2e\n", M, N, K, err)
end

println("\ndone")
