export MtlSparseVector, MtlSparseMatrixCSC, MtlSparseMatrixCSR

import LinearAlgebra
using LinearAlgebra: Adjoint, Transpose
using SparseArrays
using KernelAbstractions: @index

"""
    MtlSparseVector{Tv,Ti,S} <: AbstractSparseVector{Tv,Ti}

A sparse vector whose indices and stored values are Metal arrays with storage mode `S`.
"""
mutable struct MtlSparseVector{Tv,Ti,S} <: GPUArrays.AbstractGPUSparseVector{Tv,Ti}
    iPtr::MtlVector{Ti,S}
    nzVal::MtlVector{Tv,S}
    len::Int
    nnz::Ti

    function MtlSparseVector{Tv,Ti,S}(
        iPtr::MtlVector{Ti,S},
        nzVal::MtlVector{Tv,S},
        len::Integer,
    ) where {Tv,Ti<:Integer,S}
        len >= 0 || throw(ArgumentError("the vector length must be nonnegative"))
        length(iPtr) == length(nzVal) ||
            throw(ArgumentError("the index and value arrays must have the same length"))
        new{Tv,Ti,S}(iPtr, nzVal, Int(len), convert(Ti, length(nzVal)))
    end
end

"""
    MtlSparseMatrixCSC{Tv,Ti,S} <: AbstractSparseMatrix{Tv,Ti}

A sparse matrix in compressed sparse column (CSC) format. Its column pointers, row indices,
and stored values are Metal arrays with storage mode `S`.
"""
mutable struct MtlSparseMatrixCSC{Tv,Ti,S} <: GPUArrays.AbstractGPUSparseMatrixCSC{Tv,Ti}
    colPtr::MtlVector{Ti,S}
    rowVal::MtlVector{Ti,S}
    nzVal::MtlVector{Tv,S}
    dims::NTuple{2,Int}
    nnz::Ti

    function MtlSparseMatrixCSC{Tv,Ti,S}(
        colPtr::MtlVector{Ti,S},
        rowVal::MtlVector{Ti,S},
        nzVal::MtlVector{Tv,S},
        dims::NTuple{2,<:Integer},
    ) where {Tv,Ti<:Integer,S}
        all(>=(0), dims) || throw(ArgumentError("matrix dimensions must be nonnegative"))
        length(colPtr) == dims[2] + 1 || throw(
            ArgumentError("a CSC matrix needs one column pointer per column plus one"),
        )
        length(rowVal) == length(nzVal) ||
            throw(ArgumentError("the row-index and value arrays must have the same length"))
        new{Tv,Ti,S}(
            colPtr,
            rowVal,
            nzVal,
            (Int(dims[1]), Int(dims[2])),
            convert(Ti, length(nzVal)),
        )
    end
end

"""
    MtlSparseMatrixCSR{Tv,Ti,S} <: AbstractSparseMatrix{Tv,Ti}

A sparse matrix in compressed sparse row (CSR) format. Its row pointers, column indices,
and stored values are Metal arrays with storage mode `S`.
"""
mutable struct MtlSparseMatrixCSR{Tv,Ti,S} <: GPUArrays.AbstractGPUSparseMatrixCSR{Tv,Ti}
    rowPtr::MtlVector{Ti,S}
    colVal::MtlVector{Ti,S}
    nzVal::MtlVector{Tv,S}
    dims::NTuple{2,Int}
    nnz::Ti

    function MtlSparseMatrixCSR{Tv,Ti,S}(
        rowPtr::MtlVector{Ti,S},
        colVal::MtlVector{Ti,S},
        nzVal::MtlVector{Tv,S},
        dims::NTuple{2,<:Integer},
    ) where {Tv,Ti<:Integer,S}
        all(>=(0), dims) || throw(ArgumentError("matrix dimensions must be nonnegative"))
        length(rowPtr) == dims[1] + 1 ||
            throw(ArgumentError("a CSR matrix needs one row pointer per row plus one"))
        length(colVal) == length(nzVal) || throw(
            ArgumentError("the column-index and value arrays must have the same length"),
        )
        new{Tv,Ti,S}(
            rowPtr,
            colVal,
            nzVal,
            (Int(dims[1]), Int(dims[2])),
            convert(Ti, length(nzVal)),
        )
    end
end

const MtlSparseArray = Union{MtlSparseVector,MtlSparseMatrixCSC,MtlSparseMatrixCSR}


## Component constructors

MtlSparseVector(
    iPtr::MtlVector{Ti,S},
    nzVal::MtlVector{Tv,S},
    len::Integer,
) where {Tv,Ti<:Integer,S} = MtlSparseVector{Tv,Ti,S}(iPtr, nzVal, len)
MtlSparseVector{Tv,Ti}(
    iPtr::MtlVector{Ti,S},
    nzVal::MtlVector{Tv,S},
    len::Integer,
) where {Tv,Ti<:Integer,S} = MtlSparseVector{Tv,Ti,S}(iPtr, nzVal, len)

MtlSparseMatrixCSC(
    colPtr::MtlVector{Ti,S},
    rowVal::MtlVector{Ti,S},
    nzVal::MtlVector{Tv,S},
    dims::NTuple{2,<:Integer},
) where {Tv,Ti<:Integer,S} = MtlSparseMatrixCSC{Tv,Ti,S}(colPtr, rowVal, nzVal, dims)
MtlSparseMatrixCSC{Tv,Ti}(
    colPtr::MtlVector{Ti,S},
    rowVal::MtlVector{Ti,S},
    nzVal::MtlVector{Tv,S},
    dims::NTuple{2,<:Integer},
) where {Tv,Ti<:Integer,S} = MtlSparseMatrixCSC{Tv,Ti,S}(colPtr, rowVal, nzVal, dims)

MtlSparseMatrixCSR(
    rowPtr::MtlVector{Ti,S},
    colVal::MtlVector{Ti,S},
    nzVal::MtlVector{Tv,S},
    dims::NTuple{2,<:Integer},
) where {Tv,Ti<:Integer,S} = MtlSparseMatrixCSR{Tv,Ti,S}(rowPtr, colVal, nzVal, dims)
MtlSparseMatrixCSR{Tv,Ti}(
    rowPtr::MtlVector{Ti,S},
    colVal::MtlVector{Ti,S},
    nzVal::MtlVector{Tv,S},
    dims::NTuple{2,<:Integer},
) where {Tv,Ti<:Integer,S} = MtlSparseMatrixCSR{Tv,Ti,S}(rowPtr, colVal, nzVal, dims)


## Basic array interface

Base.size(x::MtlSparseVector) = (x.len,)
Base.size(x::Union{MtlSparseMatrixCSC,MtlSparseMatrixCSR}) = x.dims
Base.length(x::MtlSparseVector) = x.len
Base.length(x::Union{MtlSparseMatrixCSC,MtlSparseMatrixCSR}) = prod(x.dims)

device(x::MtlSparseArray) = device(SparseArrays.nonzeros(x))
storagemode(::Type{<:MtlSparseVector{<:Any,<:Any,S}}) where {S} = S
storagemode(::Type{<:MtlSparseMatrixCSC{<:Any,<:Any,S}}) where {S} = S
storagemode(::Type{<:MtlSparseMatrixCSR{<:Any,<:Any,S}}) where {S} = S
storagemode(x::MtlSparseArray) = storagemode(typeof(x))
is_shared(x::MtlSparseArray) = storagemode(x) == SharedStorage
is_managed(x::MtlSparseArray) = storagemode(x) == ManagedStorage
is_private(x::MtlSparseArray) = storagemode(x) == PrivateStorage
is_memoryless(x::MtlSparseArray) = storagemode(x) == Memoryless

Base.show(io::IOContext, x::MtlSparseVector) = show(io, SparseVector(x))
Base.show(io::IOContext, x::Union{MtlSparseMatrixCSC,MtlSparseMatrixCSR}) =
    show(io, SparseMatrixCSC(x))

function Base.show(io::IO, mime::MIME"text/plain", x::MtlSparseVector)
    GPUArrays.@allowscalar @invoke show(io, mime, x::AbstractSparseVector)
end

function Base.show(
    io::IO,
    ::MIME"text/plain",
    x::Union{MtlSparseMatrixCSC,MtlSparseMatrixCSR},
)
    xnnz = nnz(x)
    m, n = size(x)
    print(
        io,
        m,
        "×",
        n,
        " ",
        typeof(x),
        " with ",
        xnnz,
        " stored ",
        xnnz == 1 ? "entry" : "entries",
    )
    if m != 0 && n != 0
        println(io, ":")
        Base.print_array(IOContext(io, :typeinfo => eltype(x)), SparseMatrixCSC(x))
    end
end


## CPU/GPU construction and format conversion

function MtlSparseVector{Tv,Ti,S}(x::SparseVector) where {Tv,Ti<:Integer,S}
    MtlSparseVector{Tv,Ti,S}(
        MtlVector{Ti,S}(SparseArrays.nonzeroinds(x)),
        MtlVector{Tv,S}(SparseArrays.nonzeros(x)),
        length(x),
    )
end
MtlSparseVector{Tv,Ti}(x::SparseVector) where {Tv,Ti<:Integer} =
    MtlSparseVector{Tv,Ti,DefaultStorageMode}(x)
MtlSparseVector{Tv}(x::SparseVector{<:Any,Ti}) where {Tv,Ti<:Integer} =
    MtlSparseVector{Tv,Ti}(x)
MtlSparseVector(x::SparseVector{Tv,Ti}) where {Tv,Ti<:Integer} = MtlSparseVector{Tv,Ti}(x)
MtlSparseVector(x::MtlSparseVector) = x

function MtlSparseMatrixCSC{Tv,Ti,S}(x::SparseMatrixCSC) where {Tv,Ti<:Integer,S}
    MtlSparseMatrixCSC{Tv,Ti,S}(
        MtlVector{Ti,S}(x.colptr),
        MtlVector{Ti,S}(x.rowval),
        MtlVector{Tv,S}(x.nzval),
        size(x),
    )
end
MtlSparseMatrixCSC{Tv,Ti}(x::SparseMatrixCSC) where {Tv,Ti<:Integer} =
    MtlSparseMatrixCSC{Tv,Ti,DefaultStorageMode}(x)
MtlSparseMatrixCSC{Tv}(x::SparseMatrixCSC{<:Any,Ti}) where {Tv,Ti<:Integer} =
    MtlSparseMatrixCSC{Tv,Ti}(x)
MtlSparseMatrixCSC(x::SparseMatrixCSC{Tv,Ti}) where {Tv,Ti<:Integer} =
    MtlSparseMatrixCSC{Tv,Ti}(x)
MtlSparseMatrixCSC(x::MtlSparseMatrixCSC) = x

function MtlSparseMatrixCSR{Tv,Ti,S}(x::SparseMatrixCSC) where {Tv,Ti<:Integer,S}
    converted = SparseMatrixCSC{Tv,Ti}(x)
    transposed = SparseMatrixCSC(transpose(converted))
    MtlSparseMatrixCSR{Tv,Ti,S}(
        MtlVector{Ti,S}(transposed.colptr),
        MtlVector{Ti,S}(transposed.rowval),
        MtlVector{Tv,S}(transposed.nzval),
        size(x),
    )
end
MtlSparseMatrixCSR{Tv,Ti}(x::SparseMatrixCSC) where {Tv,Ti<:Integer} =
    MtlSparseMatrixCSR{Tv,Ti,DefaultStorageMode}(x)
MtlSparseMatrixCSR{Tv}(x::SparseMatrixCSC{<:Any,Ti}) where {Tv,Ti<:Integer} =
    MtlSparseMatrixCSR{Tv,Ti}(x)
MtlSparseMatrixCSR(x::SparseMatrixCSC{Tv,Ti}) where {Tv,Ti<:Integer} =
    MtlSparseMatrixCSR{Tv,Ti}(x)
MtlSparseMatrixCSR(x::MtlSparseMatrixCSR) = x

MtlSparseVector(x::SparseMatrixCSC{Tv,Ti}) where {Tv,Ti<:Integer} =
    MtlSparseVector(SparseVector(x))
MtlSparseMatrixCSC(x::SparseVector) = MtlSparseMatrixCSC(SparseMatrixCSC(x))
MtlSparseMatrixCSR(x::SparseVector) = MtlSparseMatrixCSR(SparseMatrixCSC(x))

function SparseArrays.SparseMatrixCSC(x::MtlSparseMatrixCSR)
    transposed = SparseMatrixCSC(
        size(x, 2),
        size(x, 1),
        Array(x.rowPtr),
        Array(x.colVal),
        Array(x.nzVal),
    )
    SparseMatrixCSC(transpose(transposed))
end

@inline function _compressed_segment(ptrs, p::Integer)
    lo = 1
    hi = length(ptrs)
    while lo < hi
        mid = (lo + hi + 1) >> 1
        if @inbounds(ptrs[mid]) <= p
            lo = mid
        else
            hi = mid - 1
        end
    end
    lo
end

@inline function _lower_bound(values, target::Integer)
    lo = 1
    hi = length(values) + 1
    while lo < hi
        mid = (lo + hi) >> 1
        if @inbounds(values[mid]) < target
            lo = mid + 1
        else
            hi = mid
        end
    end
    lo
end

KernelAbstractions.@kernel function _csc_sort_keys_kernel!(keys, A)
    p = @index(Global, Linear)
    col = _compressed_segment(A.colPtr, p)
    row = @inbounds A.rowVal[p]
    @inbounds keys[p] = (Int64(row) - 1) * Int64(size(A, 2)) + Int64(col)
end

KernelAbstractions.@kernel function _csr_sort_keys_kernel!(keys, A)
    p = @index(Global, Linear)
    row = _compressed_segment(A.rowPtr, p)
    col = @inbounds A.colVal[p]
    @inbounds keys[p] = (Int64(col) - 1) * Int64(size(A, 1)) + Int64(row)
end

KernelAbstractions.@kernel function _csc_to_csr_reorder_kernel!(
    rows,
    cols,
    values,
    A,
    permutation,
)
    p = @index(Global, Linear)
    source = Int(@inbounds permutation[p])
    @inbounds begin
        rows[p] = A.rowVal[source]
        cols[p] = _compressed_segment(A.colPtr, source)
        values[p] = A.nzVal[source]
    end
end

KernelAbstractions.@kernel function _csr_to_csc_reorder_kernel!(
    cols,
    rows,
    values,
    A,
    permutation,
)
    p = @index(Global, Linear)
    source = Int(@inbounds permutation[p])
    @inbounds begin
        cols[p] = A.colVal[source]
        rows[p] = _compressed_segment(A.rowPtr, source)
        values[p] = A.nzVal[source]
    end
end

KernelAbstractions.@kernel function _compressed_pointers_kernel!(pointers, primary_indices)
    segment = @index(Global, Linear)
    @inbounds pointers[segment] = _lower_bound(primary_indices, segment)
end

function MtlSparseMatrixCSC{Tv,Ti,S}(x::MtlSparseMatrixCSR) where {Tv,Ti<:Integer,S}
    entries = Int(nnz(x))
    colPtr = MtlVector{Ti,S}(undef, size(x, 2) + 1)
    rowVal = MtlVector{Ti,S}(undef, entries)
    nzVal = MtlVector{Tv,S}(undef, entries)

    if entries > 0
        backend = KernelAbstractions.get_backend(x)
        keys = MtlVector{Int64,S}(undef, entries)
        _csr_sort_keys_kernel!(backend)(keys, x; ndrange = entries)
        permutation = sortperm(keys)

        sorted_cols = MtlVector{Ti,S}(undef, entries)
        _csr_to_csc_reorder_kernel!(backend)(
            sorted_cols,
            rowVal,
            nzVal,
            x,
            permutation;
            ndrange = entries,
        )
        _compressed_pointers_kernel!(backend)(
            colPtr,
            sorted_cols;
            ndrange = length(colPtr),
        )
    else
        fill!(colPtr, one(Ti))
    end

    MtlSparseMatrixCSC(colPtr, rowVal, nzVal, size(x))
end
MtlSparseMatrixCSC(x::MtlSparseMatrixCSR{Tv,Ti,S}) where {Tv,Ti<:Integer,S} =
    MtlSparseMatrixCSC{Tv,Ti,S}(x)
function MtlSparseMatrixCSR{Tv,Ti,S}(x::MtlSparseMatrixCSC) where {Tv,Ti<:Integer,S}
    entries = Int(nnz(x))
    rowPtr = MtlVector{Ti,S}(undef, size(x, 1) + 1)
    colVal = MtlVector{Ti,S}(undef, entries)
    nzVal = MtlVector{Tv,S}(undef, entries)

    if entries > 0
        backend = KernelAbstractions.get_backend(x)
        keys = MtlVector{Int64,S}(undef, entries)
        _csc_sort_keys_kernel!(backend)(keys, x; ndrange = entries)
        permutation = sortperm(keys)

        sorted_rows = MtlVector{Ti,S}(undef, entries)
        _csc_to_csr_reorder_kernel!(backend)(
            sorted_rows,
            colVal,
            nzVal,
            x,
            permutation;
            ndrange = entries,
        )
        _compressed_pointers_kernel!(backend)(
            rowPtr,
            sorted_rows;
            ndrange = length(rowPtr),
        )
    else
        fill!(rowPtr, one(Ti))
    end

    MtlSparseMatrixCSR(rowPtr, colVal, nzVal, size(x))
end
MtlSparseMatrixCSR(x::MtlSparseMatrixCSC{Tv,Ti,S}) where {Tv,Ti<:Integer,S} =
    MtlSparseMatrixCSR{Tv,Ti,S}(x)

KernelAbstractions.@kernel function _sparse_vector_to_dense_kernel!(output, x)
    p = @index(Global, Linear)
    @inbounds output[x.iPtr[p]] = x.nzVal[p]
end

KernelAbstractions.@kernel function _sparse_csc_to_dense_kernel!(output, x)
    p = @index(Global, Linear)
    col = _compressed_segment(x.colPtr, p)
    @inbounds output[x.rowVal[p], col] = x.nzVal[p]
end

KernelAbstractions.@kernel function _sparse_csr_to_dense_kernel!(output, x)
    p = @index(Global, Linear)
    row = _compressed_segment(x.rowPtr, p)
    @inbounds output[row, x.colVal[p]] = x.nzVal[p]
end

function MtlArray{T,N,S}(x::MtlSparseArray) where {T,N,S}
    N == ndims(x) || throw(
        DimensionMismatch(
            "cannot construct a $N-dimensional Metal array from " *
            "$(ndims(x))-dimensional sparse data",
        ),
    )

    output = zeros(T, size(x); storage = S)
    entries = Int(nnz(x))
    entries == 0 && return output

    backend = KernelAbstractions.get_backend(x)
    if x isa MtlSparseVector
        _sparse_vector_to_dense_kernel!(backend)(output, x; ndrange = entries)
    elseif x isa MtlSparseMatrixCSC
        _sparse_csc_to_dense_kernel!(backend)(output, x; ndrange = entries)
    else
        _sparse_csr_to_dense_kernel!(backend)(output, x; ndrange = entries)
    end
    output
end
MtlArray{T,N}(x::MtlSparseArray) where {T,N} = MtlArray{T,N,storagemode(x)}(x)
MtlArray{T}(x::MtlSparseArray) where {T} = MtlArray{T,ndims(x),storagemode(x)}(x)
MtlArray(x::MtlSparseArray) = MtlArray{eltype(x),ndims(x),storagemode(x)}(x)

for MT in (:MtlSparseMatrixCSC, :MtlSparseMatrixCSR)
    @eval begin
        $MT(x::Transpose{<:Any,<:SparseMatrixCSC}) = $MT(SparseMatrixCSC(x))
        $MT(x::Adjoint{<:Any,<:SparseMatrixCSC}) = $MT(SparseMatrixCSC(x))
    end
end

@inline _isnotzero(x) = !iszero(x)

KernelAbstractions.@kernel function _dense_csc_structure_kernel!(
    rowVal,
    colPtr,
    linear_indices,
    rows,
)
    i = @index(Global, Linear)
    if i <= length(rowVal)
        linear = Int(@inbounds linear_indices[i])
        @inbounds rowVal[i] = mod(linear - 1, rows) + 1
    end
    if i <= length(colPtr)
        first_linear_index = (i - 1) * rows + 1
        @inbounds colPtr[i] = _lower_bound(linear_indices, first_linear_index)
    end
end

function SparseArrays.sparse(x::MtlVector; fmt::Symbol = :csc)
    fmt === :csc || throw(ArgumentError("sparse vectors only support fmt=:csc"))
    indices = findall(_isnotzero, x)
    MtlSparseVector(indices, x[indices], length(x))
end

function SparseArrays.sparse(x::MtlMatrix; fmt::Symbol = :csc)
    fmt in (:csc, :csr) ||
        throw(ArgumentError("unsupported sparse format $fmt; expected :csc or :csr"))

    linear = reshape(x, length(x))
    linear_indices = findall(_isnotzero, linear)
    Ti = eltype(linear_indices)
    S = storagemode(x)
    rowVal = MtlVector{Ti,S}(undef, length(linear_indices))
    colPtr = MtlVector{Ti,S}(undef, size(x, 2) + 1)
    backend = KernelAbstractions.get_backend(x)
    _dense_csc_structure_kernel!(backend)(
        rowVal,
        colPtr,
        linear_indices,
        size(x, 1);
        ndrange = max(length(rowVal), length(colPtr)),
    )
    csc = MtlSparseMatrixCSC(colPtr, rowVal, linear[linear_indices], size(x))

    if fmt === :csc
        csc
    else
        MtlSparseMatrixCSR(csc)
    end
end

function SparseArrays.sparse(x::MtlSparseVector; fmt::Symbol = :csc)
    fmt === :csc || throw(ArgumentError("sparse vectors only support fmt=:csc"))
    x
end
function SparseArrays.sparse(x::MtlSparseMatrixCSC; fmt::Symbol = :csc)
    fmt === :csc && return x
    fmt === :csr && return MtlSparseMatrixCSR(x)
    throw(ArgumentError("unsupported sparse format $fmt; expected :csc or :csr"))
end
function SparseArrays.sparse(x::MtlSparseMatrixCSR; fmt::Symbol = :csr)
    fmt === :csr && return x
    fmt === :csc && return MtlSparseMatrixCSC(x)
    throw(ArgumentError("unsupported sparse format $fmt; expected :csc or :csr"))
end


## Adapt integration

Adapt.adapt_storage(::Type{MtlArray}, x::SparseVector) = MtlSparseVector(x)
Adapt.adapt_storage(::Type{<:MtlArray{T}}, x::SparseVector{<:Any,Ti}) where {T,Ti} =
    MtlSparseVector{T,Ti}(x)
function Adapt.adapt_storage(
    ::Type{<:MtlArray{T,N}},
    x::SparseVector{<:Any,Ti},
) where {T,N,Ti}
    N == 1 || throw(
        DimensionMismatch("cannot adapt a sparse vector to a $N-dimensional array type"),
    )
    MtlSparseVector{T,Ti}(x)
end
Adapt.adapt_storage(::Type{<:MtlArray{T,N,S}}, x::SparseVector{<:Any,Ti}) where {T,N,S,Ti} =
    N == 1 ? MtlSparseVector{T,Ti,S}(x) :
    throw(DimensionMismatch("cannot adapt a sparse vector to a $N-dimensional array type"))
Adapt.adapt_storage(::Type{MtlArray}, x::SparseMatrixCSC) = MtlSparseMatrixCSC(x)
Adapt.adapt_storage(::Type{<:MtlArray{T}}, x::SparseMatrixCSC{<:Any,Ti}) where {T,Ti} =
    MtlSparseMatrixCSC{T,Ti}(x)
function Adapt.adapt_storage(
    ::Type{<:MtlArray{T,N}},
    x::SparseMatrixCSC{<:Any,Ti},
) where {T,N,Ti}
    N == 2 || throw(
        DimensionMismatch("cannot adapt a sparse matrix to a $N-dimensional array type"),
    )
    MtlSparseMatrixCSC{T,Ti}(x)
end
Adapt.adapt_storage(
    ::Type{<:MtlArray{T,N,S}},
    x::SparseMatrixCSC{<:Any,Ti},
) where {T,N,S,Ti} =
    N == 2 ? MtlSparseMatrixCSC{T,Ti,S}(x) :
    throw(DimensionMismatch("cannot adapt a sparse matrix to a $N-dimensional array type"))

function Adapt.adapt_storage(to::MtlArrayAdaptor{S}, x::SparseVector{Tv,Ti}) where {Tv,Ti,S}
    MtlSparseVector(
        MtlVector{Ti,S}(SparseArrays.nonzeroinds(x)),
        adapt(to, nonzeros(x)),
        length(x),
    )
end
function Adapt.adapt_storage(
    to::MtlArrayAdaptor{S},
    x::SparseMatrixCSC{Tv,Ti},
) where {Tv,Ti,S}
    MtlSparseMatrixCSC(
        MtlVector{Ti,S}(x.colptr),
        MtlVector{Ti,S}(x.rowval),
        adapt(to, x.nzval),
        size(x),
    )
end

Adapt.adapt_storage(::MtlArrayAdaptor{S}, x::MtlSparseVector{Tv,Ti,S}) where {Tv,Ti,S} = x
Adapt.adapt_storage(::MtlArrayAdaptor{S}, x::MtlSparseMatrixCSC{Tv,Ti,S}) where {Tv,Ti,S} =
    x
Adapt.adapt_storage(::MtlArrayAdaptor{S}, x::MtlSparseMatrixCSR{Tv,Ti,S}) where {Tv,Ti,S} =
    x

Adapt.adapt_storage(::MtlArrayAdaptor{S}, x::MtlSparseVector{Tv,Ti}) where {Tv,Ti,S} =
    MtlSparseVector{Tv,Ti,S}(SparseVector(x))
Adapt.adapt_storage(::MtlArrayAdaptor{S}, x::MtlSparseMatrixCSC{Tv,Ti}) where {Tv,Ti,S} =
    MtlSparseMatrixCSC{Tv,Ti,S}(SparseMatrixCSC(x))
Adapt.adapt_storage(::MtlArrayAdaptor{S}, x::MtlSparseMatrixCSR{Tv,Ti}) where {Tv,Ti,S} =
    MtlSparseMatrixCSR{Tv,Ti,S}(SparseMatrixCSC(x))

Adapt.adapt_storage(::Type{Array}, x::MtlSparseVector) = SparseVector(x)
Adapt.adapt_storage(::Type{Array}, x::Union{MtlSparseMatrixCSC,MtlSparseMatrixCSR}) =
    SparseMatrixCSC(x)

function Adapt.adapt_structure(to::Adaptor, x::MtlSparseVector{Tv,Ti}) where {Tv,Ti}
    GPUArrays.GPUSparseDeviceVector{
        Tv,
        Ti,
        MtlDeviceVector{Ti,AS.Device},
        MtlDeviceVector{Tv,AS.Device},
        AS.Device,
    }(
        adapt(to, x.iPtr),
        adapt(to, x.nzVal),
        x.len,
        x.nnz,
    )
end
function Adapt.adapt_structure(to::Adaptor, x::MtlSparseMatrixCSC{Tv,Ti}) where {Tv,Ti}
    GPUArrays.GPUSparseDeviceMatrixCSC{
        Tv,
        Ti,
        MtlDeviceVector{Ti,AS.Device},
        MtlDeviceVector{Tv,AS.Device},
        AS.Device,
    }(
        adapt(to, x.colPtr),
        adapt(to, x.rowVal),
        adapt(to, x.nzVal),
        x.dims,
        x.nnz,
    )
end
function Adapt.adapt_structure(to::Adaptor, x::MtlSparseMatrixCSR{Tv,Ti}) where {Tv,Ti}
    GPUArrays.GPUSparseDeviceMatrixCSR{
        Tv,
        Ti,
        MtlDeviceVector{Ti,AS.Device},
        MtlDeviceVector{Tv,AS.Device},
        AS.Device,
    }(
        adapt(to, x.rowPtr),
        adapt(to, x.colVal),
        adapt(to, x.nzVal),
        x.dims,
        x.nnz,
    )
end


## GPUArrays sparse interface

GPUArrays.dense_array_type(::Type{<:MtlSparseArray}) = MtlArray
GPUArrays.sparse_array_type(::Type{<:MtlSparseVector}) = MtlSparseVector
GPUArrays.sparse_array_type(::Type{<:MtlSparseMatrixCSC}) = MtlSparseMatrixCSC
GPUArrays.sparse_array_type(::Type{<:MtlSparseMatrixCSR}) = MtlSparseMatrixCSR
GPUArrays.csc_type(::MtlSparseMatrixCSR) = MtlSparseMatrixCSC
GPUArrays.csr_type(::MtlSparseMatrixCSC) = MtlSparseMatrixCSR
GPUArrays.csc_type(::Type{<:MtlSparseMatrixCSR}) = MtlSparseMatrixCSC
GPUArrays.csr_type(::Type{<:MtlSparseMatrixCSC}) = MtlSparseMatrixCSR

# `abs(::Complex{<:Integer})` returns Float64 on the CPU. Metal cannot represent that
# intermediate type, so perform those sparse reductions in Float32, matching `mtl`'s
# policy for floating-point values.
const MtlSparseComplexIntegerMatrix =
    Union{MtlSparseMatrixCSC{<:Complex{<:Integer}},MtlSparseMatrixCSR{<:Complex{<:Integer}}}

@inline _metal_complex_integer_abs(x) = abs(ComplexF32(x))

function Base.mapreduce(
    ::typeof(abs),
    op,
    A::MtlSparseComplexIntegerMatrix;
    dims = :,
    init = nothing,
)
    converted_init = init === nothing ? nothing : Float32(init)
    invoke(
        Base.mapreduce,
        Tuple{Any,Any,GPUArrays.AbstractGPUSparseMatrix},
        _metal_complex_integer_abs,
        op,
        A;
        dims,
        init = converted_init,
    )
end

function LinearAlgebra.norm(A::MtlSparseComplexIntegerMatrix, p::Real = 2)
    values = _metal_complex_integer_abs.(nonzeros(A))
    if p == Inf
        maximum(values)
    elseif p == -Inf
        minimum(values)
    elseif p == 0
        Float64(nnz(A))
    else
        fp = Float32(p)
        sum(values .^ fp) ^ inv(fp)
    end
end

Base.similar(x::MtlSparseMatrixCSR) =
    MtlSparseMatrixCSR(copy(x.rowPtr), copy(x.colVal), similar(x.nzVal), size(x))
Base.similar(x::MtlSparseMatrixCSR, ::Type{T}) where {T} =
    MtlSparseMatrixCSR(copy(x.rowPtr), copy(x.colVal), similar(x.nzVal, T), size(x))

function Base.similar(
    x::MtlSparseMatrixCSC{Tv,Ti,S},
    ::Type{T},
    m::Int,
    n::Int,
) where {Tv,Ti,S,T}
    MtlSparseMatrixCSC(
        ones(Ti, n + 1; storage = S),
        MtlVector{Ti,S}(undef, 0),
        MtlVector{T,S}(undef, 0),
        (m, n),
    )
end
function Base.similar(
    x::MtlSparseMatrixCSR{Tv,Ti,S},
    ::Type{T},
    m::Int,
    n::Int,
) where {Tv,Ti,S,T}
    MtlSparseMatrixCSR(
        ones(Ti, m + 1; storage = S),
        MtlVector{Ti,S}(undef, 0),
        MtlVector{T,S}(undef, 0),
        (m, n),
    )
end
Base.similar(
    x::Union{MtlSparseMatrixCSC{Tv,Ti},MtlSparseMatrixCSR{Tv,Ti}},
    m::Int,
    n::Int,
) where {Tv,Ti} = similar(x, Tv, m, n)
Base.similar(
    x::Union{MtlSparseMatrixCSC,MtlSparseMatrixCSR},
    ::Type{T},
    dims::Tuple{Int,Int},
) where {T} = similar(x, T, dims...)
Base.similar(
    x::Union{MtlSparseMatrixCSC{Tv,Ti},MtlSparseMatrixCSR{Tv,Ti}},
    dims::Tuple{Int,Int},
) where {Tv,Ti} = similar(x, Tv, dims...)

Base.copy(x::MtlSparseMatrixCSR) = copyto!(similar(x), x)
function Base.copyto!(dst::MtlSparseMatrixCSR, src::MtlSparseMatrixCSR)
    size(dst) == size(src) || throw(ArgumentError("inconsistent sparse matrix size"))
    resize!(dst.rowPtr, length(src.rowPtr))
    resize!(dst.colVal, length(src.colVal))
    resize!(dst.nzVal, length(src.nzVal))
    copyto!(dst.rowPtr, src.rowPtr)
    copyto!(dst.colVal, src.colVal)
    copyto!(dst.nzVal, src.nzVal)
    dst.nnz = src.nnz
    dst
end

function Base.getindex(A::MtlSparseMatrixCSR{Tv,Ti}, i::Integer, j::Integer) where {Tv,Ti}
    @boundscheck checkbounds(A, i, j)
    first = Int(A.rowPtr[i])
    last = Int(A.rowPtr[i+1] - one(Ti))
    first > last && return zero(Tv)
    p = searchsortedfirst(A.colVal, convert(Ti, j), first, last, Base.Order.Forward)
    (p > last || A.colVal[p] != j) && return zero(Tv)
    A.nzVal[p]
end

function GPUArrays._sptranspose(A::MtlSparseMatrixCSR{Tv,Ti,S}) where {Tv,Ti,S}
    transposed = MtlSparseMatrixCSC(A.rowPtr, A.colVal, A.nzVal, reverse(size(A)))
    MtlSparseMatrixCSR{Tv,Ti,S}(transposed)
end
function GPUArrays._spadjoint(A::MtlSparseMatrixCSR{Tv,Ti,S}) where {Tv,Ti,S}
    transposed = MtlSparseMatrixCSC(A.rowPtr, A.colVal, conj(A.nzVal), reverse(size(A)))
    MtlSparseMatrixCSR{Tv,Ti,S}(transposed)
end
function GPUArrays._sptranspose(A::MtlSparseMatrixCSC{Tv,Ti,S}) where {Tv,Ti,S}
    transposed = MtlSparseMatrixCSR(A.colPtr, A.rowVal, A.nzVal, reverse(size(A)))
    MtlSparseMatrixCSC{Tv,Ti,S}(transposed)
end
function GPUArrays._spadjoint(A::MtlSparseMatrixCSC{Tv,Ti,S}) where {Tv,Ti,S}
    transposed = MtlSparseMatrixCSR(A.colPtr, A.rowVal, conj(A.nzVal), reverse(size(A)))
    MtlSparseMatrixCSC{Tv,Ti,S}(transposed)
end


## Sparse matrix multiplication

@noinline function _unsupported_csc_multiplication()
    throw(
        ArgumentError(
            "multiplication with MtlSparseMatrixCSC is not implemented; " *
            "explicitly convert the matrix with MtlSparseMatrixCSR(A)",
        ),
    )
end

KernelAbstractions.@kernel function _csr_matvec_kernel!(y, A, x, alpha, beta)
    row = @index(Global, Linear)
    acc = zero(eltype(y))
    @inbounds for p = Int(A.rowPtr[row]):Int(A.rowPtr[row+1]-1)
        acc += A.nzVal[p] * x[A.colVal[p]]
    end
    if iszero(beta)
        @inbounds y[row] = alpha * acc
    else
        @inbounds y[row] = alpha * acc + beta * y[row]
    end
end

function LinearAlgebra.mul!(
    y::MtlVector,
    A::MtlSparseMatrixCSR,
    x::MtlVector,
    alpha::Number,
    beta::Number,
)
    length(x) == size(A, 2) || throw(
        DimensionMismatch(
            "matrix has $(size(A, 2)) columns but input has length $(length(x))",
        ),
    )
    length(y) == size(A, 1) || throw(
        DimensionMismatch(
            "matrix has $(size(A, 1)) rows but output has length $(length(y))",
        ),
    )
    device(A) == device(x) == device(y) || throw(
        ArgumentError("all sparse matrix-vector operands must use the same Metal device"),
    )
    isempty(y) && return y

    backend = KernelAbstractions.get_backend(y)
    kernel! = _csr_matvec_kernel!(backend)
    kernel!(y, A, x, alpha, beta; ndrange = length(y))
    y
end

LinearAlgebra.mul!(y::MtlVector, A::MtlSparseMatrixCSR, x::MtlVector) =
    LinearAlgebra.mul!(y, A, x, true, false)
LinearAlgebra.mul!(
    ::MtlVector,
    ::MtlSparseMatrixCSC,
    ::MtlVector,
    ::Number,
    ::Number,
) = _unsupported_csc_multiplication()
LinearAlgebra.mul!(y::MtlVector, A::MtlSparseMatrixCSC, x::MtlVector) =
    _unsupported_csc_multiplication()

function Base.:*(A::MtlSparseMatrixCSR, x::MtlVector)
    T = Base.promote_op(*, eltype(A), eltype(x))
    y = similar(x, T, (size(A, 1),))
    LinearAlgebra.mul!(y, A, x, true, false)
end
Base.:*(::MtlSparseMatrixCSC, ::MtlVector) = _unsupported_csc_multiplication()

KernelAbstractions.@kernel function _csr_matmat_kernel!(C, A, B, alpha, beta)
    I = @index(Global, Cartesian)
    row, col = Tuple(I)
    acc = zero(eltype(C))
    @inbounds for p = Int(A.rowPtr[row]):Int(A.rowPtr[row+1]-1)
        acc += A.nzVal[p] * B[A.colVal[p], col]
    end
    if iszero(beta)
        @inbounds C[row, col] = alpha * acc
    else
        @inbounds C[row, col] = alpha * acc + beta * C[row, col]
    end
end

function LinearAlgebra.mul!(
    C::MtlMatrix,
    A::MtlSparseMatrixCSR,
    B::MtlMatrix,
    alpha::Number,
    beta::Number,
)
    size(B, 1) == size(A, 2) || throw(
        DimensionMismatch(
            "sparse matrix has $(size(A, 2)) columns but dense matrix has " *
            "$(size(B, 1)) rows",
        ),
    )
    expected = (size(A, 1), size(B, 2))
    size(C) == expected || throw(
        DimensionMismatch("output has size $(size(C)), but multiplication needs $expected"),
    )
    device(A) == device(B) == device(C) || throw(
        ArgumentError("all sparse matrix-matrix operands must use the same Metal device"),
    )
    isempty(C) && return C

    backend = KernelAbstractions.get_backend(C)
    kernel! = _csr_matmat_kernel!(backend)
    kernel!(C, A, B, alpha, beta; ndrange = size(C))
    C
end

LinearAlgebra.mul!(C::MtlMatrix, A::MtlSparseMatrixCSR, B::MtlMatrix) =
    LinearAlgebra.mul!(C, A, B, true, false)
LinearAlgebra.mul!(
    ::MtlMatrix,
    ::MtlSparseMatrixCSC,
    ::MtlMatrix,
    ::Number,
    ::Number,
) = _unsupported_csc_multiplication()
LinearAlgebra.mul!(::MtlMatrix, ::MtlSparseMatrixCSC, ::MtlMatrix) =
    _unsupported_csc_multiplication()

function Base.:*(A::MtlSparseMatrixCSR, B::MtlMatrix)
    T = Base.promote_op(*, eltype(A), eltype(B))
    C = similar(B, T, (size(A, 1), size(B, 2)))
    LinearAlgebra.mul!(C, A, B, true, false)
end
Base.:*(::MtlSparseMatrixCSC, ::MtlMatrix) = _unsupported_csc_multiplication()
