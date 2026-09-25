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
    @test adapt(MtlSparseMatrixCSR{Float32,Int32}, A) isa MtlSparseMatrixCSR{Float32,Int32}
end

@testset "constructors" begin
    A = sprand(Float32, 10, 8, 0.3)
    for S in (MtlSparseMatrixCSR, MtlSparseMatrixCSC, MtlSparseMatrixCOO)
        dA = S(A)
        @test dA isa S{Float32,Int64}
        @test SparseMatrixCSC(dA) == A
        # explicit element types convert on the host, so Float64 inputs work
        dA = S{Float32,Int32}(SparseMatrixCSC{Float64}(A))
        @test dA isa S{Float32,Int32}
        @test SparseMatrixCSC(dA) == A
        @test S{Float32}(SparseMatrixCSC{Float64}(A)) isa S{Float32,Int64}
        # from dense arrays and other formats
        @test SparseMatrixCSC(S(MtlArray(Matrix(A)))) == A
        @test SparseMatrixCSC(S(mtl(A))) == A
        # densify
        @test MtlArray(dA) isa MtlMatrix{Float32}
        @test Array(MtlArray(dA)) == Matrix(A)
        @test MtlArray{Float16}(dA) isa MtlMatrix{Float16}
        @test MtlArray{Float32,2,Metal.SharedStorage}(dA) isa MtlMatrix{Float32,Metal.SharedStorage}
    end
    x = sprand(Float32, 20, 0.3)
    @test MtlSparseVector(x) isa MtlSparseVector{Float32,Int64}
    @test MtlSparseVector{Float32,Int32}(SparseVector{Float64}(x)) isa MtlSparseVector{Float32,Int32}
    @test Array(MtlArray(MtlSparseVector(x))) == Vector(x)
end
