# Kernel functions

Functions available inside kernels, grouped by topic. See
[Kernel programming](../usage/kernel.md) and
[Advanced kernel programming](../usage/kernel_advanced.md) for examples, and the
[Metal Shading Language specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf)
for the corresponding Metal operations. Julia-specific behavior is documented below.

## Indexing

The positions and sizes of the thread, its SIMD-group, quad-group and threadgroup, and the
grid. Positions and indices are 1-based. See Apple's
[Creating threads and threadgroups](https://developer.apple.com/documentation/metal/creating-threads-and-threadgroups).

```@docs
thread_position_in_grid
thread_position_in_threadgroup
threadgroup_position_in_grid
threads_per_grid
threads_per_threadgroup
threadgroups_per_grid
thread_index_in_threadgroup
thread_index_in_simdgroup
thread_index_in_quadgroup
simdgroup_index_in_threadgroup
quadgroup_index_in_threadgroup
simdgroups_per_threadgroup
quadgroups_per_threadgroup
threads_per_simdgroup
thread_execution_width
dispatch_threads_per_threadgroup
dispatch_simdgroups_per_threadgroup
dispatch_quadgroups_per_threadgroup
grid_origin
grid_size
```

### 16-bit variants

```@docs
thread_position_in_grid_i16
thread_position_in_threadgroup_i16
threadgroup_position_in_grid_i16
threads_per_grid_i16
threads_per_threadgroup_i16
threadgroups_per_grid_i16
thread_index_in_threadgroup_i16
thread_index_in_simdgroup_i16
thread_index_in_quadgroup_i16
simdgroup_index_in_threadgroup_i16
quadgroup_index_in_threadgroup_i16
simdgroups_per_threadgroup_i16
quadgroups_per_threadgroup_i16
threads_per_simdgroup_i16
thread_execution_width_i16
dispatch_threads_per_threadgroup_i16
dispatch_simdgroups_per_threadgroup_i16
dispatch_quadgroups_per_threadgroup_i16
grid_origin_i16
grid_size_i16
```

## Versions and GPU families

```@docs
metal_version
air_version
apple_family
```

## Device arrays

```@docs
MtlDeviceArray
MtlDeviceVector
MtlDeviceMatrix
Metal.Const
```

## Threadgroup memory

```@docs
MtlThreadGroupArray
```

## Synchronization

Barriers and fences, which order memory accesses between threads. See Apple's
[Resource synchronization](https://developer.apple.com/documentation/metal/resource-synchronization).

```@docs
threadgroup_barrier
simdgroup_barrier
atomic_thread_fence
MemoryFlags
memory_order
thread_scope
```

## SIMD-group functions

Functions that exchange data between the threads of a SIMD-group.

```@docs
simd_shuffle
simd_shuffle_xor
simd_shuffle_down
simd_shuffle_up
simd_shuffle_and_fill_down
simd_shuffle_and_fill_up
simd_ballot
simd_vote_all
simd_vote_any
```

## Quad-group functions

Functions that exchange data between the four threads of a quad-group.

```@docs
quad_shuffle
quad_shuffle_xor
quad_shuffle_down
quad_shuffle_up
quad_shuffle_and_fill_down
quad_shuffle_and_fill_up
quad_ballot
quad_vote_all
quad_vote_any
```

## SIMD-group matrices

8×8 matrices distributed over the threads of a SIMD-group, multiplied by its threads
together.

```@docs
MtlSimdgroupMatrix
simdgroup_load
simdgroup_store
simdgroup_multiply
simdgroup_multiply_accumulate
```

## Tensor operations

Matrix multiplication with the Metal 4 tensor operations, on GPUs of the Metal 4 family
with macOS 26.

```@docs
MtlInlineTensor
TensorOpsMatmul2D
matmul2d_descriptor
Metal.Matmul2DMode
```

## Atomics

Atomic operations on device and threadgroup memory. The low-level functions follow MSL's
`atomic_*_explicit` functions, taking pointers and optional memory orders; `Metal.@atomic`
offers a higher-level interface on arrays.

```@docs
Metal.@atomic
Metal.atomic_load_explicit
Metal.atomic_store_explicit
Metal.atomic_exchange_explicit
Metal.atomic_compare_exchange_weak_explicit
Metal.atomic_fetch_add_explicit
Metal.atomic_fetch_sub_explicit
Metal.atomic_fetch_min_explicit
Metal.atomic_fetch_max_explicit
Metal.atomic_fetch_and_explicit
Metal.atomic_fetch_or_explicit
Metal.atomic_fetch_xor_explicit
Metal.atomic_min_explicit
Metal.atomic_max_explicit
Metal.atomic_fetch_op_explicit
```

## Printing

```@docs
@mtlprintf
@mtlprint
@mtlprintln
@mtlshow
```

## Random numbers

In kernels, `rand()`, `rand(T)`, `randn()` and `randn(T)` from the Random standard library
draw from a Philox2x32 generator, which every launch seeds with a new random seed. Call
`Random.seed!(seed)` in the kernel, from every SIMD-group, for reproducible numbers.
