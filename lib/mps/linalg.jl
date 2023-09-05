using LinearAlgebra
using LinearAlgebra: MulAddMul, wrap

# Valid combination of input (A and B matrices) and output (C) types
const MPS_VALID_MATMUL_TYPES =
    [(Int8, Float16),
     (Int8, Float32),
     (Int16, Float32),
     (Float16, Float16),
     (Float32, Float32)]

LinearAlgebra.generic_matmatmul!(C::MtlMatrix, tA, tB, A::MtlMatrix, B::MtlMatrix, _add::MulAddMul) =
    LinearAlgebra.generic_matmatmul!(C, tA, tB, A, B, _add.alpha, _add.beta)
@autoreleasepool function LinearAlgebra.generic_matmatmul!(C::MtlMatrix, tA, tB,
                                                           A::MtlMatrix, B::MtlMatrix,
                                                           alpha::Number, beta::Number)
    mA, nA = LinearAlgebra.lapack_size(tA, A)
    mB, nB = LinearAlgebra.lapack_size(tB, B)

    if nA != mB
        throw(DimensionMismatch("A has dimensions ($mA,$nA) but B has dimensions ($mB,$nB)"))
    end

    if C === A || B === C
        throw(ArgumentError("output matrix must not be aliased with input matrix"))
    end

    if mA == 0 || nA == 0 || nB == 0
        if size(C) != (mA, nB)
            throw(DimensionMismatch("C has dimensions $(size(C)), should have ($mA,$nB)"))
        end
    end

    transA = tA == 'T' || tA == 'C'
    transB = tB == 'T' || tB == 'C'

    typA = eltype(A)
    typB = eltype(B)
    typC = eltype(C)

    # If possible, dispatch to performance shaders
    if is_supported(device()) &&
       typA == typB && (typA, typC) in MPS_VALID_MATMUL_TYPES
        matmul!(C, A, B, alpha, beta, transA, transB)
    else
        GPUArrays.generic_matmatmul!(C, wrap(A, tA), wrap(B, tB), alpha, beta)
    end
end

const MPS_VALID_MATVECMUL_TYPES =
    [(Float16, Float16),
     (Float16, Float32),
     (Float32, Float32)]

LinearAlgebra.generic_matvecmul!(C::MtlVector, tA::AbstractChar, A::MtlMatrix, B::MtlVector, _add::MulAddMul) =
    LinearAlgebra.generic_matvecmul!(C, tA, A, B, _add.alpha, _add.beta)
@autoreleasepool function LinearAlgebra.generic_matvecmul!(C::MtlVector, tA::AbstractChar,
                                                           A::MtlMatrix, B::MtlVector,
                                                           alpha::Number, beta::Number)
    mA, nA = LinearAlgebra.lapack_size(tA, A)
    mB = length(B)
    mC = length(C)

    if nA != mB
        throw(DimensionMismatch("A has dimensions ($mA,$nA) but B has dimensions ($mB,$nB)"))
    end

    if B === C
        throw(ArgumentError("output matrix must not be aliased with input matrix"))
    end

    if mA == 0 || nA == 0 || mB == 0
        if mC != mB
            throw(DimensionMismatch("C has length ($mC), should have ($mB)"))
        end
    end

    transA = tA == 'T' || tA == 'C'

    typA = eltype(A)
    typB = eltype(B)
    typC = eltype(C)

    # If possible, dispatch to performance shaders
    if is_supported(device()) &&
        typA == typB && (typA, typC) in MPS_VALID_MATVECMUL_TYPES
        matvecmul!(C, A, B, alpha, beta, transA)
    else
        GPUArrays.generic_matmatmul!(C, wrap(A, tA), B, alpha, beta)
    end
end

@inline checkpositivedefinite(status) =
    status == MPSMatrixDecompositionStatusNonPositiveDefinite || throw(PosDefException(status))
@inline checknonsingular(status) =
    status != MPSMatrixDecompositionStatusSingular || throw(SingularException(status))

# GPU-compatible accessors of the LU decomposition properties
function Base.getproperty(F::LU{T,<:MtlMatrix}, d::Symbol) where T
    m, n = size(F)
    if d === :L
        L = tril!(getfield(F, :factors)[1:m, 1:min(m,n)])
        L[1:m+1:end] .= one(T)
        return L
    else
        invoke(getproperty, Tuple{LU{T}, Symbol}, F, d)
    end
end

# Metal's pivoting sequence needs to be iterated sequentially...
# TODO: figure out a GPU-compatible way to get the permutation matrix
LinearAlgebra.ipiv2perm(v::MtlVector, maxi::Integer) =
    LinearAlgebra.ipiv2perm(Array(v), maxi)
LinearAlgebra.ipiv2perm(v::MtlVector{<:Any,MTL.CPUStorage}, maxi::Integer) =
    LinearAlgebra.ipiv2perm(unsafe_wrap(Array, v), maxi)

@autoreleasepool function LinearAlgebra.lu(A::MtlMatrix{T};
                                           check::Bool=true) where {T<:MtlFloat}
    M,N = size(A)
    dev = device()
    queue = global_queue(dev)

    At = MtlMatrix{T,PrivateStorage}(undef, (N, M))
    mps_a = MPSMatrix(A)
    mps_at = MPSMatrix(At)

    cmdbuf = MPSCommandBuffer(queue) do cbuf
        kernel = MPSMatrixCopy(dev, N, M, false, true)
        descriptor = MPSMatrixCopyDescriptor(mps_a, mps_at)
        encode!(cbuf, kernel, descriptor)
    end

    P = similar(A, UInt32, 1, min(N, M))
    status = MtlArray{MPSMatrixDecompositionStatus,0,SharedStorage}(undef)

    commitAndContinue!(cmdbuf) do cbuf
        mps_p = MPSMatrix(P)
        kernel = MPSMatrixDecompositionLU(dev, M, N)
        encode!(cbuf, kernel, mps_at, mps_at, mps_p, status)
    end

    B = similar(A, M, N)

    commit!(cmdbuf) do cbuf
        mps_b = MPSMatrix(B)
        kernel = MPSMatrixCopy(dev, M, N, false, true)
        descriptor = MPSMatrixCopyDescriptor(mps_at, mps_b)
        encode!(cbuf, kernel, descriptor)
    end

    p = vec(P) .+ UInt32(1)

    wait_completed(cmdbuf)

    status = convert(LinearAlgebra.BlasInt, status[])
    check && checknonsingular(status)

    return LinearAlgebra.LU(B, p, status)
end

function _check_lu_success(info, allowsingular)
    if VERSION >= v"1.11.0-DEV.1535"
        if info < 0 # zero pivot error from unpivoted LU
            LinearAlgebra.checknozeropivot(-info)
        else
            allowsingular || LinearAlgebra.checknonsingular(info)
        end
    else
        LinearAlgebra.checknonsingular(info)
    end
end

# TODO: dispatch on pivot strategy
@autoreleasepool function LinearAlgebra.lu!(A::MtlMatrix{T};
                                            check::Bool=true,
                                            allowsingular::Bool=false) where {T<:MtlFloat}
    M,N = size(A)
    dev = device()
    queue = global_queue(dev)

    At = MtlMatrix{T,PrivateStorage}(undef, (N, M))
    mps_a = MPSMatrix(A)
    mps_at = MPSMatrix(At)

    cmdbuf = MPSCommandBuffer(queue) do cbuf
        kernel = MPSMatrixCopy(dev, N, M, false, true)
        descriptor = MPSMatrixCopyDescriptor(mps_a, mps_at)
        encode!(cbuf, kernel, descriptor)
    end

    P = similar(A, UInt32, 1, min(N, M))
    status = MtlArray{MPSMatrixDecompositionStatus,0,SharedStorage}(undef)

    commitAndContinue!(cmdbuf) do cbuf
        mps_p = MPSMatrix(P)
        kernel = MPSMatrixDecompositionLU(dev, M, N)
        encode!(cbuf, kernel, mps_at, mps_at, mps_p, status)
    end

    commit!(cmdbuf) do cbuf
        kernel = MPSMatrixCopy(dev, M, N, false, true)
        descriptor = MPSMatrixCopyDescriptor(mps_at, mps_a)
        encode!(cbuf, kernel, descriptor)
    end

    p = vec(P) .+ UInt32(1)

    wait_completed(cmdbuf)

    status = convert(LinearAlgebra.BlasInt, status[])
    check && _check_lu_success(status, allowsingular)

    return LinearAlgebra.LU(A, p, status)
end

@autoreleasepool function LinearAlgebra.transpose!(B::MtlMatrix{T},
                                                   A::MtlMatrix{T}) where {T}
    axes(B,2) == axes(A,1) && axes(B,1) == axes(A,2) || throw(DimensionMismatch("transpose"))

    M,N = size(A)
    dev = device()
    queue = global_queue(dev)
    cmdbuf = MTLCommandBuffer(queue)

    mps_a = MPSMatrix(A)
    mps_b = MPSMatrix(B)

    descriptor = MPSMatrixCopyDescriptor(mps_a, mps_b)
    kernel = MPSMatrixCopy(dev, N, M, false, true)
    encode!(cmdbuf, kernel, descriptor)

    commit!(cmdbuf)

    wait_completed(cmdbuf)

    return B
end


function LinearAlgebra.:(\)(A::LU{T,<:MtlMatrix{T},<:MtlVector{UInt32}}, B::MtlVecOrMat{T}) where {T<:MtlFloat}
    C = deepcopy(B)
    LinearAlgebra.ldiv!(A, C)
    return C
end


function LinearAlgebra.ldiv!(A::LU{T,<:MtlMatrix{T},<:MtlVector{UInt32}}, B::MtlVecOrMat{T}) where {T<:MtlFloat}
    M, N = size(B, 1), size(B, 2)
    dev = current_device()
    queue = global_queue(dev)

    At = similar(A.factors)
    Bt = similar(B, (N, M))
    P = reshape((A.ipiv .- UInt32(1)), (1, M))
    X = similar(B, (N, M))

    transpose!(At, A.factors)
    transpose!(Bt, B)

    mps_a = MPSMatrix(At)
    mps_b = MPSMatrix(Bt)
    mps_p = MPSMatrix(P)
    mps_x = MPSMatrix(X)

    MTLCommandBuffer(queue) do cmdbuf
        kernel = MPSMatrixSolveLU(dev, false, M, N)
        encode!(cmdbuf, kernel, mps_a, mps_b, mps_p, mps_x)
    end

    transpose!(B, X)
    return B
end


function LinearAlgebra.ldiv!(A::UpperTriangular{T,<:MtlMatrix{T}}, B::MtlVecOrMat{T}) where {T<:MtlFloat}
    M, N = size(B, 1), size(B, 2)
    dev = current_device()
    queue = global_queue(dev)

    Ad = MtlMatrix(A')
    Br = similar(B, (M, M))
    X = similar(Br)

    transpose!(Br, B)

    mps_a = MPSMatrix(Ad)
    mps_b = MPSMatrix(Br)
    mps_x = MPSMatrix(X)

    buf = MTLCommandBuffer(queue) do cmdbuf
        kernel = MPSMatrixSolveTriangular(dev, false, true, false, false, N, M, 1.0)
        encode!(cmdbuf, kernel, mps_a, mps_b, mps_x)
    end

    wait_completed(buf)

    copy!(B, X)
    return B
end


function LinearAlgebra.ldiv!(A::UnitUpperTriangular{T,<:MtlMatrix{T}}, B::MtlVecOrMat{T}) where {T<:MtlFloat}
    M, N = size(B, 1), size(B, 2)
    dev = current_device()
    queue = global_queue(dev)

    Ad = MtlMatrix(A)
    Br = reshape(B, (M, N))
    X = similar(Br)

    mps_a = MPSMatrix(Ad)
    mps_b = MPSMatrix(Br)
    mps_x = MPSMatrix(X)


    buf = MTLCommandBuffer(queue) do cmdbuf
        kernel = MPSMatrixSolveTriangular(dev, true, false, false, true, M, N, 1.0)
        encode!(cmdbuf, kernel, mps_a, mps_b, mps_x)
    end

    wait_completed(buf)

    copy!(Br, X)
    return B
end


function LinearAlgebra.ldiv!(A::LowerTriangular{T,<:MtlMatrix{T}}, B::MtlVecOrMat{T}) where {T<:MtlFloat}
    M, N = size(B, 1), size(B, 2)
    dev = current_device()
    queue = global_queue(dev)

    Ad = MtlMatrix(A)
    Br = reshape(B, (M, N))
    X = similar(Br)

    mps_a = MPSMatrix(Ad)
    mps_b = MPSMatrix(Br)
    mps_x = MPSMatrix(X)


    buf = MTLCommandBuffer(queue) do cmdbuf
        kernel = MPSMatrixSolveTriangular(dev, true, true, false, false, M, N, 1.0)
        encode!(cmdbuf, kernel, mps_a, mps_b, mps_x)
    end

    wait_completed(buf)

    copy!(Br, X)
    return B
end


function LinearAlgebra.ldiv!(A::UnitLowerTriangular{T,<:MtlMatrix{T}}, B::MtlVecOrMat{T}) where {T<:MtlFloat}
    M, N = size(B, 1), size(B, 2)
    dev = current_device()
    queue = global_queue(dev)

    Ad = MtlMatrix(A)
    Br = reshape(B, (M, N))
    X = similar(Br)

    mps_a = MPSMatrix(Ad)
    mps_b = MPSMatrix(Br)
    mps_x = MPSMatrix(X)


    buf = MTLCommandBuffer(queue) do cmdbuf
        kernel = MPSMatrixSolveTriangular(dev, true, true, false, true, M, N, 1.0)
        encode!(cmdbuf, kernel, mps_a, mps_b, mps_x)
    end

    wait_completed(buf)

    copy!(Br, X)
    return B
end