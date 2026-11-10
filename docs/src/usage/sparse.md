# Sparse arrays

Metal.jl supports sparse vectors and sparse matrices in CSR, CSC and COO format. The
formats and their operations are implemented by GPUArrays.jl, for every back-end; Metal.jl
names them for its storage (`MtlSparseVector`, `MtlSparseMatrixCSR`, `MtlSparseMatrixCSC`,
`MtlSparseMatrixCOO`) and decides how `mtl` transfers host sparse arrays.

## Moving sparse arrays to the GPU

`mtl` picks the best representation on Metal, just as it narrows `Float64` to `Float32`
for dense arrays: sparse matrices become CSR, with `Int32` indices when they fit, and
their values follow the dense rules.

```julia
using Metal, SparseArrays

A = sprand(1_000, 1_000, 0.01)     # SparseMatrixCSC{Float64,Int64}
dA = mtl(A)                        # MtlSparseMatrixCSR{Float32,Int32}
dx = mtl(sprand(1_000, 0.1))       # MtlSparseVector{Float32,Int32}
```

To choose the format and types, use a constructor, or `adapt` to keep them as they are:

```julia
MtlSparseMatrixCSR{Float32,Int32}(A)    # explicit types, converted on the host
MtlSparseMatrixCSC{Float32}(A)          # CSC{Float32,Int64}
MtlSparseMatrixCSC(A)                   # keeps Float64, which Metal does not support
adapt(MtlArray{Float32}, A)             # CSC{Float32,Int64}: the format and index type stay
```

Constructors also accept dense arrays (dropping their zeros) and sparse arrays in other
formats, which are converted on the device. `sparse(dD; fmt=:csr)` does the same for a
dense `MtlMatrix`. Back on the host, `SparseMatrixCSC(dA)`, `SparseVector(dx)` and
`Array(dA)` copy the data, and `MtlArray(dA)` densifies on the device.

Sparse arrays can be assembled on the device from coordinates, like with SparseArrays:

```julia
I = MtlArray(Int32[1, 2, 2, 3]); J = MtlArray(Int32[1, 1, 1, 3]); V = Metal.rand(Float32, 4)
S = sparse(I, J, V, 3, 3)          # repeated coordinates are added, in input order
S = sparse(I, J, V, 3, 3; fmt=:csr)
```

## Operations

GPU sparse arrays support broadcasting (a function that preserves zeros keeps the sparse
structure, others give a dense result), reductions (`sum`, `maximum`, `mapreduce` with
`dims`), products with dense vectors and matrices (`*`, 5-argument `mul!`, with transposed,
adjoint, `Symmetric` and `Hermitian` operands), products of sparse matrices, conversions
between formats, `findnz`, `triu`/`tril`, `diag`, `kron`, `reshape`, `dropzeros`,
`droptol!`, slicing with ranges, and more. Everything runs on the GPU; only printing and
explicit conversions to host arrays copy data back.

The storage buffers are fields of the matrix (`rowPtr`, `colVal` and `nzVal` for CSR), and
the same struct can be passed to a kernel:

```julia
function rowsum_kernel(out, A)
    i = thread_position_in_grid().x
    if i <= length(out)
        acc = 0f0
        for k in A.rowPtr[i]:A.rowPtr[i+1]-1
            acc += A.nzVal[k]
        end
        out[i] = acc
    end
    return
end
out = Metal.zeros(Float32, size(dA, 1))
@metal threads=256 groups=cld(length(out), 256) rowsum_kernel(out, dA)
```

Individual entries cannot be set: assemble a new array with `sparse(I, J, V)`, broadcast,
or update the stored values through `nonzeros(A)`.

## Choosing a format

- **CSR** (what `mtl` produces) is the best format for `A * x` and `A * B`: every thread
  gathers the entries of one row.
- **CSC** suits `transpose(A) * x` and dense × sparse products (`D * A`), whose natural
  layout is by column.
- Products with the "other" orientation (`transpose(A) * x` for CSR, `A * x` for CSC)
  first regroup the matrix, which involves a sort and costs much more than the product.
  When the same transposed product is computed repeatedly, convert once:
  `At = copy(transpose(A))`.
- Conversions between CSR and CSC, and reductions along the non-compressed dimension,
  sort the entries as well. **COO** converts to and from CSR cheaply.

These are the characteristics of the current, generic implementation, which uses no
atomics and gives deterministic results; faster algorithms will follow.
