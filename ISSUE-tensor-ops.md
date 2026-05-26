# Metal 4 tensor ops (matmul2d / cooperative_tensor) — status

## What's working

`examples/flashattention.jl` now has an `attention_tensor(Q, K, V)` path that
dispatches the two attention matmuls via the Metal 4 `tensor_ops::matmul2d`
primitives. It matches the CPU reference at `D = N = 64`, single head, single
batch. Requires macOS 26+.

The device-side wrappers live in `src/device/intrinsics/tensor.jl`:

- `MtlInlineTensor{T, R}` — kernel-stack tensor view (`tensor_inline` form)
  over an `MtlDeviceArray`. Built via `air.init_strided_private_tensor`. The
  per-thread tensor descriptor is held by a `Ref{NTuple{64, UInt8}}` —
  Julia's `llvm-alloc-opt` pass promotes it to a stack alloca because every
  use is `@inline`d into the kernel and the gc-managed object only escapes
  via `pointer_from_objref` (which `allocopt` treats as `addrescaped`, not
  `escaped`). `GC.@preserve` around the ccalls keeps the buffer alive
  across the runtime calls.
- `matmul2d_descriptor(m, n, k=-1; transpose_left, transpose_right,
  relaxed_precision, mode)` — 20-byte POD matching
  `mpp::tensor_ops::matmul2d_descriptor`.
- `tensor_ops_matmul2d!(desc, left, right, dest, threads)` — dispatches one
  of `__tensorops_impl_matmul2d_op_run_dv_{tl}_dv_{tr}_dv_{td}` based on the
  element types of the operand tensors. `threads` must equal
  `simdgroup_size * num_simdgroups` for the descriptor's scope.

The inline-tensor route lets us reuse the existing Metal.jl kernel ABI:
kernel args are still `MtlDeviceArray`s, so no host-side `MTLTensor` /
`MTL4ComputeCommandEncoder` wrapping is needed.

The GPUCompiler bits:

- `GPUCompiler/src/metal.jl` `isintrinsic` whitelists `__tensorops_impl_`
  symbols (alongside `air.`).
- `annotate_air_intrinsics!` attaches `section "air.externally_defined"` and
  `(convergent, nounwind)` attributes to `__tensorops_impl_*` declarations.
  Without the section attribute, the metallib back-end won't resolve the
  symbol from the MetalPerformancePrimitives runtime.

## What's intentionally not exposed

- **`static_slice<>` / compile-time extents.** Apple's tensor API only
  exposes `static_slice` on `tensor_handle` operands, not `tensor_inline`.
  An inline tensor built with static extents (e.g.
  `tensor<device half, extents<int32_t, 64, 32>, tensor_inline>`) emits
  identical AIR to one built with dynamic extents — same
  `air.init_strided_private_tensor` + runtime extents arrays. So encoding
  static extents in the `MtlInlineTensor` type would only buy us a slightly
  smaller alloca for the extents tuple; it would not enable bounds-check
  elision in the matmul or in the slice path. We leave it dynamic.

## What's not working / known limitations

- **Two `__tensorops_impl_matmul2d_op_run_*` calls in one kernel crash the
  Metal back-end** at pipeline-state creation
  (`XPC_ERROR_CONNECTION_INTERRUPTED` from `AGXMetalG15X_M1`). MSL-compiled
  metallibs of the same kernel shape build pipeline states fine, so the
  crash is triggered by our specific AIR pattern: the
  `matmul2d_descriptor` ends up populated as a sequence of per-field
  stores (via Julia's lowering of `Ref(::matmul2d_descriptor)` and SROA),
  rather than Apple's pattern of `memcpy` from a `linkonce_odr` constant
  global. The likely fix is to emit the constant-global + memcpy pattern
  for descriptors whose fields are compile-time constants. Local
  reproducer in `bugs/two_matmul_crash/` (gitignored — see the README
  there for the AIR diff and what's been tried). The attention example
  sidesteps this by splitting QK and PV into two dispatches.
- **No `cooperative_tensor` yet.** That means the softmax epilogue can't be
  done in registers — the scores tile is materialized in device memory. A
  proper Flash Attention would fuse the softmax into the cooperative tensor
  between the two matmuls.
- **No `tensor_handle` kernel args.** Apple's matmul samples (and the bulk of
  the MPP docs) describe tensors as host-bound `MTLTensor` parameters that
  arrive in the kernel as opaque `%struct._tensor_t addrspace(1)*`. That
  requires both a host-side `MTL4ArgumentTable` / `MTLTensor` wrapping and a
  Metal.jl kernel-ABI rewrite. Inline tensors give us most of the
  expressiveness without any of that.
- **No threadgroup-memory matmul.** Only `dv_*` (device-memory) variants of
  the run helpers are wrapped. `tg_*` variants would let us stage tiles into
  threadgroup memory.
- **`D == N` only.** The attention example uses one matmul descriptor sized
  to a single 64×64 tile; supporting arbitrary `D, N` means dispatching
  multiple threadgroups and tiling on the host.

## Reverse-engineering reference

Annotated AIR for the kernels we generate Apple-style equivalents for:

- `bin/simple_matmul.metal` / `bin/simple_matmul.ll` — minimal NN matmul,
  device-memory destination, `tensor_handle` parameters.
- `bin/coop_matmul.metal` / `bin/coop_matmul.ll` — cooperative-tensor
  destination with a trivial scale-by-2 postfix epilogue. Closest template
  for the proper Flash Attention path.
- `bin/inline_matmul.metal` / `bin/inline_matmul.ll` — the `tensor_inline`
  form that Metal.jl actually uses. Matches the IR shape our wrappers emit.

Apple's headers:

- `<MetalToolchain>/usr/metal/<ver>/lib/clang/<ver>/include/metal/{metal_tensor,metal_cooperative_tensor}`
- `/System/Library/Frameworks/MetalPerformancePrimitives.framework/Versions/A/Headers/{MPPTensorOpsMatMul2d.h,__impl/MPPTensorOpsMatMul2dImpl.h}`

### AIR shapes used by our wrappers

Inline tensor construction (`air.*` intrinsics, in `i32`-indexed flavor):

```llvm
i16 @air.get_descriptor_size_tensor(i16 rank, i16 index_size)
void @air.init_strided_private_tensor.i32.global(i8* %handle, i16 rank,
                                                 i8 addrspace(1)* %data,
                                                 i8* %extents, i8* %strides,
                                                 i8 %contiguous)
i32  @air.get_extent_private_tensor.i32(i8* %handle, i16 rank, i16 dim)
void @air.slice_private_tensor_private_tensor.s.i32(i8* %dst, i8* %src,
                                                    i16 rank, i8* %origin,
                                                    i8* %extents)
```

Matmul run (externally-defined, `section "air.externally_defined"`):

```llvm
void @__tensorops_impl_matmul2d_op_run_dv_{tl}_dv_{tr}_dv_{td}(
    %"struct.matmul2d_descriptor"* %desc,
    i8* %left,        i32 %left_desc_type,
    i8* %right,       i32 %right_desc_type,
    i8* %destination, i32 %dest_desc_type,
    i32 %threads)
```

`{tl}, {tr}, {td}` are element-type suffixes (`f16`, `f32`, `bf16`, `i8`, …)
and the descriptor types are `1` for `tensor_handle`, `2` for
`tensor_inline`.

## What's still TODO

In rough order of value:

1. **`MtlCooperativeTensor`** — would enable the proper Flash Attention
   postfix-fusion path. Needs dynamic stack allocation (the Apple compiler
   emits `alloca i8, i64 %sz` where `%sz` comes from
   `__tensorops_impl_matmul2d_op_cooperative_tensor_data_size` and is marked
   `"deferred-static-alloca-size"`). Workaround: reserve a conservative
   upper bound at compile time.
2. **Threadgroup-memory matmul variants.** Wrap `_tg_*` flavors of the run
   helpers and let `MtlInlineTensor` accept a `MtlThreadGroupArray`.
3. **Tile decomposition.** Drop the `D == N == tile` constraint by
   dispatching multiple threadgroups per matmul and slicing on `tgid`.
4. **`tensor_handle` kernel args + host-side `MTLTensor` / `MTL4` wrappers.**
   The biggest piece, and the closest path to what Apple's samples
   demonstrate. Inline tensors get us most of the way without it, so this
   is now only worth doing if we want first-class interop with Apple's
   tensor APIs (e.g., to consume an `MTLTensor` produced by some other
   framework).
