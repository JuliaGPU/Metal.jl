# sparse arrays
#
# GPUArrays implements the sparse formats generically, parametrized on their storage. Metal
# names them for `MtlVector` storage, and decides how `mtl` transfers host sparse arrays.

using SparseArrays
using SparseArrays: getcolptr, nonzeroinds
using GPUArrays: GPUSparseVector, GPUSparseMatrixCSR, GPUSparseMatrixCSC, GPUSparseMatrixCOO

export MtlSparseVector, MtlSparseMatrixCSR, MtlSparseMatrixCSC, MtlSparseMatrixCOO

"""
    MtlSparseVector{Tv,Ti}

A sparse vector with values of type `Tv` and indices of type `Ti` stored in `MtlVector`s:
GPUArrays' `GPUSparseVector` with Metal storage. Construct one from a host `SparseVector`,
a dense vector or another sparse vector with `MtlSparseVector(x)` or
`MtlSparseVector{Tv,Ti}(x)`, or with `mtl(x)`.
"""
const MtlSparseVector{Tv,Ti} = GPUSparseVector{Tv,Ti,<:MtlVector{Ti},<:MtlVector{Tv}}

"""
    MtlSparseMatrixCSR{Tv,Ti}

A sparse matrix in compressed sparse row format stored in `MtlVector`s: GPUArrays'
`GPUSparseMatrixCSR` with Metal storage. This is what `mtl` makes of a `SparseMatrixCSC`,
and the fastest format for `A * x`. Construct one from a host sparse matrix, a dense
matrix or a sparse matrix in another format with `MtlSparseMatrixCSR(A)` or
`MtlSparseMatrixCSR{Tv,Ti}(A)`.
"""
const MtlSparseMatrixCSR{Tv,Ti} = GPUSparseMatrixCSR{Tv,Ti,<:MtlVector{Ti},<:MtlVector{Tv}}

"""
    MtlSparseMatrixCSC{Tv,Ti}

A sparse matrix in compressed sparse column format stored in `MtlVector`s: GPUArrays'
`GPUSparseMatrixCSC` with Metal storage, the layout of `SparseMatrixCSC`. It suits
`transpose(A) * x` and dense × sparse products. See [`MtlSparseMatrixCSR`](@ref) for the
constructors.
"""
const MtlSparseMatrixCSC{Tv,Ti} = GPUSparseMatrixCSC{Tv,Ti,<:MtlVector{Ti},<:MtlVector{Tv}}

"""
    MtlSparseMatrixCOO{Tv,Ti}

A sparse matrix in coordinate format, sorted by row, stored in `MtlVector`s: GPUArrays'
`GPUSparseMatrixCOO` with Metal storage. See [`MtlSparseMatrixCSR`](@ref) for the
constructors.
"""
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

const MtlSparseMatrix{Tv,Ti} =
    Union{MtlSparseMatrixCSR{Tv,Ti}, MtlSparseMatrixCSC{Tv,Ti}, MtlSparseMatrixCOO{Tv,Ti}}

# Constructors on the aliases: move the input to Metal (keeping its format and types), then
# convert on the device. With explicit element types, host inputs are converted first,
# as Metal may not support their element type (Float64).
host_convert(::Type{Tv}, ::Type{Ti}, A::SparseMatrixCSC) where {Tv,Ti} = SparseMatrixCSC{Tv,Ti}(A)
host_convert(::Type{Tv}, ::Type{Ti}, x::SparseVector) where {Tv,Ti} = SparseVector{Tv,Ti}(x)
host_convert(::Type{Tv}, ::Type{Ti}, A::Array) where {Tv,Ti} = Array{Tv}(A)
host_convert(::Type, ::Type, A) = A

for (alias, generic) in ((:MtlSparseVector, :GPUSparseVector), (:MtlSparseMatrixCSR, :GPUSparseMatrixCSR),
                         (:MtlSparseMatrixCSC, :GPUSparseMatrixCSC), (:MtlSparseMatrixCOO, :GPUSparseMatrixCOO))
    @eval begin
        $alias(A::AbstractArray) = $generic(adapt(MtlArray, A))
        $alias{Tv}(A::AbstractArray) where {Tv} =
            $generic{Tv}(adapt(MtlArray, host_convert(Tv, input_indtype(A), A)))
        $alias{Tv,Ti}(A::AbstractArray) where {Tv,Ti} =
            $generic{Tv,Ti}(adapt(MtlArray, host_convert(Tv, Ti, A)))
    end
end
# the index type to keep; dense inputs get `Int`, as in GPUArrays' conversions
input_indtype(A::AbstractSparseArray) = SparseArrays.indtype(A)
input_indtype(A) = Int

# densify on the device (the generic constructors copy through the host)
for (N, Sparse) in ((1, :MtlSparseVector), (2, :MtlSparseMatrix))
    @eval begin
        MtlArray{T,$N,S}(A::$Sparse) where {T,S} = copyto!(MtlArray{T,$N,S}(undef, size(A)), A)
        MtlArray{T,$N,S}(A::$Sparse{T}) where {T,S} = copyto!(MtlArray{T,$N,S}(undef, size(A)), A)
        MtlArray{T,$N}(A::$Sparse) where {T} = MtlArray{T,$N,DefaultStorageMode}(A)
        MtlArray{T,$N}(A::$Sparse{T}) where {T} = MtlArray{T,$N,DefaultStorageMode}(A)
    end
end
