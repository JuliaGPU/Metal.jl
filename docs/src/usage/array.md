# Arrays

```@meta
DocTestSetup = quote
    using Metal, Random
    Random.seed!(Metal.default_rng(), 1)
end
```

`MtlArray` implements Julia's array interface, with GPU implementations of broadcasting,
reductions, sorting and other operations.

## Creating arrays

Copy a CPU array to an [`MtlArray`](@ref), and copy the result back with `Array`:

```jldoctest
julia> a = MtlArray(Float32[1, 2, 3])
3-element MtlVector{Float32, Metal.SharedStorage}:
 1.0
 2.0
 3.0

julia> Array(a .* 2f0)
3-element Vector{Float32}:
 2.0
 4.0
 6.0
```

The type parameters are the element type, the number of dimensions and the
[storage mode](@ref storage-modes). `copyto!` copies between CPU and GPU arrays in either
direction.

[`Metal.zeros`](@ref) and [`Metal.ones`](@ref) create `Float32` arrays by default. [`Metal.fill`](@ref) uses the
type of the supplied value:

```jldoctest
julia> Metal.zeros(2, 3)
2×3 MtlMatrix{Float32, Metal.SharedStorage}:
 0.0  0.0  0.0
 0.0  0.0  0.0

julia> Metal.fill(Int32(7), 2)
2-element MtlVector{Int32, Metal.SharedStorage}:
 7
 7
```

`MtlArray{T}(undef, dims)` and `similar` allocate without initializing, like their `Array`
counterparts.

Use [`mtl`](@ref) to adapt existing data, such as model parameters, for the GPU. It converts
`Float64` arrays to `Float32`, preserves wrappers such as `adjoint`, and leaves `isbits`
values such as ranges unchanged:

```jldoctest
julia> mtl([1.0, 2.0])
2-element MtlVector{Float32, Metal.SharedStorage}:
 1.0
 2.0

julia> mtl([1.0, 2.0]')
1×2 adjoint(::MtlVector{Float32, Metal.SharedStorage}) with eltype Float32:
 1.0  2.0

julia> mtl(1:3)
1:3
```

`MtlArray(x)` never changes the element type.

## Element types

Apple GPUs have no double-precision arithmetic: the [Metal Shading Language
specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf)
has no `double` type. `MtlArray` therefore rejects `Float64`, and 128-bit integers, also
inside structs and complex numbers:

```jldoctest
julia> MtlArray([1.0, 2.0])
ERROR: Metal does not support Float64 values, try using Float32 instead
Stacktrace:
[...]
```

Supported element types are `Float32`, `Float16`, `BFloat16` (from
[BFloat16s.jl](https://github.com/JuliaMath/BFloat16s.jl)), signed and unsigned integers up
to 64 bits, `Bool`, complex numbers of these, and `isbits` structs made of them. Element
types must be stored inline, so `MtlArray{Any}` or arrays of mutable structs are not
possible.

`Float64` scalars introduce unsupported double arithmetic, and out-of-place operations
such as `a .* 2.0` also request a `Float64` result array; both fail. Write literals as `Float32` (`2f0`, not `2.0`) and convert scalars with
`Float32(x)`.

## Array operations

Array operations that have a GPU implementation run on the GPU. These include broadcasting
and `map`, reductions and `mapreduce` (with or without `dims`), `accumulate` and `cumsum`,
`sort`, `sortperm`, `findall`, `reverse`, and indexing with arrays:

```jldoctest
julia> a = MtlArray(Float32[3, 1, 2]);

julia> a .^ 2 .+ 1f0
3-element MtlVector{Float32, Metal.SharedStorage}:
 10.0
  2.0
  5.0

julia> sum(a), maximum(a)
(6.0f0, 3.0f0)

julia> sum(Metal.ones(2, 3); dims=2)
2×1 MtlMatrix{Float32, Metal.SharedStorage}:
 3.0
 3.0

julia> cumsum(a)
3-element MtlVector{Float32, Metal.SharedStorage}:
 3.0
 4.0
 6.0

julia> sort(a)
3-element MtlVector{Float32, Metal.SharedStorage}:
 1.0
 2.0
 3.0

julia> a[findall(>(1f0), a)]
2-element MtlVector{Float32, Metal.SharedStorage}:
 3.0
 2.0
```

Views and `reshape` share the parent's memory. For matrix multiplication, factorizations and FFTs, see
[Numerical operations](numerical.md).

Most operations queue GPU work and return without waiting. Operations that return CPU
results wait for that work; see [Tasks and synchronization](@ref).

## Scalar indexing

Some operations without a GPU implementation fall back to generic Julia code that accesses
elements from the CPU. This depends on the array's [storage mode](@ref storage-modes):

- Shared arrays (the default) are accessible by the CPU, so `a[i]` reads the element directly
  after waiting for GPU work on `a` to finish. This is allowed, and fast for a single element,
  but a fallback that loops over a large array runs serially on the CPU.
- Private arrays aren't accessible by the CPU, and scalar indexing them is an error, except
  when the REPL displays an array:

```julia
julia> a = MtlArray{Float32,1,Metal.PrivateStorage}([1, 2, 3]);

julia> a[1]
ERROR: Scalar indexing is disallowed.
Invocation of getindex resulted in scalar indexing of a GPU array.
This is typically caused by calling an iterating implementation of a method.
Such implementations *do not* execute on the GPU, but very slowly on the CPU,
and therefore should be avoided.

If you want to allow scalar iteration, use `allowscalar` or `@allowscalar`
to enable scalar iteration globally or for the operations in question.
```

To allow scalar indexing explicitly, wrap the code in `Metal.@allowscalar`. To find
accidental CPU fallbacks, use private arrays while developing. The `default_storage`
preference changes the default storage mode (see [Configuration](@ref)).
`Metal.allowscalar(false)` does not affect shared arrays.

## Array wrappers and Adapt

Wrapper types such as `SubArray`, `Adjoint`, `Transpose`, `PermutedDimsArray` and
`ReshapedArray` around an `MtlArray` work with broadcasting and can be passed to kernels.

[Adapt.jl](https://github.com/JuliaGPU/Adapt.jl) converts nested structures, keeping
wrappers and leaving non-array fields alone. `adapt(MtlArray, x)` keeps element types
(and so fails on `Float64`); `mtl(x)` is the same with `Float64` converted to `Float32`:

```julia
julia> using Adapt

julia> adapt(MtlArray, (weights = Float32[1, 2], scale = 2))
(weights = MtlArray(Float32[1.0, 2.0]), scale = 2)
```

```jldoctest
julia> mtl(view([1.0, 2.0, 3.0], 2:3))
2-element view(::MtlVector{Float32, Metal.SharedStorage}, 2:3) with eltype Float32:
 2.0
 3.0
```

The target type can fix some parameters and take the rest from the source, e.g.
`adapt(MtlArray{Float16}, x)` or
`adapt(MtlArray{<:Any,<:Any,Metal.PrivateStorage}, x)`.

## Random numbers

[`Metal.rand`](@ref) and [`Metal.randn`](@ref) create arrays of random numbers (`Float32` by default), and
`rand!` and `randn!` from the Random standard library fill an existing `MtlArray`.
[`Metal.seed!`](@ref) seeds the generators of the current task. Its native generator,
[`Metal.default_rng`](@ref), can also be seeded on its own:

```jldoctest
julia> using Random

julia> Random.seed!(Metal.default_rng(), 1);

julia> Metal.rand(2)
2-element MtlVector{Float32, Metal.SharedStorage}:
 0.67199826
 0.87411195

julia> rand!(Metal.zeros(Float32, 2))
2-element MtlVector{Float32, Metal.SharedStorage}:
 0.23174448
 0.9386339
```

These use `Metal.default_rng()`, a counter-based generator from GPUArrays.jl. [`Metal.mps_rng()`](@ref) returns a generator backed by
[Metal Performance Shaders](https://developer.apple.com/documentation/metalperformanceshaders/mpsmatrixrandom),
which generates uniformly distributed `Float32` values and integers, and normally
distributed `Float32` values. To generate random numbers inside a kernel, see
[Advanced kernel programming](kernel_advanced.md).
