using LinearAlgebra

# Valid combination of input (A and B matrices) and output (C) types
const MPS_VALID_MATMUL_TYPES =
    [(Int8, Float16),
     (Int8, Float32),
     (Int16, Float32),
     (Float16, Float16),
     (Float32, Float32)]

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


checkpositivedefinite(status) = status == MPSMatrixDecompositionStatusNonPositiveDefinite || throw(PosDefException(infstatuso))
checknonsingular(status) = status != MPSMatrixDecompositionStatusSingular || throw(SingularException(status))


function LinearAlgebra.lu(A::MtlMatrix{T}; check::Bool = true) where {T}
    M,N = size(A)
    dev = current_device()

    lu_kernel = MPSMatrixDecompositionLU(dev, N, M)

    B = similar(A)
    P = MtlMatrix{UInt32}(undef, 1, min(N, M))

    mps_a = MPSMatrix(A)
    mps_b = MPSMatrix(B)
    mps_p = MPSMatrix(P)

    status_buf = MTLBuffer(dev, sizeof(MPSMatrixDecompositionStatus); storage=Shared)

    cmdbuf = MTLCommandBuffer(global_queue(dev))
    Metal.MPS.encode!(cmdbuf, lu_kernel, mps_a, mps_b, mps_p, status_buf)
    commit!(cmdbuf)
    wait_completed(cmdbuf)

    status_ptr = Ptr{Cint}(status_buf.contents)
    status = unsafe_load(status_ptr)
    check && checknonsingular(status)

    return B, P
    #return LinearAlgebra.LU(B, vec(P).+1, convert(LinearAlgebra.BlasInt, status))
end

export lu!

function LinearAlgebra.lu!(A::MtlMatrix{T}; check::Bool = true) where {T}
    M,N = size(A)
    dev = current_device()

    lu_kernel = MPSMatrixDecompositionLU(dev, N, M)

    P = MtlMatrix{UInt32}(undef, 1, min(N, M))

    mps_a = MPSMatrix(A)
    mps_p = MPSMatrix(P)

    status_buf = MTLBuffer(dev, sizeof(MPSMatrixDecompositionStatus); storage=Shared)

    cmdbuf = MTLCommandBuffer(global_queue(dev))
    Metal.MPS.encode!(cmdbuf, lu_kernel, mps_a, mps_a, mps_p, status_buf)
    commit!(cmdbuf)
    wait_completed(cmdbuf)

    status_ptr = Ptr{MPSMatrixDecompositionStatus}(status_buf.contents)
    status = unsafe_load(status_ptr)
    check && checknonsingular(status)

    return A, P
    #return LinearAlgebra.LU(A', vec(P), convert(LinearAlgebra.BlasInt, status))
end