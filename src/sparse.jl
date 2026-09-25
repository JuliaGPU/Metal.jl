# sparse arrays
#
# GPUArrays implements the sparse formats generically, parametrized on their storage. Metal
# names them for `MtlVector` storage, and decides how `mtl` transfers host sparse arrays.

using SparseArrays
using SparseArrays: getcolptr, nonzeroinds
using GPUArrays: GPUSparseVector, GPUSparseMatrixCSR, GPUSparseMatrixCSC, GPUSparseMatrixCOO

export MtlSparseVector, MtlSparseMatrixCSR, MtlSparseMatrixCSC, MtlSparseMatrixCOO

const MtlSparseVector{Tv,Ti} = GPUSparseVector{Tv,Ti,<:MtlVector{Ti},<:MtlVector{Tv}}
const MtlSparseMatrixCSR{Tv,Ti} = GPUSparseMatrixCSR{Tv,Ti,<:MtlVector{Ti},<:MtlVector{Tv}}
const MtlSparseMatrixCSC{Tv,Ti} = GPUSparseMatrixCSC{Tv,Ti,<:MtlVector{Ti},<:MtlVector{Tv}}
const MtlSparseMatrixCOO{Tv,Ti} = GPUSparseMatrixCOO{Tv,Ti,<:MtlVector{Ti},<:MtlVector{Tv}}

# `mtl` picks the best representation, just as it narrows Float64 for dense arrays:
# matrices become CSR, indices Int32 (32-bit arithmetic and atomics are much cheaper on
# Apple GPUs) unless they do not fit, and values follow the dense rules.
mtl_indtype(A::AbstractSparseArray) =
    max(size(A)..., nnz(A) + 1) <= typemax(Int32) ? Int32 : SparseArrays.indtype(A)

# the CSC buffers of `transpose(A)`, computed on the host, are the CSR buffers of `A`
function Adapt.adapt_structure(to::MtlArrayAdaptor{S}, A::SparseMatrixCSC) where {S}
    Ti = mtl_indtype(A)
    At = copy(transpose(A))
    GPUSparseMatrixCSR(MtlVector{Ti,S}(getcolptr(At)), MtlVector{Ti,S}(rowvals(At)),
                       adapt(to, nonzeros(At)), size(A))
end
function Adapt.adapt_structure(to::MtlArrayAdaptor{S}, x::SparseVector) where {S}
    Ti = mtl_indtype(x)
    GPUSparseVector(MtlVector{Ti,S}(nonzeroinds(x)), adapt(to, nonzeros(x)), length(x))
end
