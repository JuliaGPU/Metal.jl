# Performance

The measurements below use an M1 with 8 GPU cores, macOS 27 and Julia 1.13. Use
[Profiling](profiling.md) to check which changes help your workload.

## Measure correctly

GPU operations return before the GPU has finished, so time them with
[`Metal.@sync`](@ref), which waits for the work it launched:

```julia
using Metal, BenchmarkTools
a = Metal.rand(Float32, 1024, 1024)
@btime Metal.@sync sin.($a)
```

Without `Metal.@sync`, the elapsed time doesn't reliably include the GPU work. Run each
operation once before timing it, to exclude compilation. [`Metal.@profile`](@ref) breaks
the time down into individual kernels and copies.

## Use 32-bit or narrower element types

Apple GPUs have no `Float64` support, and Metal.jl rejects `Float64` arrays and kernels.
Use `Float32`, which is also what `mtl` converts `Float64` arrays to. Where the precision
suffices, `Float16` halves the memory traffic: a broadcast over 2²⁴ elements took 1.4 ms
with `Float16` versus 2.5 ms with `Float32`. Apple GPUs also emulate 64-bit integer
division: a kernel computing `i ÷ d` and `i % d` took 16.5 ms with `Int64` operands and
1.4 ms with `Int32`. Prefer `Int32` arithmetic in hot loops.

## Avoid repeated CPU access

An `MtlArray` in shared storage (the default) can be read and written element by element
from the CPU, but each access first waits for the GPU work that uses the array, and a loop
over the elements runs serially on the CPU. Reading `a[1]` after each of 100 launches took
153 µs per iteration, against 7 µs when reading once at the end. Use array operations
(`sum`, `findall`, `map`, broadcasting) instead of loops, and copy results to the CPU in
one go with `Array`.

Use private arrays to detect accidental CPU fallbacks; see
[Scalar indexing](@ref).

## Submit work in batches

Metal.jl collects kernel launches and copies into command buffers, which it submits
together (see [Tasks and synchronization](../usage/tasks.md)). Synchronizing after every
operation defeats this and adds a round trip to the GPU each time: 100 small broadcasts
took 7 µs per launch when synchronizing once at the end, and 130 to 180 µs when calling
`synchronize()` after each. Only synchronize, or read results on the CPU, when you need
the values. If [`Metal.@profile`](@ref) shows many short operations with idle time between
them, check for unnecessary synchronization.

## Fuse and reshape broadcasts

Each broadcast expression compiles to one kernel, so write `y .= a .* x .+ b` instead of
separate statements, which launch a kernel and allocate a temporary for each operation.

After about ten broadcasts with the same output shape, Metal.jl compiles a kernel
specialized for that shape, so the eleventh call compiles again. For 2D or
higher-dimensional arrays whose first dimension is not a power of two, this specialized
kernel is slow ([#101](https://github.com/JuliaGPU/Metal.jl/issues/101)): `A .= B .* 2f0`
took 9.7 ms for 4095×4096 matrices, against 2.5 ms for 4096×4096. When all operands have
the same shape, broadcasting over `vec` views avoids it, at 2.6 ms for either size; if
your broadcast is much slower than the `vec` version, this is the cause:

```julia
vec(A) .= vec(B) .* 2f0
```

## Launch whole SIMD-groups

Apple GPUs execute threads in SIMD-groups of 32, the pipeline's thread execution width
(`kernel.pipeline.threadExecutionWidth` of a kernel compiled with `@metal launch=false`).
A threadgroup size that isn't a multiple of it leaves threads of the last SIMD-group idle:
an arithmetic-heavy kernel took 10.9 ms with 32 to 1024 threads per threadgroup, and
20.8 ms with 33. Within the multiples, the size made no difference for that kernel, nor for
a memory-bound copy. See [Kernel programming](../usage/kernel.md) for choosing launch
sizes.

## Choose storage mode by access needs

On the M1, kernels accessed shared and private storage equally fast: a broadcast over
2²⁴ elements ran at 55 GB/s in both. Pick the storage mode based on whether the CPU needs
access (see [Memory](../usage/memory.md)).

## Keep the default matrix multiplication algorithm

Matrix products use Apple's MPSGraph when it supports the element types, which on the M1
was about 2.5 times faster for `Float32` than Metal.jl's own kernels (1800 versus 750
GFLOP/s at 2048×2048). Only change [`Metal.matmul_alg`](@ref) when you have measured a benefit
for your sizes and types (see [Numerical operations](../usage/numerical.md)).

## Account for compilation

The first call of a kernel, or of a broadcast with a new function or argument types,
compiles it: the first broadcast in a new session took 494 ms, and later ones 0.5 ms. If
only the first call is slow, check compilation overhead. See
[Compilation and caches](@ref) for caching and package precompilation.
