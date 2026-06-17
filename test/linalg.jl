using Test, Metal

using LinearAlgebra, ScopedValues

@testset "matmul algorithm selection" begin
    # MPSGraph's Float16 matmul produces wrong results on some paravirtualized GPUs (e.g. the
    # GitHub Actions runners), even though it works on others. Skip those correctness checks
    # on virtual devices; the buildkite CI still covers them on real hardware.
    virtual = Metal.is_virtual(Metal.device())

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

        # low-precision eltypes accumulate differently on-device; compare with a
        # tolerance rather than the default near-exact elementwise `.≈`
        rtol = max(sqrt(eps(real(float(outT)))), sqrt(eps(real(float(inT)))))
        return isapprox(outT.(a)*outT.(b), Array(mc); rtol)
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
        @test test_matmul(Float16, Float32; vec_b) skip=virtual # should use MPSGraph on M1/M2

        # :MPS
        mpsInT = vec_b ? Float32 : Int16
        @test test_matmul(mpsInT, Float32; vec_b, alg=:MPS)
        @test test_matmul(Float16, Float32; vec_b, alg=:MPS)

        # :MPSGraph
        @test test_matmul(Int8, Float32; vec_b, alg=:MPSGraph)
        @test test_matmul(Float16, Float32; vec_b, alg=:MPSGraph) skip=virtual

        # :GPUArrays
        @test test_matmul(Int32, Int32; vec_b, alg=:GPUArrays)
        @test test_matmul(Int8, Float32; vec_b, alg=:GPUArrays)
        @test test_matmul(Float16, Float32; vec_b, alg=:GPUArrays)

        # :simd (simdgroup kernel, Float16/Float32 only)
        @test test_matmul(Float32, Float32; vec_b, alg=:simd)
        @test_throws "algorithm `:simd`" test_matmul(Int32, Int32; vec_b, alg=:simd)
        # :scalar (scalar kernel, any eltype)
        @test test_matmul(Int32, Int32; vec_b, alg=:scalar)
        @test test_matmul(Float32, Float32; vec_b, alg=:scalar)
        # :tensor is matrix-only and needs tile-divisible dims; N=20 errors either way
        @test_throws Exception test_matmul(Float32, Float32; vec_b, alg=:tensor)
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

@testset "native GEMM" begin
    op(M, t) = t == 'N' ? M : t == 'C' ? adjoint(M) : transpose(M)
    mk(T, sz) = T <: Integer ? rand(T(1):T(4), sz...) : rand(T, sz...)
    tol(T) = real(T) == Float16 ? 1.0f-1 : real(T) == Float32 ? 1.0f-3 : 1e-5

    # C = α·op(A)·op(B) + β·C against a CPU oracle, forcing a specific native kernel
    function nativetest(T, M, N, K, tA, tB, α, β; alg=:native)
        sA = tA == 'N' ? (M, K) : (K, M)
        sB = tB == 'N' ? (K, N) : (N, K)
        Ah = mk(T, sA); Bh = mk(T, sB); Ch = mk(T, (M, N))
        dA = MtlArray(Ah); dB = MtlArray(Bh); dC = MtlArray(copy(Ch))
        ref = α .* (op(Ah, tA) * op(Bh, tB)) .+ β .* Ch
        @with (Metal.matmul_alg => alg) mul!(dC, op(dA, tA), op(dB, tB), α, β)
        T <: Integer ? Array(dC) == ref : isapprox(Array(dC), ref; rtol=tol(T))
    end

    # simd path (Float16/Float32): transpose × α/β × ragged shapes. Forced via `:simd` so
    # the simdgroup kernel is exercised regardless of whether a tensor path is available.
    @testset "$T $tA$tB α=$α β=$β" for T in (Float32, Float16),
                                        (tA, tB) in (("N","N"), ("N","T"), ("T","N"), ("T","T")),
                                        (α, β) in ((T(1), T(0)), (T(2), T(0)), (T(1), T(1)), (T(2), T(3)))
        @test nativetest(T, 64, 48, 32, only(tA), only(tB), α, β; alg=:simd)   # aligned
        @test nativetest(T, 65, 47, 33, only(tA), only(tB), α, β; alg=:simd)   # ragged
    end

    # scalar path (ComplexF32, Int32): includes conjugate transpose
    @testset "$T $tA$tB" for T in (ComplexF32, Int32),
                             (tA, tB) in (("N","N"), ("N","T"), ("T","N"), ("C","N"), ("N","C"))
        α = T(2); β = T <: Integer ? T(1) : T(1) / 2
        @test nativetest(T, 40, 24, 16, only(tA), only(tB), α, β; alg=:scalar)
        @test nativetest(T, 41, 25, 17, only(tA), only(tB), α, β; alg=:scalar)   # ragged
    end

    # offset views (dense MtlMatrix with offset≠0): the case MPSGraph falls back on
    @testset "offset views" begin
        for (T, alg) in ((Float32, :simd), (ComplexF32, :scalar))
            P = MtlArray(mk(T, (40, 60))); Q = MtlArray(mk(T, (32, 50)))
            A = view(P, :, 3:34)      # 40×32, offset≠0, dense
            B = view(Q, :, 2:41)      # 32×40, offset≠0, dense
            @test A isa MtlMatrix && A.offset != 0 && B isa MtlMatrix && B.offset != 0
            C = MtlArray(zeros(T, 40, 40))
            ref = Array(A) * Array(B)
            @with (Metal.matmul_alg => alg) mul!(C, A, B)
            @test isapprox(Array(C), ref; rtol=tol(T))
        end
    end

    # matrix-vector
    @testset "gemv" begin
        for tA in ('N', 'T')
            A = MtlArray(rand(Float32, 50, 70)); x = MtlArray(rand(Float32, tA == 'N' ? 70 : 50))
            y = MtlArray(zeros(Float32, tA == 'N' ? 50 : 70))
            ref = op(Array(A), tA) * Array(x)
            @with (Metal.matmul_alg => :native) mul!(y, op(A, tA), x)
            @test isapprox(Array(y), ref; rtol=1.0f-3)
        end
    end

    # Symmetric/Hermitian wrapper chars ('S'/'s'/'H'/'h'): the simd and scalar kernels
    # gather through the stored triangle, so these run natively instead of through the
    # GPUArrays fallback. The reference uses the same wrapper on the CPU, so the random
    # data in the non-stored triangle catches any read outside the stored one. BLAS
    # eltypes (Float32/ComplexF32) only reach Metal's generic_matmatmul! on Julia 1.12+,
    # where GPUArrays overrides generic_matmatmul_wrapper! away from BLAS.symm!/hemm!.
    @testset "Symmetric/Hermitian wrappers" begin
        check(T, dX, ref) = T <: Integer ? Array(dX) == ref : isapprox(Array(dX), ref; rtol=tol(T))
        @testset "$W{$T} :$uplo" for T in (Float32, Float16, ComplexF32, Int32),
                                     W in (Symmetric, Hermitian),
                                     uplo in (:U, :L)
            # older LinearAlgebra dispatches BLAS eltypes into BLAS.symm!/hemm!
            T <: LinearAlgebra.BlasFloat && VERSION < v"1.12" && continue
            n = 33
            Ah = mk(T, (n, n)); Bh = mk(T, (n, n)); bh = mk(T, (n,))
            dA = MtlArray(Ah); dB = MtlArray(Bh); db = MtlArray(bh)

            # wrapped on the left and on the right
            dC = MtlArray(zeros(T, n, n))
            @with (Metal.matmul_alg => :native) mul!(dC, W(dA, uplo), dB)
            @test check(T, dC, W(Ah, uplo) * Bh)
            @with (Metal.matmul_alg => :native) mul!(dC, dB, W(dA, uplo))
            @test check(T, dC, Bh * W(Ah, uplo))

            # with α and β
            Eh = mk(T, (n, n)); dE = MtlArray(copy(Eh))
            @with (Metal.matmul_alg => :native) mul!(dE, W(dA, uplo), dB, T(2), T(3))
            @test check(T, dE, T(2) .* (W(Ah, uplo) * Bh) .+ T(3) .* Eh)

            # matrix-vector
            dc = MtlArray(zeros(T, n))
            @with (Metal.matmul_alg => :native) mul!(dc, W(dA, uplo), db)
            @test check(T, dc, W(Ah, uplo) * bh)
        end

        # forcing a specific kernel works too; the tensor kernel can't handle wrappers
        A64 = MtlArray(rand(Float32, 64, 64)); B64 = MtlArray(rand(Float32, 64, 64))
        ref = Symmetric(Array(A64)) * Array(B64)
        for alg in (:simd, :scalar)
            C64 = MtlArray(zeros(Float32, 64, 64))
            @with (Metal.matmul_alg => alg) mul!(C64, Symmetric(A64), B64)
            @test isapprox(Array(C64), ref; rtol=tol(Float32))
        end
        @test_throws Exception (@with (Metal.matmul_alg => :tensor) mul!(MtlArray(zeros(Float32, 64, 64)), Symmetric(A64), B64))
    end

    # degenerate shapes
    @testset "edge shapes" begin
        @test nativetest(Float32, 1, 1, 1, 'N', 'N', 1.0f0, 0.0f0)
        @test nativetest(Float32, 1, 64, 100, 'N', 'N', 1.0f0, 0.0f0)
        @test nativetest(Float32, 64, 1, 100, 'N', 'N', 1.0f0, 0.0f0)
        # empty contraction: C = β·C
        C = MtlArray(fill(2.0f0, 4, 4))
        @with (Metal.matmul_alg => :native) mul!(C, MtlArray(rand(Float32, 4, 0)), MtlArray(rand(Float32, 0, 4)), 1.0f0, 3.0f0)
        @test Array(C) == fill(6.0f0, 4, 4)
    end

    # differential check: native must agree with MPSGraph where MPSGraph applies
    @testset "differential vs MPSGraph" begin
        A = MtlArray(rand(Float32, 96, 80)); B = MtlArray(rand(Float32, 80, 64))
        Cj = MtlArray(zeros(Float32, 96, 64)); Cg = MtlArray(zeros(Float32, 96, 64))
        @with (Metal.matmul_alg => :native) mul!(Cj, A, B)
        @with (Metal.matmul_alg => :MPSGraph) mul!(Cg, A, B)
        @test isapprox(Array(Cj), Array(Cg); rtol=1.0f-3)
    end

    # Metal 4 tensor-ops path (`:tensor`): only fires on a capable device (macOS 26+ /
    # Metal4 family), for the plain C = A·B (N/N, α=1, β=0) with tile-divisible dims and a
    # supported eltype.
    @testset "tensor-ops path" begin
        if Metal.tensor_matmul_capable()
            ttol(T) = T === Float32 ? 1.0f-3 : 1.0f-1
            @testset "$T $M×$N×$K" for T in (Float32, Float16, BFloat16),
                                       (M, N, K) in ((64, 64, 32), (128, 256, 64), (512, 512, 128))
                A = MtlArray(rand(T, M, K)); B = MtlArray(rand(T, K, N))
                ref = Array(A) * Array(B)
                @test Metal.supports_tensor_matmul(MtlArray(zeros(T, M, N)), A, B, 'N', 'N', true, false)
                Ct = MtlArray(zeros(T, M, N))
                @with (Metal.matmul_alg => :tensor) mul!(Ct, A, B)
                @test isapprox(Array(Ct), ref; rtol=ttol(T))
            end

            # forcing `:tensor` on operands it can't handle errors (like an unsupported :MPS)
            A = MtlArray(rand(Float32, 64, 64)); B = MtlArray(rand(Float32, 64, 64))
            @test_throws Exception (@with (Metal.matmul_alg => :tensor) mul!(MtlArray(zeros(Float32, 64, 64)), transpose(A), B))  # transpose
            @test_throws Exception (@with (Metal.matmul_alg => :tensor) mul!(MtlArray(zeros(Float32, 64, 64)), A, B, 2f0, 1f0))  # α/β
            Aodd = MtlArray(rand(Float32, 65, 33)); Bodd = MtlArray(rand(Float32, 33, 47))
            @test_throws Exception (@with (Metal.matmul_alg => :tensor) mul!(MtlArray(zeros(Float32, 65, 47)), Aodd, Bodd))      # not tile-divisible
            Ai = MtlArray(rand(Int32, 64, 64)); Bi = MtlArray(rand(Int32, 64, 64))
            @test_throws Exception (@with (Metal.matmul_alg => :tensor) mul!(MtlArray(zeros(Int32, 64, 64)), Ai, Bi))            # unsupported eltype
        else
            @test_skip Metal.tensor_matmul_capable()
        end
    end
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
