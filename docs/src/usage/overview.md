# [Overview](@id UsageOverview)

The Metal.jl package provides three distinct, but related, interfaces for Metal programming:

- the `MtlArray` type: for programming with arrays;
- native kernel programming capabilities: for writing Metal kernels in Julia;
- Metal API wrappers: for low-level interactions with the Metal libraries.

Much of the Julia Metal programming stack can be used by just relying on the `MtlArray` type,
and using platform-agnostic programming patterns like `broadcast` and other array
abstractions. Only once you hit a performance bottleneck, or some missing functionality, you
might need to write a custom kernel or use the underlying Metal APIs.


## The `MtlArray` type

The `MtlArray` type is an essential part of the toolchain. Primarily, it is used to manage
GPU memory, and copy data from and back to the CPU:

```julia
a = MtlArray{Int}(undef, 1024)

# essential memory operations, like copying, filling, reshaping, ...
b = copy(a)
fill!(b, 0)
@test b == Metal.zeros(Int, 1024)

# automatic memory management
a = nothing
```

Beyond memory management, there are a whole range of array operations to process your data.
This includes several higher-order operations that take other code as arguments, such as
`map`, `reduce` or `broadcast`. With these, it is possible to perform kernel-like operations
without actually writing your own GPU kernels:

```julia
a = Metal.zeros(1024)
b = Metal.ones(1024)
a.^2 .+ sin.(b)
```

When possible, these operations integrate with existing vendor libraries.For example,
multiplying matrices or generating random numbers will automatically dispatch to these
high-quality libraries, if types are supported, and fall back to generic implementations
otherwise.
