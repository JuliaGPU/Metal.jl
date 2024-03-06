# Array programming

```@meta
DocTestSetup = quote
    using Metal
end
```

The easiest way to use the GPU's massive parallelism, is by expressing operations in terms
of arrays: Metal.jl provides an array type, `MtlArray`, and many specialized array operations
that execute efficiently on the GPU hardware. In this section, we will briefly demonstrate
use of the `MtlArray` type. Since we expose Metal's functionality by implementing existing
Julia interfaces on the `MtlArray` type, you should refer to the [upstream Julia
documentation](https://docs.julialang.org) for more information on these operations.

If you encounter missing functionality, or are running into operations that trigger
so-called "scalar iteration", have a look at the [issue
tracker](https://github.com/JuliaGPU/Metal.jl/issues) and file a new issue if there's none.
Do note that you can always access the underlying Metal APIs by calling into the relevant
submodule.


## Construction and Initialization

The `MtlArray` type aims to implement the `AbstractArray` interface, and provide
implementations of methods that are commonly used when working with arrays. That means you
can construct `MtlArray`s in the same way as regular `Array` objects:

```jldoctest
julia> MtlArray{Int}(undef, 2)
2-element MtlVector{Int64, Private}:
 0
 0

julia> MtlArray{Int}(undef, (1,2))
1×2 MtlMatrix{Int64, Private}:
 0  0

julia> similar(ans)
1×2 MtlMatrix{Int64, Private}:
 0  0
```

Copying memory to or from the GPU can be expressed using constructors as well, or by calling
`copyto!`:

```jldoctest
julia> a = MtlArray([1,2])
2-element MtlVector{Int64, Private}:
 1
 2

julia> b = Array(a)
2-element Vector{Int64}:
 1
 2

julia> copyto!(b, a)
2-element Vector{Int64}:
 1
 2
```


## Higher-order abstractions

The real power of programming GPUs with arrays comes from Julia's higher-order array
abstractions: Operations that take user code as an argument, and specialize execution on it.
With these functions, you can often avoid having to write custom kernels. For example, to
perform simple element-wise operations you can use `map` or `broadcast`:

```jldoctest
julia> a = MtlArray{Float32}(undef, (1,2));

julia> a .= 5
1×2 MtlMatrix{Float32, Private}:
 5.0  5.0

julia> map(sin, a)
1×2 MtlMatrix{Float32, Private}:
 -0.958924  -0.958924
```

To reduce the dimensionality of arrays, Metal.jl implements the various flavours of
`(map)reduce(dim)`:

```jldoctest
julia> a = Metal.ones(2,3)
2×3 MtlMatrix{Float32, Private}:
 1.0  1.0  1.0
 1.0  1.0  1.0

julia> reduce(+, a)
6.0f0

julia> mapreduce(sin, *, a; dims=2)
2×1 MtlMatrix{Float32, Private}:
 0.59582335
 0.59582335

julia> b = Metal.zeros(1)
1-element MtlVector{Float32, Private}:
 0.0

julia> Base.mapreducedim!(identity, +, b, a)
1×1 MtlMatrix{Float32, Private}:
 6.0
```
