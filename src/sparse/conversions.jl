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
        _compressed_pointers_kernel!(backend)(colPtr, sorted_cols; ndrange = length(colPtr))
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
        _compressed_pointers_kernel!(backend)(rowPtr, sorted_rows; ndrange = length(rowPtr))
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
