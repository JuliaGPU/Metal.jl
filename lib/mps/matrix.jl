
# MPS Data Type Bitfields
const MPSDataTypeComplexBit = UInt32(0x01000000)
const MPSDataTypeFloatBit = UInt32(0x10000000)
const MPSDataTypeSignedBit = UInt32(0x20000000)
const MPSDataTypeNormalizedBit = UInt32(0x40000000)
const MPSDataTypeAlternateEncodingBit = UInt32(0x80000000)

# Mapping from Julia types to the Performance Shader bitfields
const jl_typ_to_mps = Dict{DataType,UInt32}(
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

const MPTMatrix = Ptr{cmt.MtMPSMatrix}

mutable struct MpsMatrix
    handle::MPTMatrix
end

"""
    MPSMatrix(arr::MtlMatrix)

Metal matrix representation used in Performance Shaders.

Note that this results in a transposed view of the input,
as Metal stores matrices row-major instead of column-major.
"""
function MPSMatrix(arr::MtlMatrix{T}) where T
    n_cols, n_rows = size(arr)
    desc = cmt.mtNewMatrixDescriptorWithRows(n_rows, n_cols, sizeof(T)*n_cols,
                                             jl_typ_to_mps[T])
    return cmt.mtNewMPSMatrixInitWithBuffer(arr.buffer, desc)
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

    mat_mul_kernel =
        cmt.mtNewMPSMatrixMultiplication(current_device(),
                                         transpose_b, transpose_a,
                                         rows_c, cols_c, cols_a,
                                         alpha, beta)

    # Encode and commit matmul kernel
    cmdbuf = MtlCommandBuffer(global_queue(current_device()))
    cmt.mtMPSMatMulEncodeToCommandBuffer(mat_mul_kernel, cmdbuf, mps_b, mps_a, mps_c)
    commit!(cmdbuf)

    c
end
