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
