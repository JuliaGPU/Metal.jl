using LinearAlgebra, ScopedValues

if MPS.is_supported(device())

@testset "matmul algorithm selection" begin
    # test that unsupported configurations error properly
    N = 20
    function test_matmul(inT, outT; vec_b=false, alg=:auto)
        a = MtlArray(rand(inT, N, N))
        b = MtlArray(rand(inT, vec_b ? (N,) : (N, N)))
        c = fill!(similar(b, outT), zero(outT))

        @with (Metal.matmul_alg => alg) mul!(c,a,b)
    end

    # Unsupported for MPS and MPSGraph
    for vec_b in (true, false)
        @test_throws "Matrix multiplication algorithm `:MPS`" test_matmul(Int8, Int16; vec_b, alg=:MPS)
        @test_throws "Matrix multiplication algorithm `:MPSGraph`" test_matmul(Int8, Int16; vec_b, alg=:MPSGraph)

        # Invalid algorithm Symbol
        @test_throws ":bad is not a valid matmul algorithm." test_matmul(Int8, Int16; vec_b, alg=:bad)
        @test_throws ":bad is not a valid matmul algorithm." test_matmul(Float16, Float16; vec_b, alg=:bad)
    end
end

@testset "test matrix vector multiplication of views" begin
    N = 20

    a = rand(Float32, N, N)
    b = rand(Float32, N)
    c = a * b

    mtl_a = mtl(a)
    mtl_b = mtl(b)
    mtl_c = mtl_a * mtl_b

    @test Array(mtl_c) ≈ c

    view_a = @view a[:, 10:end]
    view_b = @view b[10:end]

    mtl_view_a = @view mtl_a[:, 10:end]
    mtl_view_b = @view mtl_b[10:end]

    mtl_view_c = mtl_view_a * mtl_view_b
    view_c = view_a * view_b

    @test Array(mtl_view_c) ≈ view_c
end

using Metal: storagemode
@testset "decompositions" begin
    A = MtlMatrix(rand(Float32, 1024, 1024))
    lua = lu(A)
    @test lua.L * lua.U ≈ MtlMatrix(lua.P) * A

    A = MtlMatrix(rand(Float32, 1024, 512))
    lua = lu(A)
    @test lua.L * lua.U ≈ MtlMatrix(lua.P) * A

    A = MtlMatrix(rand(Float32, 512, 1024))
    lua = lu(A)
    @test lua.L * lua.U ≈ MtlMatrix(lua.P) * A

    a = rand(Float32, 1024, 1024)
    A = MtlMatrix(a)
    B = MtlMatrix(a)
    lua = lu!(A)
    @test lua.L * lua.U ≈ MtlMatrix(lua.P) * B

    A = MtlMatrix{Float32}([1 2; 0 0])
    @test_throws SingularException lu(A)

    altStorage = Metal.DefaultStorageMode != Metal.PrivateStorage ? Metal.PrivateStorage : Metal.SharedStorage
    A = MtlMatrix{Float32, altStorage}(rand(Float32, 1024, 1024))
    lua = lu(A)
    @test storagemode(lua.factors) == storagemode(lua.ipiv) == storagemode(A)
    lua = lu!(A)
    @test storagemode(lua.factors) == storagemode(lua.ipiv) == storagemode(A)
end

end
