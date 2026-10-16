## descriptor

export MPSVectorDescriptor

# @objcwrapper MPSVectorDescriptor <: NSObject


function MPSVectorDescriptor(length::Integer, dataType::Union{DataType,MPSDataType})
    return @objc [MPSVectorDescriptor vectorDescriptorWithLength:length::NSUInteger
                                      dataType:dataType::MPSDataType]::MPSVectorDescriptor
end

function MPSVectorDescriptor(length::Integer, vectors, vectorBytes::Integer,
                             dataType::Union{DataType,MPSDataType})
    return @objc [MPSVectorDescriptor vectorDescriptorWithLength:length::NSUInteger
                                      vectors:vectors::NSUInteger
                                      vectorBytes:vectorBytes::NSUInteger
                                      dataType:dataType::MPSDataType]::MPSVectorDescriptor
end


## high-level object

export MPSVector

# @objcwrapper managed = true MPSVector <: NSObject

function MPSVector(buf, descriptor::MPSVectorDescriptor, offset::Integer=0)
    return @objc [[MPSVector alloc]::id{MPSVector} initWithBuffer:buf::id{MTLBuffer}
                                             offset:offset::NSUInteger
                                             descriptor:descriptor::id{MPSVectorDescriptor}]::MPSVector
end

function MPSVector(dev::MTLDevice, descriptor::MPSVectorDescriptor)
    return @objc [[MPSVector alloc]::id{MPSVector} initWithDevice:dev::id{MTLDevice}
                                             descriptor:descriptor::id{MPSVectorDescriptor}]::MPSVector
end

"""
    MPSVector(arr::MtlVector)

Metal vector representation used in Performance Shaders.
"""
function MPSVector(arr::MtlVector{T}) where T
    desc = MPSVectorDescriptor(length(arr), T)
    offset = arr.offset
    return MPSVector(arr, desc, offset)
end

# @objcwrapper managed = true MPSTemporaryVector <: MPSVector

function MPSTemporaryVector(commandBuffer::MTLCommandBufferLike, descriptor::MPSVectorDescriptor)
    return @objc [MPSTemporaryVector temporaryVectorWithCommandBuffer:commandBuffer::id{MTLCommandBuffer}
                                      descriptor:descriptor::id{MPSVectorDescriptor}]::MPSTemporaryVector
end


## matrix vector multiplication

export MPSMatrixVectorMultiplication, encode!, matvecmul!

# @objcwrapper managed = true MPSMatrixVectorMultiplication <: MPSMatrixBinaryKernel

function MPSMatrixVectorMultiplication(dev, transpose, rows, columns, alpha, beta)
    return @objc [[MPSMatrixVectorMultiplication alloc]::id{MPSMatrixVectorMultiplication} initWithDevice:dev::id{MTLDevice}
                                                                                     transpose:transpose::Bool
                                                                                     rows:rows::NSUInteger
                                                                                     columns:columns::NSUInteger
                                                                                     alpha:alpha::Cdouble
                                                                                     beta:beta::Cdouble]::MPSMatrixVectorMultiplication
end

function encode!(cmdbuf::MTLCommandBufferLike, matvecmul::MPSMatrixVectorMultiplicationLike, inputMatrix, inputVector, resultVector)
    @objc [matvecmul::id{MPSMatrixVectorMultiplication} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                        inputMatrix:inputMatrix::id{MPSMatrix}
                                                        inputVector:inputVector::id{MPSVector}
                                                        resultVector:resultVector::id{MPSVector}]::Nothing
end

"""
    MPS.matvecmul!(y, A, x, α=true, β=false; tA='N') -> y

Compute `y = α * opA(A) * x + β * y` using `MPSMatrixVectorMultiplication`, where `opA` is
the identity (`'N'`) or the transpose (`'T'` or `'C'`), as selected by `tA`.

`A` is an `MtlArray` matrix and `x` and `y` are `MtlArray` vectors, with element types
that are one of the combinations in `MPS.MPS_VALID_MATVECMUL_TYPES`. The multiplication
executes asynchronously, ordered with the other work submitted from the current task.
"""
function matvecmul!(c::MtlVector, a::MtlMatrix, b::MtlVector, alpha::Number=true,
                    beta::Number=false; tA::AbstractChar='N')
    transpose = mps_transpose(tA)
    # NOTE: MPS uses row major, while Julia is col-major
    cols_a = size(a, transpose ? 1 : 2)
    rows_c = length(c)

    # Create MPS-compatible matrix/vector from the MtlArrays
    mps_a = MPSMatrix(a)
    mps_b = MPSVector(b)
    mps_c = MPSVector(c)

    matvec_mul_kernel = MPSMatrixVectorMultiplication(device(), !transpose,
                                                      rows_c, cols_a,
                                                      alpha, beta)

    # Encode and commit matmul kernel
    cmdbuf = MTLCommandBuffer(global_queue(device()))
    encode!(cmdbuf, matvec_mul_kernel, mps_a, mps_b, mps_c)
    commit!(cmdbuf)

    return c
end

function matvecmul!(c::MtlVector, a::MtlMatrix, b::MtlVector, alpha::Number, beta::Number,
                    transpose::Bool)
    Base.depwarn("`MPS.matvecmul!(c, a, b, α, β, transpose::Bool)` is deprecated, use `MPS.matvecmul!(c, a, b, α, β; tA)` with 'N' or 'T' instead.",
                 :matvecmul!)
    return matvecmul!(c, a, b, alpha, beta; tA=transpose ? 'T' : 'N')
end
