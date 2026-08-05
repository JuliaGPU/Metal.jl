using LinearAlgebra
using SparseArrays

@testset "sparse arrays" begin
    @testset "construction and conversion" begin
        v = SparseVector{Float32,Int32}(6, Int32[2, 5], Float32[3, 0])
        dv = MtlSparseVector(v)
        @test dv isa MtlSparseVector{Float32,Int32,Metal.DefaultStorageMode}
        @test SparseVector(dv) == v
        @test nnz(dv) == 2
        @test eltype(SparseArrays.nonzeroinds(dv)) == Int32

        A = SparseMatrixCSC{Float32,Int32}(sparse(Float32[1 0 2; 0 0 0; 3 4 0]))
        dcsc = MtlSparseMatrixCSC(A)
        dcsr = MtlSparseMatrixCSR(A)
        @test dcsc isa MtlSparseMatrixCSC{Float32,Int32,Metal.DefaultStorageMode}
        @test dcsr isa MtlSparseMatrixCSR{Float32,Int32,Metal.DefaultStorageMode}
        @test SparseMatrixCSC(dcsc) == A
        @test SparseMatrixCSC(dcsr) == A
        @test SparseMatrixCSC(MtlSparseMatrixCSC(dcsr)) == A
        @test SparseMatrixCSC(MtlSparseMatrixCSR(dcsc)) == A
        @test Array(MtlArray(dv)) == Array(v)
        @test Array(MtlArray(dcsc)) == Array(A)
        @test Array(MtlArray(dcsr)) == Array(A)
        @test Metal.storagemode(MtlArray(dcsc)) == Metal.storagemode(dcsc)
        @test sparse(dcsc; fmt = :csc) === dcsc
        @test sparse(dcsr; fmt = :csr) === dcsr
        @test SparseMatrixCSC(sparse(dcsc; fmt = :csr)) == A
        @test SparseMatrixCSC(sparse(dcsr; fmt = :csc)) == A
        @test eltype(dcsc.colPtr) == Int32
        @test eltype(dcsr.rowPtr) == Int32

        @test MtlSparseMatrixCSC(dcsc) === dcsc
        @test MtlSparseMatrixCSR(dcsr) === dcsr
        @test MtlSparseVector(dv) === dv

        component_csc = MtlSparseMatrixCSC(
            copy(dcsc.colPtr),
            copy(dcsc.rowVal),
            copy(dcsc.nzVal),
            size(dcsc),
        )
        component_csr = MtlSparseMatrixCSR(
            copy(dcsr.rowPtr),
            copy(dcsr.colVal),
            copy(dcsr.nzVal),
            size(dcsr),
        )
        component_v = MtlSparseVector(copy(dv.iPtr), copy(dv.nzVal), length(dv))
        @test SparseMatrixCSC(component_csc) == A
        @test SparseMatrixCSC(component_csr) == A
        @test SparseVector(component_v) == v

        @test SparseMatrixCSC(MtlSparseMatrixCSC(transpose(A))) == transpose(A)
        @test SparseMatrixCSC(MtlSparseMatrixCSR(adjoint(A))) == adjoint(A)

        dense = MtlArray(Array(A))
        @test sparse(dense) isa MtlSparseMatrixCSC
        @test sparse(dense; fmt = :csr) isa MtlSparseMatrixCSR
        @test SparseMatrixCSC(sparse(dense)) == A
        @test SparseMatrixCSC(sparse(dense; fmt = :csr)) == A
        @test eltype(sparse(dense).colPtr) == Int64
        @test_throws ArgumentError sparse(dense; fmt = :coo)

        dense_vector = MtlVector{Float32,Metal.SharedStorage}(Float32[0, 2, 0, 3])
        sparse_vector = sparse(dense_vector)
        @test SparseVector(sparse_vector) == sparsevec(Float32[0, 2, 0, 3])
        @test is_shared(sparse_vector)

        stored_zeros = SparseMatrixCSC(2, 2, Int32[1, 2, 3], Int32[1, 2], Float32[0, 2])
        @test nnz(MtlSparseMatrixCSC(stored_zeros)) == nnz(stored_zeros)
        @test nonzeros(SparseMatrixCSC(MtlSparseMatrixCSR(stored_zeros))) ==
              nonzeros(stored_zeros)

        shared_csc = MtlSparseMatrixCSC{Float32,Int32,Metal.SharedStorage}(A)
        private_csr = MtlSparseMatrixCSR{ComplexF32,Int64,Metal.PrivateStorage}(shared_csc)
        @test SparseMatrixCSC(private_csr) == ComplexF32.(A)
        @test is_private(private_csr)
        @test eltype(private_csr.rowPtr) == Int64
        @test is_shared(MtlArray(shared_csc))
        @test Array(MtlArray{ComplexF32}(shared_csc)) == ComplexF32.(Array(A))
        @test_throws DimensionMismatch MtlArray{Float32,1}(shared_csc)

        empty = spzeros(Float32, 0, 4)
        @test size(MtlSparseMatrixCSC(empty)) == (0, 4)
        @test size(MtlSparseMatrixCSR(empty)) == (0, 4)
        @test nnz(MtlSparseMatrixCSR(empty)) == 0
        empty_dense = MtlArray(zeros(Float32, 0, 4))
        @test SparseMatrixCSC(sparse(empty_dense)) == empty
        @test SparseMatrixCSC(sparse(empty_dense; fmt = :csr)) == empty

        @test occursin("MtlSparseMatrixCSC", sprint(show, MIME"text/plain"(), dcsc))
        @test !isempty(sprint(show, MIME"text/plain"(), dv))
    end

    @testset "adaptation and storage" begin
        A64 = sparse([1.0 0.0; 0.0 2.0])
        v64 = sparsevec([1.0, 0.0, 2.0])
        @test mtl(A64) isa MtlSparseMatrixCSC{Float32,Int64,Metal.DefaultStorageMode}
        @test mtl(v64) isa MtlSparseVector{Float32,Int64,Metal.DefaultStorageMode}

        A = SparseMatrixCSC{Float32,Int32}(A64)
        shared_csc = MtlSparseMatrixCSC{Float32,Int32,Metal.SharedStorage}(A)
        shared_csr = MtlSparseMatrixCSR{Float32,Int32,Metal.SharedStorage}(A)
        private_csc = MtlSparseMatrixCSC{Float32,Int32,Metal.PrivateStorage}(A)
        @test is_shared(shared_csc)
        @test is_shared(shared_csr)
        @test is_private(private_csc)
        @test mtl(shared_csc; storage = Metal.SharedStorage) === shared_csc
        @test mtl(shared_csr; storage = Metal.SharedStorage) === shared_csr
        @test is_shared(mtl(private_csc; storage = Metal.SharedStorage))
        @test Metal.storagemode(similar(shared_csc)) == Metal.SharedStorage
        @test Metal.storagemode(similar(shared_csr, ComplexF32)) == Metal.SharedStorage
        @test size(similar(shared_csc, Float32, (3, 4))) == (3, 4)
        @test size(similar(shared_csr, (3, 4))) == (3, 4)
        @test Metal.storagemode(similar(shared_csc, Float32, 3, 4)) == Metal.SharedStorage
        @test Metal.storagemode(similar(shared_csr, Float32, 3, 4)) == Metal.SharedStorage

        complex_int = sparse(Complex{Int32}[1+2im 0; 0 3-im])
        dcomplex_int = MtlSparseMatrixCSR(complex_int)
        @test mapreduce(abs, +, dcomplex_int) ≈ mapreduce(abs, +, complex_int)
        @test norm(dcomplex_int, Inf) ≈ norm(complex_int, Inf)
    end
end
