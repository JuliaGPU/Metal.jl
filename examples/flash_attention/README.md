# Flash Attention examples

Two reference implementations of scaled dot-product attention on Apple
Silicon GPUs from Julia, illustrating different programming models that
Metal.jl exposes.

## `fa_mps.jl`

The trivial baseline. Uses standard Julia operators (`*`, broadcasting,
`maximum`, `sum`, `exp`) on `MtlArray`. The matrix multiplications are
dispatched to **MPSGraph / MPSMatrixMultiplication** by
[`src/linalg.jl`](../../src/linalg.jl); the rest is GPUArrays.

Not actually a Flash Attention algorithm — the full N×N scores matrix is
materialized in device memory — but it is the right reference to verify a
custom kernel against, and the fastest path to "attention runs on GPU"
when you don't need a custom kernel.

Works on macOS 13+ / M1+.

## `fa_mpsgraph.jl`

The high-level MPS path. Builds a one-node MPSGraph using
`scaledDotProductAttentionWithQueryTensor` (macOS 14+), which fuses
Q·Kᵀ → scale → softmax → ·V into a single op. Apple uses the same op as
the backbone of their own SDPA paths (MLX falls back to it; Core ML
lowers attention to it), so it's the closest thing to "ask Apple for
attention" that Metal.jl can give you.

Inputs are 4-D `(head_dim, seq, num_heads, batch)` in Julia — MPSGraph
sees these reversed as `(batch, num_heads, seq, head_dim)`, the layout
Apple's SDPA expects.

Works on macOS 14+ / M1+.

## `fa_simdgroup.jl`

A single-block scaled dot-product attention kernel built from
`MtlSimdgroupMatrix{Float16, 8, 8}` (see `src/device/intrinsics/`). One
simdgroup of 32 lanes does the QKᵀ and PV matrix multiplies via two
`simdgroup_matrix` ops; the row-wise softmax is done in scalar code
through threadgroup memory.

The example is intentionally minimal — Q, K, V are fixed at 8×8 — so the
control flow stays readable. A production implementation would:

  - sweep KV in blocks with online-softmax state (`m`, `l` per query row),
  - tile D across multiple simdgroups,
  - overlap loads with compute via `simdgroup_async_copy`,
  - and split the backward pass into separate dQ / dKV kernels to avoid
    FP32 atomics on Apple GPUs.

See [philipturner/metal-flash-attention](https://github.com/philipturner/metal-flash-attention)
for a tuned reference (Swift + MSL, ~83 % ALU on M1 Max).

K is host-transposed to `K_t` before launch — Metal.jl's `simdgroup_load`
issues a transposed-from-MSL load to compensate for Julia's column-major
storage, so `Q · K_t` in the kernel equals mathematical `Q · K^T`.
Exposing a `transpose=false` variant of `simdgroup_load` would let the
host transpose drop; that's a small follow-up to
`src/device/intrinsics/simd.jl`.

Works on macOS 13+ / M1+.

## Not included: `fa_metal4.jl`

A third path would use the Metal 4 `cooperative_tensor` /
`tensor_ops::matmul2d` primitives with postfix-fusion of the softmax
epilogue. Apple positions this as the "preferred programming model for
ML applications" — on M5 hardware it can issue Neural-Accelerator MMAs
and skip threadgroup memory entirely.

That path is not yet wired up in Metal.jl. The Objective-C classes are
already generated in `lib/mtl/libmtl.jl` (gated on `macos(v"26.0.0")`);
what remains is a Julia-side `MtlCooperativeTensor` wrapper plus a
host-side `MTLTensor` / `MTL4ComputeCommandEncoder` binding. Note that
the device-side ops lower to externally-defined
`__tensorops_impl_matmul2d_op_*` symbols rather than `air.*` intrinsics,
so the binding pattern differs from the SIMD-group case. Validation
needs macOS 26 + Xcode 26; M5 hardware is required to see the
Neural-Accelerator speedup.

## References

  - Apple — *Discover Metal 4* (WWDC25 Session 205) and
    *Combine Metal 4 machine learning and graphics* (WWDC25 Session 262).
  - Apple — *Metal Performance Primitives Programming Guide* (PDF, 2025).
  - philipturner — [metal-flash-attention](https://github.com/philipturner/metal-flash-attention).
  - llama.cpp — [Metal 4 cooperative-tensor FA backend (PR #16634)](https://github.com/ggml-org/llama.cpp/pull/16634).
  - liuliu — [example_matmul_metal4](https://github.com/liuliu/example_matmul_metal4) (minimal MSL probe for the Metal 4 host API).
