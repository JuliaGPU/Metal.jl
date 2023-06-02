export MPSVectorDescriptor

@objcwrapper MPSVectorDescriptor <: NSObject

@objcproperties MPSVectorDescriptor begin
    @autoproperty length::NSUInteger setter=setLength
    @autoproperty vectors::NSUInteger
    @autoproperty dataType::MPSDataType setter=setDataType
    @autoproperty vectorBytes::NSUInteger
end


function MPSVectorDescriptor(length, dataType)
    desc = @objc [MPSVectorDescriptor vectorDescriptorWithLength:length::NSUInteger
                                      dataType:jl_typ_to_mps[dataType]::MPSDataType]::id{MPSVectorDescriptor}
    obj = MPSVectorDescriptor(desc)
    # XXX: who releases this object?
    return obj
end

function MPSVectorDescriptor(length, vectors, vectorBytes, dataType)
    desc = @objc [MPSVectorDescriptor vectorDescriptorWithLength:length::NSUInteger
                                      vectors:vectors::NSUInteger
                                      vectorBytes:vectorBytes::NSUInteger
                                      dataType:jl_typ_to_mps[dataType]::MPSDataType]::id{MPSVectorDescriptor}
    obj = MPSVectorDescriptor(desc)
    # XXX: who releases this object?
    return obj
end


export MPSVector

@objcwrapper immutable=false MPSVector <: NSObject

@objcproperties MPSVector begin
    @autoproperty device::id{MTLDevice}
    @autoproperty length::NSUInteger
    @autoproperty vectors::NSUInteger
    @autoproperty dataType::MPSDataType
    @autoproperty vectorBytes::NSUInteger
    @autoproperty offset::NSUInteger
    @autoproperty data::id{MTLBuffer}
end

"""
    MPSVector(arr::MtlVector)

Metal vector representation used in Performance Shaders.
"""
function MPSVector(arr::MtlVector{T}) where T
    len = length(arr)
    desc = MPSVectorDescriptor(len, T)
    vec = @objc [MPSVector alloc]::id{MPSVector}
    obj = MPSVector(vec)
    finalizer(release, obj)
    @objc [obj::id{MPSVector} initWithBuffer:arr.buffer::id{MTLBuffer}
                              descriptor:desc::id{MPSVectorDescriptor}]::id{MPSVector}
    return obj
end

#
# matrix vector multiplication
#

@objcwrapper immutable=false MPSMatrixVectorMultiplication <: MPSKernel

function MPSMatrixVectorMultiplication(device, transpose, rows, columns, alpha, beta)
    kernel = @objc [MPSMatrixVectorMultiplication alloc]::id{MPSMatrixVectorMultiplication}
    obj = MPSMatrixVectorMultiplication(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSMatrixVectorMultiplication} initWithDevice:device::id{MTLDevice}
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
A MPSMatrixVectorMultiplication kernel thay computes:
y = alpha * op(A) * x + beta * y
"""
function matvecmul!(y::MtlVector, a::MtlMatrix, x::MtlVector, alpha::Number=true, beta::Number=false,
                    transpose=false)
    # NOTE: MPS uses row major, while Julia is col-major
    cols_a = size(a, transpose ? 1 : 2)
    rows_y = length(y)

    # Create MPS-compatible matrix/vector from the MtlArrays
    mps_a = MPSMatrix(a)
    mps_x = MPSVector(x)
    mps_y = MPSVector(y)

    matvec_mul_kernel = MPSMatrixVectorMultiplication(current_device(), !transpose,
                                                      rows_y, cols_a,
                                                      alpha, beta)

    # Encode and commit matmul kernel
    cmdbuf = MTLCommandBuffer(global_queue(current_device()))
    encode!(cmdbuf, matvec_mul_kernel, mps_a, mps_x, mps_y)
    commit!(cmdbuf)

    return y
end