## descriptor

export MPSVectorDescriptor

# @objcwrapper MPSVectorDescriptor <: NSObject


function MPSVectorDescriptor(length::Integer, dataType::Union{DataType,MPSDataType})
    desc = @objc [MPSVectorDescriptor vectorDescriptorWithLength:length::NSUInteger
                                      dataType:dataType::MPSDataType]::id{MPSVectorDescriptor}
    MPSVectorDescriptor(desc)
end

function MPSVectorDescriptor(length::Integer, vectors, vectorBytes::Integer,
                             dataType::Union{DataType,MPSDataType})
    desc = @objc [MPSVectorDescriptor vectorDescriptorWithLength:length::NSUInteger
                                      vectors:vectors::NSUInteger
                                      vectorBytes:vectorBytes::NSUInteger
                                      dataType:dataType::MPSDataType]::id{MPSVectorDescriptor}
    MPSVectorDescriptor(desc)
end


## high-level object

export MPSVector

# @objcwrapper immutable=false MPSVector <: NSObject

function MPSVector(buf, descriptor::MPSVectorDescriptor, offset::Integer=0)
    vec = @objc [MPSVector alloc]::id{MPSVector}
    obj = MPSVector(vec)
    finalizer(release, obj)
    @objc [obj::id{MPSVector} initWithBuffer:buf::id{MTLBuffer}
                              offset:offset::NSUInteger
                              descriptor:descriptor::id{MPSVectorDescriptor}]::id{MPSVector}
    return obj
end

function MPSVector(dev::MTLDevice, descriptor::MPSVectorDescriptor)
    vec = @objc [MPSVector alloc]::id{MPSVector}
    obj = MPSVector(vec)
    finalizer(release, obj)
    @objc [obj::id{MPSVector} initWithDevice:dev::id{MTLDevice}
                              descriptor:descriptor::id{MPSVectorDescriptor}]::id{MPSVector}
    return obj
end

"""
    MPSVector(arr::MtlVector)

Metal vector representation used in Performance Shaders.
"""
function MPSVector(arr::MtlVector{T}) where T
    desc = MPSVectorDescriptor(length(arr), T)
    offset = arr.offset * sizeof(T)
    return MPSVector(arr, desc, offset)
end

# @objcwrapper immutable=false MPSTemporaryVector <: MPSVector

function MPSTemporaryVector(commandBuffer::MTLCommandBuffer, descriptor::MPSVectorDescriptor)
    obj = @objc [MPSTemporaryVector temporaryVectorWithCommandBuffer:commandBuffer::id{MTLCommandBuffer}
                              descriptor:descriptor::id{MPSVectorDescriptor}]::id{MPSTemporaryVector}
    return MPSTemporaryVector(obj)
end


## matrix vector multiplication

export MPSMatrixVectorMultiplication, encode!, matvecmul!

# @objcwrapper immutable=false MPSMatrixVectorMultiplication <: MPSMatrixBinaryKernel

function MPSMatrixVectorMultiplication(dev, transpose, rows, columns, alpha, beta)
    kernel = @objc [MPSMatrixVectorMultiplication alloc]::id{MPSMatrixVectorMultiplication}
    obj = MPSMatrixVectorMultiplication(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSMatrixVectorMultiplication} initWithDevice:dev::id{MTLDevice}
                                                  transpose:transpose::Bool
                                                  rows:rows::NSUInteger
                                                  columns:columns::NSUInteger
                                                  alpha:alpha::Cdouble
                                                  beta:beta::Cdouble]::id{MPSMatrixVectorMultiplication}
    return obj
end

function encode!(cmdbuf::MTLCommandBuffer, matvecmul::MPSMatrixVectorMultiplication, inputMatrix, inputVector, resultVector)
    @objc [matvecmul::id{MPSMatrixVectorMultiplication} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                        inputMatrix:inputMatrix::id{MPSMatrix}
                                                        inputVector:inputVector::id{MPSVector}
                                                        resultVector:resultVector::id{MPSVector}]::Nothing
end

"""
    matvecmul!(c::MtlVector, a::MtlMatrix, b::MtlVector, alpha=1, beta=1, transpose=false)

A `MPSMatrixVectorMultiplication` kernel thay computes:
    `c = alpha * op(a) * b + beta * c`

This function should not typically be used. Rather, use the normal `LinearAlgebra` interface
with any `MtlArray` and it should be accelerated using Metal Performance Shaders.
"""
function matvecmul!(c::MtlVector, a::MtlMatrix, b::MtlVector, alpha::Number=true, beta::Number=false,
                    transpose=false)
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
