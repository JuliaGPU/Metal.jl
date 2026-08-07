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
