# Array programming

```@meta
DocTestSetup = quote
    using Metal

    import Random
    Random.seed!(1)

    Metal.seed!(1)
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
2-element MtlVector{Int64, Metal.PrivateStorage}:
 0
 0

julia> MtlArray{Int}(undef, (1,2))
1×2 MtlMatrix{Int64, Metal.PrivateStorage}:
 0  0

julia> similar(ans)
1×2 MtlMatrix{Int64, Metal.PrivateStorage}:
 0  0
```

Copying memory to or from the GPU can be expressed using constructors as well, or by calling
`copyto!`:

```jldoctest
julia> a = MtlArray([1,2])
2-element MtlVector{Int64, Metal.PrivateStorage}:
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
1×2 MtlMatrix{Float32, Metal.PrivateStorage}:
 5.0  5.0

julia> map(sin, a)
1×2 MtlMatrix{Float32, Metal.PrivateStorage}:
 -0.958924  -0.958924
```

To reduce the dimensionality of arrays, Metal.jl implements the various flavours of
`(map)reduce(dim)`:

```jldoctest
julia> a = Metal.ones(2,3)
2×3 MtlMatrix{Float32, Metal.PrivateStorage}:
 1.0  1.0  1.0
 1.0  1.0  1.0

julia> reduce(+, a)
6.0f0

julia> mapreduce(sin, *, a; dims=2)
2×1 MtlMatrix{Float32, Metal.PrivateStorage}:
 0.59582335
 0.59582335

julia> b = Metal.zeros(1)
1-element MtlVector{Float32, Metal.PrivateStorage}:
 0.0

julia> Base.mapreducedim!(identity, +, b, a)
1-element MtlVector{Float32, Metal.PrivateStorage}:
 6.0
```

## Sparse arrays

Metal.jl implements GPUArrays' generic sparse-array interface with
`MtlSparseVector`, `MtlSparseMatrixCSC`, and `MtlSparseMatrixCSR`. Constructing one from a
CPU sparse array preserves its value and index types, so use `Float32` or `ComplexF32`
values because Metal does not support `Float64`:

```julia
using SparseArrays

A = sparse(Float32[1 0 2; 0 0 0; 3 4 0])
dA = MtlSparseMatrixCSR(A)
dx = mtl(Float32[1, 2, 3])
dy = dA * dx
```

The opinionated `mtl(A)` constructor follows the same policy as dense arrays and converts
`Float64` and `ComplexF64` values to their 32-bit equivalents. A storage mode can be chosen
explicitly with a fully parameterized constructor, for example
`MtlSparseMatrixCSR{Float32,Int64,Metal.SharedStorage}(A)`.

`sparse(dense_mtl_matrix)` creates a CSC matrix, while
`sparse(dense_mtl_matrix; fmt=:csr)` creates CSR. Dense-to-sparse conversion performs its
compaction on the GPU, but synchronizes once to obtain the number of stored entries needed
for the exact-size allocation. Sparse-to-dense and CSC/CSR conversions are GPU-resident.
CSR matrix-vector and sparse-matrix–dense-matrix multiplication support five-argument
`mul!`. Multiplication with CSC matrices is deliberately unsupported because an implicit
conversion would allocate and sort despite `mul!` normally being allocation-free. Convert
the format explicitly when multiplication is needed:

```julia
dA_csr = MtlSparseMatrixCSR(dA_csc)
dy = dA_csr * dx
```

Sparse broadcasting, reductions, `iszero`, `norm`, and the supported one/Infinity norms
come from GPUArrays. COO and BSR storage, sparse–sparse matrix products, sparse solves, and
factorizations are not implemented. Unlike CUDA, AMDGPU, and oneAPI—which can use cuSPARSE,
rocSPARSE, and oneMKL respectively—Metal.jl does not currently use a vendor sparse library,
so vendor-optimized format conversion, SpMV and SpMM, and higher-level sparse algebra are
not available. Reductions of absolute values from complex integer matrices use `Float32`
intermediates because Julia's normal result type is `Float64`, which Metal cannot represent.
Apple's MPSGraph exposes [COO, CSC, and CSR sparse
tensors](https://developer.apple.com/documentation/metalperformanceshadersgraph/mpsgraphsparsestoragetype),
but Metal.jl does not yet wrap its sparse graph operations.

## Random numbers

Base's convenience functions for generating random numbers are available in Metal as well:

```jldoctest
julia> Metal.rand(2)
2-element MtlVector{Float32, Metal.PrivateStorage}:
 0.67199826
 0.87411195

julia> Metal.randn(Float32, 2, 1)
2×1 MtlMatrix{Float32, Metal.PrivateStorage}:
 -0.35001364
 -0.064419515
```

Behind the scenes, these random numbers come from GPUArrays.jl's RNG, exposed as
`Metal.RNG`, and returned by `Metal.default_rng()`. Operations on it are implemented using
methods from the Random standard library:

```jldoctest
julia> using Random

julia> a = Random.rand(Metal.default_rng(), Float32, 1)
1-element MtlVector{Float32, Metal.PrivateStorage}:
 0.67199826

julia> Random.rand!(Metal.default_rng(), a)
1-element MtlVector{Float32, Metal.PrivateStorage}:
 0.23174448
```

Two additional RNGs are available:

- `MPS.RNG` (returned by `Metal.mps_rng()`): a generator backed by
  [Metal Performance Shaders](https://developer.apple.com/documentation/metalperformanceshaders/mpsmatrixrandom?language=objc).
  Supports uniform distributions over `Float32` and the integer types, and normal
  `Float32`. `Metal.seed!` reseeds it alongside the default RNG so that switching to
  it is reproducible.

- `Metal.KernelRNG` (returned by `Metal.kernel_rng()`): a kernel calling Metal's
  on-device random number generator. Kept for testing and performance comparison.

!!! note
    `MPSMatrixRandom` functionality requires Metal.jl >= v1.4

!!! warning
    `Random.rand!(::MPS.RNG, args...)` and `Random.randn!(::MPS.RNG, args...)` have a framework limitation that requires the byte offset and byte size of the destination array to be a multiple of 4.
