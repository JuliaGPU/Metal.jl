# Native Julia GEMM for Metal.
#
# Two device kernels back the native matmul paths (see `src/linalg.jl`); the matmul
# algorithm `:simd`/`:tensor` forces one, while `:native`/`:auto` pick among them:
#
#  * `gemm_tensor_kernel!` is the Metal 4 fast path. It drives `tensor_ops::matmul2d`
#    over a tile decomposition. Only available on Metal4-capable devices, for the element
#    type combinations in `GEMM_TENSOR_ELTYPES`. Matrices, and views with contiguous columns
#    in increasing order, are read in place, also transposed ones; Symmetric/Hermitian
#    wrappers and other views are packed into dense copies (`gemm_tensor!`). α and β are
#    applied by the kernel itself, unless C can't be written in place or the contraction is
#    split into slices (for products with few tiles and a long one): the product, or the
#    partial products of the slices, then go to a workspace that a second kernel adds up,
#    scales and combines with C (`gemm_tensor!`).
#
#  * `gemm_simd_kernel!` is the portable fast path for `Float16`/`Float32`. It stages tiles
#    of `op(A)`/`op(B)` into threadgroup memory (bounds-checked, so any M/N/K and
#    any buffer offset are handled) and contracts them with the `simdgroup_matrix`
#    8x8 tensor primitives, accumulating in `Float32`.
#
# Operands that neither kernel supports (complex, integers, mixed eltypes) go to GPUArrays'
# generic kernels, which work for any eltype supporting `+`/`*`, any transpose, and any
# offset.
#
# All honor the LinearAlgebra contract `C = α·op(A)·op(B) + β·C` with the
# operand char in {'N','T','C'} (transpose/adjoint) or {'S','s','H','h'} (the
# LinearAlgebra wrapper chars for Symmetric/Hermitian, upper/lowercase = upper/lower
# triangle stored) applied to each operand.

const MtlMatrixRangeView{T} =
    SubArray{T,2,<:MtlArray{T},<:Tuple{Vararg{Union{Base.RangeIndex,Base.ReshapedUnitRange}}}}
const MtlMatrixOperand{T} = Union{MtlMatrix{T},MtlMatrixRangeView{T}}

## device-side operand access (transpose / conjugate / symmetric gather applied)

# element (i, j) of Symmetric/Hermitian(M), reading only the stored triangle
@inline function symherm(M, i, j, ::Val{UPPER}, ::Val{HERM}) where {UPPER, HERM}
    if HERM && i == j
        x = @inbounds M[i, i]
        oftype(x, real(x))
    elseif UPPER ? (j >= i) : (j <= i)
        @inbounds M[i, j]
    else
        x = @inbounds M[j, i]
        HERM ? conj(x) : x
    end
end

# op(X)[i, j], reading the stored (possibly transposed/wrapped) matrix. used for both
# operands: A's element is op(A)[outrow, contr], B's is op(B)[contr, outcol]
@inline function opelem(X, ::Val{TX}, i, j) where {TX}
    if TX === 'N'
        @inbounds X[i, j]
    elseif TX === 'C'
        @inbounds conj(X[j, i])
    elseif TX === 'T'
        @inbounds X[j, i]
    elseif TX === 'S' || TX === 's'
        symherm(X, i, j, Val(TX === 'S'), Val(false))
    else # 'H' / 'h'
        symherm(X, i, j, Val(TX === 'H'), Val(true))
    end
end

# Metal has no Float64, so the kernels take double-precision α and β in single precision,
# as `mtl` converts Float64 values (and as the simd kernel computes anyway)
device_scalar(x::Float64) = Float32(x)
device_scalar(x::ComplexF64) = ComplexF32(x)
device_scalar(x) = x

# the length of the contraction of `op(A)·op(B)` for the operand char `tA` (see `gemm!`); the
# Symmetric/Hermitian ones are of square matrices
@inline contraction_length(tA::Char, A) = (tA === 'T' || tA === 'C') ? size(A, 1) : size(A, 2)

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

# Whether an `R`-typed fragment assembled in registers (via `cvt`) can be written straight to
# device memory with `simdgroup_store`. Apple's frontend only ever materializes a simdgroup
# matrix through a matrix intrinsic (load / multiply / init_filled), never by assembling a
# `<64 x T>` with `insertelement`. The back-end tolerates an assembled `<64 x half>`/`<64 x
# float>` operand, but an assembled `<64 x bfloat>` stores zeros — verified on M1: Apple's own
# `init_filled`+store of `bfloat` runs correctly, while a `cvt`-assembled fragment does not. So
# `BFloat16` outputs route through the f32 scratch + scalar-convert epilogue, which stores the
# f32 accumulator (matrix provenance intact) and never assembles a bfloat fragment.
@inline simd_direct_store(::Type) = true
@inline simd_direct_store(::Type{BFloat16}) = false

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
# DIRECT=true, EDGE=false: every fragment is fully in-bounds -> direct stores, no scratch.
# DIRECT=true, EDGE=true: boundary fragments are staged through a small per-simdgroup 8x8
# scratch and written elementwise with bounds checks; fragments entirely outside C are
# skipped (`gr`/`gc` are uniform across the simdgroup, so its barrier stays uniform too).
# DIRECT=false (view destinations and eltypes `simdgroup_store` can't assemble, see
# `gemm_simd!`): every fragment that overlaps C takes the scratch path, which accesses C
# elementwise.
@inline function epilogue!(C::AbstractArray{R}, scratch, acc, bm0, sm0, bn0, sn0, M, N,
                            alpha, beta, lane, sc0, ::Val{TM}, ::Val{TN},
                            ::Val{EDGE}, ::Val{SIMPLE}, ::Val{DIRECT}) where {R, TM, TN, EDGE, SIMPLE, DIRECT}
    ntuple(Val(TM * TN)) do idx
        ti = (idx - 1) % TM; tj = (idx - 1) ÷ TM
        gr = bm0 + sm0 + ti * 8; gc = bn0 + sn0 + tj * 8
        if DIRECT && (!EDGE || (gr + 8 <= M && gc + 8 <= N))
            store_frag!(C, acc[idx], gr, gc, alpha, beta, Val(SIMPLE))
        elseif gr < M && gc < N
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

# Cooperative staging of an R×C tile of op(X) at 0-based origin (r0, c0), zero-padded
# outside the R0×C0 operand. Thread t0 of NT handles elements t0, t0+NT, ..., row-fastest
# so that consecutive threads read consecutive elements of a column. The trip count is a
# compile-time constant, so the loads are unrolled and all issued before the stores: a
# runtime-bounded loop interleaving each load with its store makes every thread wait out
# the full memory latency once per element, which dominated the kernel's run time.
@inline function tile_elem(X, ::Val{TX}, t0, r0, c0, R0, C0,
                           ::Val{R}, ::Val{NT}, j) where {TX, R, NT}
    i = t0 + (j - 1) * NT
    gr = r0 + i % R; gc = c0 + i ÷ R
    (gr < R0 && gc < C0) ? Float32(opelem(X, Val(TX), gr + 1, gc + 1)) : 0.0f0
end
@inline load_tile(X, tx, t0, r0, c0, R0, C0, ::Val{R}, ::Val{C}, ::Val{NT}) where {R, C, NT} =
    ntuple(j -> tile_elem(X, tx, t0, r0, c0, R0, C0, Val(R), Val(NT), j), Val(R * C ÷ NT))
@inline function store_tile!(Xs, v, t0, ::Val{R}, ::Val{NT}) where {R, NT}
    for j in 1:length(v)
        i = t0 + (j - 1) * NT
        @inbounds Xs[i % R + 1, i ÷ R + 1] = v[j]
    end
    return
end

# A threadgroup holds a WM×WN grid of simdgroups; each simdgroup computes a TM×TN
# grid of 8x8 output blocks (register blocking for arithmetic intensity), so the
# threadgroup covers a BM×BN = (8·TM·WM)×(8·TN·WN) tile of C. BK = 8·KB is the
# contraction tile depth. Tiles are staged in threadgroup memory as Float32 and
# accumulated in Float32.
#
# Threadgroup memory bank conflicts: Apple GPU threadgroup memory has 32 banks of 4
# bytes each. Without padding, As (BM×BK) with BM=64 has a 64-float column stride;
# 64%32=0 so all columns of each A-fragment map to the same bank (8-way conflict).
# Similarly Bs (BK×BN) with BK=8 causes 2-4-way conflicts. Adding 4-float (16-byte)
# padding to the leading dimension of each tile eliminates these conflicts.
function gemm_simd_kernel!(C, A, B, alpha::Float32, beta::Float32,
                            M, N, K, ::Val{TA}, ::Val{TB},
                            ::Val{WM}, ::Val{WN}, ::Val{TM}, ::Val{TN},
                            ::Val{KB}, ::Val{EDGE}, ::Val{SIMPLE}, ::Val{DIRECT}) where {TA, TB, WM, WN, TM, TN, KB, EDGE, SIMPLE, DIRECT}
    SGM = 8 * TM; SGN = 8 * TN                         # output region per simdgroup
    BM = WM * SGM; BN = WN * SGN; BK = 8 * KB
    nthreads = WM * WN * 32

    t0 = Int(thread_index_in_threadgroup()) - 1        # 0-based thread in threadgroup
    s0 = Int(simdgroup_index_in_threadgroup()) - 1     # 0-based simdgroup
    sm0 = (s0 % WM) * SGM                               # this simdgroup's row origin
    sn0 = (s0 ÷ WM) * SGN                               # ... col origin (in threadgroup tile)
    bm0 = (Int(threadgroup_position_in_grid().x) - 1) * BM  # 0-based row origin in C
    bn0 = (Int(threadgroup_position_in_grid().y) - 1) * BN  # 0-based col origin in C

    # 4-float (16-byte) padding per leading dimension avoids bank conflicts.
    # simdgroup_load/store use size(arr)[1] as the leading dimension, so they
    # automatically pick up the padded stride.
    As = MtlThreadGroupArray(Float32, (BM + 4, BK))
    Bs = MtlThreadGroupArray(Float32, (BK + 4, BN))
    scratch = MtlThreadGroupArray(Float32, (8 + 4, EDGE ? 8 * WM * WN : 0))

    # TM×TN accumulators (ti fastest), all zero-initialized, kept in registers
    acc = ntuple(_ -> ntuple(_ -> VecElement{Float32}(0.0f0), Val(64)), Val(TM * TN))

    kt0 = 0
    while kt0 < K
        # cooperatively stage op(A) tile (BM×BK) and op(B) tile (BK×BN)
        va = load_tile(A, Val(TA), t0, bm0, kt0, M, K, Val(BM), Val(BK), Val(nthreads))
        vb = load_tile(B, Val(TB), t0, kt0, bn0, K, N, Val(BK), Val(BN), Val(nthreads))
        store_tile!(As, va, t0, Val(BM), Val(nthreads))
        store_tile!(Bs, vb, t0, Val(BK), Val(nthreads))
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
               Val(TM), Val(TN), Val(EDGE), Val(SIMPLE), Val(DIRECT))
    return
end

## tensor path: Metal 4 `tensor_ops::matmul2d` (macOS 26+, Metal4-capable devices)

# a pair of coordinates or extents of an operand, `(x, y)` for op(X), in the order of the
# matrix as it is stored: swapped for one that is stored transposed
@inline stored_pair(::Val{TR}, x, y) where {TR} = TR ? (y, x) : (x, y)

# Tiled matmul on top of `tensor_ops::matmul2d`, laid out as Apple's Metal Performance
# Primitives programming guide recommends. A threadgroup holds `GEMM_TENSOR_WM`×`GEMM_TENSOR_WN`
# simdgroups, and each simdgroup computes an SM×SN tile of `C` of its own, specialized on the
# tile shape so the matmul descriptor is a compile-time constant.
#
# The descriptor leaves K dynamic, so matmul2d loops over the contraction itself and writes
# each element of C once, rounding a narrow destination only once. Tiles at the edges of C
# are sliced to the extents that remain: matmul2d bounds-checks partial tiles against the
# extents of the tensors, so no dimension needs to be a multiple of the tile.
#
# The operands start at the first element of their matrix, with column strides `ldc`, `lda` and
# `ldb`, so views are read in place. `TRA`/`TRB` say that `A`/`B` is stored transposed, as
# `(K, M)`/`(N, K)`; matmul2d then transposes it itself, so a transposed operand needs no copy.
#
# The contraction can be split over the threadgroups along z, into slices of `KS`: those with
# z-index `z` (from 0) compute the partial product over `z·KS+1:min((z+1)·KS, K)` into the
# `z`-th of M×N matrices that follow each other in `C`, see `gemm_tensor!`. Without a
# split, `KS == K` and there is one threadgroup along z.
#
# `MODE` is what happens to the product, see `gemm_tensor_tile!`; `alpha` and `beta` are only
# used by the modes that scale.
function gemm_tensor_kernel!(C::MtlDeviceArray, A::MtlDeviceArray, B::MtlDeviceArray,
                             alpha::P, beta::P, M::Int32, N::Int32, K::Int32, KS::Int32,
                             ldc::Int32, lda::Int32, ldb::Int32,
                             ::Val{SM}, ::Val{SN}, ::Val{MODE},
                             ::Val{TRA}, ::Val{TRB}) where {P, SM, SN, MODE, TRA, TRB}
    wm, wn = Int32(GEMM_TENSOR_WM), Int32(GEMM_TENSOR_WN)
    tgid  = threadgroup_position_in_grid_3d()
    sgid  = unsafe_trunc(Int32, simdgroup_index_in_threadgroup()) - Int32(1)
    m_off = (unsafe_trunc(Int32, tgid.x) - Int32(1)) * Int32(SM) * wm + rem(sgid, wm) * Int32(SM)
    n_off = (unsafe_trunc(Int32, tgid.y) - Int32(1)) * Int32(SN) * wn + div(sgid, wm) * Int32(SN)
    # (of a threadgroup at the edge, some simdgroups can lie outside of `C`)
    (m_off >= M || n_off >= N) && return
    tm = min(Int32(SM), M - m_off)
    tn = min(Int32(SN), N - n_off)
    z = unsafe_trunc(Int32, tgid.z) - Int32(1)
    k_off = z * KS
    tk = min(KS, K - k_off)

    tA = MtlInlineTensor(A, stored_pair(Val(TRA), M, K), (Int32(1), lda))
    tB = MtlInlineTensor(B, stored_pair(Val(TRB), K, N), (Int32(1), ldb))
    tC = MtlInlineTensor(C, (M, N * unsafe_trunc(Int32, threadgroups_per_grid().z)),
                         (Int32(1), ldc))

    mA = view(tA, stored_pair(Val(TRA), m_off + Int32(1), k_off + Int32(1)),
              stored_pair(Val(TRA), tm, tk))
    mB = view(tB, stored_pair(Val(TRB), k_off + Int32(1), n_off + Int32(1)),
              stored_pair(Val(TRB), tk, tn))
    mC = view(tC, (m_off + Int32(1), z * N + n_off + Int32(1)), (tm, tn))

    mode = MODE === :accumulate ? matmul2d_multiply_accumulate : matmul2d_multiply
    op = TensorOpsMatmul2D{matmul2d_descriptor(SM, SN; transpose_left = TRA,
                                               transpose_right = TRB, mode),
                           Int32(1)}()
    gemm_tensor_tile!(op, mA, mB, mC, alpha, beta, Val(MODE))
    return
end

# `out[i] = α·acc[i] + β·old[i]` for the slots of this thread that hold an element, or
# `α·acc[i]` without `old`; `out` can be `acc` or `old`, as the slots line up
@inline scaled(acc, ::Nothing, i, alpha::P, beta::P) where {P} = alpha * acc[i]
@inline scaled(acc, old, i, alpha::P, beta::P) where {P} = alpha * acc[i] + beta * convert(P, old[i])
@inline function scale_slots!(out, acc, old, alpha, beta)
    n = length(acc)
    i = Int32(1)
    while i <= n
        isassigned(acc, i) && (out[i] = scaled(acc, old, i, alpha, beta))
        i += Int32(1)
    end
    return
end

# One tile of `C`, in one of four modes:
#
#  * `:overwrite`, `C = A·B`, and `:accumulate`, `C += A·B`: matmul2d writes to `C`.
#  * `:scale`, `C = α·A·B`, and `:scale_add`, `C = α·A·B + β·C`: matmul2d writes the product
#    to a cooperative tensor, which keeps it in thread-local memory. Each thread scales its
#    share of the elements there, and adds its share of `C`, before the result is stored to
#    `C` once. This is what Apple's guide calls postfix fusion.
#
# The scaling is done in `P`, the type of `α` and `β`, and converted for the store, see
# `gemm_tensor!`.
@inline function gemm_tensor_tile!(op, mA, mB, mC::MtlInlineTensor{T}, alpha::P, beta::P,
                                   ::Val{MODE}) where {T, P, MODE}
    if MODE === :overwrite || MODE === :accumulate
        op(mA, mB, mC)
        return
    end

    acc = MtlCooperativeTensor{P}(op, mA, mB)
    op(mA, mB, acc)
    # (the result is stored from a tensor that has the element type of `C`)
    if MODE === :scale_add
        old = MtlCooperativeTensor{T}(op, mA, mB)
        copyto!(old, mC)
        out = T === P ? acc : old
        scale_slots!(out, acc, old, alpha, beta)
    else
        out = T === P ? acc : MtlCooperativeTensor{T}(op, mA, mB)
        scale_slots!(out, acc, nothing, alpha, beta)
    end
    copyto!(mC, out)
    return
end

# Element types `matmul2d` runs as (A, B, C)
const GEMM_TENSOR_ELTYPES = let s = Set{Tuple{DataType,DataType,DataType}}()
    for (TA, TB, outs) in (
            (Float16,  Float16,  (Float16, Float32)),
            (Float16,  BFloat16, (Float16, BFloat16, Float32)),
            (Float16,  Float32,  (Float32,)),
            (Float16,  Int8,     (Float16, Float32)),
            (Float16,  UInt8,    (Float16, Float32)),
            (BFloat16, Float16,  (Float16, BFloat16, Float32)),
            (BFloat16, BFloat16, (BFloat16, Float32)),
            (BFloat16, Float32,  (Float32,)),
            (BFloat16, Int8,     (BFloat16, Float32)),
            (BFloat16, UInt8,    (BFloat16, Float32)),
            (Float32,  Float16,  (Float32,)),
            (Float32,  BFloat16, (Float32,)),
            (Float32,  Float32,  (Float32,)),
            (Float32,  Int8,     (Float32,)),
            (Float32,  UInt8,    (Float32,)),
            (Int8,     Float16,  (Float16, Float32)),
            (Int8,     BFloat16, (BFloat16, Float32)),
            (Int8,     Float32,  (Float32,)),
            (Int8,     Int8,     (Int32,)),
            (UInt8,    Float16,  (Float16, Float32)),
            (UInt8,    BFloat16, (BFloat16, Float32)),
            (UInt8,    Float32,  (Float32,)),
            (UInt8,    UInt8,    (Int32,)))
        for TC in outs
            push!(s, (TA, TB, TC))
        end
    end
    s
end

@inline function gemm_tensor_eltype(TA::Type, TB::Type, TC::Type)
    typestuple = (TA, TB, TC)
    typestuple in GEMM_TENSOR_ELTYPES || return false
    # Support from the "MatMul2d data type supported" table in the MSL spec
    BFloat16 in typestuple && macos_version() < v"26.1" && return false
    UInt8 in typestuple && macos_version() < v"26.4" && return false
    return true
end

# `tensor_ops` runs only when the device advertises the Metal 4 family; gating the launch on
# it also keeps the `__tensorops_*` symbols out of modules compiled for devices where the
# validator would reject them.
@inline function tensor_matmul_capable()
    dev = device()
    @memoize key=pointer(dev)::id{MTLDevice} begin
        metal_support() >= v"4" && MTL.supports_family(dev, MTL.MTLGPUFamilyMetal4)
    end::Bool
end

# The Apple GPU family of the device (7 for the M1, 8 for the M2, ...), or 0 if it reports
# none, for `gemm_tensor_tiles`.
@inline function gemm_tensor_family()
    dev = device()
    @memoize key=pointer(dev)::id{MTLDevice} begin
        something(MTL.highest_apple_family(dev), 0)
    end::Int
end

# The number of GPU cores, for `gemm_tensor_splits`; the M1's 8 if the system doesn't say.
gemm_tensor_cores() = (n = num_gpu_cores(); n > 0 ? n : 8)

# simdgroups per threadgroup
const GEMM_TENSOR_WM = 2
const GEMM_TENSOR_WN = 2

# The size of the tile of `C` that one simdgroup computes, with 2×2 simdgroups per
# threadgroup. matmul2d requires tiles that are multiples of 8, at least one of them a
# multiple of 16. `family` is the Apple GPU family (see `gemm_tensor_family`), `narrow` says
# that both inputs take at most 2 bytes per element (only `Float16` was measured), and
# `transA` that `A` is read transposed, as `(K, M)`.
#
# No single tile is good everywhere: the best one depends on the GPU generation, on the
# shape of `C`, and for some shapes on the element type and on whether `A` is stored
# transposed. The rules below come from timing the 14 tiles with sides of 8, 16, 32 and 64
# that matmul2d accepts, other than 64×64 (the slowest in an earlier sweep), on an M1
# (Apple7), M2 (Apple8), M3 Pro (Apple9) and M6 (Apple11), all on macOS 27.2: about 100
# shapes per device and element type (`Float32` and `Float16`), covering squares from 256 to
# 4096, rectangles, products with 1 to 256 rows or columns, sizes that are not powers of
# two, and transposed operands, each over several fresh allocations (the median of the
# samples per tile). Each rule's tile has about the lowest geometric-mean slowdown, relative
# to each shape's fastest tile, over the shapes that the rule covers; close calls went to
# the tile with the smaller worst case, or the smaller loss against the previous selection.
# On average the result is within 3-12% of the fastest tile per device, also for a second
# set of shapes, measured on the same devices, that weren't used to choose the rules.
# Products with few rows or columns are the least predictable: their fastest tile changes
# erratically with the exact sizes, so some of them still run up to 2× slower than with
# their own best tile. The rules are checked in order, so e.g. a `C` with few rows and up to
# 16 columns counts as one with few columns.
#
# On the M3 and M6, and on families that weren't measured:
# - `C` with up to 16 columns, like a matrix-vector product, gets tall 64×16 tiles.
# - `C` with up to 32 rows gets 16×8 tiles, so that the threadgroup doesn't extend far past it.
# - `C` with few rows (up to 256, and at least 4× as many columns) gets 32×16 tiles, and `C`
#   with few columns (likewise) 16×64 ones.
# - Other products of up to 1024² elements get 32×16 tiles, which make more threadgroups.
# - Larger ones use the 32×32 that Apple's guide recommends.
# The M6 multiplies 2-byte inputs much faster than the M3, and larger tiles keep up with it:
# 64×32 for large products (1.4-1.5× faster at 3000² and 4096²) and for few columns, 64×16
# for few rows. Families other than the M3's (Apple9) are assumed to be like the M6. On the
# M3, 2-byte inputs with few columns want 16×16.
#
# The M1 and M2 differ in more ways. With up to 16 rows they want 8×16 tiles, 32×16 with up
# to 32, and 32×32 with few rows. When `A` is stored transposed, products with few columns
# are fastest with tiles of 8 or 16 rows; otherwise 2-byte inputs with few columns want
# 32×32. Small products want 16×32 on the M1. Large `Float32` products want tiles of 2048
# elements, 32×64 on the M1 and 64×32 on the M2 once `M` exceeds 2048: with 32×32, a 4096²
# product runs 2.3× (M1) and 2.8× (M2) slower, and on the M2 its time varies between 82 and
# 177 ms over fresh allocations. Some sizes between 2048 and 6000 that aren't powers of two
# run 10-18% faster with 32×32 on the M2, a smaller loss than the one 64×32 avoids. Large
# 2-byte products keep 32×32.
function gemm_tensor_tiles(M::Integer, N::Integer; family::Integer, narrow::Bool = false,
                           transA::Bool = false)
    few_rows = M <= 256 && N >= 4M
    few_cols = N <= 256 && M >= 4N
    if family == 7 || family == 8
        N <= 16 && return transA ? (8, 32) : (64, 16)
        M <= 16 && return (8, 16)
        M <= 32 && return (32, 16)
        few_rows && return (32, 32)
        few_cols && return transA ? (16, 32) : narrow ? (32, 32) : (16, 64)
        M * N <= 1024 * 1024 && return family == 7 ? (16, 32) : (32, 16)
        narrow && return (32, 32)
        family == 7 && return (32, 64)
        return M > 2048 ? (64, 32) : (32, 32)
    else
        fast = narrow && family != 9
        N <= 16 && return (64, 16)
        M <= 32 && return (16, 8)
        few_rows && return fast ? (64, 16) : (32, 16)
        few_cols && return fast ? (64, 32) : narrow ? (16, 16) : (16, 64)
        M * N <= 1024 * 1024 && return (32, 16)
        return fast ? (64, 32) : (32, 32)
    end
end

# A matrix with contiguous, non-overlapping columns in increasing order, as an array starting
# at its first element and its column stride, so a tensor can be laid over it in place.
# `nothing` for other layouts, and for spans that tensor indices (`Int32`) can't address.
tensor_layout(X::MtlMatrix) = (X, size(X, 1))
function tensor_layout(X::MtlMatrixRangeView{T}) where {T}
    stride(X, 1) == 1 || return nothing
    ld = size(X, 2) == 1 ? size(X, 1) : stride(X, 2)
    ld >= size(X, 1) || return nothing
    len = (size(X, 2) - 1) * ld + size(X, 1)
    len <= typemax(Int32) || return nothing
    return (GPUArrays.derive(T, parent(X), (len,), Base.first_index(X) - 1), ld)
end

# Fill `D` with `op(X)`, gathered through `opelem` so transposes and Symmetric/Hermitian
# wrappers are applied.
function gemm_tensor_pack_kernel!(D, X, ::Val{TX}) where {TX}
    i, j = Tuple(thread_position_in_grid())
    if i <= size(D, 1) && j <= size(D, 2)
        @inbounds D[i, j] = opelem(X, Val(TX), i, j)
    end
    return
end

function gemm_tensor_pack(X, tX::Char, dims::Dims{2})
    D = MtlMatrix{eltype(X)}(undef, dims)
    @metal threads = (16, 16) groups = cld.(dims, 16) gemm_tensor_pack_kernel!(D, X, Val(tX))
    return D
end

# An operand as the kernel reads it: the array, its column stride, and whether it is stored
# transposed. Operands that can't be read in place are packed into a dense copy of op(X).
function tensor_operand(X::MtlMatrixOperand, tX::Char, dims::Dims{2})
    layout = tX in ('N', 'T', 'C') ? tensor_layout(X) : nothing
    if layout === nothing
        D = gemm_tensor_pack(X, tX, dims)
        return D, size(D, 1), false
    end
    return layout..., tX !== 'N'
end

# whether the scalar `x` converts to the integer `T` exactly, as `gemm_tensor!` converts it
function tensor_scalar(::Type{T}, x::Number) where {T <: Integer}
    try
        convert(T, x)
        return true
    catch err
        err isa InexactError || rethrow()
        return false
    end
end

# Whether `gemm_tensor!` can compute `C = α·op(A)·op(B) + β·C` for these operands: a Metal4
# device and an element type combination in `GEMM_TENSOR_ELTYPES`. Every supported eltype is
# real, so an adjoint is a transpose. Shapes, transposes, wrappers, views and α/β are all
# handled by `gemm_tensor!`, except for:
# - an integer C with α or β that its eltype can't represent (e.g. fractional ones). The
#   generic kernel scales before converting to C's eltype, so `0.5·6` gives 3, and a result
#   that isn't an integer throws, as on the CPU;
# - matrices that tensor indices (`Int32`) can't address.
@inline function supports_tensor_matmul(C, A, B, cA::Char, cB::Char,
                                        alpha::Number, beta::Number)
    tensor_matmul_capable() || return false
    gemm_tensor_eltype(eltype(A), eltype(B), eltype(C)) || return false
    eltype(C) <: Integer && !(tensor_scalar(eltype(C), alpha) && tensor_scalar(eltype(C), beta)) &&
        return false
    K = contraction_length(cA, A)
    return all(<=(typemax(Int32)), (length(C), size(C, 1) * K, K * size(C, 2)))
end

"""
    Metal.gemm_tensor!(C, A, B, α=true, β=false, cA='N', cB='N'; tile_m=0, tile_n=0)

Compute `C = α·op(A)·op(B) + β·C` via `tensor_ops::matmul2d`, one simdgroup per
`tile_m × tile_n` tile of `C` (Metal 4 only). The operands must be nonempty and conform;
callers must check [`Metal.supports_tensor_matmul`](@ref) first. Matrices, and views with contiguous columns in
increasing order, are read in place, also when transposed; other operands are packed into
dense copies first. `α` and `β` are applied by the kernel that computes the product, unless
`C` can't be written in place or the contraction is split: a long contraction of a product
with few tiles is split into slices (see `gemm_tensor_splits`). The product, or the partial
products of the slices, then go to a workspace that a second kernel adds up, scales and
combines with `C`.
`tile_*=0` selects the tiles by the rule in `gemm_tensor_tiles`; pass explicit ones to tune. Tiles
must be multiples of 8, and at least one of them a multiple of 16.
"""
function gemm_tensor!(C::MtlMatrixOperand, A::MtlMatrixOperand, B::MtlMatrixOperand,
                      alpha::Number = true, beta::Number = false,
                      cA::Char = 'N', cB::Char = 'N';
                      tile_m::Integer = 0, tile_n::Integer = 0)
    M, N = size(C)
    K = contraction_length(cA, A)
    tile_m >= 0 && tile_n >= 0 && tile_m % 8 == 0 && tile_n % 8 == 0 &&
        (tile_m == 0 || tile_n == 0 || tile_m % 16 == 0 || tile_n % 16 == 0) ||
        throw(ArgumentError("matmul2d tiles must be multiples of 8, one of them of 16; got $tile_m×$tile_n"))

    Ad, lda, trA = tensor_operand(A, cA, (M, K))
    Bd, ldb, trB = tensor_operand(B, cB, (K, N))

    plan = gemm_tensor_plan(M, N, K; family = gemm_tensor_family(), cores = gemm_tensor_cores(),
                            narrow = max(sizeof(eltype(A)), sizeof(eltype(B))) <= 2, trA,
                            tile_m, tile_n)

    # What the kernel does with the product, see `gemm_tensor_tile!`. matmul2d can't scale,
    # but it does all there is to do for α = 1 with β = 0 or 1; otherwise α and β are applied
    # in the thread-local memory of a cooperative tensor. A C that can't be laid out as a
    # tensor, and a split contraction, get the product in a workspace instead, with the
    # partial products of the slices next to each other, which `gemm_tensor_reduce_kernel!`
    # adds up, scales and combines with C.
    #
    # Scaling is done in `Tt`, `Float32` for a float destination, and converted on the store
    # into C, like the simd kernel does. α, β and the unscaled product can be out of range for
    # `Float16` while the result is not, and a narrow C is rounded once, after the slices have
    # been added up. Converting the scalars on the host also keeps `Float64` values and
    # `Bool * BFloat16` out of the kernels, which can't compile them. `matmul2d` produces
    # `Float32` for every input combination that has a float output, and `Int32` for the
    # others, so the product has the type `Tt` too.
    Tt = eltype(C) <: Integer ? eltype(C) : Float32
    α = convert(Tt, alpha)
    β = convert(Tt, beta)
    layout = plan.slices == 1 ? tensor_layout(C) : nothing
    if layout === nothing
        dest, ldc = MtlMatrix{Tt}(undef, M, N * plan.slices), M
        mode = :overwrite
    else
        dest, ldc = layout
        mode = if isone(α) && (iszero(β) || isone(β))
            iszero(β) ? :overwrite : :accumulate
        else
            iszero(β) ? :scale : :scale_add
        end
    end

    tile_m, tile_n = plan.tile
    nthreads = GEMM_TENSOR_WM * GEMM_TENSOR_WN * 32
    @metal threads = nthreads groups = (plan.groups..., plan.slices) gemm_tensor_kernel!(
        dest, Ad, Bd, α, β, Int32(M), Int32(N), Int32(K), Int32(plan.ks), Int32(ldc),
        Int32(lda), Int32(ldb), Val(Int32(tile_m)), Val(Int32(tile_n)), Val(mode), Val(trA),
        Val(trB))

    if layout === nothing
        @metal threads = 256 groups = cld(M * N, 256) gemm_tensor_reduce_kernel!(
            C, dest, α, β, Int32(plan.slices), Val(!iszero(β)))
        # (the buffer is only released once the kernels that use it are done, see `free`)
        unsafe_free!(dest)
    end
    return C
end

## split-K

# However long the contraction, the tile decomposition gives a product with a small `C` few
# threadgroups: 64×64×65536 makes two, which leave most of the GPU idle. Splitting the
# contraction into slices makes more of them. The threadgroups of each slice write its partial
# product to an M×N matrix of its own in a workspace, and a second kernel adds them up.

# the contraction is split into slices of a multiple of this
const GEMM_TENSOR_SPLIT_K = 32

# The number of slices to split a contraction of length `K` into, for a product whose tile
# decomposition gives `groups` threadgroups, on a GPU with `cores` cores; 1 to not split it.
# `narrow` says that both inputs take at most 2 bytes per element.
#
# A product is split into as many slices as keep the threadgroups of all of them within five
# per GPU core, with slices of at least 512 (but the last, which takes what remains), at most
# 32 slices, and a workspace (4 bytes per element of each partial product) of at most 32 MiB.
# More threadgroups don't make up for the overhead of the workspace and of the second kernel:
# on the M1 (8 cores), 256×256×4096 has 32 threadgroups and runs 8-17% slower in 2 or 4
# slices, while the M3 Pro (14 cores) runs 256×256×16384 (32 threadgroups) 1.1-1.2× faster
# in 2. Some products are slower in a few slices than in one, but faster in many: on the
# M3 Pro, 333×222×15000 (42 threadgroups) takes 0.81 ms, 1.16-1.25 ms in 2-4 slices, and
# 0.75 ms in 8.
#
# Products with a 4-byte input, of 512² to 1024² elements, with a contraction of at least
# 8192 are split into slices of about 2048 (or longer ones, to keep the workspace within its
# bound), even when they have enough threadgroups. All of the M1, M2, M3 Pro and M6 multiply
# such contractions more slowly per element than shorter ones: e.g. `Float32` 512×512×16384
# runs in 6.1 ms instead of 8.2 on the M1, 3.5 instead of 7.3 on the M2, 2.3 instead of 3.7
# on the M3 Pro, and 2.0 instead of 5.1 on the M6. Smaller products, and ones with 2-byte
# inputs, don't gain consistently, and larger ones (e.g. 2048×1024×4096) lose.
function gemm_tensor_splits(M::Integer, N::Integer, K::Integer, groups::Integer;
                            cores::Integer, narrow::Bool = false)
    maxsplits = min(32, (32 << 20) ÷ (4 * M * N), K ÷ 512)
    splits = clamp((5 * cores) ÷ groups, 1, max(maxsplits, 1))
    if !narrow && 512 * 512 <= M * N <= 1024 * 1024 && K >= 8192
        splits = max(splits, min(K ÷ 2048, maxsplits))
    end
    return splits
end

# How `gemm_tensor!` launches an M×N×K product: the tile of `C` that a simdgroup computes, the
# threadgroups along M and N, and the slices the contraction is split into, of length `ks`. The
# last slice takes what remains, so there can be fewer of them than `gemm_tensor_splits` asks
# for. `trA` says that A is read transposed, as `gemm_tensor!` prepared it; a `tile_m` or
# `tile_n` of 0 is selected by `gemm_tensor_tiles`.
function gemm_tensor_plan(M::Integer, N::Integer, K::Integer; family::Integer,
                          cores::Integer, narrow::Bool, trA::Bool,
                          tile_m::Integer = 0, tile_n::Integer = 0)
    if tile_m == 0 || tile_n == 0
        auto_m, auto_n = gemm_tensor_tiles(M, N; family, transA = trA, narrow)
        # next to an explicit tile of 8, the selected one needs to be a multiple of 16, and
        # next to one of 64 it stays at 32, as 64×64 is always slower
        pick(given, auto) = given % 16 != 0 && auto % 16 != 0 ? 16 :
                            given == 64 && auto == 64 ? 32 : auto
        if tile_m != 0
            tile_n = pick(tile_m, auto_n)
        elseif tile_n != 0
            tile_m = pick(tile_n, auto_m)
        else
            tile_m, tile_n = auto_m, auto_n
        end
    end
    groups = (cld(M, tile_m * GEMM_TENSOR_WM), cld(N, tile_n * GEMM_TENSOR_WN))
    splits = gemm_tensor_splits(M, N, K, prod(groups); cores, narrow)
    ks = splits == 1 ? K : cld(cld(K, splits), GEMM_TENSOR_SPLIT_K) * GEMM_TENSOR_SPLIT_K
    return (; tile = (tile_m, tile_n), groups, ks, slices = cld(K, ks))
end

# Adds up the `S` partial products in `W` in the order of the slices, so the result doesn't
# depend on the order in which they were computed, and scales the sum and adds `β·C` before
# converting the result to C's element type once. With `β = 0`, C is not read, so whatever
# it holds (e.g. NaN) doesn't reach the result. C is indexed as a matrix, so with `S = 1` this
# is also how the product reaches a C that can't be laid out as a tensor.
function gemm_tensor_reduce_kernel!(C, W, alpha::P, beta::P, S::Int32,
                                    ::Val{BETA}) where {P, BETA}
    M = unsafe_trunc(Int32, size(C, 1))
    MN = M * unsafe_trunc(Int32, size(C, 2))
    idx = unsafe_trunc(Int32, thread_position_in_grid().x) - Int32(1)
    idx < MN || return
    acc = @inbounds W[idx + Int32(1)]
    z = Int32(1)
    while z < S
        acc += @inbounds W[z * MN + idx + Int32(1)]
        z += Int32(1)
    end
    j = div(idx, M)
    i = idx - j * M
    acc *= alpha
    BETA && (acc += beta * convert(P, @inbounds C[i + Int32(1), j + Int32(1)]))
    @inbounds C[i + Int32(1), j + Int32(1)] = acc
    return
end

## host entry points

# The simd kernel stages A/B as Float32 and contracts in Float32, so the only eltype-specific
# simdgroup ops are the load/store of `C`; `BFloat16` rides the same `bf16` simdgroup intrinsics
# (re-typed from i16 by GPUCompiler before Julia 1.13). See `device/intrinsics/simd.jl`.
@inline gemm_simd_eltype(::Type{<:Union{Float16, Float32, BFloat16}},
                          ::Type{<:Union{Float16, Float32, BFloat16}},
                          ::Type{<:Union{Float16, Float32, BFloat16}}) = true
@inline gemm_simd_eltype(::Type, ::Type, ::Type) = false

# Operand-support predicate for the simdgroup kernel, mirroring `supports_mps_matmul` /
# `supports_mpsgraph_matmul` / `supports_tensor_matmul`: it handles any transpose/α/β/shape/
# offset, so it only needs a float eltype.
@inline supports_simd_matmul(C, A, B, cA::Char, cB::Char, alpha::Number, beta::Number) =
    gemm_simd_eltype(eltype(A), eltype(B), eltype(C))

# tile configuration for the fast path. WM×WN simdgroups per threadgroup, each with
# a TM×TN grid of 8x8 accumulators (keep TM·TN ≤ 16 to avoid register spilling),
# contraction depth BK = 8·KB. BM×BN = (8·TM·WM)×(8·TN·WN) output per threadgroup.
# WM=WN=2 (128 threads, 4 simdgroups): matches MLX/m5-gemm; gives 4× more concurrent
# threadgroups per core vs WM=WN=4. TM=TN=4 gives 16 MACs per simdgroup per K-step
# (vs 4 for TM=TN=2), maximizing arithmetic intensity. KB=1: a deeper KB=2 tile halves the
# barrier count, but runs 3× slower on M1 and 20% slower on M3 Pro.
const GEMM_SIMD_WM = 2
const GEMM_SIMD_WN = 2
const GEMM_SIMD_TM = 4
const GEMM_SIMD_TN = 4
const GEMM_SIMD_KB = 1

# the unrolled tile staging (`load_tile`) gives every thread the same number of elements
let nthreads = GEMM_SIMD_WM * GEMM_SIMD_WN * 32, BK = 8 * GEMM_SIMD_KB
    @assert (8 * GEMM_SIMD_TM * GEMM_SIMD_WM * BK) % nthreads == 0
    @assert (8 * GEMM_SIMD_TN * GEMM_SIMD_WN * BK) % nthreads == 0
end

function gemm_simd!(C, A, B, alpha, beta, cA::Char, cB::Char)
    M = size(C, 1); N = size(C, 2)
    K = contraction_length(cA, A)
    WM = GEMM_SIMD_WM; WN = GEMM_SIMD_WN
    TM = GEMM_SIMD_TM; TN = GEMM_SIMD_TN; KB = GEMM_SIMD_KB
    BM = 8 * TM * WM; BN = 8 * TN * WN
    threads = WM * WN * 32
    groups = (cld(M, BM), cld(N, BN))
    # aligned tiles skip the bounds-checked edge path; α=1,β=0 skips the α/β arithmetic.
    # `simdgroup_store` addresses C by its leading dimension, so view destinations — like
    # `BFloat16` outputs (see `simd_direct_store`) — always take the edge path's f32
    # scratch, which accesses C elementwise.
    direct = C isa MtlMatrix && simd_direct_store(eltype(C))
    edge = !(M % BM == 0 && N % BN == 0) || !direct
    simple = isone(alpha) && iszero(beta)
    @metal threads=threads groups=groups gemm_simd_kernel!(
        C, A, B, Float32(alpha), Float32(beta), Int(M), Int(N), Int(K),
        Val(cA), Val(cB), Val(WM), Val(WN), Val(TM), Val(TN), Val(KB), Val(edge), Val(simple),
        Val(direct))
    return C
end

"""
    Metal.gemm!(C, tA, tB, A, B, α, β; kernel=:auto)

Native GEMM computing `C = α·op_tA(A)·op_tB(B) + β·C` for `MtlMatrix` operands, or
range-based `view`s of them (including the destination).
`tA`/`tB ∈ {'N','T','C'}`, or one of the LinearAlgebra wrapper chars `{'S','s','H','h'}`
applying a Symmetric/Hermitian view of the operand (upper/lowercase selects the stored
triangle). Backs the `:native`/`:auto` matmul paths (`kernel=:auto`, picking the tensor
or the simd kernel, or GPUArrays' generic kernels for operands that neither supports) and
the `:simd`/`:tensor` paths, which set `kernel` to force a specific kernel. Forcing a
kernel that cannot handle the operands is the caller's responsibility (see
`supports_simd_matmul`/`supports_tensor_matmul`). All kernels handle every operand char:
the simd kernel and the generic ones gather elementwise through `opelem`, and the tensor
kernel packs the operands it can't read in place through it.
"""
function gemm!(C::MtlMatrixOperand, tA::Char, tB::Char,
               A::MtlMatrixOperand, B::MtlMatrixOperand,
               alpha::Number, beta::Number; kernel::Symbol = :auto)
    M = size(C, 1); N = size(C, 2)
    K = contraction_length(tA, A)
    alpha, beta = device_scalar(alpha), device_scalar(beta)

    # nothing to compute
    (M == 0 || N == 0) && return C

    # no contribution from A·B (empty contraction, or α = 0 which LinearAlgebra
    # defines as never reading A·B): C = β·C
    if K == 0 || iszero(alpha)
        if iszero(beta)
            fill!(C, zero(eltype(C)))
        elseif !isone(beta)
            C .*= beta
        end
        return C
    end

    # `:auto` picks the Metal 4 tensor-ops fast path when the device and operands allow it,
    # then the portable simdgroup kernel for floats, then GPUArrays' generic kernels; an
    # explicit `kernel` forces one of the first two.
    if kernel === :tensor
        supports_tensor_matmul(C, A, B, tA, tB, alpha, beta) ||
            error("tensor-ops GEMM is not supported for these operands")
        gemm_tensor!(C, A, B, alpha, beta, tA, tB)
    elseif kernel === :auto && supports_tensor_matmul(C, A, B, tA, tB, alpha, beta)
        gemm_tensor!(C, A, B, alpha, beta, tA, tB)
    elseif kernel === :simd || (kernel === :auto && supports_simd_matmul(C, A, B, tA, tB, alpha, beta))
        gemm_simd!(C, A, B, alpha, beta, tA, tB)
    elseif kernel === :auto
        generic_matmul!(C, tA, tB, A, B, alpha, beta)
    else
        throw(ArgumentError("unknown GEMM kernel `:$kernel`"))
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
