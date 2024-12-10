@testset "size.jl" begin
@testset "size" begin
    dim1 = rand(UInt64)
    dim2 = rand(UInt64)
    dim3 = rand(UInt64)

    @test MTL.MTLSize(dim1) == MTL.MTLSize((dim1,))
    @test MTL.MTLSize(dim1,dim2) == MTL.MTLSize((dim1,dim2))
    @test MTL.MTLSize(dim1,dim2,dim3) == MTL.MTLSize((dim1,dim2,dim3))
end

@testset "origin" begin
    dim1 = rand(UInt64)
    dim2 = rand(UInt64)
    dim3 = rand(UInt64)

    orig = MTL.MTLOrigin(dim1,dim2,dim3)
    @test orig.x == dim1
    @test orig.y == dim2
    @test orig.z == dim3
end

@testset "region" begin
    reg = MTL.MTLRegion()
    @test reg.origin isa MTL.MTLOrigin
    @test reg.size isa MTL.MTLSize
end
end
