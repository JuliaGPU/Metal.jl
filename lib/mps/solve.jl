using LinearAlgebra

## LU solve

export MPSMatrixSolveLU, encode!

# @objcwrapper MPSMatrixSolveLU <: MPSMatrixBinaryKernel

function MPSMatrixSolveLU(dev, transpose, order, numberOfRightHandSides)
    return @objc [[MPSMatrixSolveLU alloc]::id{MPSMatrixSolveLU} initWithDevice:dev::id{MTLDevice}
                                                                     transpose:transpose::Bool
                                                                         order:order::NSUInteger
                                                        numberOfRightHandSides:numberOfRightHandSides::NSUInteger]::MPSMatrixSolveLU
end

function encode!(cmdbuf::MTLCommandBufferLike, kernel::MPSMatrixSolveLULike,
                 sourceMatrix, rightHandSideMatrix, pivotIndices, solutionMatrix)
    @objc [kernel::id{MPSMatrixSolveLU} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                 sourceMatrix:sourceMatrix::id{MPSMatrix}
                                          rightHandSideMatrix:rightHandSideMatrix::id{MPSMatrix}
                                                 pivotIndices:pivotIndices::id{MPSMatrix}
                                               solutionMatrix:solutionMatrix::id{MPSMatrix}]::Nothing
end


## Cholesky solve

export MPSMatrixSolveCholesky, encode!

# @objcwrapper MPSMatrixSolveCholesky <: MPSMatrixBinaryKernel

function MPSMatrixSolveCholesky(dev, upper, order, numberOfRightHandSides)
    return @objc [[MPSMatrixSolveCholesky alloc]::id{MPSMatrixSolveCholesky} initWithDevice:dev::id{MTLDevice}
                                                                                     upper:upper::Bool
                                                                                     order:order::NSUInteger
                                                                    numberOfRightHandSides:numberOfRightHandSides::NSUInteger]::MPSMatrixSolveCholesky
end

function encode!(cmdbuf::MTLCommandBufferLike, kernel::MPSMatrixSolveCholeskyLike,
                 sourceMatrix, rightHandSideMatrix, solutionMatrix)
    @objc [kernel::id{MPSMatrixSolveCholesky} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                       sourceMatrix:sourceMatrix::id{MPSMatrix}
                                                rightHandSideMatrix:rightHandSideMatrix::id{MPSMatrix}
                                                     solutionMatrix:solutionMatrix::id{MPSMatrix}]::Nothing
end


## Triangular solve

export MPSMatrixSolveTriangular, encode!

# @objcwrapper MPSMatrixSolveTriangular <: MPSMatrixBinaryKernel

function MPSMatrixSolveTriangular(dev, right, upper, transpose, unit, order,
                                  numberOfRightHandSides, alpha::Cdouble)
    return @objc [[MPSMatrixSolveTriangular alloc]::id{MPSMatrixSolveTriangular} initWithDevice:dev::id{MTLDevice}
                                                                                         right:right::Bool
                                                                                         upper:upper::Bool
                                                                                     transpose:transpose::Bool
                                                                                          unit:unit::Bool
                                                                                         order:order::NSUInteger
                                                                        numberOfRightHandSides:numberOfRightHandSides::NSUInteger
                                                                                         alpha:alpha::Cdouble]::MPSMatrixSolveTriangular
end

function encode!(cmdbuf::MTLCommandBufferLike, kernel::MPSMatrixSolveTriangularLike,
                 sourceMatrix, rightHandSideMatrix, solutionMatrix)
    @objc [kernel::id{MPSMatrixSolveTriangular} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                         sourceMatrix:sourceMatrix::id{MPSMatrix}
                                                  rightHandSideMatrix:rightHandSideMatrix::id{MPSMatrix}
                                                       solutionMatrix:solutionMatrix::id{MPSMatrix}]::Nothing
end


## drivers

export solve_lu, solve_cholesky, solve_triangular, decompose_cholesky,
       decompose_cholesky!

@inline rhs_count(B::MtlVector) = 1
@inline rhs_count(B::MtlMatrix) = size(B, 2)

function check_square_rhs(A::MtlMatrix, B::MtlVecOrMat)
    n = LinearAlgebra.checksquare(A)
    size(B, 1) == n ||
        throw(DimensionMismatch("left hand side has $n rows, but right hand side has $(size(B, 1)) rows"))
    return n, rhs_count(B)
end

function check_square_rdiv(A::MtlMatrix, B::MtlMatrix)
    n = LinearAlgebra.checksquare(A)
    size(B, 2) == n ||
        throw(DimensionMismatch("right factor has order $n, but left hand side has $(size(B, 2)) columns"))
    return n, size(B, 1)
end

function check_rhs_out(B::MtlVecOrMat, out::MtlVecOrMat)
    size(out) == size(B) ||
        throw(DimensionMismatch("output has dimensions $(size(out)), but right hand side has dimensions $(size(B))"))
    return
end

@inline function transpose_copy!(cbuf, dev, src::MPSMatrix, dst::MPSMatrix, rows, cols)
    encode!(cbuf, MPSMatrixCopy(dev, rows, cols, false, true),
            MPSMatrixCopyDescriptor(src, dst))
end

@inline function rhs_scratch(::Type{T}, n, nrhs) where {T}
    return MtlMatrix{T, PrivateStorage}(undef, (nrhs, n))
end

@inline status_buffer() =
    MtlArray{MPSMatrixDecompositionStatus, 0, SharedStorage}(undef)

@inline function checknonsingular(status)
    status != convert(LinearAlgebra.BlasInt, MPSMatrixDecompositionStatusSingular) ||
        throw(LinearAlgebra.SingularException(status))
end

@inline function checkpositivedefinite(status)
    status != convert(LinearAlgebra.BlasInt, MPSMatrixDecompositionStatusNonPositiveDefinite) ||
        throw(LinearAlgebra.PosDefException(status))
end

@inline function uplo_char(uplo::Symbol)
    uplo === :U && return 'U'
    uplo === :L && return 'L'
    throw(ArgumentError("invalid uplo: $uplo"))
end

@inline function uplo_char(uplo::AbstractChar)
    uplo == 'U' && return 'U'
    uplo == 'L' && return 'L'
    throw(ArgumentError("invalid uplo: $uplo"))
end

@inline mps_cholesky_lower(uplo) = uplo_char(uplo) == 'U'
@inline mps_cholesky_upper(uplo) = uplo_char(uplo) == 'L'

@autoreleasepool function solve_lu(A::MtlMatrix{T}, B::MtlVecOrMat{T};
                                   check::Bool=true) where {T<:MtlFloat}
    n, nrhs = check_square_rhs(A, B)
    dev = device()
    queue = global_queue(dev)

    At = MtlMatrix{T, PrivateStorage}(undef, (n, n))
    Bt = rhs_scratch(T, n, nrhs)
    Xt = rhs_scratch(T, n, nrhs)
    X = similar(B)
    P = MtlMatrix{UInt32, PrivateStorage}(undef, (1, n))
    status = status_buffer()

    mps_a = MPSMatrix(A)
    mps_at = MPSMatrix(At)
    mps_b = MPSMatrix(B)
    mps_bt = MPSMatrix(Bt)
    mps_xt = MPSMatrix(Xt)
    mps_x = MPSMatrix(X)
    mps_p = MPSMatrix(P)

    cmdbuf = MPSCommandBuffer(queue) do cbuf
        transpose_copy!(cbuf, dev, mps_a, mps_at, n, n)
        transpose_copy!(cbuf, dev, mps_b, mps_bt, nrhs, n)
    end

    commitAndContinue!(cmdbuf) do cbuf
        encode!(cbuf, MPSMatrixDecompositionLU(dev, n, n), mps_at, mps_at, mps_p, status)
    end

    commitAndContinue!(cmdbuf) do cbuf
        encode!(cbuf, MPSMatrixSolveLU(dev, false, n, nrhs), mps_at, mps_bt, mps_p, mps_xt)
    end

    commit!(cmdbuf) do cbuf
        transpose_copy!(cbuf, dev, mps_xt, mps_x, n, nrhs)
    end

    synchronize(cmdbuf)

    info = convert(LinearAlgebra.BlasInt, status[])
    check && checknonsingular(info)
    return X
end

@autoreleasepool function solve_lu(F::LinearAlgebra.LU{T,<:MtlMatrix{T}},
                                   B::MtlVecOrMat{T};
                                   out::MtlVecOrMat{T}=B) where {T<:MtlFloat}
    n = LinearAlgebra.checksquare(F)
    size(B, 1) == n ||
        throw(DimensionMismatch("factorization has $n rows, but right hand side has $(size(B, 1)) rows"))
    check_rhs_out(B, out)
    nrhs = rhs_count(B)

    dev = device()
    queue = global_queue(dev)

    LUt = MtlMatrix{T, PrivateStorage}(undef, (n, n))
    Bt = rhs_scratch(T, n, nrhs)
    Xt = rhs_scratch(T, n, nrhs)
    P = MtlMatrix{UInt32, PrivateStorage}(undef, (1, n))
    P .= UInt32.(reshape(F.ipiv, 1, n)) .- UInt32(1)

    mps_lu = MPSMatrix(F.factors)
    mps_lut = MPSMatrix(LUt)
    mps_b = MPSMatrix(B)
    mps_bt = MPSMatrix(Bt)
    mps_xt = MPSMatrix(Xt)
    mps_out = MPSMatrix(out)
    mps_p = MPSMatrix(P)

    cmdbuf = MPSCommandBuffer(queue) do cbuf
        transpose_copy!(cbuf, dev, mps_lu, mps_lut, n, n)
        transpose_copy!(cbuf, dev, mps_b, mps_bt, nrhs, n)
    end

    commitAndContinue!(cmdbuf) do cbuf
        encode!(cbuf, MPSMatrixSolveLU(dev, false, n, nrhs), mps_lut, mps_bt, mps_p, mps_xt)
    end

    commit!(cmdbuf) do cbuf
        transpose_copy!(cbuf, dev, mps_xt, mps_out, n, nrhs)
    end

    synchronize(cmdbuf)
    return out
end

@autoreleasepool function decompose_cholesky!(A::MtlMatrix{T};
                                              uplo::Union{Symbol,AbstractChar}='U') where {T<:MtlFloat}
    n = LinearAlgebra.checksquare(A)
    dev = device()
    queue = global_queue(dev)
    status = status_buffer()

    cmdbuf = MPSCommandBuffer(queue)
    mps_a = MPSMatrix(A)
    encode!(cmdbuf, MPSMatrixDecompositionCholesky(dev, mps_cholesky_lower(uplo), n),
            mps_a, mps_a, status)
    commit!(cmdbuf)
    synchronize(cmdbuf)

    info = convert(LinearAlgebra.BlasInt, status[])
    return A, info
end

function decompose_cholesky(A::MtlMatrix{T};
                            uplo::Union{Symbol,AbstractChar}='U') where {T<:MtlFloat}
    return decompose_cholesky!(copy(A); uplo)
end

@autoreleasepool function solve_cholesky(C::LinearAlgebra.Cholesky{T,<:MtlMatrix{T}},
                                         B::MtlVecOrMat{T};
                                         out::MtlVecOrMat{T}=B) where {T<:MtlFloat}
    n = LinearAlgebra.checksquare(C)
    size(B, 1) == n ||
        throw(DimensionMismatch("factorization has $n rows, but right hand side has $(size(B, 1)) rows"))
    check_rhs_out(B, out)
    nrhs = rhs_count(B)

    dev = device()
    queue = global_queue(dev)

    Bt = rhs_scratch(T, n, nrhs)
    Xt = rhs_scratch(T, n, nrhs)

    mps_c = MPSMatrix(C.factors)
    mps_b = MPSMatrix(B)
    mps_bt = MPSMatrix(Bt)
    mps_xt = MPSMatrix(Xt)
    mps_out = MPSMatrix(out)

    cmdbuf = MPSCommandBuffer(queue) do cbuf
        transpose_copy!(cbuf, dev, mps_b, mps_bt, nrhs, n)
    end

    commitAndContinue!(cmdbuf) do cbuf
        encode!(cbuf, MPSMatrixSolveCholesky(dev, mps_cholesky_upper(C.uplo), n, nrhs),
                mps_c, mps_bt, mps_xt)
    end

    commit!(cmdbuf) do cbuf
        transpose_copy!(cbuf, dev, mps_xt, mps_out, n, nrhs)
    end

    synchronize(cmdbuf)
    return out
end

@autoreleasepool function solve_cholesky(A::MtlMatrix{T}, B::MtlVecOrMat{T};
                                         uplo::Union{Symbol,AbstractChar}='U',
                                         check::Bool=true) where {T<:MtlFloat}
    n, nrhs = check_square_rhs(A, B)
    dev = device()
    queue = global_queue(dev)

    F = copy(A)
    Bt = rhs_scratch(T, n, nrhs)
    Xt = rhs_scratch(T, n, nrhs)
    X = similar(B)
    status = status_buffer()

    mps_f = MPSMatrix(F)
    mps_b = MPSMatrix(B)
    mps_bt = MPSMatrix(Bt)
    mps_xt = MPSMatrix(Xt)
    mps_x = MPSMatrix(X)

    cmdbuf = MPSCommandBuffer(queue) do cbuf
        transpose_copy!(cbuf, dev, mps_b, mps_bt, nrhs, n)
    end

    commitAndContinue!(cmdbuf) do cbuf
        encode!(cbuf, MPSMatrixDecompositionCholesky(dev, mps_cholesky_lower(uplo), n),
                mps_f, mps_f, status)
    end

    commitAndContinue!(cmdbuf) do cbuf
        encode!(cbuf, MPSMatrixSolveCholesky(dev, mps_cholesky_upper(uplo), n, nrhs),
                mps_f, mps_bt, mps_xt)
    end

    commit!(cmdbuf) do cbuf
        transpose_copy!(cbuf, dev, mps_xt, mps_x, n, nrhs)
    end

    synchronize(cmdbuf)

    info = convert(LinearAlgebra.BlasInt, status[])
    check && checkpositivedefinite(info)
    return X
end

@autoreleasepool function solve_triangular(A::MtlMatrix{T}, B::MtlVecOrMat{T};
                                           upper::Bool, unit::Bool,
                                           transpose::Bool=false, right::Bool=false,
                                           alpha=one(T),
                                           out::MtlVecOrMat{T}=B) where {T<:MtlFloat}
    if right
        B isa MtlMatrix && out isa MtlMatrix ||
            throw(ArgumentError("right triangular solve requires matrix inputs"))
        return solve_triangular_right(A, B; upper, unit, transpose, alpha, out)
    end

    n, nrhs = check_square_rhs(A, B)
    check_rhs_out(B, out)

    dev = device()
    queue = global_queue(dev)

    Bt = rhs_scratch(T, n, nrhs)
    Xt = rhs_scratch(T, n, nrhs)

    mps_a = MPSMatrix(A)
    mps_b = MPSMatrix(B)
    mps_bt = MPSMatrix(Bt)
    mps_xt = MPSMatrix(Xt)
    mps_out = MPSMatrix(out)

    cmdbuf = MPSCommandBuffer(queue) do cbuf
        transpose_copy!(cbuf, dev, mps_b, mps_bt, nrhs, n)
    end

    commitAndContinue!(cmdbuf) do cbuf
        # MPS sees the source matrix transposed relative to Julia.  The triangle
        # flag describes that MPS view; the transpose flag describes the Julia op.
        encode!(cbuf, MPSMatrixSolveTriangular(dev, right, !upper, !transpose, unit,
                                               n, nrhs, Cdouble(alpha)),
                mps_a, mps_bt, mps_xt)
    end

    commit!(cmdbuf) do cbuf
        transpose_copy!(cbuf, dev, mps_xt, mps_out, n, nrhs)
    end

    synchronize(cmdbuf)
    return out
end

function solve_triangular_right(A::MtlMatrix{T}, B::MtlMatrix{T};
                                upper::Bool, unit::Bool, transpose::Bool=false,
                                alpha=one(T), out::MtlMatrix{T}=B) where {T<:MtlFloat}
    n, nrhs = check_square_rdiv(A, B)
    check_rhs_out(B, out)

    dev = device()
    queue = global_queue(dev)

    Bt = MtlMatrix{T, PrivateStorage}(undef, (n, nrhs))
    mps_b = MPSMatrix(B)
    mps_bt = MPSMatrix(Bt)

    cmdbuf = MPSCommandBuffer(queue) do cbuf
        transpose_copy!(cbuf, dev, mps_b, mps_bt, n, nrhs)
    end
    commit!(cmdbuf)
    synchronize(cmdbuf)

    solve_triangular(A, Bt; upper, unit, transpose=!transpose, alpha, out=Bt)

    mps_bt = MPSMatrix(Bt)
    mps_out = MPSMatrix(out)
    cmdbuf = MPSCommandBuffer(queue) do cbuf
        transpose_copy!(cbuf, dev, mps_bt, mps_out, nrhs, n)
    end
    commit!(cmdbuf)

    synchronize(cmdbuf)

    return out
end
