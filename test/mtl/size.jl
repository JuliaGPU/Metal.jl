@testset "size" begin
    dim1 = rand(UInt64)
    dim2 = rand(UInt64)
    dim3 = rand(UInt64)

    @test MTL.MTLSize(dim1) == MTL.MTLSize((dim1,))
    @test MTL.MTLSize(dim1, dim2) == MTL.MTLSize((dim1, dim2))
    @test MTL.MTLSize(dim1, dim2, dim3) == MTL.MTLSize((dim1, dim2, dim3))
end

@testset "origin" begin
    dim1 = rand(UInt64)
    dim2 = rand(UInt64)
    dim3 = rand(UInt64)

    orig1 = MTL.MTLOrigin(dim1, dim2, dim3)
    @test orig1.x == dim1
    @test orig1.y == dim2
    @test orig1.z == dim3

    orig2 = MTL.MTLOrigin(dim1, dim2)
    @test orig2.x == dim1
    @test orig2.y == dim2
    @test orig2.z == 0

    orig3 = MTL.MTLOrigin(dim1)
    @test orig3.x == dim1
    @test orig3.y == 0
    @test orig3.z == 0
end

@testset "region" begin
    reg1 = MTL.MTLRegion()
    @test reg1.origin isa MTL.MTLOrigin
    @test reg1.size isa MTL.MTLSize

    reg2 = MTL.MTLRegion(MTL.MTLOrigin())
    @test reg1.origin isa MTL.MTLOrigin
    @test reg1.size isa MTL.MTLSize
end
