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

@testset "native :Julia GEMM" begin
    _op(M, t) = t == 'N' ? M : t == 'C' ? adjoint(M) : transpose(M)
    _mk(T, sz) = T <: Integer ? rand(T(1):T(4), sz...) : rand(T, sz...)
    _rtol(T) = real(T) == Float16 ? 1.0f-1 : real(T) == Float32 ? 1.0f-3 : 1e-5

    # C = α·op(A)·op(B) + β·C against a CPU oracle, forcing the native path
    function nativetest(T, M, N, K, tA, tB, α, β)
        sA = tA == 'N' ? (M, K) : (K, M)
        sB = tB == 'N' ? (K, N) : (N, K)
        Ah = _mk(T, sA); Bh = _mk(T, sB); Ch = _mk(T, (M, N))
        dA = MtlArray(Ah); dB = MtlArray(Bh); dC = MtlArray(copy(Ch))
        ref = α .* (_op(Ah, tA) * _op(Bh, tB)) .+ β .* Ch
        @with (Metal.matmul_alg => :Julia) mul!(dC, _op(dA, tA), _op(dB, tB), α, β)
        T <: Integer ? Array(dC) == ref : isapprox(Array(dC), ref; rtol=_rtol(T))
    end

    # fast path (Float16/Float32): transpose × α/β × ragged shapes
    @testset "$T $tA$tB α=$α β=$β" for T in (Float32, Float16),
                                        (tA, tB) in (("N","N"), ("N","T"), ("T","N"), ("T","T")),
                                        (α, β) in ((T(1), T(0)), (T(2), T(0)), (T(1), T(1)), (T(2), T(3)))
        @test nativetest(T, 64, 48, 32, only(tA), only(tB), α, β)   # aligned
        @test nativetest(T, 65, 47, 33, only(tA), only(tB), α, β)   # ragged
    end

    # robust path (ComplexF32, Int32): includes conjugate transpose
    @testset "$T $tA$tB" for T in (ComplexF32, Int32),
                             (tA, tB) in (("N","N"), ("N","T"), ("T","N"), ("C","N"), ("N","C"))
        α = T(2); β = T <: Integer ? T(1) : T(1) / 2
        @test nativetest(T, 40, 24, 16, only(tA), only(tB), α, β)
        @test nativetest(T, 41, 25, 17, only(tA), only(tB), α, β)   # ragged
    end

    # offset views (dense MtlMatrix with offset≠0): the case MPSGraph falls back on
    @testset "offset views" begin
        for T in (Float32, ComplexF32)
            P = MtlArray(_mk(T, (40, 60))); Q = MtlArray(_mk(T, (32, 50)))
            A = view(P, :, 3:34)      # 40×32, offset≠0, dense
            B = view(Q, :, 2:41)      # 32×40, offset≠0, dense
            @test A isa MtlMatrix && A.offset != 0 && B isa MtlMatrix && B.offset != 0
            C = MtlArray(zeros(T, 40, 40))
            ref = Array(A) * Array(B)
            @with (Metal.matmul_alg => :Julia) mul!(C, A, B)
            @test isapprox(Array(C), ref; rtol=_rtol(T))
        end
    end

    # matrix-vector
    @testset "gemv" begin
        for tA in ('N', 'T')
            A = MtlArray(rand(Float32, 50, 70)); x = MtlArray(rand(Float32, tA == 'N' ? 70 : 50))
            y = MtlArray(zeros(Float32, tA == 'N' ? 50 : 70))
            ref = _op(Array(A), tA) * Array(x)
            @with (Metal.matmul_alg => :Julia) mul!(y, _op(A, tA), x)
            @test isapprox(Array(y), ref; rtol=1.0f-3)
        end
    end

    # degenerate shapes
    @testset "edge shapes" begin
        @test nativetest(Float32, 1, 1, 1, 'N', 'N', 1.0f0, 0.0f0)
        @test nativetest(Float32, 1, 64, 100, 'N', 'N', 1.0f0, 0.0f0)
        @test nativetest(Float32, 64, 1, 100, 'N', 'N', 1.0f0, 0.0f0)
        # empty contraction: C = β·C
        C = MtlArray(fill(2.0f0, 4, 4))
        @with (Metal.matmul_alg => :Julia) mul!(C, MtlArray(rand(Float32, 4, 0)), MtlArray(rand(Float32, 0, 4)), 1.0f0, 3.0f0)
        @test Array(C) == fill(6.0f0, 4, 4)
    end

    # differential check: native must agree with MPSGraph where MPSGraph applies
    @testset "differential vs MPSGraph" begin
        A = MtlArray(rand(Float32, 96, 80)); B = MtlArray(rand(Float32, 80, 64))
        Cj = MtlArray(zeros(Float32, 96, 64)); Cg = MtlArray(zeros(Float32, 96, 64))
        @with (Metal.matmul_alg => :Julia) mul!(Cj, A, B)
        @with (Metal.matmul_alg => :MPSGraph) mul!(Cg, A, B)
        @test isapprox(Array(Cj), Array(Cg); rtol=1.0f-3)
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
