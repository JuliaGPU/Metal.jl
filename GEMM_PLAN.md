# Design: a Julia-native GEMM for Metal.jl

Status: implemented (Phases 0 through 4). The design notes below are kept for reference.
Author: investigation 2026-06-02
Priority ordering: coverage and correctness first, performance second.

## Implementation status (2026-06-02)

The code lives in `src/gemm.jl`, the `:native` arm of the selector in `src/linalg.jl`, and
the transpose-flag parameter added to `src/device/intrinsics/simd.jl`.

Coverage is complete. `:native` is a drop-in for `generic_matmatmul!` and
`generic_matvecmul!`, and it is the `:auto` fallback in place of GPUArrays. A fast
`simdgroup_matrix` kernel handles Float16 and Float32; a shared-memory tiled robust kernel
handles every other eltype (ComplexF32, the integer types, and so on). Results match a CPU
oracle across eltype, all N/T/C transpose combinations, α/β scaling, ragged shapes, offset
views, and gemv, including the offset≠0 case that MPSGraph silently falls back on. Tests are
in `test/linalg.jl` ("native GEMM"); the development toolkit is in `bin/gemm/`.

Performance is partway there. Square Float32 on an 8-core M1 runs at about 580 GFLOP/s at
2048³, roughly a third of MPS's 1760 and up from 190 for the first blocked version. Two
things moved it. The first is occupancy: 4×4 simdgroups (512 threads per threadgroup) beat
every smaller configuration by a wide margin. The second is a lean epilogue. A simdgroup
matrix is an `NTuple{64,VecElement}` spread across the lanes, so scaling it by α/β is a plain
elementwise op on the tuple and the result stores straight to device memory. That removes the
C-sized threadgroup staging tile, which was otherwise capping occupancy. The `EDGE` and
`SIMPLE` compile-time specializations keep aligned α=1/β=0 matmuls on the path with no bounds
checks.

Levers not yet pulled: the fast kernel is roughly memory-bandwidth bound at the 64×64 tile.
Closing the gap to MPS would take `float4` vectorized cooperative loads and 128×128 tiles
with a per-specialization thread budget (the general α/β kernel is register-limited to 832
threads, the lean one reaches 1024). The KB>1 (deeper contraction tile) throughput cliff is
still unexplained. Bank-conflict padding does not help, because the layout is already
conflict-free. The M5 TensorOps path remains future work (§9).

---


## 1. Motivation

Matmul on Metal.jl currently delegates entirely to two Objective-C black boxes,
MPS (`MPSMatrixMultiplication`) and MPSGraph, with a naive `GPUArrays` triple-loop
as the last-resort fallback. Both vendor paths carry bugs and limitations we keep
working around:

- MPSGraph is disabled whenever any operand has a non-zero buffer offset
  (`A.offset == 0 && B.offset == 0 && C.offset == 0`, `src/linalg.jl`), so views /
  reshaped arrays silently fall back.
- MPSGraph must force `optimizationLevel = 0` to stop ops being dispatched to the
  ANE, which hangs on large matrices (`lib/mpsgraphs/matmul.jl`).
- `MPS.matmul!` has the offset≠0 NaN-corruption issue tracked in #381.
- Neither supports Float64, complex, or bf16; the only path for unsupported
  combinations is the naive `GPUArrays.generic_matmatmul!` kernel (no tiling).
- We have no insight into, or control over, either implementation.

A native kernel written in dynamic Julia replaces both with **one readable,
testable, fixable code path** that can support arbitrary input combinations
because it is generated per type.

### Goals

1. A drop-in replacement for the existing `LinearAlgebra.generic_matmatmul!` /
   `generic_matvecmul!` dispatch — same contract, same results (within fp tolerance).
2. **Correct for every input** the LinearAlgebra interface can hand us: all eltypes
   Metal supports, all transpose/adjoint combinations, arbitrary offsets and
   strides, `α`/`β` scaling. No silent fallback to a slow path that gives a
   different answer; no input that errors where MPS/MPSGraph would have worked.
3. Strictly better than the naive `GPUArrays` fallback from day one.
4. Eventually competitive with MPS on the common F32/F16 cases.

### Non-goals (for now)

- The M5 neural-accelerator (fp16/int8 tensor unit) path. It is reachable only via
  Metal 4 TensorOps / Metal Performance Primitives (`metal_tensor`,
  `cooperative_tensor`, `matmul`), which are **not yet emittable from the AIR
  backend**. Deferred to a later, separate effort (see §9).
- Structured-matrix specializations (`Diagonal`, `Triangular`, `Symmetric` rank-k
  updates). LinearAlgebra routes most of these through their own `mul!` methods;
  we only need to handle whatever lands in `generic_matmatmul!` (see §6).
- Replacing MPS for everything immediately. We keep MPS/MPSGraph selectable; the
  native path is added as a new algorithm and only becomes the `:auto` default
  once it is proven faster (Phase 4).

## 2. The interface contract to satisfy

From the Julia stdlib `LinearAlgebra` dispatch chain
(`stdlib/LinearAlgebra/src/matmul.jl`, `LinearAlgebra.jl`):

```
A * B  /  mul!(C, A, B[, α, β])
  → _mul!(C, A, B, α, β)
      → generic_matmatmul!(C, wrapper_char(A), wrapper_char(B),
                           _unwrap(A), _unwrap(B), MulAddMul(α, β))
```

- `tA`, `tB` are characters: `'N'` (none), `'T'` (transpose), `'C'` (conjugate
  transpose). `Symmetric`/`Hermitian` arrive as a `WrapperChar` `'S'`/`'H'`.
- `A`, `B` are **unwrapped** parents (the `Transpose`/`Adjoint` is stripped; the
  transpose intent lives in the char).
- Semantics: `C = α · op_A(A) · op_B(B) + β · C`, where `op` applies the char.
- `MulAddMul{ais1,bis0,...}` encodes `α==1` / `β==0` as type params for
  constant-folding.

Metal.jl already provides the seam (`src/linalg.jl:28-110`): it defines the
6-argument `(C, tA, tB, A, B, α, β)` form and a `ScopedValue` selector
`matmul_alg[] ∈ {:auto, :MPS, :MPSGraph, :GPUArrays}`. We add `:native` to this
selector. Helpers we reuse: `LinearAlgebra.lapack_size(tA, A)` for effective dims,
`tA == 'T' || tA == 'C'` for the boolean transpose flag.

The matrix-vector form `generic_matvecmul!(C, tA, A, B, _add)` must also be
handled (gemv); it can be implemented as a thin specialization of the same kernel
with `N=1`, or a dedicated kernel later.

## 3. Kernel architecture

Synthesised from the prior art (percisely.xyz/gemm; LaurentMazare/gemm-metal incl.
the extracted MLX "steel" kernel; cyrusmsk/gemm_apple; yaroslavvb/m5-gemm —
cloned under `/tmp/gemm-research/`). They all converge on the same shape:

- **Threadgroup** = `WM × WN` simdgroups; start `WM = WN = 2` ⇒ 128 threads.
- Per-threadgroup output tile `BM × BN`; reduction depth `BK`.
  Recommended start: `BM = BN = 64`, `BK = 8`–`16`.
- Per simdgroup: a **4×4 grid of `simdgroup_float8x8` accumulators** (= 32×32
  output region). **Do not exceed 4×4** — an 8×8 accumulator grid (64 matrices)
  spills registers and runs ~10× slower.
- K-loop:
  1. cooperatively load `A` (BM×BK) and `B` (BK×BN) tiles into `threadgroup`
     memory (vectorized `float4` loads in Phase 4),
  2. `threadgroup_barrier(MemoryFlagThreadGroup)`,
  3. unrolled over the 4×4 grid: `simdgroup_load` the A/B sub-tiles,
     `simdgroup_multiply_accumulate` into the accumulators,
  4. `threadgroup_barrier`.
- **Accumulate in Float32 even for Float16 inputs.**
- Epilogue: `C = α·acc + β·C` via `simdgroup_load(C)` →
  `simdgroup_multiply`/`simdgroup_multiply_accumulate` → `simdgroup_store`.

Performance levers, in priority order (deferred to Phase 4 but recorded here so
the Phase 1 code is written not to preclude them):

1. **`max_total_threads_per_threadgroup`** — the single biggest win in every
   writeup; lets the register allocator commit to a static threadgroup size and
   stop spilling. Reachable host-side via `setMaxTotalThreadsPerThreadgroup` on the
   pipeline descriptor (`lib/mtl/libmtl.jl:1045`, macOS 13.3+). Confirm in Phase 0
   whether this, or a compile-time LLVM function attribute, actually suppresses
   spilling for our IR.
2. Full unrolling of the K-inner and `SIMD_TILE²` MMA loops.
3. `float4` coalesced cooperative loads (consecutive lanes → consecutive float4s).
4. Threadgroup-memory padding (`+ 16/sizeof(T)` per row) to avoid bank conflicts.
5. Threadgroup swizzling / Morton-order tile traversal for L2 locality at large
   sizes; double-buffering for small (latency-bound) sizes.

**Dead end to avoid:** the `air.simdgroup_async_copy_2d` DMA trick
(percisely.xyz). It only compiled on Metal ≤ 3 and is rejected by the Metal 4
frontend. Use synchronous cooperative loads.

Expected ceiling on the `simdgroup_matrix` path: ~70–85% of fp32 ALU peak —
matches/beats MPS at small/mid sizes (m5-gemm: 13.5 vs MPS 11.7 TFLOPS on M5 Max;
gemm-metal TiledSimd ~8.3 TFLOPS on M3 Max).

## 4. Primitives available vs. gaps to fill

**Already in Metal.jl (verified) — the hard part is done:**

- `simdgroup_load / simdgroup_store / simdgroup_multiply /
  simdgroup_multiply_accumulate` for `Float16` & `Float32`, in **both** Device and
  ThreadGroup address spaces (`src/device/intrinsics/simd.jl`). Matrix is an
  `NTuple{64, VecElement{T}}` (8×8). Lower to `air.simdgroup_matrix_8x8_*`.
  Pointer-eltype metadata already stamped in `src/compiler/compilation.jl:92-93`.
  Exercised by `test/device/intrinsics/simd.jl`.
- Threadgroup memory: `MtlThreadGroupArray` (`src/device/intrinsics/memory.jl`).
- Barriers: `threadgroup_barrier`, `simdgroup_barrier`
  (`src/device/intrinsics/synchronization.jl`).
- Index intrinsics: `simdgroup_index_in_threadgroup`,
  `thread_index_in_simdgroup`, `threads_per_simdgroup`,
  `simdgroups_per_threadgroup`, thread/threadgroup positions
  (`src/device/intrinsics/arguments.jl`).
- Host-side generation detection: `supports_family`, `is_m1`…`is_m4`
  (`lib/mtl/device.jl`); `MTLGPUFamily` enums (`lib/mtl/libmtl.jl`).
- The dispatch seam (`src/linalg.jl`) and the algorithm selector.

**Gaps to fill:**

1. The GEMM kernel(s) + a host launcher (tiling, grid, ragged-tile handling).
2. The `:native` arm in the `matmul_alg` selector + a capability predicate that
   decides fast-path vs. robust-path (§5).
3. **Transpose flag is hardcoded.** `simdgroup_load`/`simdgroup_store` currently
   pass `Val(true)` as the AIR transpose argument unconditionally
   (`src/device/intrinsics/simd.jl:20,29`). To handle `tA/tB ∈ {N,T,C}` and the
   column-major↔row-major reconciliation, this must become a parameter. **Change
   the binding to accept a `transpose::Bool` (default preserving current
   behaviour) rather than hardcoding it.**
4. **Mixed-precision accumulate.** The multiply/accumulate intrinsics are
   currently same-type only. F16-input/F32-accumulate needs an F32 accumulator
   tile and correct load typing — verify whether
   `air.simdgroup_matrix_8x8_multiply_accumulate` supports mixed operand/accumulate
   types or whether we up-convert F16 tiles to F32 on load.
5. The `max_total_threads_per_threadgroup` plumbing (Phase 4, but scope in Phase 0).

## 5. Coverage strategy (correctness-first)

The governing principle: a **fast tiled path** handles the aligned/common case; a
**robust path** handles everything else; together they are correct for *all*
inputs. Both are our own kernels — we do **not** delegate the hard cases back to
MPS. A single predicate chooses:

```
fast_path_applicable(C, tA, tB, A, B) =
    eltype ∈ {Float16, Float32} &&
    leading dims are contiguous (stride(·,1) == 1) &&
    column strides ≥ size (no aliasing/overlap)
    # offsets are fine — they are just a base-pointer add
```

- **Fast path:** the §3 simdgroup kernel. Handles N/T/C via the transpose flag on
  `simdgroup_load` and by swapping the M/N tile roles; ragged dims handled by a
  bounds-checked `load_safe` variant for boundary tiles (zero-pad the loaded
  simdgroup tile).
- **Robust path:** a straightforward tiled (or, initially, naive-but-correct)
  kernel that indexes through arbitrary strides/offsets and supports any eltype
  with `+`/`*` (covers Float64, complex, bf16, integers). This replaces today's
  `GPUArrays` fallback and lives in Metal.jl so we control it. Still threadgroup-
  tiled for decency, but correctness is the bar, not peak FLOPS.

**Coverage matrix to satisfy and test:**

| Axis | Cases | Handled by |
|---|---|---|
| eltype | F32, F16 | fast path |
| eltype | F64, ComplexF32/F64, BFloat16, Int* | robust path |
| transpose | NN, NT, TN, TT, and C variants | both (flag + tile swap) |
| α/β | α=1,β=0 / general α,β / β≠0 read-modify-write / α=0 | both |
| offset≠0 | views, reshaped, reinterpreted | both (base-ptr add) — this is the MPSGraph gap |
| strides | non-unit column stride, SubArray | robust path (or fast if leading-contig) |
| shape | M×K · K×N; gemv (N=1); empty dims | both; empty → early return |
| `Symmetric`/`Hermitian` (`'S'`/`'H'` char) | route via `wrap` to robust path, or let LinearAlgebra’s own mul! handle | see §6 |

Reference oracle for every case: compare against `Array` CPU `mul!` and/or the
existing `GPUArrays` kernel within fp tolerance.

## 6. Dispatch integration

In `src/linalg.jl`, extend the selector:

```julia
# matmul_alg[] ∈ {:auto, :MPS, :MPSGraph, :GPUArrays, :native}
elseif alg === :native || (alg === :auto && julia_supported)
    Metal.gemm!(C, tA, tB, A, B, alpha, beta)   # new native entry point
```

- Phase 1–3: keep `:auto` preferring MPSGraph/MPS as today; `:native` is opt-in and
  is also installed as the **fallback in place of `:GPUArrays`** (so the slow path
  is ours and correct for offsets). Flip `:auto` to prefer `:native` only in Phase 4
  once benchmarks justify it.
- `Symmetric`/`Hermitian` `WrapperChar`s: simplest correct behaviour is to
  `LinearAlgebra.wrap(A, tA)` them back and let the existing generic path expand
  them, or materialize. Do not attempt syrk/herk specialization now.
- `generic_matvecmul!`: add the matching `:native` arm calling a gemv specialization.

Native entry point signature mirrors the internal MPS one for familiarity:

```julia
function gemm!(C::MtlMatrix, tA::Char, tB::Char, A::MtlMatrix, B::MtlMatrix,
               α::Number, β::Number)
```

## 7. Generation / capability considerations

The baseline F32/F16 `simdgroup_matrix` kernel is **portable Apple7 → M5**;
generations differ only in *optimal tile size*. Select tiles **host-side** from the
existing `is_m1`…`is_m4` and core count — compile per-family variants, pick at
launch. **No new GPUCompiler target field or device-side family getter is needed
for Phases 1–4.**

A PTX-ISA-style capability getter (a `MetalCompilerTarget.gpu_family` field + a
device-side `gpu_family()` intrinsic, mirroring CUDA's `compute_capability()` and
the CUDA.jl fetcher at `tmp/CUDA.jl/CUDACore/src/compiler/compilation.jl:188-270`)
is **only** required for in-kernel branching, which the M5 TensorOps path would
want. Deferred with that path.

## 8. Phased plan (coverage-first ordering)

- **Phase 0 — validate primitives (½ day).** Microbenchmark the existing
  `simdgroup_*` intrinsics on current hardware; nail down (a) the transpose-flag
  semantics, (b) the stride/origin convention of `simdgroup_load`/`store`, (c)
  whether mixed F16→F32 accumulate is supported by the intrinsic, (d) how to
  suppress register spilling (`max_total_threads_per_threadgroup` via pipeline
  descriptor vs. LLVM attribute). Output: a working 32×32 single-simdgroup MMA
  that matches a CPU reference. De-risks everything downstream.

- **Phase 1 — correct, drop-in F32 NN kernel + robust fallback.** Tiled simdgroup
  kernel for `tA=tB='N'`, F32, with ragged-tile bounds checking; the robust
  strided/any-eltype kernel; the `:native` selector arm replacing `:GPUArrays` as
  fallback. Validate against CPU/`GPUArrays` for all shapes **including non-zero
  offsets and odd strides** (the cases MPS breaks on). At this point the package is
  already strictly more correct than today's fallback.

- **Phase 2 — full input coverage.** All `tA/tB ∈ {N,T,C}` combinations; F16 with
  F32 accumulate; mixed int→float; gemv. Now a genuine drop-in for MPS/MPSGraph
  across the whole coverage matrix (§5). This is the milestone the chosen
  priority targets.

- **Phase 3 — robustness hardening.** Empty/degenerate dims, α=0/β=0 shortcuts,
  large-K accuracy, alias detection (`A === C`), thorough test sweep across the
  matrix; wire `:native` into CI alongside the MPS/MPSGraph suites.

- **Phase 4 — performance.** `float4` loads, bank-conflict padding,
  double-buffering (small), swizzling (large); per-generation tile autotuning;
  `max_total_threads_per_threadgroup`. Benchmark vs MPS; flip `:auto` default where
  we win.

- **Phase 5 (optional, later) — M5 TensorOps.** Requires GPUCompiler capability
  getters + new AIR/MPP intrinsics; separate project.

## 9. Testing strategy

- **Oracle:** `Array(C)` vs CPU `LinearAlgebra.mul!` on `Array(A)`, `Array(B)` with
  the same `α,β,tA,tB`, within an eltype-appropriate tolerance.
- **Sweep generator:** product over {eltype} × {N,T,C}² × {α,β cases} × {square,
  tall, wide, gemv, 1×1, empty} × {dense, view-with-offset, strided SubArray,
  reshaped/reinterpreted}.
- **Differential:** for supported types, also diff against `:MPS` and `:MPSGraph`
  results to catch sign/transpose mistakes.
- **Regression anchors:** the #381 offset≠0 NaN case and the MPSGraph offset
  fallback case must produce correct results on `:native`.
- Place tests in `test/linalg.jl` (and mirror MPS/MPSGraph layout). Gate
  performance assertions out of correctness CI.

## 10. Risks & open questions

1. **Transpose-flag binding change** (§4.3) touches a shipped intrinsic — must keep
   the default behaviour for existing users of `simdgroup_load`/`store`.
2. **Mixed-precision MMA**: if the AIR intrinsic can't accumulate F16→F32 directly,
   F16 tiles must be widened to F32 on load (extra registers; revisit tiling).
3. **`max_total_threads_per_threadgroup`**: unclear yet whether the pipeline-
   descriptor setter alone suppresses spilling, or whether GPUCompiler must emit a
   function attribute. Resolved in Phase 0.
4. **Complex GEMM** on the robust path: needs care (no BLAS `'C'` shortcut) — but
   it is purely the robust strided kernel with complex arithmetic, so correctness
   is straightforward if slow.
5. **`Symmetric`/`Hermitian` chars**: confirm what actually reaches
   `generic_matmatmul!` on current Julia; `wrap`-and-expand is the safe default.

## 11. References

- Prior art (cloned under `/tmp/gemm-research/{m5-gemm,gemm_apple,gemm-metal}`):
  - percisely.xyz/gemm — hierarchical simdgroup tiling tutorial (M2). Avoid its
    async-copy trick.
  - github.com/LaurentMazare/gemm-metal — full optimization ladder + extracted MLX
    "steel" kernel (the production reference: templated BM/BN/BK/WM/WN, fp32
    accumulate, vectorized loaders, swizzling, fused α/β epilogue).
  - github.com/cyrusmsk/gemm_apple — tinygrad-derived 32×32 simdgroup kernel + bench
    harness.
  - github.com/yaroslavvb/m5-gemm — Metal-4 port using only public APIs;
    `sync_copy.metal` is the closest blueprint; documents the
    `max_total_threads_per_threadgroup` win and the 4×4-accumulator spill cliff.
  - philipturner/metal-benchmarks & metal-flash-attention — hardware throughput
    numbers, ~83% ALU-utilization ceiling, register-spill strategy.
- Metal.jl code anchors:
  - `src/linalg.jl:28-110` — dispatch seam + `matmul_alg` selector.
  - `src/device/intrinsics/simd.jl` — simdgroup matrix ops (transpose flag at 20,29).
  - `src/device/intrinsics/{memory,synchronization,arguments}.jl` — threadgroup
    memory, barriers, indices.
  - `src/compiler/compilation.jl:89-112` — intrinsic eltype metadata; target config.
  - `lib/mtl/device.jl` — `supports_family`, `is_m1`…`is_m4`.
  - `lib/mtl/libmtl.jl:1045` — `setMaxTotalThreadsPerThreadgroup`.
  - `lib/mps/matrix.jl`, `lib/mpsgraphs/matmul.jl` — current MPS/MPSGraph paths +
    their workarounds.
- Julia contract: `stdlib/LinearAlgebra/src/matmul.jl` (dispatch, `lapack_size`),
  `LinearAlgebra.jl` (`wrapper_char`, `wrap`), `adjtrans.jl` (`_unwrap`).
- CUDA capability machinery (for the eventual M5 path):
  `pkg/GPUCompiler/src/ptx.jl` (target/feature_set), `tmp/CUDA.jl` fetcher.
