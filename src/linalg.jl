using LinearAlgebra
using LinearAlgebra: MulAddMul, wrap
using .MPS
using .MPS: MPS_VALID_MATMUL_TYPES, MPS_VALID_MATVECMUL_TYPES, MtlFloat
using .MPSGraphs: MPSGRAPH_VALID_MATMUL_TYPES, MPSGRAPH_VALID_MATVECMUL_TYPES,
                  graph_matmul!, graph_matvecmul!

@inline function supports_mps_matmul(A, B, C, valid_types)
    MPS.is_supported(device(C)) &&
        eltype(A) == eltype(B) &&
        (eltype(A), eltype(C)) in valid_types
end

@inline function supports_mpsgraph_matmul(A, B, C, valid_types)
    MPS.is_supported(device(C)) &&
        eltype(A) == eltype(B) &&
        (eltype(A), eltype(C)) in valid_types &&
        # TODO: remove this limitation
        A.offset == 0 &&
        B.offset == 0 &&
        C.offset == 0
end

# Supported values are :auto, :MPS, :MPSGraph, and :GPUArrays
const matmul_alg = ScopedValue(:auto)
matmul_alg_error(alg, inT, outT, vec) = error("Matrix-$(vec ? "Vector" : "Matrix") multiplication algorithm `:$alg` is not supported for input eltype $inT and output eltype $outT.")

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

    alg = matmul_alg[]
    mps_supported = supports_mps_matmul(A, B, C, MPS_VALID_MATMUL_TYPES)
    mpsgraph_supported = supports_mpsgraph_matmul(A, B, C, MPSGRAPH_VALID_MATMUL_TYPES)
    # If possible, dispatch to MPSGraphs, then performance shaders
    if alg === :MPSGraph || (alg === :auto && mpsgraph_supported)
        mpsgraph_supported || matmul_alg_error(alg, eltype(A), eltype(C), false)
        graph_matmul!(C, A, B, alpha, beta, transA, transB)
    elseif alg === :MPS || (alg === :auto && mps_supported)
        mps_supported || matmul_alg_error(alg, eltype(A), eltype(C), false)
        matmul!(C, A, B, alpha, beta, transA, transB)
    elseif alg === :GPUArrays || alg === :auto
        GPUArrays.generic_matmatmul!(C, wrap(A, tA), wrap(B, tB), alpha, beta)
    else
        error(":$alg is not a valid matmul algorithm. Options are: `:auto`, `:MPS`, `:MPSGraph`, `:GPUArrays`")
    end
end

LinearAlgebra.generic_matvecmul!(C::MtlVector, tA::AbstractChar, A::MtlMatrix, B::MtlVector, _add::MulAddMul) =
    LinearAlgebra.generic_matvecmul!(C, tA, A, B, _add.alpha, _add.beta)
@autoreleasepool function LinearAlgebra.generic_matvecmul!(C::MtlVector, tA::AbstractChar,
                                                           A::MtlMatrix, B::MtlVector,
                                                           alpha::Number, beta::Number)
    mA, nA = LinearAlgebra.lapack_size(tA, A)
    mB = length(B)
    mC = length(C)

    if nA != mB
        throw(DimensionMismatch("A has dimensions ($mA,$nA) but B is a vector of length ($mB)"))
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

    alg = matmul_alg[]
    mps_supported = supports_mps_matmul(A, B, C, MPS_VALID_MATVECMUL_TYPES)
    mpsgraph_supported = supports_mpsgraph_matmul(A, B, C, MPSGRAPH_VALID_MATVECMUL_TYPES)
    # If possible, dispatch to MPSGraphs, then performance shaders
    if alg === :MPSGraph || (alg === :auto && mpsgraph_supported)
        mpsgraph_supported || matmul_alg_error(alg, eltype(A), eltype(C), true)
        graph_matvecmul!(C, A, B, alpha, beta, transA)
    elseif alg === :MPS || (alg === :auto && mps_supported)
        mps_supported || matmul_alg_error(alg, eltype(A), eltype(C), true)
        matvecmul!(C, A, B, alpha, beta, transA)
    elseif alg === :GPUArrays || alg === :auto
        GPUArrays.generic_matmatmul!(C, wrap(A, tA), B, alpha, beta)
    else
        error(":$alg is not a valid matmul algorithm. Options are: `:auto`, `:MPS`, `:MPSGraph`, `:GPUArrays`")
    end
end

@inline checkpositivedefinite(status) =
    status == MPS.MPSMatrixDecompositionStatusNonPositiveDefinite || throw(PosDefException(status))
@inline checknonsingular(status) =
    status != MPS.MPSMatrixDecompositionStatusSingular || throw(SingularException(status))

# GPU-compatible accessors of the LU decomposition properties
function Base.getproperty(F::LU{T, <:MtlMatrix}, d::Symbol) where {T}
    m, n = size(F)
    if d === :L
        L = tril!(getfield(F, :factors)[1:m, 1:min(m, n)])
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
LinearAlgebra.ipiv2perm(v::MtlVector{<:Any, MTL.CPUStorage}, maxi::Integer) =
    LinearAlgebra.ipiv2perm(unsafe_wrap(Array, v), maxi)

@autoreleasepool function LinearAlgebra.lu(A::MtlMatrix{T};
                                           check::Bool = true) where {T <: MtlFloat}
    M, N = size(A)
    dev = device()
    queue = global_queue(dev)

    At = MtlMatrix{T, PrivateStorage}(undef, (N, M))
    mps_a = MPSMatrix(A)
    mps_at = MPSMatrix(At)

    cmdbuf = MPSCommandBuffer(queue) do cbuf
        kernel = MPSMatrixCopy(dev, N, M, false, true)
        descriptor = MPSMatrixCopyDescriptor(mps_a, mps_at)
        encode!(cbuf, kernel, descriptor)
    end

    P = similar(A, UInt32, 1, min(N, M))
    status = MtlArray{MPS.MPSMatrixDecompositionStatus, 0, SharedStorage}(undef)

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

    status = convert(LinearAlgebra.BlasInt, status[]::MPS.MPSMatrixDecompositionStatus)
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
                                            check::Bool = true,
                                            allowsingular::Bool = false) where {T <: MtlFloat}
    M, N = size(A)
    dev = device()
    queue = global_queue(dev)

    At = MtlMatrix{T, PrivateStorage}(undef, (N, M))
    mps_a = MPSMatrix(A)
    mps_at = MPSMatrix(At)

    cmdbuf = MPSCommandBuffer(queue) do cbuf
        kernel = MPSMatrixCopy(dev, N, M, false, true)
        descriptor = MPSMatrixCopyDescriptor(mps_a, mps_at)
        encode!(cbuf, kernel, descriptor)
    end

    P = similar(A, UInt32, 1, min(N, M))
    status = MtlArray{MPS.MPSMatrixDecompositionStatus, 0, SharedStorage}(undef)

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
    axes(B, 2) == axes(A, 1) && axes(B, 1) == axes(A, 2) || throw(DimensionMismatch("transpose"))

    isempty(B) && return B

    M, N = size(A)
    dev = device()
    queue = global_queue(dev)
    cmdbuf = MTLCommandBuffer(queue)

    mps_a = MPSMatrix(A)
    mps_b = MPSMatrix(B)

    descriptor = MPSMatrixCopyDescriptor(mps_a, mps_b)
    kernel = MPSMatrixCopy(dev, N, M, false, true)
    encode!(cmdbuf, kernel, descriptor)

    commit!(cmdbuf)

    return B
end
