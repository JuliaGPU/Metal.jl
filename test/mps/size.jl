# ## size

@testset "size" begin
    dim1 = rand()
    dim2 = rand()
    dim3 = rand()

    @test MPS.MPSSize(dim1) == MPS.MPSSize((dim1,))
    @test MPS.MPSSize(dim1,dim2) == MPS.MPSSize((dim1,dim2))
    @test MPS.MPSSize(dim1,dim2,dim3) == MPS.MPSSize((dim1,dim2,dim3))
end

@testset "origin" begin
    dim1 = rand()
    dim2 = rand()
    dim3 = rand()

    orig = MPS.MPSOrigin(dim1,dim2,dim3)
    @test orig.x == dim1
    @test orig.y == dim2
    @test orig.z == dim3
end

@testset "offset" begin
    dim1 = rand(Int)
    dim2 = rand(Int)
    dim3 = rand(Int)

    off = MPS.MPSOffset(dim1,dim2,dim3)
    @test off.x == dim1
    @test off.y == dim2
    @test off.z == dim3
end
