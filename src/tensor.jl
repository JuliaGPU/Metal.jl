# High-level tile-decomposed matmul on top of `tensor_ops::matmul2d`.

# Specialized on the tile shape (TM, TN, TK) and simdgroup count (NSIMD) so the
# matmul descriptor and execution width are compile-time constants — see
# `TensorOpsMatmul2D`.
function tensor_matmul_kernel!(C::MtlDeviceArray, A::MtlDeviceArray, B::MtlDeviceArray,
                               M::UInt32, N::UInt32, K::UInt32,
                               ::Val{TM}, ::Val{TN}, ::Val{TK},
                               ::Val{NSIMD}) where {TM, TN, TK, NSIMD}
    tgid    = threadgroup_position_in_grid_3d()
    n_tile  = Int32(tgid.x) - Int32(1)
    m_tile  = Int32(tgid.y) - Int32(1)
    n_off   = n_tile * Int32(TN)
    m_off   = m_tile * Int32(TM)

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

"""
    tensor_matmul!(C, A, B; tile_m=64, tile_n=64, tile_k=32)

Compute `C = A * B` (Julia matrix-product semantics) using
`tensor_ops::matmul2d` with a tile decomposition. `A` is `(m, k)`, `B` is
`(k, n)`, `C` is `(m, n)`, all column-major `MtlMatrix`. `C` is zeroed
before the matmul (the kernel accumulates).

`tile_m`, `tile_n`, `tile_k` set the per-threadgroup tile shape. The
matrix dimensions must be evenly divisible by their respective tiles
(`m % tile_m == 0`, `n % tile_n == 0`, `k % tile_k == 0`). Each
threadgroup uses 4 SIMD-groups (128 threads on the M1/M2 hardware) and
covers one `(tile_m, tile_n)` output tile; the K dimension is looped over
inside the kernel via `multiply_accumulate`.

The implementation maps Julia's natural `C = A * B` to the matmul2d
operand convention by swapping `A`/`B` at the kernel level: matmul2d's
`apple_A` slot receives Julia's `B`, its `apple_B` slot receives Julia's
`A`. This lets every operand use packed strides without an explicit
transpose flag — matmul2d's storage order for the (M, N) output happens
to be the transpose of how Julia reads the same buffer column-major, so
two swaps cancel out and the user gets the answer they expect.

Requires macOS 26+.
"""
function tensor_matmul!(C::MtlMatrix{TC}, A::MtlMatrix{TA}, B::MtlMatrix{TB};
                        tile_m::Integer = 64, tile_n::Integer = 64,
                        tile_k::Integer = 32) where {TA, TB, TC}
    m, k = size(A)
    k2, n = size(B)
    k == k2 || throw(DimensionMismatch(
        "A is ($m, $k), B is ($k2, $n) — inner dims must match"))
    size(C) == (m, n) || throw(DimensionMismatch(
        "C is $(size(C)), expected ($m, $n)"))

    # Apple-side dims (see above for the swap derivation).
    aM, aN, aK = n, m, k
    aM % tile_m == 0 || throw(ArgumentError(
        "tile_m=$tile_m must divide n=$n"))
    aN % tile_n == 0 || throw(ArgumentError(
        "tile_n=$tile_n must divide m=$m"))
    aK % tile_k == 0 || throw(ArgumentError(
        "tile_k=$tile_k must divide k=$k"))

    fill!(C, zero(TC))
    groups = (aN ÷ tile_n, aM ÷ tile_m, 1)
    nsimd = 4
    @metal threads = nsimd * 32 groups = groups tensor_matmul_kernel!(
        C, A, B,
        UInt32(aM), UInt32(aN), UInt32(aK),
        Val(Int32(tile_m)), Val(Int32(tile_n)), Val(Int32(tile_k)),
        Val(Int32(nsimd)))
    return C
end
