#
# matrix descriptor
#
using Metal,Test;
using .MPS: MPSNDArrayDescriptor, MPSDataType, lengthOfDimension
@testset "MPSNDArrayDescriptor" begin
    T = Float32
    DT = convert(MPSDataType, T)
    rows = 2
    cols = 3
    rowBytes = sizeof(T) * cols
    mats = 4

    desc1 = MPSNDArrayDescriptor(T, 5,4,3,2,1)
    @test desc1 isa MPSNDArrayDescriptor
    @test desc1.dataType == DT
    @test desc1.preferPackedRows == false
    @test desc1.numberOfDimensions == 5

    @test lengthOfDimension(desc1,4) == 5
    @test lengthOfDimension(desc1,3) == 4
    MPS.transposeDimensionwithDimension(desc1, 3,4)
    @test lengthOfDimension(desc1,4) == 4
    @test lengthOfDimension(desc1,3) == 5

    desc2 = MPSNDArrayDescriptor(T, (4,3,2,1))
    @test desc2 isa MPSNDArrayDescriptor
    @test desc2.dataType == DT
    @test desc2.numberOfDimensions == 4
    desc2.numberOfDimensions = 6
    @test desc2.numberOfDimensions == 6
    desc2.preferPackedRows = true
    @test desc2.preferPackedRows == true

end


#
# matrix object
#

using .MPS: MPSNDArray
@testset "MPSNDArray" begin
    dev = device()
    T1 = Int
    DT1 = convert(MPSDataType, T1)

    desc1 = MPSNDArrayDescriptor(T1, 5,4,3,2,1)
    ndarr1 = MPSNDArray(dev, desc1)
    @test ndarr1 isa MPSNDArray
    @test ndarr1.dataType == DT1
    @test ndarr1.dataTypeSize == 8
    @test ndarr1.device == dev
    ndarr1.label = "Test1"
    @test ndarr1.label == "Test1"
    @test ndarr1.numberOfDimensions == 5
    @test ndarr1.parent === nothing
    @test ndarr1.descriptor isa MPSNDArrayDescriptor
    @test ndarr1.resourceSize isa UInt
    @test ndarr1.userBuffer === nothing

    ndarr2 = MPSNDArray(dev, 4)
    @test ndarr2 isa MPSNDArray
    @test ndarr2.dataType == convert(MPSDataType, Float32)
    @test ndarr2.dataTypeSize == 4
    @test ndarr2.device == dev
    ndarr2.label = "Test2"
    @test ndarr2.label == "Test2"
    @test ndarr2.numberOfDimensions == 1
    @test ndarr2.parent === nothing
    @test ndarr2.descriptor isa MPSNDArrayDescriptor
    @test ndarr2.resourceSize isa UInt
    @test ndarr2.userBuffer === nothing

    arr3 = MtlArray(ones(Float16, 2,3,8))
    ndarr3 = MPSNDArray(arr3)

    arr4 = MtlArray(arr3)
    @test arr3 == arr4

    arr5 = MtlArray(ones(Float16, 2,3,4))
    @test_throws AssertionError MPSNDArray(arr5)

end


#
# matrix multiplication
#

using .MPS: MPSNDArrayMatrixMultiplication
@testset "MPSNDArrayMatrixMultiplication" begin
    alpha = 1
    beta = 0

    ndarray_mat_mul = MPSNDArrayMatrixMultiplication(device(), 2)

    @test ndarray_mat_mul isa MPSNDArrayMatrixMultiplication

    @test ndarray_mat_mul.alpha === 1.0
    @test ndarray_mat_mul.beta === 1.0
    ndarray_mat_mul.alpha = 0.4
    ndarray_mat_mul.beta = 0.6
    @test ndarray_mat_mul.alpha === 0.4
    @test ndarray_mat_mul.beta === 0.6
end
