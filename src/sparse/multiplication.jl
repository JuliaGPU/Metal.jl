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
LinearAlgebra.mul!(::MtlVector, ::MtlSparseMatrixCSC, ::MtlVector, ::Number, ::Number) =
    _unsupported_csc_multiplication()
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
LinearAlgebra.mul!(::MtlMatrix, ::MtlSparseMatrixCSC, ::MtlMatrix, ::Number, ::Number) =
    _unsupported_csc_multiplication()
LinearAlgebra.mul!(::MtlMatrix, ::MtlSparseMatrixCSC, ::MtlMatrix) =
    _unsupported_csc_multiplication()

function Base.:*(A::MtlSparseMatrixCSR, B::MtlMatrix)
    T = Base.promote_op(*, eltype(A), eltype(B))
    C = similar(B, T, (size(A, 1), size(B, 2)))
    LinearAlgebra.mul!(C, A, B, true, false)
end
Base.:*(::MtlSparseMatrixCSC, ::MtlMatrix) = _unsupported_csc_multiplication()
