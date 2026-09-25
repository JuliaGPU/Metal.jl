using SparseArrays
using GPUArrays: GPUSparseMatrixCSC

@testset "mtl" begin
    A = sprand(Float64, 10, 8, 0.3)
    dA = mtl(A)
    @test dA isa MtlSparseMatrixCSR{Float32,Int32}
    @test nonzeros(dA) isa MtlVector{Float32,Metal.PrivateStorage}
    @test SparseMatrixCSC(dA) ≈ A

    dA = mtl(A; storage=Metal.SharedStorage)
    @test dA.rowPtr isa MtlVector{Int32,Metal.SharedStorage}
    @test nonzeros(dA) isa MtlVector{Float32,Metal.SharedStorage}

    @test mtl(SparseMatrixCSC{Float16}(A)) isa MtlSparseMatrixCSR{Float16,Int32}
    @test mtl(sparse(Int64[1, 2], Int64[1, 2], Int64[3, 4])) isa MtlSparseMatrixCSR{Int64,Int32}

    x = sprand(Float64, 20, 0.3)
    dx = mtl(x)
    @test dx isa MtlSparseVector{Float32,Int32}
    @test SparseVector(dx) ≈ x
end

@testset "adapt" begin
    # structural adapt keeps the format and types
    A = sprand(Float32, 10, 8, 0.3)
    dA = adapt(MtlArray, A)
    @test dA isa MtlSparseMatrixCSC{Float32,Int64}
    @test SparseMatrixCSC(dA) == A
    dA = adapt(MtlArray{Float32,1,Metal.SharedStorage}, A)
    @test dA.colPtr isa MtlVector{Int64,Metal.SharedStorage}
    @test adapt(Array, dA) == A
end
