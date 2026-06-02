# Standalone tuning harness: sweep tile configs / epilogue strategies for the core
# NN, alpha=1, beta=0, Float32 case (full tiles only) to find perf levers.
# Run: julia --project=. bin/gemm/tune.jl
using Metal, LinearAlgebra, Printf

@inline _afrag(As, sm0, ks, ::Val{TM}) where {TM} =
    ntuple(ti -> Metal.simdgroup_load(As, (sm0 + (ti - 1) * 8 + 1, ks + 1)), Val(TM))
@inline _bfrag(Bs, sn0, ks, ::Val{TN}) where {TN} =
    ntuple(tj -> Metal.simdgroup_load(Bs, (ks + 1, sn0 + (tj - 1) * 8 + 1)), Val(TN))
@inline _mma(acc, af, bf, ::Val{TM}, ::Val{TN}) where {TM, TN} =
    ntuple(Val(TM * TN)) do idx
        ti = (idx - 1) % TM + 1; tj = (idx - 1) ÷ TM + 1
        Metal.simdgroup_multiply_accumulate(af[ti], bf[tj], acc[idx])
    end
# compile-time unrolled fold over KB ks-steps (acc threaded as arg -> no spill)
@inline _foldk(acc, As, Bs, sm0, sn0, ::Val{TM}, ::Val{TN}, k, ::Val{0}) where {TM, TN} = acc
@inline function _foldk(acc, As, Bs, sm0, sn0, vTM::Val{TM}, vTN::Val{TN}, k, ::Val{R}) where {TM, TN, R}
    af = _afrag(As, sm0, k, vTM)
    bf = _bfrag(Bs, sn0, k, vTN)
    acc2 = _mma(acc, af, bf, vTM, vTN)
    _foldk(acc2, As, Bs, sm0, sn0, vTM, vTN, k + 8, Val(R - 1))
end

@inline function _store_direct(C, acc, r0, c0, ::Val{TM}, ::Val{TN}) where {TM, TN}
    ntuple(Val(TM * TN)) do idx
        ti = (idx - 1) % TM; tj = (idx - 1) ÷ TM
        Metal.simdgroup_store(acc[idx], C, (r0 + ti * 8 + 1, c0 + tj * 8 + 1))
        nothing
    end
    return
end

# direct-store kernel (no Cs), full tiles only, alpha=1 beta=0 NN
function knn!(C, A, B, M, N, K, ::Val{WM}, ::Val{WN}, ::Val{TM}, ::Val{TN}, ::Val{KB}) where {WM, WN, TM, TN, KB}
    SGM = 8 * TM; SGN = 8 * TN
    BM = WM * SGM; BN = WN * SGN; BK = 8 * KB
    nthreads = WM * WN * 32
    t0 = Int(Metal.thread_index_in_threadgroup()) - 1
    s0 = Int(Metal.simdgroup_index_in_threadgroup()) - 1
    sm0 = (s0 % WM) * SGM; sn0 = (s0 ÷ WM) * SGN
    bm0 = (Int(Metal.threadgroup_position_in_grid().x) - 1) * BM
    bn0 = (Int(Metal.threadgroup_position_in_grid().y) - 1) * BN
    As = MtlThreadGroupArray(Float32, (BM, BK))
    Bs = MtlThreadGroupArray(Float32, (BK, BN))
    acc = ntuple(_ -> ntuple(_ -> VecElement{Float32}(0.0f0), Val(64)), Val(TM * TN))
    kt0 = 0
    while kt0 < K
        i = t0; nelA = BM * BK
        while i < nelA
            m = i % BM; k = i ÷ BM
            @inbounds As[m + 1, k + 1] = A[bm0 + m + 1, kt0 + k + 1]
            i += nthreads
        end
        i = t0; nelB = BK * BN
        while i < nelB
            k = i % BK; n = i ÷ BK
            @inbounds Bs[k + 1, n + 1] = B[kt0 + k + 1, bn0 + n + 1]
            i += nthreads
        end
        Metal.threadgroup_barrier(Metal.MemoryFlagThreadGroup)
        acc = _foldk(acc, As, Bs, sm0, sn0, Val(TM), Val(TN), 0, Val(KB))
        Metal.threadgroup_barrier(Metal.MemoryFlagThreadGroup)
        kt0 += BK
    end
    _store_direct(C, acc, bm0 + sm0, bn0 + sn0, Val(TM), Val(TN))
    return
end

# elementwise scale of a simdgroup matrix held as NTuple{64,VecElement{Float32}}
@inline _combine(acc, cb, a, b) = ntuple(i -> VecElement{Float32}(a * acc[i].value + b * cb[i].value), Val(64))
@inline _scale(acc, a) = ntuple(i -> VecElement{Float32}(a * acc[i].value), Val(64))

# direct elementwise alpha/beta store of one full 8x8 fragment
@inline function _store_frag!(C, accidx, gr, gc, alpha, beta)
    if iszero(beta)
        Metal.simdgroup_store(_scale(accidx, alpha), C, (gr + 1, gc + 1))
    else
        cb = Metal.simdgroup_load(C, (gr + 1, gc + 1))
        Metal.simdgroup_store(_combine(accidx, cb, alpha, beta), C, (gr + 1, gc + 1))
    end
    return
end

# epilogue as a top-level fn so the unrolled ntuple doesn't capture the reassigned acc.
# EDGE=false: all fragments are fully in-bounds -> pure direct stores (no scratch).
@inline function _epi!(C, scratch, acc, bm0, sm0, bn0, sn0, M, N, alpha, beta, lane, sc0,
                       ::Val{TM}, ::Val{TN}, ::Val{EDGE}) where {TM, TN, EDGE}
    ntuple(Val(TM * TN)) do idx
        ti = (idx - 1) % TM; tj = (idx - 1) ÷ TM
        gr = bm0 + sm0 + ti * 8; gc = bn0 + sn0 + tj * 8
        if !EDGE || (gr + 8 <= M && gc + 8 <= N)
            _store_frag!(C, acc[idx], gr, gc, alpha, beta)
        else
            Metal.simdgroup_store(acc[idx], scratch, (1, sc0 + 1))
            Metal.simdgroup_barrier(Metal.MemoryFlagThreadGroup)
            e = lane
            while e < 64
                r = e % 8; c = e ÷ 8; gi = gr + r; gj = gc + c
                if gi < M && gj < N
                    sv = @inbounds scratch[r + 1, sc0 + c + 1]
                    @inbounds C[gi + 1, gj + 1] = iszero(beta) ? alpha * sv : alpha * sv + beta * C[gi + 1, gj + 1]
                end
                e += 32
            end
        end
        nothing
    end
    return
end

# full kernel with elementwise alpha/beta epilogue + bounded edges via small scratch
function kab!(C, A, B, alpha, beta, M, N, K, ::Val{WM}, ::Val{WN}, ::Val{TM}, ::Val{TN}, ::Val{KB}, ::Val{EDGE}) where {WM, WN, TM, TN, KB, EDGE}
    SGM = 8 * TM; SGN = 8 * TN
    BM = WM * SGM; BN = WN * SGN; BK = 8 * KB
    nthreads = WM * WN * 32
    t0 = Int(Metal.thread_index_in_threadgroup()) - 1
    s0 = Int(Metal.simdgroup_index_in_threadgroup()) - 1
    sm0 = (s0 % WM) * SGM; sn0 = (s0 ÷ WM) * SGN
    bm0 = (Int(Metal.threadgroup_position_in_grid().x) - 1) * BM
    bn0 = (Int(Metal.threadgroup_position_in_grid().y) - 1) * BN
    As = MtlThreadGroupArray(Float32, (BM, BK))
    Bs = MtlThreadGroupArray(Float32, (BK, BN))
    scratch = MtlThreadGroupArray(Float32, (8, EDGE ? 8 * WM * WN : 0))   # per-simdgroup 8x8
    acc = ntuple(_ -> ntuple(_ -> VecElement{Float32}(0.0f0), Val(64)), Val(TM * TN))
    kt0 = 0
    while kt0 < K
        i = t0; nelA = BM * BK
        while i < nelA
            m = i % BM; k = i ÷ BM; gr = bm0 + m; gc = kt0 + k
            @inbounds As[m + 1, k + 1] = (gr < M && gc < K) ? A[gr + 1, gc + 1] : 0.0f0
            i += nthreads
        end
        i = t0; nelB = BK * BN
        while i < nelB
            k = i % BK; n = i ÷ BK; gr = kt0 + k; gc = bn0 + n
            @inbounds Bs[k + 1, n + 1] = (gr < K && gc < N) ? B[gr + 1, gc + 1] : 0.0f0
            i += nthreads
        end
        Metal.threadgroup_barrier(Metal.MemoryFlagThreadGroup)
        acc = _foldk(acc, As, Bs, sm0, sn0, Val(TM), Val(TN), 0, Val(KB))
        Metal.threadgroup_barrier(Metal.MemoryFlagThreadGroup)
        kt0 += BK
    end
    lane = Int(Metal.thread_index_in_simdgroup()) - 1
    sc0 = s0 * 8
    _epi!(C, scratch, acc, bm0, sm0, bn0, sn0, M, N, alpha, beta, lane, sc0, Val(TM), Val(TN), Val(EDGE))
    return
end

function timed(cfg, M, N, K; iters=30)
    WM, WN, TM, TN, KB = cfg
    BM = 8 * TM * WM; BN = 8 * TN * WN
    (M % BM == 0 && N % BN == 0 && K % (8 * KB) == 0) || return NaN
    A = MtlArray(rand(Float32, M, K)); B = MtlArray(rand(Float32, K, N)); C = MtlArray(zeros(Float32, M, N))
    threads = WM * WN * 32; groups = (M ÷ BM, N ÷ BN)
    try
        @metal threads=threads groups=groups knn!(C, A, B, M, N, K, Val(WM), Val(WN), Val(TM), Val(TN), Val(KB))
        Metal.synchronize()
    catch e
        return NaN
    end
    err = maximum(abs.(Array(C) - Array(A) * Array(B))) / maximum(abs.(Array(A) * Array(B)))
    err > 1f-2 && return -err
    best = Inf
    for _ in 1:iters
        t = @elapsed begin
            @metal threads=threads groups=groups knn!(C, A, B, M, N, K, Val(WM), Val(WN), Val(TM), Val(TN), Val(KB))
            Metal.synchronize()
        end
        best = min(best, t)
    end
    2.0 * M * N * K / best / 1e9
end

M = N = K = 2048
configs = [
    (4, 4, 2, 2, 1), (4, 4, 2, 2, 2), (4, 4, 2, 2, 4),
    (4, 4, 1, 1, 1), (4, 4, 1, 1, 2), (4, 4, 1, 1, 4),
    (4, 4, 2, 1, 2), (4, 4, 1, 2, 2), (4, 4, 3, 3, 1),
    (8, 4, 2, 2, 1), (4, 8, 2, 2, 1), (8, 4, 1, 1, 2),
    (8, 8, 1, 1, 1), (8, 8, 1, 1, 2), (4, 4, 2, 2, 8),
    (8, 4, 2, 1, 2), (4, 8, 1, 2, 2), (8, 8, 2, 1, 1),
]
println("== direct-store NN F32 $(M)^3 (no Cs) ==")
for cfg in configs
    g = timed(cfg, M, N, K)
    BM = 8 * cfg[3] * cfg[1]; BN = 8 * cfg[4] * cfg[2]
    @printf("WM%d WN%d TM%d TN%d KB%d  BM%-3d BN%-3d thr%-4d | %8.1f GFLOP/s\n",
            cfg..., BM, BN, cfg[1] * cfg[2] * 32, g)
end

# full alpha/beta + ragged epilogue kernel
function timed_ab(cfg, M, N, K, alpha, beta; iters=30)
    WM, WN, TM, TN, KB = cfg
    BM = 8 * TM * WM; BN = 8 * TN * WN
    A = MtlArray(rand(Float32, M, K)); B = MtlArray(rand(Float32, K, N))
    Ch = rand(Float32, M, N); C = MtlArray(copy(Ch))
    threads = WM * WN * 32; groups = (cld(M, BM), cld(N, BN))
    edge = !(M % BM == 0 && N % BN == 0)
    ref = alpha .* (Array(A) * Array(B)) .+ beta .* Ch
    @metal threads=threads groups=groups kab!(C, A, B, Float32(alpha), Float32(beta), M, N, K, Val(WM), Val(WN), Val(TM), Val(TN), Val(KB), Val(edge))
    Metal.synchronize()
    err = maximum(abs.(Array(C) - ref)) / max(1f0, maximum(abs.(ref)))
    err > 1f-2 && return -err
    best = Inf
    for _ in 1:iters
        t = @elapsed begin
            @metal threads=threads groups=groups kab!(C, A, B, Float32(alpha), Float32(beta), M, N, K, Val(WM), Val(WN), Val(TM), Val(TN), Val(KB), Val(edge))
            Metal.synchronize()
        end
        best = min(best, t)
    end
    2.0 * M * N * K / best / 1e9
end

println("\n== alpha/beta epilogue kernel (kab!), <=512 threads ==")
safe(g) = (g === NaN || isnan(g)) ? "  --  " : @sprintf("%7.1f", g)
for cfg in [(4, 4, 2, 2, 1), (4, 4, 4, 4, 1), (4, 4, 3, 3, 1),
            (4, 4, 2, 4, 1), (4, 4, 4, 2, 1), (4, 4, 4, 4, 2),
            (2, 4, 4, 4, 1), (4, 2, 4, 4, 1), (4, 4, 3, 2, 1)]
    WM, WN, TM, TN, KB = cfg
    g1 = try timed_ab(cfg, 2048, 2048, 2048, 1.0, 0.0) catch; NaN end
    g2 = try timed_ab(cfg, 2048, 2048, 2048, 2.0, 0.5) catch; NaN end
    gr = try timed_ab(cfg, 2000, 2000, 2000, 1.0, 0.0) catch; NaN end
    BM = 8 * TM * WM; BN = 8 * TN * WN
    @printf("WM%d WN%d TM%d TN%d KB%d BM%-3d BN%-3d thr%-4d | α1β0 %s  α2β.5 %s  ragged %s\n",
            cfg..., BM, BN, WM * WN * 32, safe(g1), safe(g2), safe(gr))
end
