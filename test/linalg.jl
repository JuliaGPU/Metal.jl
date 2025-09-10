using LinearAlgebra, ScopedValues

if MPS.is_supported(device())

@testset "matmul algorithm selection" begin
    # test that unsupported configurations error properly
    N = 20
    function test_matmul(inT, outT; vec_b=false, alg=:auto)
        a = inT <: Integer ? inT.(rand(-5:5, N,N)) : rand(inT, N, N)

        bdims = vec_b ? (N,) : (N, N)
        b = inT <: Integer ? inT.(rand(-5:5, bdims)) : rand(inT, bdims)

        ma = MtlArray(a)
        mb = MtlArray(b)
        mc = fill!(similar(mb, outT), zero(outT))

        @with (Metal.matmul_alg => alg) mul!(mc,ma,mb)

        return all((outT.(a)*outT.(b)) .≈ Array(mc))
    end

    for vec_b in (true, false)
        @testset let vec_b = vec_b
        # Unsupported for MPS and MPSGraph
        @test_throws "Matrix-$(vec_b ? "Vector" : "Matrix") multiplication algorithm `:MPS`" test_matmul(Int8, Int16; vec_b, alg=:MPS)
        @test_throws "Matrix-$(vec_b ? "Vector" : "Matrix") multiplication algorithm `:MPSGraph`" test_matmul(Int8, Int16; vec_b, alg=:MPSGraph)

        # Invalid algorithm Symbol
        @test_throws ":bad is not a valid matmul algorithm." test_matmul(Int8, Int16; vec_b, alg=:bad)
        @test_throws ":bad is not a valid matmul algorithm." test_matmul(Float16, Float16; vec_b, alg=:bad)

        # :auto
        @test test_matmul(Int32, Int32; vec_b)     # fallback to GPUArrays
        @test test_matmul(Int8, Float32; vec_b)    # should use MPS
        Metal.macos_version() >= v"14" && @test test_matmul(Float16, Float32; vec_b) # should use MPSGraph on M1/M2

        # :MPS
        mpsInT = vec_b ? Float32 : Int16
        @test test_matmul(mpsInT, Float32; vec_b, alg=:MPS)
        Metal.macos_version() >= v"14" && @test test_matmul(Float16, Float32; vec_b, alg=:MPS)

        # :MPSGraph
        @test test_matmul(Int8, Float32; vec_b, alg=:MPSGraph)
        Metal.macos_version() >= v"14" && @test test_matmul(Float16, Float32; vec_b, alg=:MPSGraph)

        # :GPUArrays
        @test test_matmul(Int32, Int32; vec_b, alg=:GPUArrays)
        @test test_matmul(Int8, Float32; vec_b, alg=:GPUArrays)
        Metal.macos_version() >= v"14" && @test test_matmul(Float16, Float32; vec_b, alg=:GPUArrays)
        end
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

@testset "transpose" begin
    A = MtlMatrix(rand(Float32, 0, 1024))
    B = Metal.zeros(Float32, 1024, 0)

    # Issue #656
    @test isempty(transpose!(B, A))
end

end
