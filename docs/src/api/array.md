# Arrays and memory

See [Arrays](../usage/array.md) for array operations and
[Memory](../usage/memory.md) for storage modes, memory sharing and allocation.

## Array types

```@docs
MtlArray
MtlVector
MtlMatrix
MtlVecOrMat
mtl
Metal.zeros
Metal.ones
Metal.fill
Metal.allowscalar
```

## Random numbers

```@docs
Metal.rand
Metal.randn
Metal.seed!
Metal.default_rng
Metal.mps_rng
```

## Linear algebra

```@docs
Metal.matmul_alg
```

## Storage modes

The storage mode of an array decides whether the CPU can access its memory. See Apple's
[Choosing a resource storage mode for Apple GPUs](https://developer.apple.com/documentation/metal/choosing-a-resource-storage-mode-for-apple-gpus).

```@docs
Metal.SharedStorage
Metal.PrivateStorage
Metal.ManagedStorage
is_shared
is_private
is_managed
```

## Sharing memory with the CPU

```@docs
Base.unsafe_wrap(::Type{<:MtlArray}, ::Array, ::Any)
Base.unsafe_wrap(::Type{Array}, ::MtlArray, ::Any)
Base.resize!(::MtlVector, ::Integer)
```

## Memory use

```@docs
total_memory
free_memory
Metal.@allocated
Metal.@time
```

## Buffers

Metal.jl's low-level buffer allocator, which `MtlArray` uses.

```@docs
alloc
free
```
