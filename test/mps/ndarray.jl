#
# matrix descriptor
#
using Metal,Test;
using .MPS: MPSNDArrayDescriptor, MPSDataType, lengthOfDimension, descriptor, resourceSize
@static if Metal.macos_version() >= v"15"
    using .MPS: userBuffer
end

@testset "MPSNDArrayDescriptor" begin
    T = Float32
    DT = convert(MPSDataType, T)

    desc1 = MPSNDArrayDescriptor(T,1,2,3,4,5)
    @test desc1 isa MPSNDArrayDescriptor
    @test desc1.dataType == DT
    @test desc1.numberOfDimensions == 5

    @test lengthOfDimension(desc1,4) == 5
    @test lengthOfDimension(desc1,3) == 4
    MPS.transposeDimensionwithDimension(desc1, 3,4)
    @test lengthOfDimension(desc1,4) == 4
    @test lengthOfDimension(desc1,3) == 5

    desc2 = MPSNDArrayDescriptor(T, (1,2,3,4))
    @test desc2 isa MPSNDArrayDescriptor
    @test desc2.dataType == DT
    @test desc2.numberOfDimensions == 4
    desc2.numberOfDimensions = 6
    @test desc2.numberOfDimensions == 6

    @static if Metal.macos_version() >= v"15"
        @test desc1.preferPackedRows == false

        desc2.preferPackedRows = true
        @test desc2.preferPackedRows == true
    end
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
    @test descriptor(ndarr1) isa MPSNDArrayDescriptor
    @test resourceSize(ndarr1) isa UInt
    @test size(ndarr1) == (5,4,3,2,1)

    ndarr2 = MPSNDArray(dev, 4)
    @test ndarr2 isa MPSNDArray
    @test ndarr2.dataType == convert(MPSDataType, Float32)
    @test ndarr2.dataTypeSize == 4
    @test ndarr2.device == dev
    ndarr2.label = "Test2"
    @test ndarr2.label == "Test2"
    @test ndarr2.numberOfDimensions == 1
    @test ndarr2.parent === nothing
    @test descriptor(ndarr2) isa MPSNDArrayDescriptor
    @test resourceSize(ndarr2) isa UInt

    arr3 = MtlArray(ones(Float16, 2,3,4))
    @test_throws "First dimension of input MtlArray must have a byte size divisible by 16" MPSNDArray(arr3)

    arr4 = MtlArray(ones(Float16, 8,3,2))

    @static if Metal.macos_version() >= v"15"
        @test userBuffer(ndarr1) === nothing
        @test userBuffer(ndarr2) === nothing

        ndarr4 = MPSNDArray(arr4)

        arr5 = MtlArray(arr4)
        @test arr4 == arr5
    else
        @test_throws "Creating an MPSNDArray that shares data with user-provided MTLBuffer is only supported in macOS v15+" MPSNDArray(arr4)
    end
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
