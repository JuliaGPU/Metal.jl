# Native Julia GEMM for Metal.
#
# Two device kernels back the `:Julia` matmul algorithm (see `src/linalg.jl`):
#
#  * `_gemm_simd_kernel!` — the fast path for `Float16`/`Float32`. It stages tiles
#    of `op(A)`/`op(B)` into threadgroup memory (bounds-checked, so any M/N/K and
#    any buffer offset are handled) and contracts them with the `simdgroup_matrix`
#    8x8 tensor primitives, accumulating in `Float32`.
#
#  * `_gemm_robust_kernel!` — the correctness fallback for every other eltype
#    (complex, bfloat16, integers, ...). A classic shared-memory tiled kernel that
#    works for any eltype supporting `+`/`*`, any transpose, and any offset.
#
# Both honor the LinearAlgebra contract `C = α·op(A)·op(B) + β·C` with the
# transpose char `∈ {'N','T','C'}` applied to each operand.

## device-side operand access (transpose / conjugate applied)

# op(A)[outrow, contr], reading the stored (possibly transposed) matrix
@inline function _opA(A, ::Val{TA}, outrow, contr) where {TA}
    if TA === 'N'
        @inbounds A[outrow, contr]
    elseif TA === 'C'
        @inbounds conj(A[contr, outrow])
    else # 'T'
        @inbounds A[contr, outrow]
    end
end

# op(B)[contr, outcol]
@inline function _opB(B, ::Val{TB}, contr, outcol) where {TB}
    if TB === 'N'
        @inbounds B[contr, outcol]
    elseif TB === 'C'
        @inbounds conj(B[outcol, contr])
    else # 'T'
        @inbounds B[outcol, contr]
    end
end

## fast path: simdgroup_matrix tiled kernel (Float16/Float32, F32 accumulate)

# One simdgroup computes one 8x8 output block; a threadgroup holds a WM×WN grid of
# simdgroups, so it covers a (8·WM)×(8·WN) tile of C. BK = 8·KB is the contraction
# tile depth. Tiles are staged in threadgroup memory as Float32.
function _gemm_simd_kernel!(C, A, B, alpha::Float32, beta::Float32,
                            M, N, K, ::Val{TA}, ::Val{TB},
                            ::Val{WM}, ::Val{WN}, ::Val{KB}) where {TA, TB, WM, WN, KB}
    BM = 8 * WM
    BN = 8 * WN
    BK = 8 * KB
    nthreads = WM * WN * 32

    t0 = Int(thread_index_in_threadgroup()) - 1        # 0-based thread in threadgroup
    s0 = Int(simdgroup_index_in_threadgroup()) - 1     # 0-based simdgroup
    wm = s0 % WM                                       # simdgroup row in the WM×WN grid
    wn = s0 ÷ WM                                       # simdgroup col
    bm0 = (Int(threadgroup_position_in_grid().x) - 1) * BM  # 0-based row origin in C
    bn0 = (Int(threadgroup_position_in_grid().y) - 1) * BN  # 0-based col origin in C

    As = MtlThreadGroupArray(Float32, (BM, BK))
    Bs = MtlThreadGroupArray(Float32, (BK, BN))
    Cs = MtlThreadGroupArray(Float32, (BM, BN))

    acc = ntuple(_ -> VecElement{Float32}(0.0f0), Val(64))

    kt0 = 0
    while kt0 < K
        # cooperatively stage op(A) tile (BM×BK) and op(B) tile (BK×BN)
        i = t0
        nelA = BM * BK
        while i < nelA
            m = i % BM; k = i ÷ BM
            gr = bm0 + m; gc = kt0 + k
            v = (gr < M && gc < K) ? Float32(_opA(A, Val(TA), gr + 1, gc + 1)) : 0.0f0
            @inbounds As[m + 1, k + 1] = v
            i += nthreads
        end
        i = t0
        nelB = BK * BN
        while i < nelB
            k = i % BK; n = i ÷ BK
            gr = kt0 + k; gc = bn0 + n
            v = (gr < K && gc < N) ? Float32(_opB(B, Val(TB), gr + 1, gc + 1)) : 0.0f0
            @inbounds Bs[k + 1, n + 1] = v
            i += nthreads
        end
        threadgroup_barrier(MemoryFlagThreadGroup)

        # contract this simdgroup's 8x8 block over the BK tile
        ks = 0
        while ks < BK
            a = simdgroup_load(As, (wm * 8 + 1, ks + 1))
            b = simdgroup_load(Bs, (ks + 1, wn * 8 + 1))
            acc = simdgroup_multiply_accumulate(a, b, acc)
            ks += 8
        end
        threadgroup_barrier(MemoryFlagThreadGroup)
        kt0 += BK
    end

    # store accumulators to a threadgroup tile, then apply α/β cooperatively
    simdgroup_store(acc, Cs, (wm * 8 + 1, wn * 8 + 1))
    threadgroup_barrier(MemoryFlagThreadGroup)

    R = eltype(C)
    i = t0
    nC = BM * BN
    while i < nC
        m = i % BM; n = i ÷ BM
        gi = bm0 + m + 1; gj = bn0 + n + 1
        if gi <= M && gj <= N
            cv = @inbounds Cs[m + 1, n + 1]
            if iszero(beta)
                @inbounds C[gi, gj] = R(alpha * cv)
            else
                @inbounds C[gi, gj] = R(alpha * cv + beta * C[gi, gj])
            end
        end
        i += nthreads
    end
    return
end

## robust path: shared-memory tiled kernel (any eltype / transpose / offset)

function _gemm_robust_kernel!(C, A, B, alpha, beta,
                              M, N, K, ::Val{TA}, ::Val{TB}, ::Val{TILE}) where {TA, TB, TILE}
    TAT = eltype(A); TBT = eltype(B); R = eltype(C)

    li = Int(thread_position_in_threadgroup().x)
    lj = Int(thread_position_in_threadgroup().y)
    gi = (Int(threadgroup_position_in_grid().x) - 1) * TILE + li
    gj = (Int(threadgroup_position_in_grid().y) - 1) * TILE + lj

    As = MtlThreadGroupArray(TAT, (TILE, TILE))
    Bs = MtlThreadGroupArray(TBT, (TILE, TILE))

    z = zero(TAT) * zero(TBT)
    acc = z + z
    nkt = cld(K, TILE)
    kt = 0
    while kt < nkt
        k0 = kt * TILE
        ac = k0 + lj
        @inbounds As[li, lj] = (gi <= M && ac <= K) ? _opA(A, Val(TA), gi, ac) : zero(TAT)
        ar = k0 + li
        @inbounds Bs[li, lj] = (ar <= K && gj <= N) ? _opB(B, Val(TB), ar, gj) : zero(TBT)
        threadgroup_barrier(MemoryFlagThreadGroup)
        @inbounds for kk in 1:TILE
            acc += As[li, kk] * Bs[kk, lj]
        end
        threadgroup_barrier(MemoryFlagThreadGroup)
        kt += 1
    end

    if gi <= M && gj <= N
        if iszero(beta)
            @inbounds C[gi, gj] = R(alpha * acc)
        else
            @inbounds C[gi, gj] = R(alpha * acc + beta * C[gi, gj])
        end
    end
    return
end

## host entry points

@inline _gemm_fast_eltype(::Type{<:Union{Float16, Float32}},
                          ::Type{<:Union{Float16, Float32}},
                          ::Type{<:Union{Float16, Float32}}) = true
@inline _gemm_fast_eltype(::Type, ::Type, ::Type) = false

# tile configuration for the fast path (tuned in the perf phase)
const GEMM_SIMD_WM = 2
const GEMM_SIMD_WN = 2
const GEMM_SIMD_KB = 1

function _gemm_simd!(C, A, B, alpha, beta, cA::Char, cB::Char)
    M = size(C, 1); N = size(C, 2)
    K = cA === 'N' ? size(A, 2) : size(A, 1)
    WM = GEMM_SIMD_WM; WN = GEMM_SIMD_WN; KB = GEMM_SIMD_KB
    BM = 8 * WM; BN = 8 * WN
    threads = WM * WN * 32
    groups = (cld(M, BM), cld(N, BN))
    @metal threads=threads groups=groups _gemm_simd_kernel!(
        C, A, B, Float32(alpha), Float32(beta), Int(M), Int(N), Int(K),
        Val(cA), Val(cB), Val(WM), Val(WN), Val(KB))
    return C
end

const GEMM_ROBUST_TILE = 16

function _gemm_robust!(C, A, B, alpha, beta, cA::Char, cB::Char)
    M = size(C, 1); N = size(C, 2)
    K = cA === 'N' ? size(A, 2) : size(A, 1)
    TILE = GEMM_ROBUST_TILE
    threads = (TILE, TILE)
    groups = (cld(M, TILE), cld(N, TILE))
    @metal threads=threads groups=groups _gemm_robust_kernel!(
        C, A, B, alpha, beta, Int(M), Int(N), Int(K), Val(cA), Val(cB), Val(TILE))
    return C
end

"""
    Metal.gemm!(C, tA, tB, A, B, α, β)

Native GEMM computing `C = α·op_tA(A)·op_tB(B) + β·C` for `MtlMatrix` operands.
`tA`/`tB ∈ {'N','T','C'}`. Used by the `:Julia` matmul algorithm.
"""
function gemm!(C::MtlMatrix, tA::Char, tB::Char, A::MtlMatrix, B::MtlMatrix,
               alpha::Number, beta::Number)
    M = size(C, 1); N = size(C, 2)
    K = tA === 'N' ? size(A, 2) : size(A, 1)

    # nothing to compute
    (M == 0 || N == 0) && return C

    # empty contraction: C = β·C
    if K == 0
        if iszero(beta)
            fill!(C, zero(eltype(C)))
        else
            C .*= beta
        end
        return C
    end

    if _gemm_fast_eltype(eltype(A), eltype(B), eltype(C))
        _gemm_simd!(C, A, B, alpha, beta, tA, tB)
    else
        _gemm_robust!(C, A, B, alpha, beta, tA, tB)
    end
    return C
end

# matrix-vector multiply as a thin N=1 GEMM
function gemv!(C::MtlVector, tA::Char, A::MtlMatrix, B::MtlVector,
               alpha::Number, beta::Number)
    Cm = reshape(C, length(C), 1)
    Bm = reshape(B, length(B), 1)
    gemm!(Cm, tA, 'N', A, Bm, alpha, beta)
    return C
end
