#
# matrix descriptor
#
using .MTL: MTLOrigin
using .MPS: MPSMatrixDescriptor, MPSDataType
@testset "MPSMatrixDescriptor" begin
    T = Float32
    DT = convert(MPSDataType, T)
    rows = 2
    cols = 3
    rowBytes = sizeof(T) * cols
    mats = 4

    desc1 = MPSMatrixDescriptor(rows, cols, rowBytes, T)
    @test desc1 isa MPSMatrixDescriptor
    @test desc1.rows == rows
    @test desc1.columns == cols
    @test desc1.rowBytes == rowBytes
    @test desc1.matrices == 1
    @test desc1.dataType == DT
    @test desc1.matrixBytes == rowBytes * rows

    desc2 = MPSMatrixDescriptor(rows, cols, mats, rowBytes, rowBytes * rows, T)
    @test desc2 isa MPSMatrixDescriptor
    @test desc2.rows == rows
    @test desc2.columns == cols
    @test desc2.rowBytes == rowBytes
    @test desc2.matrices == mats
    @test desc2.dataType == DT
    @test desc2.matrixBytes == rowBytes * rows
end


#
# matrix object
#

using .MPS: MPSMatrix
@testset "MPSMatrix" begin
    dev = device()
    T = Float32
    DT = convert(MPSDataType, T)
    rows = 2
    cols = 3
    rowBytes = sizeof(T) * cols
    mats = 4

    desc = MPSMatrixDescriptor(rows, cols, rowBytes, T)
    devmat = MPSMatrix(dev, desc)
    @test devmat isa MPSMatrix
    @test devmat.device == dev
    @test devmat.rows == rows
    @test devmat.columns == cols
    @test devmat.rowBytes == rowBytes
    @test devmat.matrices == 1
    @test devmat.dataType == DT
    @test devmat.matrixBytes == rowBytes * rows
    @test devmat.offset == 0

    mat = MtlMatrix{T}(undef, rows, cols)
    acols, arows = size(mat)
    arowBytes = sizeof(T) * acols
    abufmat = MPSMatrix(mat)
    @test abufmat isa MPSMatrix
    @test abufmat.device == dev
    @test abufmat.rows == arows
    @test abufmat.columns == acols
    @test abufmat.rowBytes == arowBytes
    @test abufmat.matrices == 1
    @test abufmat.dataType == DT
    @test abufmat.matrixBytes == arowBytes * arows
    @test abufmat.offset == 0
    @test abufmat.data == mat.data[]

    vmat = @view mat[:, 2:3]
    vcols, vrows = size(vmat)
    vrowBytes = sizeof(T) * vcols
    vbufmat = MPSMatrix(vmat)
    @test vbufmat isa MPSMatrix
    @test vbufmat.device == dev
    @test vbufmat.rows == vrows
    @test vbufmat.columns == vcols
    @test vbufmat.rowBytes == vrowBytes
    @test vbufmat.matrices == 1
    @test vbufmat.dataType == DT
    @test vbufmat.matrixBytes == vrowBytes * vrows
    @test vbufmat.offset == vmat.offset * sizeof(T)
    @test vbufmat.data == vmat.data[]

    arr = MtlArray{T,3}(undef, rows, cols, mats)
    mcols, mrows, mmats = size(arr)
    mrowBytes = sizeof(T) * mcols
    mpsmat = MPSMatrix(mat)
    @test mpsmat isa MPSMatrix
    @test mpsmat.device == dev
    @test mpsmat.rows == mrows
    @test mpsmat.columns == mcols
    @test mpsmat.rowBytes == mrowBytes
    @test mpsmat.matrices == 1
    @test mpsmat.dataType == DT
    @test mpsmat.matrixBytes == mrowBytes * mrows
    @test mpsmat.offset == 0
    @test mpsmat.data == mat.data[]

    vec = MtlVector{T}(undef, rows)
    veccols, vecrows = length(vec), 1
    vecrowBytes = sizeof(T)*veccols
    vmpsmat = MPSMatrix(vec)
    @test vmpsmat isa MPSMatrix
    @test vmpsmat.device == dev
    @test vmpsmat.rows == vecrows
    @test vmpsmat.columns == veccols
    @test vmpsmat.rowBytes == vecrowBytes
    @test vmpsmat.matrices == 1
    @test vmpsmat.dataType == DT
    @test vmpsmat.matrixBytes == vecrowBytes*vecrows
    @test vmpsmat.offset == 0
    @test vmpsmat.data == vec.data[]
end


#
# matrix multiplication
#

using .MPS: MPSMatrixMultiplication
@testset "MPSMatrixMultiplication" begin
    T = Float32
    DT = convert(MPSDataType, T)
    rows_a = 3
    cols_a = 3
    rows_c = 3
    cols_c = 3
    transpose_a = false
    transpose_b = false
    alpha = 1
    beta = 0

    mat_mul = MPSMatrixMultiplication(device(),
                                        transpose_b, transpose_a,
                                        rows_c, cols_c, cols_a,
                                        alpha, beta)

    @test mat_mul isa MPSMatrixMultiplication
    @test mat_mul.leftMatrixOrigin == MTLOrigin(0, 0, 0)
    @test mat_mul.rightMatrixOrigin == MTLOrigin(0, 0, 0)
    @test mat_mul.resultMatrixOrigin == MTLOrigin(0, 0, 0)
    @test mat_mul.batchSize == typemax(UInt)
    @test mat_mul.batchStart == typemin(UInt)

    @test copy(mat_mul) isa MPSMatrixMultiplication
end


using .MPS: MPSMatrixFindTopK
@testset "MPSMatrixFindTopK" begin
    off = 2
    k = 5
    rows = 2
    cols = 3

    topk = MPSMatrixFindTopK(device(), k)
    topk.indexOffset = off
    topk.sourceColumns = cols
    topk.sourceRows = rows

    @test topk isa MPSMatrixFindTopK
    @test topk.indexOffset == off
    @test topk.numberOfTopKValues == k
    @test topk.sourceColumns == cols
    @test topk.sourceRows == rows
end

# Ensure that the function does not error
@testset "MPSMatrixRandom sync state" begin
    cmdbuf = MTL.MTLCommandBuffer(global_queue(device()))
    rng = MPS.MPSMatrixRandomMTGP32(device())
    @test isnothing(MPS.synchronize_state(rng, cmdbuf))
end
