# Numerical operations

Metal.jl implements matrix products, linear solves and Fourier transforms for `MtlArray`s
through Julia's LinearAlgebra and AbstractFFTs interfaces.
The work is done by Apple's [Metal Performance Shaders](https://developer.apple.com/documentation/metalperformanceshaders)
(MPS) and [MPSGraph](https://developer.apple.com/documentation/metalperformanceshadersgraph)
frameworks, or by Metal.jl's own kernels.

## Matrix multiplication

`*` and `mul!` work on `MtlMatrix` and `MtlVector` operands, including their transposes and
adjoints, and the five-argument `mul!(C, A, B, α, β)`:

```jldoctest
julia> using Metal, LinearAlgebra

julia> A = MtlArray(Float32[1 2; 3 4]); B = MtlArray(Float32[5 6; 7 8]);

julia> Array(A * B)
2×2 Matrix{Float32}:
 19.0  22.0
 43.0  50.0

julia> C = Metal.ones(Float32, 2, 2);

julia> mul!(C, A', B, 2f0, 1f0);   # C = 2 * A' * B + C

julia> Array(C)
2×2 Matrix{Float32}:
 53.0  61.0
 77.0  89.0
```



### Choosing the implementation

By default, Metal.jl uses MPSGraph when it supports the operands, and otherwise one of its
own kernels. MPSGraph handles `Float32`, `Float16`, `BFloat16`, `ComplexF32` and
`ComplexF16` matrices, and `Int8`/`Int16` inputs with a floating-point output (the full list
is `MPSGraphs.MPSGRAPH_VALID_MATMUL_TYPES`). Everything else, such as integer matrices,
`Symmetric` and `Hermitian` wrappers, strided views, and devices without MPS (e.g.
virtualized GPUs), uses the native kernels.

To force a choice, set [`Metal.matmul_alg`](@ref) with `@with` from `Base.ScopedValues` (Julia 1.11+;
on Julia 1.10, from the ScopedValues.jl package):

```julia
julia> using Metal, Base.ScopedValues

julia> A = Metal.rand(Float32, 1024, 1024); B = Metal.rand(Float32, 1024, 1024);

julia> C = @with Metal.matmul_alg => :native A * B;

julia> Array(C) ≈ Array(A) * Array(B)
true
```

| Value | Implementation |
|:------|:---------------|
| `:auto` (default) | `:MPSGraph` if supported, else `:native` |
| `:MPSGraph` | [`MPSGraphs.matmul!`](@ref) |
| `:MPS` | [`MPS.matmul!`](@ref); `Float32`, `Float16`, and `Int8`/`Int16` inputs (`MPS.MPS_VALID_MATMUL_TYPES`) |
| `:native` | Metal.jl's kernels: `:tensor` if possible, then `:simd`, then `:scalar` |
| `:tensor` | Metal 4 tensor operations; only `C = A * B` without transposes or scaling, all `Float32`, `Float16` or `BFloat16`, with dimensions that are multiples of 8, on GPUs of the Metal 4 family with macOS 26 or later |
| `:simd` | SIMD-group matrix kernel; `Float32`, `Float16` and `BFloat16` |
| `:scalar` | threadgroup-tiled kernel for any element type |
| `:GPUArrays` | the generic GPUArrays.jl kernel |

Forcing an unsupported algorithm throws an error. Keep `:auto` unless measurements favor
another choice: on an M1, MPSGraph and MPS run a 2048×2048 `Float32` product about
2.5 times faster than the native kernels.

## Factorizations and solves

LU and Cholesky factorizations, and solves with them, run on the GPU through MPS.

!!! warning
    These MPS operations only support `Float32`. Calling them on `Float16` matrices aborts
    the Julia process.

```julia
julia> using Metal, LinearAlgebra

julia> A = MtlArray(Float32[4 1 0; 1 3 1; 0 1 2]); b = MtlArray(Float32[1, 2, 3]);

julia> x = A \ b;

julia> Array(A) * Array(x) ≈ Array(b)
true

julia> F = lu(A);         # factorize once, solve many times

julia> Array(F \ b) ≈ Array(x)
true

julia> C = cholesky(A);

julia> Array(ldiv!(C, copy(b))) ≈ Array(x)
true
```

The following are GPU-accelerated for `Float32` matrices:

- `lu`, `lu!`, and `\` with a square matrix;
- `cholesky` and `cholesky!` (also of `Symmetric` and `Hermitian` wrappers), which throw
  `PosDefException` for a matrix that isn't positive definite;
- `\` and `ldiv!` with an `LU` or `Cholesky` factorization;
- `\`, `ldiv!`, `/` and `rdiv!` with `UpperTriangular`, `LowerTriangular` and their unit
  variants, including transposes and adjoints;
- `det`, `logdet`, `logabsdet` and `inv` of a matrix or of an `LU` or `Cholesky`
  factorization.

`lu` throws `SingularException` for a singular matrix unless you pass `check=false`. The
permutation vector `F.p` and permutation matrix `F.P` are computed on the CPU.

Other factorizations (`qr`, `svd`, `eigen`), `\` with a non-square matrix, `/` with a
general matrix, and factorizations of complex matrices are not implemented for `MtlArray`s.
Some of them fall back to LinearAlgebra's generic code, which accesses the shared array
element by element from the CPU: correct but slow, and failing with an error on arrays in
private storage. Copy the matrix to the CPU with `Array` instead.

## Fourier transforms

Loading Metal.jl makes the [AbstractFFTs.jl](https://juliamath.github.io/AbstractFFTs.jl/stable/)
interface available, implemented with MPSGraph: `fft`, `ifft`, `bfft`, `rfft`, `irfft`,
`brfft`, the in-place `fft!`, `ifft!` and `bfft!`, and the corresponding plans.

```julia
julia> using Metal

julia> x = MtlArray(Float32[1, 2, 3, 4]);

julia> Array(fft(x))
4-element Vector{ComplexF32}:
 10.0f0 + 0.0f0im
 -2.0f0 + 2.0f0im
 -2.0f0 + 0.0f0im
 -2.0f0 - 2.0f0im

julia> Array(irfft(rfft(x), 4))
4-element Vector{Float32}:
 1.0
 2.0
 3.0
 4.0
```

Transforms support `ComplexF32` and `ComplexF16`. `fft` converts `Float32` and `Float16`
inputs to complex; use `rfft` to exploit real-valued input. Integer inputs are converted
to `Float32`. Any
array length works, not only powers of two, and you can transform along any subset of
dimensions. The input must be a contiguous `MtlArray`; strided views and wrappers like
`transpose` are not supported.

To transform many arrays of the same shape, create a plan once and apply it. A plan's
`\` applies the inverse:

```julia
julia> X = MtlArray(rand(ComplexF32, 256, 64));

julia> p = plan_fft(X, 1)   # 1D transforms along the columns
MPSGraph FFT ComplexF32 forward plan for 256×64 MtlArray of ComplexF32

julia> Y = p * X;

julia> Array(p \ Y) ≈ Array(X)
true
```

## Top-k selection

[`MPS.topk`](@ref) returns the `k` largest values of each column of a `Float32` or
`Float16` matrix and their row indices, for `k` up to 16:

```julia
julia> using Metal

julia> A = MtlArray(Float32[3 1; 1 4; 2 0; 5 9]);

julia> idx, vals = MPS.topk(A, 2);

julia> Array(idx)
2×2 Matrix{UInt32}:
 0x00000004  0x00000004
 0x00000001  0x00000002

julia> Array(vals)
2×2 Matrix{Float32}:
 5.0  9.0
 3.0  4.0
```

## Calling MPSGraph directly

The `MPSGraphs` module exposes the MPSGraph operations behind these interfaces, and others
without a Base or LinearAlgebra counterpart: batched matrix multiplication of 3D arrays,
softmax, convolution and pooling. Call them to pick MPSGraph explicitly, with
[`MPSGraphs.supports`](@ref) to check whether a call is supported before making it. See
[Metal Performance Shaders Graph](@ref) for the operations and their requirements.
