#
# vector descriptor
#

using .MPS: MPSVectorDescriptor, MPSDataType
@testset "MPSVectorDescriptor" begin
    T = Float32
    DT = convert(MPSDataType, T)
    len = 2
    vectorBytes = sizeof(T) * len
    vecs = 4

    desc1 = MPSVectorDescriptor(len, T)
    @test desc1 isa MPSVectorDescriptor
    @test desc1.length == len
    @test desc1.vectorBytes == vectorBytes
    @test desc1.vectors == 1
    @test desc1.dataType == DT

    desc2 = MPSVectorDescriptor(len, vecs, vectorBytes, T)
    @test desc2 isa MPSVectorDescriptor
    @test desc2.length == len
    @test desc2.vectorBytes == vectorBytes
    @test desc2.vectors == vecs
    @test desc2.dataType == DT
end


#
# matrix object
#

using .MPS: MPSVector
@testset "MPSVector" begin
    dev = device()
    T = Float32
    DT = convert(MPSDataType, T)
    len = 4
    vectorBytes = sizeof(T) * len

    desc = MPSVectorDescriptor(len, T)
    devmat = MPSVector(dev, desc)
    @test devmat isa MPSVector
    @test devmat.device == dev
    @test devmat.length == len
    @test devmat.vectorBytes == vectorBytes
    @test devmat.vectors == 1
    @test devmat.dataType == DT
    @test devmat.offset == 0

    vec = MtlVector{T}(undef, len)
    abufvec = MPSVector(vec)
    @test abufvec isa MPSVector
    @test abufvec.device == dev
    @test abufvec.length == len
    @test abufvec.vectorBytes == vectorBytes
    @test abufvec.vectors == 1
    @test abufvec.dataType == DT
    @test abufvec.offset == 0
    @test abufvec.data == vec.data[]

    vvec = @view vec[2:4]
    vlen = length(vvec)
    vvectorBytes = sizeof(T) * vlen
    vbufmat = MPSVector(vvec)
    @test vbufmat isa MPSVector
    @test vbufmat.device == dev
    @test vbufmat.length == vlen
    @test vbufmat.vectorBytes == vvectorBytes
    @test vbufmat.vectors == 1
    @test vbufmat.dataType == DT
    @test vbufmat.offset == vvec.offset * sizeof(T)
    @test vbufmat.data == vvec.data[]
end


#
# matrix multiplication
#

using .MPS: MPSMatrixVectorMultiplication
@testset "MPSMatrixVectorMultiplication" begin
    T = Float32
    DT = convert(MPSDataType, T)
    rows_a = 3
    cols_a = 3
    rows_c = 3
    cols_c = 3
    trans = false
    alpha = 1
    beta = 0

    matvec_mul = MPSMatrixVectorMultiplication(device(), trans,
                                                      rows_c, cols_a,
                                                      alpha, beta)

    @test matvec_mul isa MPSMatrixVectorMultiplication
end
