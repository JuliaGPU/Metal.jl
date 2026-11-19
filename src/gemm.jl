# Native Julia GEMM for Metal.
#
# Three device kernels back the native matmul paths (see `src/linalg.jl`); the matmul
# algorithm `:simd`/`:scalar`/`:tensor` forces one, while `:native`/`:auto` pick among them:
#
#  * `gemm_tensor_kernel!` is the Metal 4 fast path. It drives `tensor_ops::matmul2d`
#    over a tile decomposition. Only available on Metal4-capable devices, for the element
#    type combinations in `GEMM_TENSOR_ELTYPES`. Matrices, and views with contiguous columns
#    in increasing order, are read in place, also transposed ones; Symmetric/Hermitian
#    wrappers and other views are packed into dense copies, and α and β are applied around
#    the kernel (`gemm_tensor!`).
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

## scalar path: per-element shared-memory tiled kernel (any eltype / transpose / offset)

# α/β scaling for the scalar kernel. LinearAlgebra passes `Bool` α/β (`MulAddMul`'s
# strong-zero flags), and `Bool * AbstractFloat` lowers through `copysign` — which the
# Metal backend cannot compile for `BFloat16` — so handle `Bool` with a select instead.
# (The false cases never execute: α = 0 returns early in `gemm!` and β = 0 takes the
# `iszero` branch below; they just have to compile.)
@inline bscale(a, x) = a * x
@inline bscale(a::Bool, x) = a ? x : zero(x)

function gemm_scalar_kernel!(C, A, B, alpha, beta,
                              M, N, K, ::Val{TA}, ::Val{TB}, ::Val{TILE}) where {TA, TB, TILE}
    TAT = eltype(A); TBT = eltype(B); R = eltype(C)

    # accumulate in a wide enough type so narrow-integer (Int8/Int16) inputs don't
    # overflow.
    Tacc = promote_type(R, typeof(zero(TAT) * zero(TBT) + zero(TAT) * zero(TBT)))

    li = Int(thread_position_in_threadgroup().x)
    lj = Int(thread_position_in_threadgroup().y)
    gi = (Int(threadgroup_position_in_grid().x) - 1) * TILE + li
    gj = (Int(threadgroup_position_in_grid().y) - 1) * TILE + lj

    As = MtlThreadGroupArray(TAT, (TILE, TILE))
    Bs = MtlThreadGroupArray(TBT, (TILE, TILE))

    acc = zero(Tacc)
    nkt = cld(K, TILE)
    kt = 0
    while kt < nkt
        k0 = kt * TILE
        ac = k0 + lj
        @inbounds As[li, lj] = (gi <= M && ac <= K) ? opelem(A, Val(TA), gi, ac) : zero(TAT)
        ar = k0 + li
        @inbounds Bs[li, lj] = (ar <= K && gj <= N) ? opelem(B, Val(TB), ar, gj) : zero(TBT)
        threadgroup_barrier(MemoryFlagThreadGroup)
        @inbounds for kk in 1:TILE
            acc = muladd(As[li, kk], Bs[kk, lj], acc)
        end
        threadgroup_barrier(MemoryFlagThreadGroup)
        kt += 1
    end

    if gi <= M && gj <= N
        # `setindex!` converts to `R` for us; an explicit `R(...)` would additionally
        # demand a constructor, which element types like `SVector` don't provide
        if iszero(beta)
            @inbounds C[gi, gj] = bscale(alpha, acc)
        else
            @inbounds C[gi, gj] = bscale(alpha, acc) + bscale(beta, C[gi, gj])
        end
    end
    return
end

## tensor path: Metal 4 `tensor_ops::matmul2d` (macOS 26+, Metal4-capable devices)

# Tiled matmul on top of `tensor_ops::matmul2d`, laid out as Apple's Metal Performance
# Primitives programming guide recommends. A threadgroup holds WM×WN simdgroups, and each
# simdgroup computes an SM×SN tile of `C` of its own, specialized on the tile shape so the
# matmul descriptor is a compile-time constant.
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
# `MODE` is what happens to the product: `:overwrite` writes it to C, and `:accumulate` adds it
# to what C holds.
function gemm_tensor_kernel!(C::MtlDeviceArray, A::MtlDeviceArray, B::MtlDeviceArray,
                             M::Int32, N::Int32, K::Int32,
                             ldc::Int32, lda::Int32, ldb::Int32,
                             ::Val{SM}, ::Val{SN}, ::Val{WM}, ::Val{WN}, ::Val{MODE},
                             ::Val{TRA}, ::Val{TRB}) where {SM, SN, WM, WN, MODE, TRA, TRB}
    tgid  = threadgroup_position_in_grid_3d()
    sgid  = unsafe_trunc(Int32, simdgroup_index_in_threadgroup()) - Int32(1)
    m_off = (unsafe_trunc(Int32, tgid.x) - Int32(1)) * Int32(SM * WM) + rem(sgid, Int32(WM)) * Int32(SM)
    n_off = (unsafe_trunc(Int32, tgid.y) - Int32(1)) * Int32(SN * WN) + div(sgid, Int32(WM)) * Int32(SN)
    # (of a threadgroup at the edge, some simdgroups can lie outside of `C`)
    (m_off >= M || n_off >= N) && return
    tm = min(Int32(SM), M - m_off)
    tn = min(Int32(SN), N - n_off)

    tA = MtlInlineTensor(A, TRA ? (K, M) : (M, K), (Int32(1), lda))
    tB = MtlInlineTensor(B, TRB ? (N, K) : (K, N), (Int32(1), ldb))
    tC = MtlInlineTensor(C, (M, N), (Int32(1), ldc))

    mA = TRA ? view(tA, (Int32(1), m_off + Int32(1)), (K, tm)) :
               view(tA, (m_off + Int32(1), Int32(1)), (tm, K))
    mB = TRB ? view(tB, (n_off + Int32(1), Int32(1)), (tn, K)) :
               view(tB, (Int32(1), n_off + Int32(1)), (K, tn))
    mC = view(tC, (m_off + Int32(1), n_off + Int32(1)), (tm, tn))

    mode = MODE === :accumulate ? matmul2d_multiply_accumulate : matmul2d_multiply
    op = TensorOpsMatmul2D{matmul2d_descriptor(SM, SN; transpose_left = TRA,
                                               transpose_right = TRB, mode),
                           Int32(1)}()
    op(mA, mB, mC)
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

# The size of the tile of `C` that one simdgroup computes. Apple's guide recommends 32×32 with
# 2×2 simdgroups per threadgroup, which is also the fastest here for large products. Smaller
# and thin ones are faster with tiles of 16, which occupy more of the GPU, and the rows grow
# to 32 before the columns do. A product of a few columns, like a matrix-vector one, is a
# little faster still with tiles of 8 columns. The thresholds were measured on an M2 Max with
# `Float32` and `Float16`; tiles of 64 are slower. matmul2d requires tiles that are multiples
# of 8, at least one of them a multiple of 16.
const GEMM_TENSOR_WM = 2
const GEMM_TENSOR_WN = 2

function gemm_tensor_tiles(M::Integer, N::Integer)
    area = M * N
    tm = (area >= 512 * 512 && M >= 64) ? 32 : 16
    tn = (area >= 2048 * 2048 && N >= 64) ? 32 : N <= 8 ? 8 : 16
    return (tm, tn)
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
#   scalar kernel scales before converting to C's eltype, so `0.5·6` gives 3, and a result
#   that isn't an integer throws, as on the CPU;
# - matrices that tensor indices (`Int32`) can't address.
@inline function supports_tensor_matmul(C, A, B, cA::Char, cB::Char,
                                        alpha::Number, beta::Number)
    tensor_matmul_capable() || return false
    gemm_tensor_eltype(eltype(A), eltype(B), eltype(C)) || return false
    eltype(C) <: Integer && !(tensor_scalar(eltype(C), alpha) && tensor_scalar(eltype(C), beta)) &&
        return false
    K = (cA === 'T' || cA === 'C') ? size(A, 1) : size(A, 2)
    return all(<=(typemax(Int32)), (length(C), size(C, 1) * K, K * size(C, 2)))
end

"""
    Metal.gemm_tensor!(C, A, B, α=true, β=false, cA='N', cB='N'; tile_m=0, tile_n=0)

Compute `C = α·op(A)·op(B) + β·C` via `tensor_ops::matmul2d`, one simdgroup per
`tile_m × tile_n` tile of `C` (Metal 4 only). The operands must be nonempty and conform;
callers must check [`Metal.supports_tensor_matmul`](@ref) first. Matrices, and views with contiguous columns in
increasing order, are read in place, also when transposed; other operands are packed into
dense copies first. The product goes through a temporary when `α ≠ 1`, when `C` can't be
written in place, or when a `Float16`/`BFloat16` `C` is scaled by `β ≠ 0, 1`.
`tile_*=0` selects the tiles by the rule in `gemm_tensor_tiles`; pass explicit ones to tune. Tiles
must be multiples of 8, and at least one of them a multiple of 16.
"""
function gemm_tensor!(C::MtlMatrixOperand, A::MtlMatrixOperand, B::MtlMatrixOperand,
                      alpha::Number = true, beta::Number = false,
                      cA::Char = 'N', cB::Char = 'N';
                      tile_m::Integer = 0, tile_n::Integer = 0)
    M, N = size(C)
    K = (cA === 'T' || cA === 'C') ? size(A, 1) : size(A, 2)
    auto_m, auto_n = gemm_tensor_tiles(M, N)
    tile_m = tile_m == 0 ? auto_m : tile_m
    tile_n = tile_n == 0 ? auto_n : tile_n
    tile_m > 0 && tile_n > 0 && tile_m % 8 == 0 && tile_n % 8 == 0 &&
        (tile_m % 16 == 0 || tile_n % 16 == 0) ||
        throw(ArgumentError("matmul2d tiles must be multiples of 8, one of them of 16; got $tile_m×$tile_n"))

    Ad, lda, trA = tensor_operand(A, cA, (M, K))
    Bd, ldb, trB = tensor_operand(B, cB, (K, N))

    # matmul2d can't scale, so α and β are applied around it. With α = 1 the product goes
    # straight into C, added to the β-scaled C unless β = 0. Otherwise, or when C can't be
    # laid out as a tensor, it goes into a temporary that is combined with C after. So does
    # it for a narrow C (`Float16`, `BFloat16`) with β ≠ 0, 1: storing β·C would round it to
    # C's precision, or overflow, before the product is added.
    #
    # Scaling is done in `Tt`, `Float32` for a float destination, and converted on the store
    # into C, like the simd kernel does. α, β and the unscaled product can be out of range for
    # `Float16` while the result is not. Converting the scalars on the host also keeps
    # `Float64` values and `Bool * BFloat16` (see `bscale`) out of the broadcasts, which
    # can't compile them. `matmul2d` produces `Float32` for every input combination that has
    # a float output, so the temporary has that type too.
    Tt = eltype(C) <: Integer ? eltype(C) : Float32
    α = convert(Tt, alpha)
    β = convert(Tt, beta)
    layout = tensor_layout(C)
    mode = if layout === nothing
        nothing
    elseif isone(alpha) && (iszero(beta) || isone(beta))
        iszero(beta) ? :overwrite : :accumulate
    elseif isone(alpha) && eltype(C) === Tt
        C .= β .* Tt.(C)
        :accumulate
    else
        nothing
    end
    direct = mode !== nothing
    Cd, ldc = direct ? layout : (MtlMatrix{Tt}(undef, M, N), M)
    direct || (mode = :overwrite)

    wm, wn = GEMM_TENSOR_WM, GEMM_TENSOR_WN
    groups = (cld(M, tile_m * wm), cld(N, tile_n * wn))
    @metal threads = wm * wn * 32 groups = groups gemm_tensor_kernel!(
        Cd, Ad, Bd, Int32(M), Int32(N), Int32(K), Int32(ldc), Int32(lda), Int32(ldb),
        Val(Int32(tile_m)), Val(Int32(tile_n)), Val(Int32(wm)), Val(Int32(wn)), Val(mode),
        Val(trA), Val(trB))

    if !direct
        if iszero(β)
            C .= α .* Cd
        else
            C .= α .* Cd .+ β .* Tt.(C)
        end
    end
    return C
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
# offset, so it only needs a float eltype. The scalar kernel is the universal fallback and
# handles any eltype, so it needs no such predicate (it is the kernel `:native` falls back to).
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
    K = (cA === 'T' || cA === 'C') ? size(A, 1) : size(A, 2)
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

const GEMM_SCALAR_TILE = 16

function gemm_scalar!(C, A, B, alpha, beta, cA::Char, cB::Char)
    M = size(C, 1); N = size(C, 2)
    K = (cA === 'T' || cA === 'C') ? size(A, 1) : size(A, 2)
    TILE = GEMM_SCALAR_TILE
    threads = (TILE, TILE)
    groups = (cld(M, TILE), cld(N, TILE))
    @metal threads=threads groups=groups gemm_scalar_kernel!(
        C, A, B, alpha, beta, Int(M), Int(N), Int(K), Val(cA), Val(cB), Val(TILE))
    return C
end

"""
    Metal.gemm!(C, tA, tB, A, B, α, β; kernel=:auto)

Native GEMM computing `C = α·op_tA(A)·op_tB(B) + β·C` for `MtlMatrix` operands, or
range-based `view`s of them (including the destination).
`tA`/`tB ∈ {'N','T','C'}`, or one of the LinearAlgebra wrapper chars `{'S','s','H','h'}`
applying a Symmetric/Hermitian view of the operand (upper/lowercase selects the stored
triangle). Backs the `:native`/`:auto` matmul paths (`kernel=:auto`, picking
the best of the tensor/simd/scalar kernels) and the `:simd`/`:scalar`/`:tensor` paths, which set
`kernel` to force a specific kernel. Forcing a kernel that cannot handle the operands is the
caller's responsibility (see `supports_simd_matmul`/`supports_tensor_matmul`). All kernels
handle every operand char: the simd and scalar kernels gather elementwise through `opelem`,
and the tensor kernel packs the operands it can't read in place through it.
"""
function gemm!(C::MtlMatrixOperand, tA::Char, tB::Char,
               A::MtlMatrixOperand, B::MtlMatrixOperand,
               alpha::Number, beta::Number; kernel::Symbol = :auto)
    M = size(C, 1); N = size(C, 2)
    K = (tA === 'T' || tA === 'C') ? size(A, 1) : size(A, 2)
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
    # then the portable simdgroup kernel for floats, then the scalar fallback; an
    # explicit `kernel` forces one of them.
    if kernel === :tensor
        supports_tensor_matmul(C, A, B, tA, tB, alpha, beta) ||
            error("tensor-ops GEMM is not supported for these operands")
        gemm_tensor!(C, A, B, alpha, beta, tA, tB)
    elseif kernel === :auto && supports_tensor_matmul(C, A, B, tA, tB, alpha, beta)
        gemm_tensor!(C, A, B, alpha, beta, tA, tB)
    elseif kernel === :simd || (kernel === :auto && supports_simd_matmul(C, A, B, tA, tB, alpha, beta))
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
