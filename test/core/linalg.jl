using Test, Metal

using LinearAlgebra, ScopedValues

# MPS and MPSGraph are optional: tests that force an algorithm the device lacks are skipped
supported(alg) = alg === :MPS ? MPS.is_supported(Metal.device()) :
                 alg === :MPSGraph ? MPSGraphs.is_supported(Metal.device()) : true
# in loops over algorithms: records the skip of an unsupported one
skipped(alg) = supported(alg) ? false : (@test_skip "matmul_alg = :$alg"; true)

@testset "matmul algorithm selection" begin
    # MPSGraph's Float16 matmul produces wrong results on some paravirtualized GPUs (e.g. the
    # GitHub Actions runners), even though it works on others. Skip those correctness checks
    # on virtual devices; the buildkite CI still covers them on real hardware.
    virtual = Metal.is_virtual(Metal.device())

    # the GPUs Metal.jl supports all have SIMD-group matrices, for the :simd kernel
    Metal.is_supported(Metal.device()) && @test Metal.simd_matmul_capable()

    # test that unsupported configurations error properly
    N = 20
    function test_matmul(inT, outT; vec_b=false, alg=:auto,
                         range=(inT <: Unsigned ? (0:10) : (-5:5)))
        a = inT <: Integer ? inT.(rand(range, N,N)) : rand(inT, N, N)

        bdims = vec_b ? (N,) : (N, N)
        b = inT <: Integer ? inT.(rand(range, bdims)) : rand(inT, bdims)

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
        @test_throws ":bad is not a valid $(vec_b ? "matvecmul" : "matmul") algorithm." test_matmul(Int8, Int16; vec_b, alg=:bad)
        @test_throws ":bad is not a valid $(vec_b ? "matvecmul" : "matmul") algorithm." test_matmul(Float16, Float16; vec_b, alg=:bad)

        # :auto
        @test test_matmul(Int32, Int32; vec_b)     # falls back to GPUArrays
        @test test_matmul(Int8, Float32; vec_b)    # should use MPS
        @test test_matmul(Float16, Float32; vec_b) skip=virtual # should use MPSGraph on M1/M2

        # :MPS
        mpsInT = vec_b ? Float32 : Int16
        @test test_matmul(mpsInT, Float32; vec_b, alg=:MPS) skip=!supported(:MPS)
        @test test_matmul(Float16, Float32; vec_b, alg=:MPS) skip=!supported(:MPS)

        # :MPSGraph
        @test test_matmul(Int8, Float32; vec_b, alg=:MPSGraph) skip=!supported(:MPSGraph)
        @test test_matmul(Float16, Float32; vec_b, alg=:MPSGraph) skip=virtual || !supported(:MPSGraph)

        # :GPUArrays (generic kernel, any eltype)
        @test test_matmul(Int32, Int32; vec_b, alg=:GPUArrays)
        @test test_matmul(Float32, Float32; vec_b, alg=:GPUArrays)
        @test test_matmul(Float16, Float32; vec_b, alg=:GPUArrays)
        # narrow-integer inputs need a wide accumulator; the K=20 dot product overflows Int8
        @test test_matmul(Int8,  Float32; vec_b, alg=:GPUArrays)
        @test test_matmul(UInt8, Float32; vec_b, alg=:GPUArrays)
        @test test_matmul(Int8,  Int32;   vec_b, alg=:GPUArrays)
        # large values whose product overflows Int16 still accumulate into Int32
        @test test_matmul(Int16, Int32;   vec_b, alg=:GPUArrays, range=-300:300)
        @test test_matmul(Int32, Int32;   vec_b, alg=:scalar)   # still accepted

        # :native falls back to the generic kernel for operands its own kernels don't take
        @test test_matmul(Int32, Int32; vec_b, alg=:native)
        @test test_matmul(Int8,  Int32; vec_b, alg=:native)

        # :simd (simdgroup kernel, Float16/Float32 only)
        @test test_matmul(Float32, Float32; vec_b, alg=:simd)
        @test_throws "algorithm `:simd`" test_matmul(Int32, Int32; vec_b, alg=:simd)
        # :tensor is matrix-only and needs tile-divisible dims; N=20 errors either way
        @test_throws Exception test_matmul(Float32, Float32; vec_b, alg=:tensor)
        end
    end
end

@testset "β = 0 ignores the output's contents" begin
    A = MtlArray(rand(Float32, 8, 8))
    B = MtlArray(rand(Float32, 8, 8))
    x = MtlArray(rand(Float32, 8))
    @testset "$alg" for alg in (:auto, :MPS, :MPSGraph, :native, :GPUArrays)
        skipped(alg) && continue
        C = MtlArray(fill(NaN32, 8, 8))
        @with (Metal.matmul_alg => alg) mul!(C, A, B)
        @test Array(C) ≈ Array(A) * Array(B)

        y = MtlArray(fill(NaN32, 8))
        @with (Metal.matmul_alg => alg) mul!(y, A, x)
        @test Array(y) ≈ Array(A) * Array(x)
    end
end

@testset "empty dimensions" begin
    # products with M, K or N == 0 must not reach the backends (MPS asserts on empty buffers):
    # the result is empty, or β·C when the contraction dimension is empty
    @testset "$alg $(vec_b ? "gemv" : "gemm") $(M)×$(K)×$(N)" for alg in (:auto, :MPS, :MPSGraph, :native, :GPUArrays),
                                                                  vec_b in (false, true),
                                                                  (M, K, N) in ((0, 5, 4), (3, 0, 4), (3, 5, 0))
        vec_b && N == 0 && continue
        A = rand(Float32, M, K)
        B = vec_b ? rand(Float32, K) : rand(Float32, K, N)
        C = vec_b ? rand(Float32, M) : rand(Float32, M, N)
        ref = mul!(copy(C), A, B, 2f0, 3f0)
        dC = MtlArray(C)
        @with (Metal.matmul_alg => alg) mul!(dC, MtlArray(A), MtlArray(B), 2f0, 3f0)
        @test Array(dC) ≈ ref
    end
end

@testset "destination size mismatch" begin
    # the backends take the output size from C, so a wrongly sized C has to be rejected up
    # front (MPSGraph asserts on it, the native kernels silently compute a partial product)
    A = MtlArray(rand(Float32, 4, 3))
    B = MtlArray(rand(Float32, 3, 5))
    x = MtlArray(rand(Float32, 3))
    @testset "$alg" for alg in (:auto, :MPS, :MPSGraph, :native, :GPUArrays)
        @with (Metal.matmul_alg => alg) begin
            for dims in ((1, 5), (8, 5), (4, 4), (4, 6))
                @test_throws DimensionMismatch mul!(Metal.zeros(Float32, dims), A, B)
                @test_throws DimensionMismatch mul!(Metal.zeros(Float32, dims), 'N', 'N', A, B, true, false)
            end
            for len in (2, 8)
                @test_throws DimensionMismatch mul!(Metal.zeros(Float32, len), A, x)
                @test_throws DimensionMismatch mul!(Metal.zeros(Float32, len), 'N', A, x, true, false)
            end
        end
    end
    # views go through the `MtlMatrixOperand` method
    @test_throws DimensionMismatch mul!(Metal.zeros(Float32, 1, 5), 'N', 'N', view(A, 1:2, :), B, true, false)
    @test_throws DimensionMismatch mul!(view(Metal.zeros(Float32, 4, 5), 1:2, :), A, B)
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

@testset "matrix multiplication of range views" begin
    @testset "$T" for T in [Float32, Float16, BFloat16]
        x = ones(T, 2, 2)
        y = ones(T, 4, 2)
        dx = MtlArray(x)
        dy = MtlArray(y)
        @test Array(dx * view(dy, 1:2, :)) ≈ x * view(y, 1:2, :)

        a = rand(T, 4, 3)
        b = rand(T, 3, 5)
        da = MtlArray(a)
        db = MtlArray(b)
        av = view(da, 2:3, :)
        bv = view(db, :, 2:4)

        # Call the storage-level `mul!` directly so these exercise the native kernels and honor `matmul_alg`
        for alg in (:auto, :simd, :GPUArrays)
            C = MtlArray(zeros(T, 2, 5))
            @with (Metal.matmul_alg => alg) LinearAlgebra.mul!(C, 'N', 'N', av, db, true, false)
            @test Array(C) ≈ view(a, 2:3, :) * b

            C = MtlArray(zeros(T, 4, 3))
            @with (Metal.matmul_alg => alg) LinearAlgebra.mul!(C, 'N', 'N', da, bv, true, false)
            @test Array(C) ≈ a * view(b, :, 2:4)

            C = MtlArray(zeros(T, 2, 3))
            @with (Metal.matmul_alg => alg) LinearAlgebra.mul!(C, 'N', 'N', av, bv, true, false)
            @test Array(C) ≈ view(a, 2:3, :) * view(b, :, 2:4)
        end

        # non-unit strides (step-range views)
        as = rand(T, 8, 6)
        bs = rand(T, 6, 10)
        xs = rand(T, 6)
        das = MtlArray(as)
        dbs = MtlArray(bs)
        dxs = MtlArray(xs)
        asv = view(das, 1:2:8, :)
        bsv = view(dbs, :, 1:2:10)

        @test Array(asv * bsv) ≈ view(as, 1:2:8, :) * view(bs, :, 1:2:10)
        @test Array(asv' * asv) ≈ view(as, 1:2:8, :)' * view(as, 1:2:8, :)
        @test Array(asv * dxs) ≈ view(as, 1:2:8, :) * xs

        for alg in (:auto, :simd, :GPUArrays)
            C = MtlArray(zeros(T, 4, 5))
            @with (Metal.matmul_alg => alg) LinearAlgebra.mul!(C, 'N', 'N', asv, bsv, true, false)
            @test Array(C) ≈ view(as, 1:2:8, :) * view(bs, :, 1:2:10)

            C = MtlArray(zeros(T, 6, 6))
            @with (Metal.matmul_alg => alg) LinearAlgebra.mul!(C, 'T', 'N', asv, asv, true, false)
            @test Array(C) ≈ view(as, 1:2:8, :)' * view(as, 1:2:8, :)
        end

        # strided destination
        for alg in (:auto, :simd, :GPUArrays)
            cs = rand(T, 8, 5)
            dcs = MtlArray(cs)
            mul!(view(cs, 1:2:8, :), view(as, 1:2:8, :), view(bs, :, 1:2:10), 2.0f0, 1.0f0)
            @with (Metal.matmul_alg => alg) LinearAlgebra.mul!(view(dcs, 1:2:8, :), 'N', 'N', asv, bsv, 2.0f0, 1.0f0)
            @test Array(dcs) ≈ cs
        end

        # strided destination with contiguous operands: the view is dense but its leading
        # dimension differs from its height, which the simd kernel must not direct-store to
        a2 = rand(T, 2, 3)
        b2 = rand(T, 3, 5)
        da2 = MtlArray(a2)
        db2 = MtlArray(b2)
        for alg in (:auto, :simd, :GPUArrays)
            c2 = rand(T, 4, 5)
            dc2 = MtlArray(c2)
            mul!(view(c2, 1:2, :), a2, b2)
            @with (Metal.matmul_alg => alg) LinearAlgebra.mul!(view(dc2, 1:2, :), 'N', 'N', da2, db2, true, false)
            @test Array(dc2) ≈ c2
        end
    end
end

@testset "Float64 α and β" begin
    # Metal has no Float64, so the scalars must be converted before they reach a kernel
    A, B, C, x = rand(Float32, 20, 30), rand(Float32, 30, 10), rand(Float32, 20, 10), rand(Float32, 30)
    dA, dB, dC, dx = MtlArray.((A, B, C, x))
    for alg in (:auto, :native, :simd, :GPUArrays)
        dc = copy(dC)
        @with (Metal.matmul_alg => alg) mul!(dc, dA, dB, 2, 0.5)
        @test Array(dc) ≈ 2 * A * B + C / 2

        dc = copy(dC)
        @with (Metal.matmul_alg => alg) mul!(view(dc, :, 2:9), dA, view(dB, :, 2:9), 2, 0.5)
        @test Array(dc)[:, 2:9] ≈ 2 * A * B[:, 2:9] + C[:, 2:9] / 2

        dy = dC[:, 1]
        @with (Metal.matmul_alg => alg) mul!(dy, dA, dx, 2, 0.5)
        @test Array(dy) ≈ 2 * A * x + C[:, 1] / 2
    end

    # only β applies
    for alg in (:native, :GPUArrays)
        dc = copy(dC)
        @with (Metal.matmul_alg => alg) mul!(dc, dA, dB, 0, 0.5)
        @test Array(dc) ≈ C / 2
    end
end

@testset "empty product into a view" begin
    # only β applies, on the GPU (private storage can't be indexed from the host)
    C = rand(Float32, 8, 6)
    dC = MtlArray{Float32,2,Metal.PrivateStorage}(C)
    mul!(view(dC, 2:5, :), Metal.zeros(Float32, 4, 0), transpose(Metal.zeros(Float32, 6, 0)), 1f0, 0.5f0)
    @test Array(dC) ≈ [i in 2:5 ? C[i, j] / 2 : C[i, j] for i in 1:8, j in 1:6]
end

@testset "5-arg mul! of strided views" begin
    # views that aren't valid BLAS operands (stepped rows, reversed columns, wrapped or
    # vector views) must reach Metal's methods too, so the algorithm selection applies
    C, A, B = rand(Float32, 30, 60), rand(Float32, 70, 50), rand(Float32, 40, 90)
    x, y = rand(Float32, 80), rand(Float32, 80)
    products = [
        "stepped rows"     => (C, A, B, x, y) -> (view(C, 2:25, 2:2:52), view(A, 3:2:50, 1:33), view(B, 1:33, 5:3:80)),
        "reversed columns" => (C, A, B, x, y) -> (view(C, 2:25, 31:-1:2), view(A, 3:26, 33:-1:1), view(B, 1:33, 5:34)),
        "adjoint"          => (C, A, B, x, y) -> (view(C, 2:25, 2:31), view(A, 1:2:65, 1:24)', view(B, 1:33, 5:34)),
        "symmetric"        => (C, A, B, x, y) -> (view(C, 2:21, 2:31), Symmetric(view(A, 3:2:41, 1:20)), view(B, 1:20, 5:34)),
        "matvec"           => (C, A, B, x, y) -> (view(y, 1:2:48), view(A, 3:2:50, 1:33), view(x, 2:2:66)),
        "matvec columns"   => (C, A, B, x, y) -> (view(C, 1:24, 3), view(A, 3:26, 1:33), view(A, 2:2:66, 40)),
    ]
    dC, dA, dB, dx, dy = MtlArray.((C, A, B, x, y))
    @testset "$name" for (name, f) in products
        c, a, b = f(C, A, B, x, y)
        ref = 2 * Array(a) * Array(b) + c / 2
        vec = c isa AbstractVector
        # Float64 scalars must not reach the kernels
        for alg in (:auto, :native, :simd, :GPUArrays), (α, β) in ((2f0, 0.5f0), (2, 0.5))
            dc, da, db = f(copy(dC), dA, dB, dx, copy(dy))
            @with (Metal.matmul_alg => alg) mul!(dc, da, db, α, β)
            @test Array(dc) ≈ ref
        end
        dc, da, db = f(copy(dC), dA, dB, dx, copy(dy))
        mul!(dc, da, db, 0, 0.5)
        @test Array(dc) ≈ c / 2
        for alg in (vec ? (:MPS, :MPSGraph, :tensor) : (:MPS, :MPSGraph))
            dc, da, db = f(copy(dC), dA, dB, dx, copy(dy))
            @test_throws "multiplication algorithm `:$alg` is not supported" @with (Metal.matmul_alg => alg) mul!(dc, da, db, 2f0, 0.5f0)
        end
    end

    # an empty inner dimension only scales the destination (on the GPU: private storage
    # can't be indexed from the host)
    P = MtlArray{Float32,2,Metal.PrivateStorage}(C)
    mul!(view(P, 1:2:29, :), Metal.zeros(Float32, 15, 0), Metal.zeros(Float32, 0, 60), 1f0, 0.5f0)
    @test Array(P) ≈ [isodd(i) ? C[i, j] / 2 : C[i, j] for i in 1:30, j in 1:60]
    for alg in (:auto, :MPS, :GPUArrays)
        p = MtlArray{Float32,1,Metal.PrivateStorage}(y)
        @with (Metal.matmul_alg => alg) mul!(view(p, 1:2:79), Metal.zeros(Float32, 40, 0), Metal.zeros(Float32, 0), Inf32, 0.5f0)
        @test Array(p) ≈ [isodd(i) ? y[i] / 2 : y[i] for i in 1:80]
    end
    @test_throws DimensionMismatch mul!(view(copy(dy), 1:2:79), dA, view(dx, 1:2:79))

    # a row of a matrix has no column view for the native kernels, so only the generic one
    # takes it
    for alg in (:auto, :native, :GPUArrays)
        c, a, b = view(copy(dC), 3, 1:24), view(dA, 3:26, 1:33), view(dB, 1:33, 7)
        @with (Metal.matmul_alg => alg) mul!(c, a, b)
        @test Array(c) ≈ Array(a) * Array(b)
    end
    c, a, b = view(copy(dC), 3, 1:24), view(dA, 3:26, 1:33), view(dB, 1:33, 7)
    @test_throws "multiplication algorithm `:simd` is not supported" @with (Metal.matmul_alg => :simd) mul!(c, a, b)
end

@testset "unambiguous view products" begin
    # the methods intercepting products with views must be more specific than GPUArrays' and
    # LinearAlgebra's in every argument
    ambiguous = []
    for name in (:mul!, :_mul!)
        isdefined(LinearAlgebra, name) || continue
        ms = collect(methods(getfield(LinearAlgebra, name)))
        for m in ms, n in ms
            m.module === Metal && m !== n && Base.isambiguous(m, n) &&
                push!(ambiguous, "$(m.file):$(m.line) and $(n.file):$(n.line)")
        end
    end
    @test isempty(ambiguous)
end

@testset "native GEMM" begin
    op(M, t) = t == 'N' ? M : t == 'C' ? adjoint(M) : transpose(M)
    mk(T, sz) = T <: Integer ? rand(T(1):T(4), sz...) : rand(T, sz...)
    tol(T) = real(T) in (Float16, BFloat16) ? 1.0f-1 : real(T) == Float32 ? 1.0f-3 : 1e-5

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

    # simd path (Float16/Float32/BFloat16): transpose × α/β × ragged shapes. Forced via `:simd`
    # so the simdgroup kernel is exercised regardless of whether a tensor path is available.
    # BFloat16 routes its epilogue through f32 scratch (see `simd_direct_store`), which the
    # β≠0 / ragged cases here exercise.
    @testset "$T $tA$tB α=$α β=$β" for T in (Float32, Float16, BFloat16),
                                        (tA, tB) in (("N","N"), ("N","T"), ("T","N"), ("T","T")),
                                        (α, β) in ((T(1), T(0)), (T(2), T(0)), (T(1), T(1)), (T(2), T(3)))
        @test nativetest(T, 64, 48, 32, only(tA), only(tB), α, β; alg=:simd)   # aligned
        @test nativetest(T, 65, 47, 33, only(tA), only(tB), α, β; alg=:simd)   # ragged
    end

    # generic fallback of `:native` (ComplexF32, Int32): includes conjugate transpose
    @testset "$T $tA$tB" for T in (ComplexF32, Int32),
                             (tA, tB) in (("N","N"), ("N","T"), ("T","N"), ("C","N"), ("N","C"))
        α = T(2); β = T <: Integer ? T(1) : T(1) / 2
        @test nativetest(T, 40, 24, 16, only(tA), only(tB), α, β)
        @test nativetest(T, 41, 25, 17, only(tA), only(tB), α, β)   # ragged
    end

    # offset views (dense MtlMatrix with offset≠0): the case MPSGraph falls back on
    @testset "offset views" begin
        for (T, alg) in ((Float32, :simd), (ComplexF32, :native))
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

    # Symmetric/Hermitian wrapper chars ('S'/'s'/'H'/'h'): the simd kernel gathers through
    # the stored triangle, as the generic one does for the eltypes that fall back to it.
    # The reference uses the same wrapper on the CPU, so the random data in the non-stored
    # triangle catches any read outside the stored one. BLAS eltypes (Float32/ComplexF32)
    # only reach Metal's storage-level `mul!` on Julia 1.12+, where GPUArrays overrides
    # generic_matmatmul_wrapper! away from BLAS.symm!/hemm!.
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
        for alg in (:simd, :GPUArrays)
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
        if supported(:MPSGraph)
            A = MtlArray(rand(Float32, 96, 80)); B = MtlArray(rand(Float32, 80, 64))
            Cj = MtlArray(zeros(Float32, 96, 64)); Cg = MtlArray(zeros(Float32, 96, 64))
            @with (Metal.matmul_alg => :native) mul!(Cj, A, B)
            @with (Metal.matmul_alg => :MPSGraph) mul!(Cg, A, B)
            @test isapprox(Array(Cj), Array(Cg); rtol=1.0f-3)
        else
            @test_skip "matmul_alg = :MPSGraph"
        end
    end

    # Metal 4 tensor-ops path (`:tensor`): only fires on a capable device (macOS 26+ /
    # Metal4 family), for the plain C = A·B (N/N, α=1, β=0) with tile-divisible dims and a
    # supported eltype.
    @testset "tensor-ops path" begin
        # the tensor intrinsics take the operands of the targeted AIR version
        Mat = MtlDeviceMatrix{Float32, 1}
        tt = Tuple{Mat, Mat, Mat, UInt32, UInt32, UInt32,
                   Val{Int32(64)}, Val{Int32(64)}, Val{Int32(32)}, Val{Int32(4)}}
        air(macos) = sprint() do io
            Metal.code_air(io, Metal.gemm_tensor_kernel!, tt; kernel=true, macos,
                           dump_module=true)
        end
        # Typed-pointer LLVM versions may use either i8 or {} as the pointee type. The null
        # pointer is passed through a cast to the type the intrinsic is declared with.
        @test occursin(r"call void @air\.init_strided_private_tensor\.i32\.global\(.*, i8 0, (?:(?:i8|\{\}) addrspace\(1\)\*|ptr addrspace\(1\)) (?:null|%\d+), i32 0, i8 -1\)\n",
                       air(v"27"))
        # the thread count is one the GPU compiler resolves when it compiles for the device
        @test occursin("call i32 @air.get_simdgroup_size.i32()", air(v"27"))
        # matmul2d is called through the entry point of the targeted macOS version, with
        # neither quantization scales nor static extents
        @test occursin(r"call void @__tensorops_impl_matmul2d_op_run_dv_f32_dv_f32_dv_f32_v2\([^,]+, [^,]+, i32 2, i32 0, i32 0, i32 0, i32 -1, i32 -1, [^,]+, i32 2, i32 0, i32 0, i32 0, i32 -1, i32 -1, [^,]+, i32 2, i32 -1, i32 -1, i32 %\d+\)",
                       air(v"27"))
        @test occursin(r"call void @__tensorops_impl_matmul2d_op_run_dv_f32_dv_f32_dv_f32\([^,]+, [^,]+, i32 2, [^,]+, i32 2, [^,]+, i32 2, i32 %\d+\)",
                       air(v"26"))
        # the declarations carry the pointee types Apple's front end uses, for the downgrader
        @test occursin("!{i32 0, %struct._tensor_t undef, i32 2, i8 undef, i32 3, i8 undef, i32 4, i8 undef, i32 6, i8 undef}",
                       air(v"27"))
        @test occursin("!{i32 0, %\"struct.mpp::tensor_ops::matmul2d_descriptor\" undef, i32 1, i8 undef, i32 8, i8 undef, i32 15, i8 undef}",
                       air(v"27"))
        # the descriptors are allocated with a size the back end computes, like Apple's
        # front end does it
        let ir = air(v"27"), m = match(r"(%\d+) = call i64 @metal\.tensor_descriptor_size\.r2\(\)", ir)
            # (three tensors and three views)
            @test m !== nothing && count("alloca i8, i64 $(m[1]), align 8", ir) == 6
        end
        @test occursin(r"define linkonce_odr hidden i64 @metal\.tensor_descriptor_size\.r2\(\)[^\n]*\{\n[^\n]*\n\s+%\d+ = call i16 @air\.get_descriptor_size_tensor\(i16 2, i16 4\)",
                       air(v"27"))
        @test occursin(r"attributes #\d+ = \{ \"deferred-static-alloca-size\" \}", air(v"27"))
        # narrow integers are passed without extension attribute
        @test !occursin("signext", air(v"27"))
        @test occursin(r"call void @air\.init_strided_private_tensor\.i32\.global\(.*, i8 0\)\n",
                       air(v"26"))
        ## the views over threadgroup memory take a threadgroup pointer
        function tg_tensor(out)
            buf = MtlThreadGroupArray(Float32, (8, 4))
            t = Metal.MtlInlineTensor{Float32, 2, Metal.AS.ThreadGroup}(buf, (8, 4))
            out[1] = Metal.get_extent_private_tensor(t.storage, Int16(2), Int16(1))
            return
        end
        tg_air(macos) = sprint() do io
            Metal.code_air(io, tg_tensor, Tuple{MtlDeviceVector{Int32, 1}}; kernel=true, macos)
        end
        @test occursin(r"call void @air\.init_strided_private_tensor\.i32\.local\(.*, i8 0, (?:(?:i8|\{\}) addrspace\(3\)\*|ptr addrspace\(3\)) (?:null|%\d+), i32 0, i8 -1\)\n",
                       tg_air(v"27"))
        @test occursin(r"call void @air\.init_strided_private_tensor\.i32\.local\(.*, i8 0\)\n",
                       tg_air(v"26"))
        @test occursin(r"call i32 @air\.get_extent_private_tensor\.i32\(.*, i16 1, i16 0\)\n",
                       tg_air(v"27"))
        @test occursin(r"call i32 @air\.get_extent_private_tensor\.i32\(.*, i16 1\)\n",
                       tg_air(v"26"))
        ## tensors live on the stack, so they cannot escape the kernel
        @noinline tensor_extent(t) = Metal.get_extent_private_tensor(t.storage, Int16(2), Int16(0))
        function escaping_tensor(out, A)
            out[1] = tensor_extent(Metal.MtlInlineTensor(A))
            return
        end
        @test_throws "escaped the kernel's stack" Metal.code_air(devnull, escaping_tensor,
            Tuple{MtlDeviceVector{Int32, 1}, MtlDeviceMatrix{Float32, 1}}; kernel=true)
        ## the size of a descriptor depends on its rank
        function ranked_tensors(out, A)
            t1 = Metal.MtlInlineTensor(A, (256,))
            t3 = Metal.MtlInlineTensor(A, (4, 8, 8))
            out[1] = Metal.get_extent_private_tensor(t1.storage, Int16(1), Int16(0)) +
                     Metal.get_extent_private_tensor(t3.storage, Int16(3), Int16(2))
            return
        end
        let ir = sprint() do io
                Metal.code_air(io, ranked_tensors,
                               Tuple{MtlDeviceVector{Int32, 1}, MtlDeviceMatrix{Float32, 1}};
                               kernel=true)
            end
            for rank in (1, 3)
                m = match(Regex("(%\\d+) = call i64 @metal\\.tensor_descriptor_size\\.r$rank\\(\\)"), ir)
                @test m !== nothing && count("alloca i8, i64 $(m[1]), align 8", ir) == 1
            end
        end
        if Metal.tensor_matmul_capable()
            @testset "macOS $macos" for macos in filter(<=(Metal.macos_version()), [v"26", v"27"])
                out = MtlArray(zeros(Int32, 1))
                @metal macos=macos tg_tensor(out)
                @test Array(out) == [4]

                @metal macos=macos ranked_tensors(out, MtlArray(zeros(Float32, 16, 16)))
                @test Array(out) == [256 + 8]
            end
        end

        if Metal.tensor_matmul_capable()
            ttol(T) = T === Float32 ? 1.0f-3 : 1.0f-1
            # BFloat16 tensor operands need macOS 26.1
            ttypes = Metal.macos_version() >= v"26.1" ? (Float32, Float16, BFloat16) : (Float32, Float16)
            @testset "$T $M×$N×$K" for T in ttypes,
                                       (M, N, K) in ((64, 64, 32), (128, 256, 64), (512, 512, 128))
                A = MtlArray(rand(T, M, K)); B = MtlArray(rand(T, K, N))
                ref = Array(A) * Array(B)
                @test Metal.supports_tensor_matmul(MtlArray(zeros(T, M, N)), A, B, 'N', 'N', true, false)
                Ct = MtlArray(zeros(T, M, N))
                @with (Metal.matmul_alg => :tensor) mul!(Ct, A, B)
                @test isapprox(Array(Ct), ref; rtol=ttol(T))
            end

            # every element type combination in `GEMM_TENSOR_ELTYPES` gives the right product, or
            # is rejected when macOS is too old for it (BFloat16: 26.1, UInt8: 26.4)
            tgen(T, dims...) = T <: Integer ? rand(T <: Unsigned ? (T(0):T(10)) : (T(-5):T(5)), dims...) : rand(T, dims...)
            @testset "$TA × $TB → $TC" for (TA, TB, TC) in sort!(collect(Metal.GEMM_TENSOR_ELTYPES); by=string)
                a = tgen(TA, 64, 32); b = tgen(TB, 32, 64)
                A = MtlArray(a); B = MtlArray(b); C = MtlArray(zeros(TC, 64, 64))
                needs = max(BFloat16 in (TA, TB, TC) ? v"26.1" : v"26", UInt8 in (TA, TB) ? v"26.4" : v"26")
                if Metal.macos_version() >= needs
                    @test Metal.supports_tensor_matmul(C, A, B, 'N', 'N', true, false)
                    @with (Metal.matmul_alg => :tensor) mul!(C, A, B)
                    # integer products are exact
                    @test isapprox(Float64.(Array(C)), Float64.(a) * Float64.(b); rtol=TC <: Integer ? 0 : ttol(TC))
                else
                    @test !Metal.supports_tensor_matmul(C, A, B, 'N', 'N', true, false)
                    @test_throws Exception (@with (Metal.matmul_alg => :tensor) mul!(C, A, B))
                end
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

# factorizations and solves of Float32 matrices use MPS, which is optional
mps = MPS.is_supported(device())

@testset "decompositions" begin
    if mps
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

        # singular matrices report the first zero pivot, like LAPACK
        a = Float32[1 2; 2 4]
        A = MtlMatrix(a)
        @test_throws SingularException(2) lu(A)
        @test_throws SingularException(2) lu!(copy(A))
        @test_throws SingularException(2) A \ MtlVector(Float32[1, 2])
        @test lu(A; check=false).info == lu(a; check=false).info
    else
        @test_skip "Float32 LU (MPS)"
    end

    # MPS only decomposes Float32 matrices, and aborts the process on others; they use
    # LinearAlgebra's generic implementation instead, which needs CPU access to the array
    if Metal.DefaultStorageMode == Metal.SharedStorage
        a = Float16[4 1; 1 3]
        A = MtlMatrix(a)
        lua = lu(A)
        @test Array(lua.L * lua.U) ≈ a[lua.p, :]
        # (cholesky promotes to Float32)
        @test Array(cholesky(A).U) ≈ cholesky(a).U skip=!mps
        @test Array(A \ MtlVector(Float16[1, 2])) ≈ a \ Float16[1, 2]
    end

    if mps
        altStorage = Metal.DefaultStorageMode != Metal.SharedStorage ? Metal.SharedStorage : Metal.PrivateStorage
        A = MtlMatrix{Float32, altStorage}(rand(Float32, 1024, 1024))
        lua = lu(A)
        @test storagemode(lua.factors) == storagemode(lua.ipiv) == storagemode(A)
        lua = lu!(A)
        @test storagemode(lua.factors) == storagemode(lua.ipiv) == storagemode(A)
    else
        @test_skip "Float32 LU (MPS)"
    end

    @testset "empty $(M)×$(N)" for (M, N) in ((0, 0), (0, 3), (3, 0))
        A = MtlMatrix{Float32}(undef, M, N)
        for lua in (lu(A), lu!(A))
            @test size(lua.factors) == (M, N)
            @test isempty(lua.ipiv)
            @test lua.ipiv isa MtlVector{UInt32}
            @test issuccess(lua)
        end
    end
end

@testset "linear solve" begin
    T = Float32
    n = 64
    nrhs = 3

    # storage mode is transparent to the solve kernels, and CI runs the whole suite
    # under both the private- and shared-default storage modes, so the numerical tests
    # just use the default storage. A separate check below pins storage propagation.
    A = rand(T, n, n)
    A .+= T(n) .* Matrix{T}(I, n, n)
    b = rand(T, n)
    B = rand(T, n, nrhs)
    BR = rand(T, nrhs, n)

    dA = MtlMatrix(A)
    db = MtlVector(b)
    dB = MtlMatrix(B)
    dBR = MtlMatrix(BR)

    if mps
        @test Array(dA \ db) ≈ A \ b rtol=1f-4
        @test Array(dA \ dB) ≈ A \ B rtol=1f-4

        # Regression coverage for JuliaGPU/Metal.jl#145: older MPS solve code reported
        # blocks of NaNs for systems larger than 128x128.
        nlarge = 160
        Alarge = rand(T, nlarge, nlarge)
        Alarge .+= T(nlarge) .* Matrix{T}(I, nlarge, nlarge)
        Blarge = rand(T, nlarge, nlarge)
        dAlarge = MtlMatrix(Alarge)
        dBlarge = MtlMatrix(Blarge)
        xlarge = Array(dAlarge \ dBlarge)
        @test all(isfinite, xlarge)
        @test xlarge ≈ Alarge \ Blarge rtol=1f-4
        Flarge = lu(dAlarge)
        xlarge = Array(Flarge \ dBlarge)
        @test all(isfinite, xlarge)
        @test xlarge ≈ Alarge \ Blarge rtol=1f-4
        Ularge = UpperTriangular(MtlMatrix(triu(Alarge)))
        xlarge = Array(Ularge \ dBlarge)
        @test all(isfinite, xlarge)
        @test xlarge ≈ UpperTriangular(triu(Alarge)) \ Blarge rtol=1f-4
        Llarge = LowerTriangular(MtlMatrix(tril(Alarge)))
        xlarge = Array(Llarge \ dBlarge)
        @test all(isfinite, xlarge)
        @test xlarge ≈ LowerTriangular(tril(Alarge)) \ Blarge rtol=1f-4
    else
        @test_skip "Float32 solves (MPS)"
    end

    Als = rand(T, 8, 7)
    bls = rand(T, 8)
    dAls = MtlMatrix(Als)
    dbls = MtlVector(bls)
    if Metal.DefaultStorageMode == Metal.PrivateStorage
        @test_throws ErrorException dAls \ dbls
    else
        @test dAls \ dbls ≈ Als \ bls rtol=1f-4
    end

    if mps
        Ap = T[0 2 1; 1 1 0; 2 0 1]
        bp = T[1, 2, 3]
        dAp = MtlMatrix(Ap)
        dbp = MtlVector(bp)
        Fp = lu(dAp)
        @test Array(Fp \ dbp) ≈ Ap \ bp rtol=1f-4
        xp = copy(dbp)
        ldiv!(Fp, xp)
        @test Array(xp) ≈ Ap \ bp rtol=1f-4
        xp = similar(dbp)
        ldiv!(xp, Fp, dbp)
        @test Array(xp) ≈ Ap \ bp rtol=1f-4

        F = lu(dA)
        @test Array(F \ db) ≈ A \ b rtol=1f-4
        @test Array(F \ dB) ≈ A \ B rtol=1f-4
        x = copy(db)
        ldiv!(F, x)
        @test Array(x) ≈ A \ b rtol=1f-4
        x = similar(db)
        ldiv!(x, F, db)
        @test Array(x) ≈ A \ b rtol=1f-4

        M = rand(T, n, n)
        SPD = M'M + T(n) .* Matrix{T}(I, n, n)
        dSPD = MtlMatrix(SPD)
        C = cholesky(dSPD)
        @test Array(C \ db) ≈ SPD \ b rtol=1f-4

        CS = cholesky(Symmetric(dSPD, :L))
        @test Array(CS \ dB) ≈ SPD \ B rtol=1f-4

        CH = cholesky(Hermitian(dSPD, :U))
        yc = copy(db)
        ldiv!(CH, yc)
        @test Array(yc) ≈ SPD \ b rtol=1f-4

        for (triangle, cpuA) in ((UpperTriangular, triu(A)),
                                (LowerTriangular, tril(A)),
                                (UnitUpperTriangular, triu(A)),
                                (UnitLowerTriangular, tril(A)))
            dT = triangle(MtlMatrix(cpuA))
            cT = triangle(cpuA)
            @test Array(dT \ db) ≈ cT \ b rtol=1f-4
            @test Array(dT \ dB) ≈ cT \ B rtol=1f-4
            @test Array(transpose(dT) \ db) ≈ transpose(cT) \ b rtol=1f-4
            @test Array(transpose(dT) \ dB) ≈ transpose(cT) \ B rtol=1f-4
            @test Array(dBR / dT) ≈ BR / cT rtol=1f-4
            @test Array(dBR / transpose(dT)) ≈ BR / transpose(cT) rtol=1f-4
            y = copy(db)
            ldiv!(dT, y)
            @test Array(y) ≈ cT \ b rtol=1f-4
            Y = copy(dBR)
            rdiv!(Y, dT)
            @test Array(Y) ≈ BR / cT rtol=1f-4
            Yt = copy(dBR)
            rdiv!(Yt, transpose(dT))
            @test Array(Yt) ≈ BR / transpose(cT) rtol=1f-4
        end
    else
        @test_skip "Float32 factorizations and solves (MPS)"
    end

    @testset "empty $(triangle)" for triangle in (UpperTriangular, UnitLowerTriangular)
        E, e, W = MtlMatrix{T}(undef, 0, 0), MtlVector{T}(undef, 0), MtlMatrix{T}(undef, 0, 3)
        @test size(triangle(E) \ e) == (0,)
        @test size(triangle(E) \ W) == (0, 3)
        @test size(transpose(triangle(E)) \ W) == (0, 3)
        @test size(copy(W') / triangle(E)) == (3, 0)
        @test size(copy(W') / transpose(triangle(E))) == (3, 0)
        @test size(triangle(dA) \ MtlMatrix{T}(undef, n, 0)) == (n, 0)
    end

    if mps
        @testset "empty LU and Cholesky" begin
            E, W, Z = MtlMatrix{T}(undef, 0, 0), MtlMatrix{T}(undef, 0, 3), MtlMatrix{T}(undef, n, 0)
            @test size(E \ W) == (0, 3)
            @test size(lu(E) \ W) == (0, 3)
            @test size(cholesky(E) \ W) == (0, 3)
            @test size(dA \ Z) == (n, 0)
            @test size(F \ Z) == (n, 0)
            @test size(C \ Z) == (n, 0)
            # without right hand sides, the coefficient matrix is still checked
            @test_throws SingularException MtlMatrix(T[1 2; 2 4]) \ MtlMatrix{T}(undef, 2, 0)
        end

        dsing = MtlMatrix(T[1 2; 2 4])
        bsing = MtlVector(T[1, 2])
        @test_throws SingularException dsing \ bsing

        dnonposdef = MtlMatrix(T[1 2; 2 1])
        @test_throws PosDefException cholesky(dnonposdef)

        # outputs should inherit the storage mode of the inputs
        altStorage = Metal.DefaultStorageMode != Metal.PrivateStorage ? Metal.PrivateStorage : Metal.SharedStorage
        aA = MtlMatrix{T,altStorage}(A)
        ab = MtlVector{T,altStorage}(b)
        @test storagemode(aA \ ab) == altStorage
        @test storagemode(cholesky(MtlMatrix{T,altStorage}(SPD)).factors) == altStorage
    else
        @test_skip "Float32 factorizations and solves (MPS)"
    end
end

@testset "derived" begin
    T = Float32
    n = 16

    A = rand(T, n, n)
    A .+= T(n) .* Matrix{T}(I, n, n)
    dA = MtlMatrix(A)

    if mps
        F = lu(dA)
        cF = lu(A)
        @test det(dA) ≈ det(A) rtol=1f-4
        @test det(F) ≈ det(cF) rtol=1f-4

        logabs, sgndet = logabsdet(dA)
        clogabs, csgndet = logabsdet(A)
        @test logabs ≈ clogabs rtol=1f-4
        @test sgndet ≈ csgndet
        flogabs, fsgndet = logabsdet(F)
        cflogabs, fcsgndet = logabsdet(cF)
        @test flogabs ≈ cflogabs rtol=1f-4
        @test fsgndet ≈ fcsgndet
        @test logdet(dA) ≈ logdet(A) rtol=1f-4
        @test logdet(F) ≈ logdet(cF) rtol=1f-4

        invA = inv(dA)
        @test Array(invA) ≈ inv(A) rtol=1f-4
        @test Array(inv(F)) ≈ inv(cF) rtol=1f-4
        @test Array(invA * dA) ≈ Matrix{T}(I, n, n) rtol=1f-4

        M = rand(T, n, n)
        SPD = M'M + T(n) .* Matrix{T}(I, n, n)
        dSPD = MtlMatrix(SPD)
        C = cholesky(dSPD)
        cC = cholesky(SPD)
        @test det(C) ≈ det(cC) rtol=1f-4
        @test logdet(C) ≈ logdet(cC) rtol=1f-4
        clogabs, csgndet = logabsdet(C)
        cclogabs, ccsgndet = logabsdet(cC)
        @test clogabs ≈ cclogabs rtol=1f-4
        @test csgndet ≈ ccsgndet
        @test Array(inv(C)) ≈ inv(cC) rtol=1f-4

        pivotA = T[0 1; 1 0]
        dpivotA = MtlMatrix(pivotA)
        @test det(dpivotA) ≈ det(pivotA)
        _, pivotsign = logabsdet(dpivotA)
        @test pivotsign ≈ -one(T)

        dsing = MtlMatrix(T[1 2; 2 4])
        @test det(dsing) == zero(T)

        altStorage = Metal.DefaultStorageMode != Metal.PrivateStorage ? Metal.PrivateStorage : Metal.SharedStorage
        aA = MtlMatrix{T,altStorage}(A)
        aSPD = MtlMatrix{T,altStorage}(SPD)
        @test storagemode(inv(aA)) == altStorage
        @test storagemode(inv(lu(aA))) == altStorage
        @test storagemode(inv(cholesky(aSPD))) == altStorage
    else
        @test_skip "Float32 factorizations (MPS)"
    end

    @test tr(dA) ≈ tr(A)
    @test det(UpperTriangular(dA)) ≈ det(UpperTriangular(A)) rtol=1f-4
end

@testset "transpose" begin
    A = MtlMatrix(rand(Float32, 0, 1024))
    B = Metal.zeros(Float32, 1024, 0)

    # Issue #656
    @test isempty(transpose!(B, A))

    @testset "$T" for T in (Float32, ComplexF32, Int64, Complex{Int16})
        A = rand(T, 5, 3)
        @test Array(transpose!(Metal.zeros(T, 3, 5), MtlMatrix(A))) == transpose(A)
        @test Array(copy(transpose(MtlMatrix(A)))) == transpose(A)
    end
end
