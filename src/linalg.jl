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

# Supported values:
#   :auto     - best available: vendor (MPSGraph/MPS) where supported, else a native kernel
#   :MPS      - MetalPerformanceShaders
#   :MPSGraph - MetalPerformanceShadersGraph
#   :GPUArrays- the generic GPUArrays kernel
#   :native   - best of Metal.jl's own kernels (tensor → simd → scalar), picked per operands
#   :simd     - force the simdgroup_matrix kernel (Float16/Float32)
#   :scalar     - force the scalar shared-memory kernel (any eltype)
#   :tensor   - force the Metal 4 tensor-ops kernel (Metal4 device, plain C=A*B, float)
# The native kernels live in src/gemm.jl.
const matmul_alg = ScopedValue(:auto)
matmul_alg_error(alg, inT, outT, vec) = error("Matrix-$(vec ? "Vector" : "Matrix") multiplication algorithm `:$alg` is not supported for input eltype $inT and output eltype $outT.")

# LinearAlgebra's wrapper_char only ever produces 'N'/'T'/'C' or the Symmetric/Hermitian
# wrapper chars 'S'/'s'/'H'/'h', all of which the native GEMM kernels handle (the MPS
# paths only the former); gemm_char normalizes an AbstractChar (e.g. a
# LinearAlgebra.WrapperChar) to the plain Char the kernels specialize on.
@inline is_ntc(t) = (t == 'N') || (t == 'T') || (t == 'C')
@inline gemm_char(t) = Char(t)

matmul_alg_invalid(alg, vec) =
    error(":$alg is not a valid $(vec ? "matvecmul" : "matmul") algorithm. Options are: `:auto`, `:MPS`, `:MPSGraph`, `:GPUArrays`, `:native`, `:simd`, `:scalar`$(vec ? "" : ", `:tensor`")")

# shared native-kernel path: a forced :simd/:tensor kernel must support the operands
# (the scalar kernel handles anything); :native/:auto let gemm! pick the kernel
@inline function native_matmul!(C, tA, tB, A, B, alpha, beta, alg)
    cA = gemm_char(tA); cB = gemm_char(tB)
    if alg === :simd
        supports_simd_matmul(C, A, B, cA, cB, alpha, beta) ||
            matmul_alg_error(alg, eltype(A), eltype(C), false)
    elseif alg === :tensor
        supports_tensor_matmul(C, A, B, cA, cB, alpha, beta) ||
            matmul_alg_error(alg, eltype(A), eltype(C), false)
    end
    kernel = (alg === :native || alg === :auto) ? :auto : alg
    gemm!(C, cA, cB, A, B, alpha, beta; kernel)
end

# a product with an empty dimension is finished before any backend is chosen: MPS asserts on
# zero-sized buffers, and the result does not depend on A or B anyway. C is either empty (M or
# N == 0), or only β applies (K == 0).
function empty_matmul!(C, beta)
    isempty(C) && return C
    iszero(beta) ? fill!(C, zero(eltype(C))) : rmul!(C, beta)
end

@autoreleasepool function LinearAlgebra.mul!(C::MtlMatrix, tA, tB, A::MtlMatrix, B::MtlMatrix,
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
        return empty_matmul!(C, beta)
    end

    alg = matmul_alg[]
    # the MPS paths only handle plain transpose/adjoint operands; only probe MPSGraph
    # support when a branch below can actually use it
    ntc = is_ntc(tA) && is_ntc(tB)
    mpsgraph_supported = (alg === :MPSGraph || alg === :auto) && ntc &&
                         supports_mpsgraph_matmul(A, B, C, MPSGRAPH_VALID_MATMUL_TYPES)
    # If possible, dispatch to MPSGraphs, then performance shaders
    if alg === :MPSGraph || (alg === :auto && mpsgraph_supported)
        mpsgraph_supported || matmul_alg_error(alg, eltype(A), eltype(C), false)
        graph_matmul!(C, A, B, alpha, beta, tA, tB)
    elseif alg === :native || alg === :auto || alg === :simd || alg === :scalar || alg === :tensor
        native_matmul!(C, tA, tB, A, B, alpha, beta, alg)
    elseif alg === :MPS
        (ntc && supports_mps_matmul(A, B, C, MPS_VALID_MATMUL_TYPES)) || matmul_alg_error(alg, eltype(A), eltype(C), false)
        transA = tA == 'T' || tA == 'C'
        transB = tB == 'T' || tB == 'C'
        matmul!(C, A, B, alpha, beta, transA, transB)
    elseif alg === :GPUArrays
        GPUArrays.generic_matmatmul!(C, wrap(A, tA), wrap(B, tB), alpha, beta)
    else
        matmul_alg_invalid(alg, false)
    end
end

@autoreleasepool function LinearAlgebra.mul!(C::MtlMatrixOperand, tA, tB,
                                             A::MtlMatrixOperand, B::MtlMatrixOperand,
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
        return empty_matmul!(C, beta)
    end

    alg = matmul_alg[]
    if alg === :native || alg === :auto || alg === :simd || alg === :scalar || alg === :tensor
        native_matmul!(C, tA, tB, A, B, alpha, beta, alg)
    elseif alg === :GPUArrays
        GPUArrays.generic_matmatmul!(C, wrap(A, tA), wrap(B, tB), alpha, beta)
    elseif alg === :MPS || alg === :MPSGraph
        matmul_alg_error(alg, eltype(A), eltype(C), false)
    else
        matmul_alg_invalid(alg, false)
    end
end

if isdefined(LinearAlgebra, :generic_matmatmul_wrapper!)
    function LinearAlgebra.generic_matmatmul_wrapper!(C::MtlMatrixOperand{T},
                                                      tA::AbstractChar, tB::AbstractChar,
                                                      A::MtlMatrixOperand{T},
                                                      B::MtlMatrixOperand{T},
                                                      alpha::Number, beta::Number,
                                                      val::LinearAlgebra.BlasFlag.SyrkHerkGemm) where {T<:LinearAlgebra.BlasFloat}
        LinearAlgebra.mul!(C, tA, tB, A, B, alpha, beta)
    end
end

@autoreleasepool function LinearAlgebra.mul!(C::MtlVector, tA::AbstractChar, A::MtlMatrix, B::MtlVector,
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
        if mC != mA
            throw(DimensionMismatch("C has length ($mC), should have ($mA)"))
        end
        return empty_matmul!(C, beta)
    end

    alg = matmul_alg[]
    # the MPS paths only handle plain transpose/adjoint operands; only probe MPSGraph
    # support when a branch below can actually use it
    ntc = is_ntc(tA)
    mpsgraph_supported = (alg === :MPSGraph || alg === :auto) && ntc &&
                         supports_mpsgraph_matmul(A, B, C, MPSGRAPH_VALID_MATVECMUL_TYPES)
    # If possible, dispatch to MPSGraphs, then performance shaders
    if alg === :MPSGraph || (alg === :auto && mpsgraph_supported)
        mpsgraph_supported || matmul_alg_error(alg, eltype(A), eltype(C), true)
        graph_matvecmul!(C, A, B, alpha, beta, tA)
    elseif alg === :native || alg === :auto || alg === :simd || alg === :scalar
        # matrix-vector products go through the native gemv; `:simd`/`:scalar` force the
        # kernel. The tensor kernel is matrix-only, so `:tensor` isn't handled here and
        # falls through to the unsupported-algorithm error below.
        cA = gemm_char(tA)
        kernel = (alg === :simd || alg === :scalar) ? alg : :auto
        alg === :simd && (supports_simd_matmul(C, A, B, cA, 'N', alpha, beta) ||
            matmul_alg_error(alg, eltype(A), eltype(C), true))
        gemv!(C, cA, A, B, alpha, beta; kernel)
    elseif alg === :MPS
        (ntc && supports_mps_matmul(A, B, C, MPS_VALID_MATVECMUL_TYPES)) || matmul_alg_error(alg, eltype(A), eltype(C), true)
        transA = tA == 'T' || tA == 'C'
        matvecmul!(C, A, B, alpha, beta, transA)
    elseif alg === :GPUArrays
        GPUArrays.generic_matmatmul!(C, wrap(A, tA), B, alpha, beta)
    else
        matmul_alg_invalid(alg, true)
    end
end

# Julia < 1.13 dispatches on the non-public `generic_matvecmul!` and `generic_matmatmul!`,
# which JuliaLang/LinearAlgebra.jl#1671 superseded by the `mul!` methods above. Forward from
# the old names, both the alpha/beta variants (1.12) and the ones taking a final MulAddMul
# (1.10 and 1.11).
@static if VERSION < v"1.13.0-rc4"
    LinearAlgebra.generic_matvecmul!(C::MtlVector, tA::AbstractChar, A::MtlMatrix, B::MtlVector, alpha::Number, beta::Number) =
        LinearAlgebra.mul!(C, tA, A, B, alpha, beta)
    LinearAlgebra.generic_matvecmul!(C::MtlVector, tA::AbstractChar, A::MtlMatrix, B::MtlVector, _add::MulAddMul) =
        LinearAlgebra.mul!(C, tA, A, B, _add.alpha, _add.beta)
    for T in (:MtlMatrix, :MtlMatrixOperand)
        @eval begin
            LinearAlgebra.generic_matmatmul!(C::$T, tA, tB, A::$T, B::$T, alpha::Number, beta::Number) =
                LinearAlgebra.mul!(C, tA, tB, A, B, alpha, beta)
            LinearAlgebra.generic_matmatmul!(C::$T, tA, tB, A::$T, B::$T, _add::MulAddMul) =
                LinearAlgebra.mul!(C, tA, tB, A, B, _add.alpha, _add.beta)
        end
    end
end

@inline checkpositivedefinite(status) =
    status != MPS.MPSMatrixDecompositionStatusNonPositiveDefinite || throw(PosDefException(status))
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
LinearAlgebra.ipiv2perm(v::MtlVector{<:Any, CPUStorage}, maxi::Integer) =
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

    synchronize(cmdbuf)

    status = convert(LinearAlgebra.BlasInt, status[]::MPS.MPSMatrixDecompositionStatus)
    check && checknonsingular(status)

    return LinearAlgebra.LU(B, p, status)
end

function check_lu_success(info, allowsingular)
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

    synchronize(cmdbuf)

    status = convert(LinearAlgebra.BlasInt, status[])
    check && check_lu_success(status, allowsingular)

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

function Base.:\(A::MtlMatrix{T}, B::MtlVecOrMat{T}) where {T<:MtlFloat}
    if size(A, 1) == size(A, 2)
        return MPS.solve_lu(A, B)
    else
        return invoke(Base.:\, Tuple{AbstractMatrix, AbstractVecOrMat}, A, B)
    end
end

function LinearAlgebra.ldiv!(F::LU{T,<:MtlMatrix{T}},
                             B::MtlVecOrMat{T}) where {T<:MtlFloat}
    return MPS.solve_lu(F, B)
end

function Base.:\(F::LU{T,<:MtlMatrix{T}},
                 B::MtlVecOrMat{T}) where {T<:MtlFloat}
    return ldiv!(F, copy(B))
end

function LinearAlgebra.cholesky!(A::MtlMatrix{T},
                                 ::LinearAlgebra.NoPivot=LinearAlgebra.NoPivot();
                                 check::Bool=true) where {T<:MtlFloat}
    factors, info = MPS.decompose_cholesky!(A; uplo='U')
    check && checkpositivedefinite(info)
    return LinearAlgebra.Cholesky(factors, 'U', info)
end

function LinearAlgebra.cholesky(A::MtlMatrix{T},
                                ::LinearAlgebra.NoPivot=LinearAlgebra.NoPivot();
                                check::Bool=true) where {T<:MtlFloat}
    return cholesky!(copy(A), LinearAlgebra.NoPivot(); check)
end

for wrapper in (:Symmetric, :Hermitian)
    @eval begin
        function LinearAlgebra.cholesky!(A::$wrapper{T,<:MtlMatrix{T}},
                                         ::LinearAlgebra.NoPivot=LinearAlgebra.NoPivot();
                                         check::Bool=true) where {T<:MtlFloat}
            factors, info = MPS.decompose_cholesky!(parent(A); uplo=A.uplo)
            check && checkpositivedefinite(info)
            return LinearAlgebra.Cholesky(factors, A.uplo, info)
        end

        function LinearAlgebra.cholesky(A::$wrapper{T,<:MtlMatrix{T}},
                                        ::LinearAlgebra.NoPivot=LinearAlgebra.NoPivot();
                                        check::Bool=true) where {T<:MtlFloat}
            factors, info = MPS.decompose_cholesky(parent(A); uplo=A.uplo)
            check && checkpositivedefinite(info)
            return LinearAlgebra.Cholesky(factors, A.uplo, info)
        end
    end
end

function LinearAlgebra.ldiv!(C::Cholesky{T,<:MtlMatrix{T}},
                             B::MtlVecOrMat{T}) where {T<:MtlFloat}
    return MPS.solve_cholesky(C, B)
end

function Base.:\(C::Cholesky{T,<:MtlMatrix{T}},
                 B::MtlVecOrMat{T}) where {T<:MtlFloat}
    return ldiv!(C, copy(B))
end

@inline function triangular_upper(uplo::AbstractChar)
    uplo == 'U' && return true
    uplo == 'L' && return false
    throw(ArgumentError("invalid triangular storage: $uplo"))
end

@inline function triangular_unit(diag::AbstractChar)
    diag == 'U' && return true
    diag == 'N' && return false
    throw(ArgumentError("invalid triangular diagonal: $diag"))
end

@inline function triangular_transpose(tfun::Function)
    tfun === identity && return false
    (tfun === transpose || tfun === adjoint) && return true
    throw(ArgumentError("unsupported triangular operation"))
end

function LinearAlgebra.generic_trimatdiv!(C::MtlVecOrMat{T}, uploc, isunitc,
                                          tfun::Function, A::MtlMatrix{T},
                                          B::MtlVecOrMat{T}) where {T<:MtlFloat}
    return MPS.solve_triangular(A, B; upper=triangular_upper(uploc),
                                unit=triangular_unit(isunitc),
                                transpose=triangular_transpose(tfun), out=C)
end

function LinearAlgebra.generic_mattridiv!(C::MtlMatrix{T}, uploc, isunitc,
                                          tfun::Function, A::MtlMatrix{T},
                                          B::MtlMatrix{T}) where {T<:MtlFloat}
    return MPS.solve_triangular(B, A; upper=triangular_upper(uploc),
                                unit=triangular_unit(isunitc),
                                transpose=triangular_transpose(tfun),
                                right=true, out=C)
end

for (triangle, upper, unit) in ((:UpperTriangular, true, false),
                                (:UnitUpperTriangular, true, true),
                                (:LowerTriangular, false, false),
                                (:UnitLowerTriangular, false, true))
    @eval begin
        function LinearAlgebra.ldiv!(A::$triangle{T,<:MtlMatrix{T}},
                                     B::MtlVecOrMat{T}) where {T<:MtlFloat}
            return MPS.solve_triangular(parent(A), B; upper=$upper, unit=$unit)
        end

        function Base.:\(A::$triangle{T,<:MtlMatrix{T}},
                         B::MtlVecOrMat{T}) where {T<:MtlFloat}
            return ldiv!(A, copy(B))
        end

        function LinearAlgebra.rdiv!(B::MtlMatrix{T},
                                     A::$triangle{T,<:MtlMatrix{T}}) where {T<:MtlFloat}
            return MPS.solve_triangular(parent(A), B; upper=$upper, unit=$unit,
                                        right=true)
        end

        function LinearAlgebra.rdiv!(B::MtlMatrix{T},
                                     A::$triangle{T,<:Union{Transpose{T,<:MtlMatrix{T}},
                                                            Adjoint{T,<:MtlMatrix{T}}}}) where {T<:MtlFloat}
            return MPS.solve_triangular(parent(parent(A)), B; upper=$(!upper),
                                        unit=$unit, transpose=true, right=true)
        end
    end
end

function lu_pivot_sign(ipiv::MtlVector)
    return isodd(count(ipiv .!= (1:length(ipiv)))) ? -1 : 1
end

function metal_identity(A::MtlMatrix{T,S}, n::Integer) where {T,S}
    return MtlMatrix{T,S}(I, n, n)
end

function LinearAlgebra.det(F::LU{T,<:MtlMatrix{T}}) where {T<:MtlFloat}
    LinearAlgebra.checksquare(F.factors)
    LinearAlgebra.issuccess(F) || return zero(T)
    return prod(diag(F.factors)) * T(lu_pivot_sign(F.ipiv))
end

function LinearAlgebra.logabsdet(F::LU{T,<:MtlMatrix{T}}) where {T<:MtlFloat}
    LinearAlgebra.checksquare(F.factors)
    LinearAlgebra.issuccess(F) || return (log(zero(T)), zero(T))
    d = diag(F.factors)
    return (mapreduce(x -> log(abs(x)), +, d), prod(sign, d) * T(lu_pivot_sign(F.ipiv)))
end

function LinearAlgebra.logdet(F::LU{T,<:MtlMatrix{T}}) where {T<:MtlFloat}
    logabs, sgndet = logabsdet(F)
    return logabs + log(sgndet)
end

function LinearAlgebra.det(C::Cholesky{T,<:MtlMatrix{T}}) where {T<:MtlFloat}
    LinearAlgebra.checksquare(C.factors)
    LinearAlgebra.issuccess(C) || return zero(T)
    return prod(abs2, diag(C.factors))
end

function LinearAlgebra.logdet(C::Cholesky{T,<:MtlMatrix{T}}) where {T<:MtlFloat}
    LinearAlgebra.checksquare(C.factors)
    LinearAlgebra.issuccess(C) || return log(zero(T))
    return 2 * mapreduce(log, +, diag(C.factors))
end

function LinearAlgebra.logabsdet(C::Cholesky{T,<:MtlMatrix{T}}) where {T<:MtlFloat}
    return (logdet(C), one(T))
end

for op in (:det, :logabsdet, :logdet)
    @eval function LinearAlgebra.$op(A::MtlMatrix{T}) where {T<:MtlFloat}
        LinearAlgebra.checksquare(A)
        return LinearAlgebra.$op(lu(A; check=false))
    end
end

function LinearAlgebra.inv(A::MtlMatrix{T}) where {T<:MtlFloat}
    n = LinearAlgebra.checksquare(A)
    return A \ metal_identity(A, n)
end

for factorization in (:LU, :Cholesky)
    @eval function LinearAlgebra.inv(F::$factorization{T,<:MtlMatrix{T}}) where {T<:MtlFloat}
        n = LinearAlgebra.checksquare(F.factors)
        return ldiv!(F, metal_identity(F.factors, n))
    end
end
