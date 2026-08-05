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

    @testset "sparse matrix-vector multiplication" begin
        function check_spmv(A, x, alpha, beta, y0; storage = Metal.DefaultStorageMode)
            csr = MtlSparseMatrixCSR{eltype(A),SparseArrays.indtype(A),storage}(A)
            dx = MtlVector{eltype(x),storage}(x)
            expected = alpha .* (A * x) .+ beta .* y0

            dy = MtlVector{eltype(y0),storage}(y0)
            @test Array(mul!(dy, csr, dx, alpha, beta)) ≈ expected
            @test Array(csr * dx) ≈ A * x
        end

        A = sparse(Float32[1 0 2 0; 0 0 0 0; 3 4 0 5])
        check_spmv(A, Float32[2, -1, 3, 4], 2.0f0, -0.5f0, Float32[1, 2, 3])

        Ac = sparse(ComplexF32[1+2im 0; 0 0; 3-im 4+im])
        check_spmv(
            Ac,
            ComplexF32[2-im, 1+im],
            ComplexF32(0.5+im),
            ComplexF32(-1),
            ComplexF32[1, 2, 3],
        )

        Ai = sparse(Int32[1 0 2; 0 0 0; 3 4 0])
        check_spmv(
            Ai,
            Int32[2, 3, 4],
            Int32(2),
            Int32(3),
            Int32[1, 2, 3];
            storage = Metal.SharedStorage,
        )

        Z = spzeros(Float32, 4, 3)
        check_spmv(Z, Float32[1, 2, 3], 2.0f0, 3.0f0, Float32[4, 5, 6, 7])

        dA = MtlSparseMatrixCSR(A)
        @test_throws DimensionMismatch dA * MtlArray(Float32[1, 2])
        @test_throws DimensionMismatch mul!(
            Metal.zeros(Float32, 2),
            dA,
            MtlArray(Float32[1, 2, 3, 4]),
        )

        empty = MtlSparseMatrixCSR(spzeros(Float32, 0, 3))
        @test isempty(empty * MtlArray(Float32[1, 2, 3]))

        csc = MtlSparseMatrixCSC(A)
        dx = MtlArray(Float32[1, 2, 3, 4])
        @test_throws ArgumentError csc * dx
        @test_throws ArgumentError mul!(Metal.zeros(Float32, 3), csc, dx)
        @test_throws ArgumentError mul!(Metal.zeros(Float32, 3), csc, dx, 2.0f0, 3.0f0)
    end

    @testset "sparse matrix-dense matrix multiplication" begin
        function check_spmm(A, B, alpha, beta, C0; storage = Metal.DefaultStorageMode)
            csr = MtlSparseMatrixCSR{eltype(A),SparseArrays.indtype(A),storage}(A)
            dB = MtlMatrix{eltype(B),storage}(B)
            dC = MtlMatrix{eltype(C0),storage}(C0)
            expected = alpha .* (A * B) .+ beta .* C0

            @test Array(mul!(dC, csr, dB, alpha, beta)) ≈ expected
            @test Array(csr * dB) ≈ A * B
        end

        A = sparse(Float32[1 0 2 0; 0 0 0 0; 3 4 0 5])
        B = Float32[2 -1; -1 3; 3 2; 4 -2]
        C0 = Float32[1 2; 3 4; 5 6]
        check_spmm(A, B, 2.0f0, -0.5f0, C0)

        Ac = sparse(ComplexF32[1+2im 0; 0 0; 3-im 4+im])
        Bc = ComplexF32[2-im 1+im; 1+im 3-im]
        Cc = ComplexF32[1 2; 3 4; 5 6]
        check_spmm(Ac, Bc, ComplexF32(0.5+im), ComplexF32(-1), Cc)

        Ai = sparse(Int32[1 0 2; 0 0 0; 3 4 0])
        Bi = Int32[2 1; 3 0; 4 -1]
        Ci = Int32[1 2; 3 4; 5 6]
        check_spmm(
            Ai,
            Bi,
            Int32(2),
            Int32(3),
            Ci;
            storage = Metal.SharedStorage,
        )

        Z = spzeros(Float32, 4, 3)
        check_spmm(
            Z,
            Float32[1 2; 3 4; 5 6],
            2.0f0,
            3.0f0,
            Float32[1 2; 3 4; 5 6; 7 8],
        )

        supported_types = (
            Int16,
            Int32,
            Int64,
            Complex{Int16},
            Complex{Int32},
            Complex{Int64},
            Float16,
            Float32,
            ComplexF16,
            ComplexF32,
        )
        @testset "supported element type $T" for T in supported_types
            At = sparse(T[1 0 2; 0 3 0])
            Bt = T[1 2; 3 4; 5 6]
            @test Array(MtlSparseMatrixCSR(At) * MtlArray(Bt)) ≈ At * Bt
        end

        dA = MtlSparseMatrixCSR(A)
        dB = MtlArray(B)
        @test_throws DimensionMismatch dA * Metal.zeros(Float32, 3, 2)
        @test_throws DimensionMismatch mul!(Metal.zeros(Float32, 2, 2), dA, dB)

        empty = MtlSparseMatrixCSR(spzeros(Float32, 0, 3))
        @test size(empty * Metal.zeros(Float32, 3, 2)) == (0, 2)

        csc = MtlSparseMatrixCSC(A)
        @test_throws ArgumentError csc * dB
        @test_throws ArgumentError mul!(Metal.zeros(Float32, 3, 2), csc, dB)
        @test_throws ArgumentError mul!(
            Metal.zeros(Float32, 3, 2),
            csc,
            dB,
            2.0f0,
            3.0f0,
        )
    end
end
