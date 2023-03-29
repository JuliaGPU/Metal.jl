using LinearAlgebra

# Valid combination of input (A and B matrices) and output (C) types
const MPS_VALID_MATMUL_TYPES =
    [(Int8, Float16),
     (Int8, Float32),
     (Int16, Float32),
     (Float16, Float16),
     (Float32, Float32)]

const MtlFloat = Union{Float32, Float16}

function gemm_dispatch!(C::MtlMatrix, A::MtlMatrix, B::MtlMatrix,
                        alpha::Number=true, beta::Number=false)
    if ndims(A) > 2
        throw(ArgumentError("A has more than 2 dimensions"))
    elseif ndims(B) > 2
        throw(ArgumentError("B has more than 2 dimensions"))
    end
    mA, nA = size(A,1), size(A,2)
    mB, nB = size(B,1), size(B,2)

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

    tA, dA = if A isa Transpose
        true, parent(A)
    else
        false, A
    end

    tB, dB = if B isa Transpose
        true, parent(B)
    else
        false, B
    end

    typA = eltype(A)
    typB = eltype(B)
    typC = eltype(C)

    # If possible, dispatch to performance shaders
    if is_supported(current_device()) &&
       typA == typB && (typA, typC) in MPS_VALID_MATMUL_TYPES
        matmul!(C, dA, dB, alpha, beta, tA, tB)
    else
        GPUArrays.generic_matmatmul!(C, A, B, alpha, beta)
    end
end

for NT in (Number, Real)
    # NOTE: alpha/beta also ::Real to avoid ambiguities with certain Base methods
    @eval begin
        LinearAlgebra.mul!(C::MtlMatrix, A::MtlMatrix, B::MtlMatrix,
                           a::$NT, b::$NT) = gemm_dispatch!(C, A, B, a, b)
    end
end


@inline checkpositivedefinite(status) = status == MPSMatrixDecompositionStatusNonPositiveDefinite || throw(PosDefException(status))
@inline checknonsingular(status) = status != MPSMatrixDecompositionStatusSingular || throw(SingularException(status))

# GPU-compatible accessors of the LU decomposition properties
function Base.getproperty(F::LU{T,<:MtlMatrix}, d::Symbol) where T
    m, n = size(F)
    if d === :L
        L = tril!(getfield(F, :factors)[1:m, 1:min(m,n)])
        L[1:m+1:end] .= one(T)
        return L
    elseif VERSION >= v"1.9.0-DEV.1775"
        invoke(getproperty, Tuple{LU{T}, Symbol}, F, d)
    else
        invoke(getproperty, Tuple{LU{T,<:StridedMatrix}, Symbol}, F, d)
    end
end

# Metal's pivoting sequence needs to be iterated sequentially...
# TODO: figure out a GPU-compatible way to get the permutation matrix
LinearAlgebra.ipiv2perm(v::MtlVector{T}, maxi::Integer) where T = LinearAlgebra.ipiv2perm(Array(v), maxi)

function LinearAlgebra.lu(A::MtlMatrix{T}; check::Bool = true) where {T<:MtlFloat}
    M,N = size(A)
    dev = current_device()
    queue = global_queue(dev)

    At = MtlMatrix{T}(undef, (N, M); storage=Private)
    mps_a = MPSMatrix(A)
    mps_at = MPSMatrix(At)

    MTLCommandBuffer(queue) do cmdbuf
        kernel = MPSMatrixCopy(dev, N, M, false, true)
        descriptor = MPSMatrixCopyDescriptor(mps_a, mps_at)
        encode!(cmdbuf, kernel, descriptor)
    end

    P = MtlMatrix{UInt32}(undef, 1, min(N, M))
    status = MtlArray{MPSMatrixDecompositionStatus}(undef)

    cmdbuf_lu = MTLCommandBuffer(queue) do cmdbuf
        mps_p = MPSMatrix(P)
        kernel = MPSMatrixDecompositionLU(dev, M, N)
        encode!(cmdbuf, kernel, mps_at, mps_at, mps_p, status)
    end

    B = MtlMatrix{T}(undef, M, N)

    MTLCommandBuffer(queue) do cmdbuf
        mps_b = MPSMatrix(B)

        kernel = MPSMatrixCopy(dev, M, N, false, true)
        descriptor = MPSMatrixCopyDescriptor(mps_at, mps_b)
        encode!(cmdbuf, kernel, descriptor)
    end

    p = vec(P) .+ UInt32(1)

    wait_completed(cmdbuf_lu)

    status = convert(LinearAlgebra.BlasInt, Metal.@allowscalar status[])
    check && checknonsingular(status)

    return LinearAlgebra.LU(B, p, status)
end

# TODO: dispatch on pivot strategy
function LinearAlgebra.lu!(A::MtlMatrix{T}; check::Bool = true) where {T<:MtlFloat}
    M,N = size(A)
    dev = current_device()
    queue = global_queue(dev)

    At = MtlMatrix{T}(undef, (N, M); storage=Private)
    mps_a = MPSMatrix(A)
    mps_at = MPSMatrix(At)

    MTLCommandBuffer(queue) do cmdbuf
        kernel = MPSMatrixCopy(dev, N, M, false, true)
        descriptor = MPSMatrixCopyDescriptor(mps_a, mps_at)
        encode!(cmdbuf, kernel, descriptor)
    end

    P = MtlMatrix{UInt32}(undef, 1, min(N, M))
    status = MtlArray{MPSMatrixDecompositionStatus}(undef)

    cmdbuf_lu = MTLCommandBuffer(queue) do cmdbuf
        mps_p = MPSMatrix(P)
        kernel = MPSMatrixDecompositionLU(dev, M, N)
        encode!(cmdbuf, kernel, mps_at, mps_at, mps_p, status)
    end

    MTLCommandBuffer(queue) do cmdbuf
        kernel = MPSMatrixCopy(dev, M, N, false, true)
        descriptor = MPSMatrixCopyDescriptor(mps_at, mps_a)
        encode!(cmdbuf, kernel, descriptor)
    end

    p = vec(P) .+ UInt32(1)

    wait_completed(cmdbuf_lu)

    status = convert(LinearAlgebra.BlasInt, Metal.@allowscalar status[])
    check && checknonsingular(status)

    return LinearAlgebra.LU(A, p, status)
end


function LinearAlgebra.transpose!(B::MtlMatrix{T}, A::MtlMatrix{T}) where {T}
    axes(B,2) == axes(A,1) && axes(B,1) == axes(A,2) || throw(DimensionMismatch("transpose"))

    M,N = size(A)
    dev = current_device()
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
