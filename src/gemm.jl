# Native Julia GEMM for Metal.
#
# Three device kernels back the native matmul paths (see `src/linalg.jl`); the matmul
# algorithm `:simd`/`:scalar`/`:tensor` forces one, while `:native`/`:auto` pick among them:
#
#  * `gemm_tensor_kernel!` is the Metal 4 fast path. It drives `tensor_ops::matmul2d`
#    over a tile decomposition. Only available on Metal4-capable devices and only for the
#    plain `C = A*B` (no transpose, α=1, β=0) with tile-divisible, float-typed operands.
#
#  * `gemm_simd_kernel!` is the portable fast path for `Float16`/`Float32`. It stages tiles
#    of `op(A)`/`op(B)` into threadgroup memory (bounds-checked, so any M/N/K and
#    any buffer offset are handled) and contracts them with the `simdgroup_matrix`
#    8x8 tensor primitives, accumulating in `Float32`.
#
#  * `gemm_scalar_kernel!` is the correctness fallback for every other eltype
#    (complex, bfloat16, integers). A classic scalar shared-memory tiled kernel that works
#    for any eltype supporting `+`/`*`, any transpose, and any offset.
#
# All honor the LinearAlgebra contract `C = α·op(A)·op(B) + β·C` with the
# transpose char in {'N','T','C'} applied to each operand.

## device-side operand access (transpose / conjugate applied)

# op(A)[outrow, contr], reading the stored (possibly transposed) matrix
@inline function opA(A, ::Val{TA}, outrow, contr) where {TA}
    if TA === 'N'
        @inbounds A[outrow, contr]
    elseif TA === 'C'
        @inbounds conj(A[contr, outrow])
    else # 'T'
        @inbounds A[contr, outrow]
    end
end

# op(B)[contr, outcol]
@inline function opB(B, ::Val{TB}, contr, outcol) where {TB}
    if TB === 'N'
        @inbounds B[contr, outcol]
    elseif TB === 'C'
        @inbounds conj(B[outcol, contr])
    else # 'T'
        @inbounds B[outcol, contr]
    end
end

## fast path: simdgroup_matrix tiled kernel (Float16/Float32, F32 accumulate)

# A simdgroup matrix is an `NTuple{64, VecElement}` distributed across the lanes, so a
# scalar multiply/AXPY is a plain elementwise op on the tuple, with no intrinsic needed.
# This lets the epilogue apply α/β and store straight to device memory, avoiding a
# large `C`-sized threadgroup staging tile (which would crush occupancy).
@inline cvt(::Type{R}, m) where {R} = ntuple(i -> VecElement{R}(R(m[i].value)), Val(64))
@inline scale(m, a) = ntuple(i -> VecElement{Float32}(a * m[i].value), Val(64))
@inline axpby(m, c, a, b) = ntuple(i -> VecElement{Float32}(a * m[i].value + b * c[i].value), Val(64))

# These helpers take the accumulator/fragment tuples as arguments (rather than
# closing over reassigned locals) so the unrolled `ntuple`s stay register-resident
# instead of being boxed onto the GC-managed (and GPU-illegal) heap.
@inline load_afrag(As, sm0, ks, ::Val{TM}) where {TM} =
    ntuple(ti -> simdgroup_load(As, (sm0 + (ti - 1) * 8 + 1, ks + 1)), Val(TM))
@inline load_bfrag(Bs, sn0, ks, ::Val{TN}) where {TN} =
    ntuple(tj -> simdgroup_load(Bs, (ks + 1, sn0 + (tj - 1) * 8 + 1)), Val(TN))
@inline mma(acc, afrag, bfrag, ::Val{TM}, ::Val{TN}) where {TM, TN} =
    ntuple(Val(TM * TN)) do idx
        ti = (idx - 1) % TM + 1
        tj = (idx - 1) ÷ TM + 1
        simdgroup_multiply_accumulate(afrag[ti], bfrag[tj], acc[idx])
    end

# store one full (in-bounds) 8x8 fragment to C with α/β applied
@inline function store_frag!(C::MtlDeviceArray{R}, accidx, gr, gc, alpha, beta,
                              ::Val{SIMPLE}) where {R, SIMPLE}
    if SIMPLE
        simdgroup_store(cvt(R, accidx), C, (gr + 1, gc + 1))
    elseif iszero(beta)
        simdgroup_store(cvt(R, scale(accidx, alpha)), C, (gr + 1, gc + 1))
    else
        cb = simdgroup_load(C, (gr + 1, gc + 1))
        simdgroup_store(cvt(R, axpby(accidx, cvt(Float32, cb), alpha, beta)), C, (gr + 1, gc + 1))
    end
    return
end

# epilogue, kept top-level so the unrolled ntuple doesn't capture the reassigned acc.
# EDGE=false: every fragment is fully in-bounds -> direct stores, no scratch needed.
# EDGE=true: boundary fragments are staged through a small per-simdgroup 8x8 scratch
# and written elementwise with bounds checks.
@inline function epilogue!(C::MtlDeviceArray{R}, scratch, acc, bm0, sm0, bn0, sn0, M, N,
                            alpha, beta, lane, sc0, ::Val{TM}, ::Val{TN},
                            ::Val{EDGE}, ::Val{SIMPLE}) where {R, TM, TN, EDGE, SIMPLE}
    ntuple(Val(TM * TN)) do idx
        ti = (idx - 1) % TM; tj = (idx - 1) ÷ TM
        gr = bm0 + sm0 + ti * 8; gc = bn0 + sn0 + tj * 8
        if !EDGE || (gr + 8 <= M && gc + 8 <= N)
            store_frag!(C, acc[idx], gr, gc, alpha, beta, Val(SIMPLE))
        else
            simdgroup_store(acc[idx], scratch, (1, sc0 + 1))
            simdgroup_barrier(MemoryFlagThreadGroup)
            e = lane
            while e < 64
                r = e % 8; c = e ÷ 8; gi = gr + r; gj = gc + c
                if gi < M && gj < N
                    sv = @inbounds scratch[r + 1, sc0 + c + 1]
                    @inbounds C[gi + 1, gj + 1] = iszero(beta) ? R(alpha * sv) : R(alpha * sv + beta * C[gi + 1, gj + 1])
                end
                e += 32
            end
        end
        nothing
    end
    return
end

# A threadgroup holds a WM×WN grid of simdgroups; each simdgroup computes a TM×TN
# grid of 8x8 output blocks (register blocking for arithmetic intensity), so the
# threadgroup covers a BM×BN = (8·TM·WM)×(8·TN·WN) tile of C. BK = 8·KB is the
# contraction tile depth. Tiles are staged in threadgroup memory as Float32 and
# accumulated in Float32.
function gemm_simd_kernel!(C, A, B, alpha::Float32, beta::Float32,
                            M, N, K, ::Val{TA}, ::Val{TB},
                            ::Val{WM}, ::Val{WN}, ::Val{TM}, ::Val{TN},
                            ::Val{KB}, ::Val{EDGE}, ::Val{SIMPLE}) where {TA, TB, WM, WN, TM, TN, KB, EDGE, SIMPLE}
    SGM = 8 * TM; SGN = 8 * TN                         # output region per simdgroup
    BM = WM * SGM; BN = WN * SGN; BK = 8 * KB
    nthreads = WM * WN * 32

    t0 = Int(thread_index_in_threadgroup()) - 1        # 0-based thread in threadgroup
    s0 = Int(simdgroup_index_in_threadgroup()) - 1     # 0-based simdgroup
    sm0 = (s0 % WM) * SGM                               # this simdgroup's row origin
    sn0 = (s0 ÷ WM) * SGN                               # ... col origin (in threadgroup tile)
    bm0 = (Int(threadgroup_position_in_grid().x) - 1) * BM  # 0-based row origin in C
    bn0 = (Int(threadgroup_position_in_grid().y) - 1) * BN  # 0-based col origin in C

    As = MtlThreadGroupArray(Float32, (BM, BK))
    Bs = MtlThreadGroupArray(Float32, (BK, BN))
    scratch = MtlThreadGroupArray(Float32, (8, EDGE ? 8 * WM * WN : 0))

    # TM×TN accumulators (ti fastest), all zero-initialized, kept in registers
    acc = ntuple(_ -> ntuple(_ -> VecElement{Float32}(0.0f0), Val(64)), Val(TM * TN))

    kt0 = 0
    while kt0 < K
        # cooperatively stage op(A) tile (BM×BK) and op(B) tile (BK×BN)
        i = t0
        nelA = BM * BK
        while i < nelA
            m = i % BM; k = i ÷ BM
            gr = bm0 + m; gc = kt0 + k
            v = (gr < M && gc < K) ? Float32(opA(A, Val(TA), gr + 1, gc + 1)) : 0.0f0
            @inbounds As[m + 1, k + 1] = v
            i += nthreads
        end
        i = t0
        nelB = BK * BN
        while i < nelB
            k = i % BK; n = i ÷ BK
            gr = kt0 + k; gc = bn0 + n
            v = (gr < K && gc < N) ? Float32(opB(B, Val(TB), gr + 1, gc + 1)) : 0.0f0
            @inbounds Bs[k + 1, n + 1] = v
            i += nthreads
        end
        threadgroup_barrier(MemoryFlagThreadGroup)

        # contract: load TM A-fragments and TN B-fragments, reuse across TM×TN MACs
        ks = 0
        while ks < BK
            afrag = load_afrag(As, sm0, ks, Val(TM))
            bfrag = load_bfrag(Bs, sn0, ks, Val(TN))
            acc = mma(acc, afrag, bfrag, Val(TM), Val(TN))
            ks += 8
        end
        threadgroup_barrier(MemoryFlagThreadGroup)
        kt0 += BK
    end

    lane = Int(thread_index_in_simdgroup()) - 1
    epilogue!(C, scratch, acc, bm0, sm0, bn0, sn0, M, N, alpha, beta, lane, s0 * 8,
               Val(TM), Val(TN), Val(EDGE), Val(SIMPLE))
    return
end

## scalar path: per-element shared-memory tiled kernel (any eltype / transpose / offset)

function gemm_scalar_kernel!(C, A, B, alpha, beta,
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
        @inbounds As[li, lj] = (gi <= M && ac <= K) ? opA(A, Val(TA), gi, ac) : zero(TAT)
        ar = k0 + li
        @inbounds Bs[li, lj] = (ar <= K && gj <= N) ? opB(B, Val(TB), ar, gj) : zero(TBT)
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

## tensor path: Metal 4 `tensor_ops::matmul2d` (macOS 26+, Metal4-capable devices)

# Tile-decomposed matmul on top of `tensor_ops::matmul2d`. Specialized on the tile shape
# (TM, TN, TK) and simdgroup count (NSIMD) so the matmul descriptor and execution width are
# compile-time constants. The K-loop trip count is kept dynamic (a runtime `K`, not a `Val`)
# to avoid crashing Apple's back-end (see the note in `device/intrinsics/tensor.jl`).
#
# The A/B swap maps Julia's column-major `C = A*B` onto matmul2d's operand convention:
# matmul2d's `apple_A` slot receives Julia's `B` and `apple_B` receives Julia's `A`, and the
# (M, N) storage order matmul2d expects happens to be the transpose of how Julia reads the
# same buffer column-major, so the two swaps cancel and the result lands in `C` as expected.
# This lets every operand use packed strides without an explicit transpose flag.
function gemm_tensor_kernel!(C::MtlDeviceArray, A::MtlDeviceArray, B::MtlDeviceArray,
                             M::UInt32, N::UInt32, K::UInt32,
                             ::Val{TM}, ::Val{TN}, ::Val{TK},
                             ::Val{NSIMD}) where {TM, TN, TK, NSIMD}
    tgid   = threadgroup_position_in_grid_3d()
    n_off  = (Int32(tgid.x) - Int32(1)) * Int32(TN)
    m_off  = (Int32(tgid.y) - Int32(1)) * Int32(TM)

    tA = MtlInlineTensor(B, (K, M))
    tB = MtlInlineTensor(A, (N, K))
    tC = MtlInlineTensor(C, (N, M))

    mC = view(tC, (n_off, m_off), (Int32(TN), Int32(TM)))

    op = TensorOpsMatmul2D{matmul2d_descriptor(TM, TN, TK;
                                               mode = matmul2d_multiply_accumulate),
                           Int32(NSIMD)}()
    nslices = Int32(K ÷ UInt32(TK))
    for s in Int32(0):(nslices - Int32(1))
        k_off = s * Int32(TK)
        mA = view(tA, (k_off, m_off), (Int32(TK), Int32(TM)))
        mB = view(tB, (n_off, k_off), (Int32(TN), Int32(TK)))
        op(mA, mB, mC)
    end
    return
end

# eltypes the tensor path handles (uniform in/out); these have `__tensorops` run helpers and
# accumulate to a sensible precision in matmul2d.
@inline gemm_tensor_eltype(::Type{T}, ::Type{T}, ::Type{T}) where {T <: Union{Float16, Float32, BFloat16}} = true
@inline gemm_tensor_eltype(::Type, ::Type, ::Type) = false

# `tensor_ops` runs only when the device advertises the Metal 4 family; gating the launch on
# it also keeps the `__tensorops_*` symbols out of modules compiled for devices where the
# validator would reject them.
@inline tensor_matmul_capable() =
    metal_support() >= v"4" && MTL.supports_family(device(), MTL.MTLGPUFamilyMetal4)

# matmul2d needs each dimension covered by whole tiles. Pick the largest validated tile that
# divides the dimension; 0 means "no usable tile" (dimension not a multiple of the smallest).
const GEMM_TENSOR_MN_TILES = (64, 32, 16, 8)
const GEMM_TENSOR_K_TILES  = (32, 16, 8)
const GEMM_TENSOR_NSIMD    = 4

@inline function gemm_tensor_tile(d::Integer, cands)
    for t in cands
        d % t == 0 && return t
    end
    return 0
end

# Whether `gemm_tensor!` can compute `C = α·op(A)·op(B) + β·C` for these operands: the kernel
# only realizes the plain `C = A*B` (no transpose, α=1, β=0) for a Metal4 device and a
# supported eltype, with dims that tile evenly.
function supports_tensor_matmul(C, A, B, cA::Char, cB::Char, alpha::Number, beta::Number)
    tensor_matmul_capable() || return false
    gemm_tensor_eltype(eltype(A), eltype(B), eltype(C)) || return false
    (cA === 'N' && cB === 'N') || return false
    (isone(alpha) && iszero(beta)) || return false
    m = size(A, 1); k = size(A, 2); n = size(B, 2)
    gemm_tensor_tile(n, GEMM_TENSOR_MN_TILES) != 0 &&
        gemm_tensor_tile(m, GEMM_TENSOR_MN_TILES) != 0 &&
        gemm_tensor_tile(k, GEMM_TENSOR_K_TILES)  != 0
end

"""
    Metal.gemm_tensor!(C, A, B, α=true, β=false, cA='N', cB='N'; tile_m=0, tile_n=0, tile_k=0)

Compute `C = A*B` via `tensor_ops::matmul2d` with a tile decomposition (Metal 4 only).
Only the plain product is realized (`cA=cB='N'`, `α=1`, `β=0`); callers must check
[`Metal.supports_tensor_matmul`](@ref) first. `tile_*=0` selects the largest validated tile
that divides the corresponding dimension; pass explicit tiles to tune.
"""
function gemm_tensor!(C::MtlMatrix, A::MtlMatrix, B::MtlMatrix,
                      alpha::Number = true, beta::Number = false,
                      cA::Char = 'N', cB::Char = 'N';
                      tile_m::Integer = 0, tile_n::Integer = 0, tile_k::Integer = 0)
    m = size(A, 1); k = size(A, 2); n = size(B, 2)
    tile_m = tile_m == 0 ? gemm_tensor_tile(n, GEMM_TENSOR_MN_TILES) : tile_m
    tile_n = tile_n == 0 ? gemm_tensor_tile(m, GEMM_TENSOR_MN_TILES) : tile_n
    tile_k = tile_k == 0 ? gemm_tensor_tile(k, GEMM_TENSOR_K_TILES)  : tile_k

    # Apple-side dims (operands swapped, see `gemm_tensor_kernel!`).
    aM, aN, aK = n, m, k
    fill!(C, zero(eltype(C)))   # the kernel accumulates into C
    groups = (aN ÷ tile_n, aM ÷ tile_m, 1)
    nsimd = GEMM_TENSOR_NSIMD
    @metal threads = nsimd * 32 groups = groups gemm_tensor_kernel!(
        C, A, B, UInt32(aM), UInt32(aN), UInt32(aK),
        Val(Int32(tile_m)), Val(Int32(tile_n)), Val(Int32(tile_k)), Val(Int32(nsimd)))
    return C
end


## host entry points

@inline gemm_simd_eltype(::Type{<:Union{Float16, Float32}},
                          ::Type{<:Union{Float16, Float32}},
                          ::Type{<:Union{Float16, Float32}}) = true
@inline gemm_simd_eltype(::Type, ::Type, ::Type) = false

# Operand-support predicate for the simdgroup kernel, mirroring `supports_mps_matmul` /
# `supports_mpsgraph_matmul` / `supports_tensor_matmul`: it handles any transpose/α/β/shape/
# offset, so it only needs a float eltype. The scalar kernel is the universal fallback and
# handles any eltype, so it needs no such predicate (it is the kernel `:native` falls back to).
@inline supports_simd_matmul(C, A, B, cA::Char, cB::Char, alpha::Number, beta::Number) =
    gemm_simd_eltype(eltype(A), eltype(B), eltype(C))

# tile configuration for the fast path. WM×WN simdgroups per threadgroup, each with
# a TM×TN grid of 8x8 accumulators (keep TM·TN ≤ 16 to avoid register spilling),
# contraction depth BK = 8·KB. BM×BN = (8·TM·WM)×(8·TN·WN) output per threadgroup.
# WM=WN=4 (512 threads) maximizes occupancy / latency hiding on current hardware.
const GEMM_SIMD_WM = 4
const GEMM_SIMD_WN = 4
const GEMM_SIMD_TM = 2
const GEMM_SIMD_TN = 2
const GEMM_SIMD_KB = 1

function gemm_simd!(C, A, B, alpha, beta, cA::Char, cB::Char)
    M = size(C, 1); N = size(C, 2)
    K = cA === 'N' ? size(A, 2) : size(A, 1)
    WM = GEMM_SIMD_WM; WN = GEMM_SIMD_WN
    TM = GEMM_SIMD_TM; TN = GEMM_SIMD_TN; KB = GEMM_SIMD_KB
    BM = 8 * TM * WM; BN = 8 * TN * WN
    threads = WM * WN * 32
    groups = (cld(M, BM), cld(N, BN))
    # aligned tiles skip the bounds-checked edge path; α=1,β=0 skips the α/β arithmetic
    edge = !(M % BM == 0 && N % BN == 0)
    simple = isone(alpha) && iszero(beta)
    @metal threads=threads groups=groups gemm_simd_kernel!(
        C, A, B, Float32(alpha), Float32(beta), Int(M), Int(N), Int(K),
        Val(cA), Val(cB), Val(WM), Val(WN), Val(TM), Val(TN), Val(KB), Val(edge), Val(simple))
    return C
end

const GEMM_SCALAR_TILE = 16

function gemm_scalar!(C, A, B, alpha, beta, cA::Char, cB::Char)
    M = size(C, 1); N = size(C, 2)
    K = cA === 'N' ? size(A, 2) : size(A, 1)
    TILE = GEMM_SCALAR_TILE
    threads = (TILE, TILE)
    groups = (cld(M, TILE), cld(N, TILE))
    @metal threads=threads groups=groups gemm_scalar_kernel!(
        C, A, B, alpha, beta, Int(M), Int(N), Int(K), Val(cA), Val(cB), Val(TILE))
    return C
end

"""
    Metal.gemm!(C, tA, tB, A, B, α, β; kernel=:auto)

Native GEMM computing `C = α·op_tA(A)·op_tB(B) + β·C` for `MtlMatrix` operands.
`tA`/`tB ∈ {'N','T','C'}`. Backs the `:native`/`:auto` matmul paths (`kernel=:auto`, picking
the best of the tensor/simd/scalar kernels) and the `:simd`/`:scalar`/`:tensor` paths, which set
`kernel` to force a specific kernel. Forcing a kernel that cannot handle the operands is the
caller's responsibility (see `supports_simd_matmul`/`supports_tensor_matmul`).
"""
function gemm!(C::MtlMatrix, tA::Char, tB::Char, A::MtlMatrix, B::MtlMatrix,
               alpha::Number, beta::Number; kernel::Symbol = :auto)
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

    # `:auto` picks the Metal 4 tensor-ops fast path when the device and operands allow it,
    # then the portable simdgroup kernel for floats, then the scalar fallback; an
    # explicit `kernel` forces one of them.
    use_tensor = kernel === :tensor ||
                 (kernel === :auto && supports_tensor_matmul(C, A, B, tA, tB, alpha, beta))
    use_simd = kernel === :simd ||
               (kernel === :auto && supports_simd_matmul(C, A, B, tA, tB, alpha, beta))
    if use_tensor
        gemm_tensor!(C, A, B, alpha, beta, tA, tB)
    elseif use_simd
        gemm_simd!(C, A, B, alpha, beta, tA, tB)
    else
        gemm_scalar!(C, A, B, alpha, beta, tA, tB)
    end
    return C
end

# matrix-vector multiply as a thin N=1 GEMM
function gemv!(C::MtlVector, tA::Char, A::MtlMatrix, B::MtlVector,
               alpha::Number, beta::Number; kernel::Symbol = :auto)
    Cm = reshape(C, length(C), 1)
    Bm = reshape(B, length(B), 1)
    gemm!(Cm, tA, 'N', A, Bm, alpha, beta; kernel)
    return C
end
