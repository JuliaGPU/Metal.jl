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
