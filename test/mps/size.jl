# ## size

@testset "size" begin
    siz1 = MPS.MPSSize()
    @test siz1.width == 0
    @test siz1.height == 0
    @test siz1.depth == 0

    dim1 = rand()
    dim2 = rand()
    dim3 = rand()

    @test MPS.MPSSize(dim1) == MPS.MPSSize((dim1,))
    @test MPS.MPSSize(dim1, dim2) == MPS.MPSSize((dim1, dim2))
    @test MPS.MPSSize(dim1, dim2, dim3) == MPS.MPSSize((dim1, dim2, dim3))
end

@testset "origin" begin
    dim1 = rand()
    dim2 = rand()
    dim3 = rand()

    orig1 = MPS.MPSOrigin(dim1, dim2, dim3)
    @test orig1.x == dim1
    @test orig1.y == dim2
    @test orig1.z == dim3

    orig2 = MPS.MPSOrigin(dim1, dim2)
    @test orig2.x == dim1
    @test orig2.y == dim2
    @test orig2.z == 0.0

    orig3 = MPS.MPSOrigin(dim1)
    @test orig3.x == dim1
    @test orig3.y == 0.0
    @test orig3.z == 0.0

    orig4 = MPS.MPSOrigin()
    @test orig4.x == 0.0
    @test orig4.y == 0.0
    @test orig4.z == 0.0
end

@testset "offset" begin
    dim1 = rand(Int)
    dim2 = rand(Int)
    dim3 = rand(Int)

    off1 = MPS.MPSOffset(dim1, dim2, dim3)
    @test off1.x == dim1
    @test off1.y == dim2
    @test off1.z == dim3

    off2 = MPS.MPSOffset(dim1, dim2)
    @test off2.x == dim1
    @test off2.y == dim2
    @test off2.z == 0

    off3 = MPS.MPSOffset(dim1)
    @test off3.x == dim1
    @test off3.y == 0
    @test off3.z == 0

    off4 = MPS.MPSOffset()
    @test off4.x == 0
    @test off4.y == 0
    @test off4.z == 0
end

@testset "region" begin
    reg1 = MPS.MPSRegion()
    @test reg1.origin isa MPS.MPSOrigin
    @test reg1.size isa MPS.MPSSize

    reg2 = MPS.MPSRegion(MPS.MPSOrigin())
    @test reg1.origin isa MPS.MPSOrigin
    @test reg1.size isa MPS.MPSSize
end
