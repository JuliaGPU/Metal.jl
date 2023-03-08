#
# matrix enums
#

@cenum MPSDataType::UInt32 begin
    MPSDataTypeComplexBit = UInt32(0x01000000)
    MPSDataTypeFloatBit = UInt32(0x10000000)
    MPSDataTypeSignedBit = UInt32(0x20000000)
    MPSDataTypeNormalizedBit = UInt32(0x40000000)
    MPSDataTypeAlternateEncodingBit = UInt32(0x80000000)
end
## bitwise operations lose type information, so allow conversions
Base.convert(::Type{MPSDataType}, x::Integer) = MPSDataType(x)

@cenum MPSKernelOptions::NSUInteger begin
    MPSKernelOptionsNone = 0
    MPSKernelOptionsSkipAPIValidation = 1 << 0
    MPSKernelOptionsAllowReducedPrecision = 1 << 1
    MPSKernelOptionsDisableInternalTiling = 1 << 2
    MPSKernelOptionsInsertDebugGroups = 1 << 3
    MPSKernelOptionsVerbose = 1 << 4
end


#
# matrix descriptor
#

export MPSMatrixDescriptor

@objcwrapper MPSMatrixDescriptor <: NSObject

# Mapping from Julia types to the Performance Shader bitfields
const jl_typ_to_mps = Dict{DataType,MPSDataType}(
    UInt8       => UInt32(8),
    UInt16      => UInt32(16),
    UInt32      => UInt32(32),
    UInt64      => UInt32(64),

    Int8        => MPSDataTypeSignedBit | UInt32(8),
    Int16       => MPSDataTypeSignedBit | UInt32(16),
    Int32       => MPSDataTypeSignedBit | UInt32(32),
    Int64       => MPSDataTypeSignedBit | UInt32(64),

    Float16     => MPSDataTypeFloatBit | UInt32(16),
    Float32     => MPSDataTypeFloatBit | UInt32(32),

    ComplexF16  => MPSDataTypeFloatBit | MPSDataTypeComplexBit | UInt32(16),
    ComplexF32  => MPSDataTypeFloatBit | MPSDataTypeComplexBit | UInt32(32)
)

function MPSMatrixDescriptor(rows, columns, rowBytes, dataType)
    desc = @objc [MPSMatrixDescriptor matrixDescriptorWithRows:rows::NSUInteger
                                      columns:columns::NSUInteger
                                      rowBytes:rowBytes::NSUInteger
                                      dataType:jl_typ_to_mps[dataType]::MPSDataType]::id{MPSMatrixDescriptor}
    obj = MPSMatrixDescriptor(desc)
    # TODO: release?
    return obj
end


#
# matrix object
#

export MPSMatrix

@objcwrapper MPSMatrix <: NSObject

"""
    MPSMatrix(arr::MtlMatrix)

Metal matrix representation used in Performance Shaders.

Note that this results in a transposed view of the input,
as Metal stores matrices row-major instead of column-major.
"""
function MPSMatrix(arr::MtlMatrix{T}) where T
    n_cols, n_rows = size(arr)
    desc = MPSMatrixDescriptor(n_rows, n_cols, sizeof(T)*n_cols, T)
    mat = @objc [MPSMatrix alloc]::id{MPSMatrix}
    obj = MPSMatrix(mat)
    # TODO: release?
    @objc [obj::id{MPSMatrix} initWithBuffer:arr.buffer::id{MTLBuffer}
                              descriptor:desc::id{MPSMatrixDescriptor}]::id{MPSMatrix}
    return obj
end


#
# kernels
#

@objcwrapper MPSKernel <: NSObject

@objcproperties MPSKernel begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
    @autoproperty options::MPSKernelOptions setter=setOptions
end


#
# matrix multiplication
#

@objcwrapper MPSMatrixMultiplication <: MPSKernel

@objcproperties MPSMatrixMultiplication begin
    @autoproperty leftMatrixOrigin::MTLOrigin setter=setLeftMatrixOrigin
    @autoproperty rightMatrixOrigin::MTLOrigin setter=setRightMatrixOrigin
    @autoproperty resultMatrixOrigin::MTLOrigin setter=setResultMatrixOrigin
    @autoproperty batchSize::NSUInteger setter=setBatchSize
    @autoproperty batchStart::NSUInteger setter=setBatchStart
end

function MPSMatrixMultiplication(device, transposeLeft, transposeRight, resultRows,
                                 resultColumns, interiorColumns, alpha, beta)
    kernel = @objc [MPSMatrixMultiplication alloc]::id{MPSMatrixMultiplication}
    obj = MPSMatrixMultiplication(kernel)
    # TODO: release?
    @objc [obj::id{MPSMatrixMultiplication} initWithDevice:device::id{MTLDevice}
                                            transposeLeft:transposeLeft::Bool
                                            transposeRight:transposeRight::Bool
                                            resultRows:resultRows::NSUInteger
                                            resultColumns:resultColumns::NSUInteger
                                            interiorColumns:interiorColumns::NSUInteger
                                            alpha:alpha::Cdouble
                                            beta:beta::Cdouble]::id{MPSMatrixMultiplication}
    return obj
end

function encode!(cmdbuf::MTLCommandBuffer, matmul::MPSMatrixMultiplication, left, right, result)
    @objc [matmul::id{MPSMatrixMultiplication} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                               leftMatrix:left::id{MPSMatrix}
                                               rightMatrix:right::id{MPSMatrix}
                                               resultMatrix:result::id{MPSMatrix}]::Nothing
end

"""
    matMulMPS(a::MtlMatrix, b::MtlMatrix, c::MtlMatrix, alpha=1, beta=1,
              transpose_left=false, transpose_right=false)

Perform `c = alpha * op(a) * beta * op(b) + beta * C`.
"""
function matmul!(c::MtlMatrix, a::MtlMatrix, b::MtlMatrix,
                 alpha::Number=true, beta::Number=true,
                 transpose_a=false, transpose_b=false)
    # NOTE: MPS uses row major, while Julia is col-major. Instead of transposing
    #       the inputs (by passing !transpose_[ab]) and afterwards transposing
    #       the output, we use the property that (AB)ᵀ = BᵀAᵀ
    cols_a = size(a)[2]
    cols_c, rows_c = size(c)

    # Create MPS-compatible matrix from the MtlArrays
    mps_a = MPSMatrix(a)
    mps_b = MPSMatrix(b)
    mps_c = MPSMatrix(c)

    mat_mul_kernel = MPSMatrixMultiplication(current_device(),
                                             transpose_b, transpose_a,
                                             rows_c, cols_c, cols_a,
                                             alpha, beta)


    # Encode and commit matmul kernel
    cmdbuf = MTLCommandBuffer(global_queue(current_device()))
    encode!(cmdbuf, mat_mul_kernel, mps_b, mps_a, mps_c)
    commit!(cmdbuf)

    c
end
