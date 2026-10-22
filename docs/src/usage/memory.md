# Memory

Apple silicon has unified memory: the CPU and GPU use the same physical memory. An
`MtlArray`'s storage mode determines whether the CPU can access its memory directly.

## [Storage modes](@id storage-modes)

Every `MtlArray` has a [storage mode](https://developer.apple.com/documentation/metal/choosing-a-resource-storage-mode-for-apple-gpus),
its third type parameter:

| Storage mode | CPU access | Use |
|---|---|---|
| [`Metal.SharedStorage`](@ref) (default) | direct | data that the CPU reads or writes |
| [`Metal.PrivateStorage`](@ref) | through copies only | data that only the GPU uses |

Metal's managed storage mode, which keeps separate CPU and GPU copies, is not supported for
`MtlArray`s.

Select a storage mode with the type parameter or a `storage` keyword argument:

```julia
using Metal

a = MtlArray{Float32,1,Metal.PrivateStorage}([1, 2, 3])
b = Metal.zeros(Float32, 1024; storage=Metal.PrivateStorage)
c = mtl(rand(3); storage=Metal.PrivateStorage)
d = similar(b; storage=Metal.SharedStorage)
```

[`Metal.ones`](@ref), [`Metal.fill`](@ref), [`Metal.rand`](@ref) and [`Metal.randn`](@ref) take the same keyword argument.
[`is_shared`](@ref) and [`is_private`](@ref) query an array's storage mode. To change the
default storage mode, set the `default_storage` preference (see [Configuration](@ref)).

### Shared storage

The CPU accesses a shared array's memory directly: indexing, iterating, printing and
`Array(a)` read from the memory that the GPU writes to. Because GPU work runs
asynchronously, Metal.jl first waits for queued GPU work, but only if that work uses the
array (see [Tasks and synchronization](@ref)). This is why scalar indexing works on shared
arrays (see [Scalar indexing](@ref)).

### Private storage

Only the GPU can access a private array. Copies to and from the CPU go through a temporary
shared buffer, and scalar indexing is an error unless you allow it. Apple recommends private
storage for data that only the GPU accesses. With Metal.jl, the practical reason to use it
is that accidental CPU access raises an error instead of silently running on the CPU.

## Sharing memory with CPU arrays

`unsafe_wrap` lets an `Array` and an `MtlArray` share memory without copying. CPU and GPU
access must be synchronized:

!!! warning
    Access through the CPU `Array` does not wait for GPU work on the shared memory. Call
    [`synchronize`](@ref) before reading or writing that memory from the CPU; otherwise you
    may read stale values or overwrite data the GPU is still using.

Wrap a shared `MtlArray` as an `Array`, e.g. to pass it to a CPU library:

```julia
a = Metal.zeros(Float32, 4)
b = unsafe_wrap(Array, a)   # a Vector{Float32} using a's memory
b[1] = 42                   # a[1] is now 42
```

The `Array` does not keep `a` alive: keep a reference to `a` for as long as you use `b`.
Private arrays cannot be wrapped.

Wrap a CPU array as an `MtlArray` to use it on the GPU:

```julia
c = rand(Float32, 1024)
d = unsafe_wrap(MtlArray, c)
d .= sin.(d)                # runs on the GPU, updating c
synchronize()
c                           # now safe to read
```

The wrapped buffer keeps `c` alive until it is released, including while queued GPU work
uses it, but `c` must not be resized while it is
wrapped. The memory doesn't need to be page-aligned.

See [examples/unified_memory.jl](https://github.com/JuliaGPU/Metal.jl/blob/main/examples/unified_memory.jl)
for an example that alternates CPU and GPU work on the same memory.

## Freeing memory

Unreachable `MtlArray`s are freed by Julia's garbage collector, once no other array shares
their memory and no queued GPU work uses it. The
collector doesn't know how much GPU memory an array holds, so Metal.jl also triggers
collections once GPU allocations exceed 75% of the device's recommended working set (50%
when it is about to wait for the GPU anyway). If an allocation still fails, it runs a full
collection, waits for the GPU, and retries.

To release memory without waiting for the collector, e.g. for large temporaries in a loop,
call `Metal.unsafe_free!(a)`. Using `a` afterwards throws an error:

```julia
a = Metal.zeros(Float32, 1 << 20)
Metal.unsafe_free!(a)
a[1]   # ERROR: ArgumentError: Attempt to use a freed reference.
```

Freeing is safe while queued GPU work still uses the array: the memory stays alive until
that work completes.

## Memory usage

| Function | Returns |
|---|---|
| [`total_memory`](@ref)`()` | Metal's recommended working set size for the GPU, a share of the system memory |
| [`free_memory`](@ref)`()` | the part of the working set that the process hasn't allocated through Metal |
| `Metal.@allocated ex` | bytes of GPU memory allocated while evaluating `ex` |
| `Metal.@time ex` | like `@time`, synchronizing before and after, and also reporting GPU allocations |

```julia
julia> Metal.@time Metal.zeros(Float32, 1024);
  0.000277 seconds (41 CPU allocations: 1.453 KiB) (1 GPU allocation: 4.000 KiB, 13.29% memmgmt time)
```
