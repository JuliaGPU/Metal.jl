using Test, Metal

using LinearAlgebra, ScopedValues

@testset "matmul algorithm selection" begin
    # MPSGraph's Float16 matmul produces wrong results on some paravirtualized GPUs (e.g. the
    # GitHub Actions runners), even though it works on others. Skip those correctness checks
    # on virtual devices; the buildkite CI still covers them on real hardware.
    virtual = Metal.is_virtual(Metal.device())

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
        @test test_matmul(mpsInT, Float32; vec_b, alg=:MPS)
        @test test_matmul(Float16, Float32; vec_b, alg=:MPS)

        # :MPSGraph
        @test test_matmul(Int8, Float32; vec_b, alg=:MPSGraph)
        @test test_matmul(Float16, Float32; vec_b, alg=:MPSGraph) skip=virtual

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
        # :tensor, also for matrix-vector products (a one-column GEMM)
        if Metal.tensor_matmul_capable()
            @test test_matmul(Float32, Float32; vec_b, alg=:tensor)
            @test test_matmul(Float16, Float32; vec_b, alg=:tensor)
        else
            @test_throws "algorithm `:tensor`" test_matmul(Float32, Float32; vec_b, alg=:tensor)
        end
        end
    end
end

@testset "β = 0 ignores the output's contents" begin
    A = MtlArray(rand(Float32, 8, 8))
    B = MtlArray(rand(Float32, 8, 8))
    x = MtlArray(rand(Float32, 8))
    @testset "$alg" for alg in (:auto, :MPS, :MPSGraph, :native, :GPUArrays)
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
        algs = (:auto, :native, :simd, :GPUArrays)
        Metal.tensor_matmul_capable() && (algs = (algs..., :tensor))
        # Float64 scalars must not reach the kernels
        for alg in algs, (α, β) in ((2f0, 0.5f0), (2, 0.5))
            dc, da, db = f(copy(dC), dA, dB, dx, copy(dy))
            @with (Metal.matmul_alg => alg) mul!(dc, da, db, α, β)
            @test Array(dc) ≈ ref
        end
        dc, da, db = f(copy(dC), dA, dB, dx, copy(dy))
        mul!(dc, da, db, 0, 0.5)
        @test Array(dc) ≈ c / 2
        for alg in (:MPS, :MPSGraph)
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
    for alg in (:simd, :tensor)
        @test_throws "multiplication algorithm `:$alg` is not supported" @with (Metal.matmul_alg => alg) mul!(c, a, b)
    end
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

    # the dedicated matrix-vector kernels, which `:native` uses for real floats
    @testset "matrix-vector kernels" begin
        # y = α·op(A)·x + β·y against Float64 on the host; with β = 0, y holds NaNs. Signed
        # inputs cancel, so the error is relative to α·|op(A)|·|x| + β·|y| for each element.
        function gemvtest(TA, TX, TY, tA, M, K, α, β)
            a = TA.(rand(Float32, tA == 'N' ? (M, K) : (K, M)) .- 0.5f0)
            x = TX.(rand(Float32, K) .- 0.5f0)
            y0 = iszero(β) ? fill(TY(NaN), M) : TY.(rand(Float32, M))
            dy = MtlArray(y0)
            @with (Metal.matmul_alg => :native) mul!(dy, op(MtlArray(a), tA), MtlArray(x), α, β)
            y1 = iszero(β) ? zeros(M) : Float64.(y0)
            ref = α .* (op(Float64.(a), tA) * Float64.(x)) .+ β .* y1
            scale = abs(α) .* (abs.(op(Float64.(a), tA)) * abs.(Float64.(x))) .+ abs(β) .* abs.(y1)
            rtol = all(==(Float32), (TA, TX, TY)) ? 1e-5 : TY == BFloat16 ? 1e-2 : 2e-3
            # (plus the rounding of a subnormal result)
            all(abs.(Float64.(Array(dy)) .- ref) .<= rtol .* scale .+ nextfloat(zero(TY)))
        end
        @testset "$TA×$TX→$TY $tA" for (TA, TX, TY) in ((Float32, Float32, Float32),
                                                        (Float16, Float16, Float16),
                                                        (BFloat16, BFloat16, BFloat16),
                                                        (Float16, Float16, Float32),
                                                        (BFloat16, Float32, Float32)),
                                       tA in ('N', 'T', 'C')
            for (M, K) in ((1, 1), (7, 33), (33, 7), (1, 1000), (1000, 1), (1000, 1000)),
                (α, β) in ((1, 0), (2, 0), (1, 1), (2, 0.5))
                @test gemvtest(TA, TX, TY, tA, M, K, α, β)
            end
        end

        # shapes that select other launch configurations
        @testset "$tA $M×$K" for tA in ('N', 'T'),
                                 (M, K) in ((256, 65536), (65536, 256), (1025, 69), (4096, 4096), (4097, 4099))
            @test gemvtest(Float32, Float32, Float32, tA, M, K, 2, 0.5)
        end

        # views: matrices with a column stride and an offset, vectors at an offset or strided;
        # what lies outside of the destination view stays untouched
        P = MtlArray(rand(Float32, 70, 80)); p = MtlArray(rand(Float32, 200))
        @testset "views $tA" for tA in ('N', 'T'), A in (view(P, 3:35, 2:41), view(P, 3:35, 2:2:80))
            M, K = tA == 'N' ? (33, 40) : (40, 33)
            for (x, Y, iy) in ((view(p, 5:4+K), MtlArray(rand(Float32, 200)), (7:6+M,)),
                               (view(p, 1:3:3K), MtlArray(rand(Float32, 200)), (2:2:2M,)),
                               (view(P, 2:1+K, 50), MtlArray(rand(Float32, 70, 3)), (1:M, 2)))
                Y0 = Array(Y)
                @with (Metal.matmul_alg => :native) mul!(view(Y, iy...), op(A, tA), x, 2, 0.5)
                ref = copy(Y0)
                ref[iy...] = 2 * op(Array(A), tA) * Array(x) + 0.5 * Y0[iy...]
                @test Array(Y) ≈ ref
            end
        end
        # single-column products of matrices, also with a strided row as op(B)
        let A = MtlArray(rand(Float32, 50, 30)), C = MtlArray(rand(Float32, 50, 1))
            for B in (MtlArray(rand(Float32, 1, 30)), view(P, 3:3, 2:31))
                C0 = Array(C)
                @with (Metal.matmul_alg => :native) mul!(C, A, transpose(B), 2, 0.5)
                @test Array(C) ≈ 2 * Array(A) * transpose(Array(B)) + 0.5 * C0
            end
        end

        # which operands take the kernels; the others take the GEMM ones
        let A = MtlArray(rand(Float32, 8, 8)), x = MtlArray(rand(Float32, 8, 1)), y = MtlArray(rand(Float32, 8, 1))
            @test Metal.supports_gemv(y, A, x, 'N', 'N')
            @test Metal.supports_gemv(view(y, 1:4, :), view(A, 2:5, :), x, 'N', 'N')
            @test !Metal.supports_gemv(view(y, 1:4, :), view(A, 1:2:8, :), x, 'N', 'N')  # stepped rows
            @test !Metal.supports_gemv(y, A, x, 'S', 'N')                                 # Symmetric
            @test !Metal.supports_gemv(MtlArray(rand(Float32, 8, 2)), A, MtlArray(rand(Float32, 8, 2)), 'N', 'N')
            @test !Metal.supports_gemv(MtlArray(rand(ComplexF32, 8, 1)), MtlArray(rand(ComplexF32, 8, 8)),
                                       MtlArray(rand(ComplexF32, 8, 1)), 'N', 'N')
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

        # forcing a specific kernel works too
        A64 = MtlArray(rand(Float32, 64, 64)); B64 = MtlArray(rand(Float32, 64, 64))
        ref = Symmetric(Array(A64)) * Array(B64)
        algs = Metal.tensor_matmul_capable() ? (:simd, :GPUArrays, :tensor) : (:simd, :GPUArrays)
        for alg in algs
            C64 = MtlArray(zeros(Float32, 64, 64))
            @with (Metal.matmul_alg => alg) mul!(C64, Symmetric(A64), B64)
            @test isapprox(Array(C64), ref; rtol=tol(Float32))
        end
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
    # Metal4 family), for C = α·op(A)·op(B) + β·C of matrices and views of a supported eltype.
    @testset "tensor-ops path" begin
        # the tensor intrinsics take the operands of the targeted AIR version
        Mat = MtlDeviceMatrix{Float32, 1}
        tt = Tuple{Mat, Mat, Mat, Float32, Float32, Int32, Int32, Int32, Int32,
                   Int32, Int32, Int32,
                   Val{Int32(32)}, Val{Int32(16)}, Val{:overwrite},
                   Val{false}, Val{false}}
        air(macos) = sprint() do io
            Metal.code_air(io, Metal.gemm_tensor_kernel!, tt; kernel=true, macos,
                           dump_module=true)
        end
        air27, air26 = air(v"27"), air(v"26")
        # Typed-pointer LLVM versions may use either i8 or {} as the pointee type. The null
        # pointer is passed through a cast to the type the intrinsic is declared with.
        @test occursin(r"call void @air\.init_strided_private_tensor\.i32\.global\(.*, i8 0, (?:(?:i8|\{\}) addrspace\(1\)\*|ptr addrspace\(1\)) (?:null|%\d+), i32 0, i8 -1\)\n",
                       air27)
        # the thread count is one the GPU compiler resolves when it compiles for the device
        @test occursin("call i32 @air.get_simdgroup_size.i32()", air27)
        # matmul2d is called through the entry point of the targeted macOS version, with
        # neither quantization scales nor static extents
        @test occursin(r"call void @__tensorops_impl_matmul2d_op_run_dv_f32_dv_f32_dv_f32_v2\([^,]+, [^,]+, i32 2, i32 0, i32 0, i32 0, i32 -1, i32 -1, [^,]+, i32 2, i32 0, i32 0, i32 0, i32 -1, i32 -1, [^,]+, i32 2, i32 -1, i32 -1, i32 %\d+\)",
                       air27)
        @test occursin(r"call void @__tensorops_impl_matmul2d_op_run_dv_f32_dv_f32_dv_f32\([^,]+, [^,]+, i32 2, [^,]+, i32 2, [^,]+, i32 2, i32 %\d+\)",
                       air26)
        # the declarations carry the pointee types Apple's front end uses, for the downgrader
        @test occursin("!{i32 0, %struct._tensor_t undef, i32 2, i8 undef, i32 3, i8 undef, i32 4, i8 undef, i32 6, i8 undef}",
                       air27)
        @test occursin("!{i32 0, %\"struct.mpp::tensor_ops::matmul2d_descriptor\" undef, i32 1, i8 undef, i32 8, i8 undef, i32 15, i8 undef}",
                       air27)
        # the descriptors are allocated with a size the back end computes, like Apple's
        # front end does it
        let ir = air27, m = match(r"(%\d+) = call i64 @metal\.tensor_descriptor_size\.r2\(\)", ir)
            # (three tensors and three views)
            @test m !== nothing && count("alloca i8, i64 $(m[1]), align 8", ir) == 6
        end
        @test occursin(r"define linkonce_odr hidden i64 @metal\.tensor_descriptor_size\.r2\(\)[^\n]*\{\n[^\n]*\n\s+%\d+ = call i16 @air\.get_descriptor_size_tensor\(i16 2, i16 4\)",
                       air27)
        @test occursin(r"attributes #\d+ = \{ \"deferred-static-alloca-size\" \}", air27)
        # narrow integers are passed without extension attribute
        @test !occursin("signext", air27)
        @test occursin(r"call void @air\.init_strided_private_tensor\.i32\.global\(.*, i8 0\)\n",
                       air26)
        ## the kernel scales in cooperative tensors
        let tt = Tuple{Mat, Mat, Mat, Float32, Float32, Int32, Int32, Int32, Int32, Int32, Int32,
                       Int32, Val{Int32(32)}, Val{Int32(16)}, Val{:scale_add}, Val{false}, Val{false}}
            scaled(macos) = sprint() do io
                Metal.code_air(io, Metal.gemm_tensor_kernel!, tt; kernel=true, macos,
                               dump_module=true)
            end
            ir = scaled(v"27")
            # (the product and the old contents of C)
            m = match(r"(%\d+) = call i64 @metal\.cooperative_tensor_size\.[n\d.]+\(\)", ir)
            @test m !== nothing && count("alloca i8, i64 $(m[1]), align 4", ir) == 2
            @test occursin(r"call void @__tensorops_impl_matmul2d_op_run_cooperative_dv_f32_dv_f32_f32_v2\([^,]+, [^,]+, i32 2, i32 0, i32 0, i32 0, i32 -1, i32 -1, [^,]+, i32 2, i32 0, i32 0, i32 0, i32 -1, i32 -1, [^,]+, i32 %\d+\)",
                           ir)
            @test occursin(r"call void @__tensorops_impl_matmul2d_op_run_cooperative_dv_f32_dv_f32_f32\([^,]+, [^,]+, i32 2, [^,]+, i32 2, [^,]+, i32 %\d+\)",
                           scaled(v"26.2"))
        end
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
        ## views of static size pass their extents on to matmul2d, the others pass none
        function static_views(C, A, B)
            tA = Metal.MtlInlineTensor(A); tB = Metal.MtlInlineTensor(B); tC = Metal.MtlInlineTensor(C)
            matmul = Metal.TensorOpsMatmul2D(Metal.matmul2d_descriptor(16, 16), Val(1))
            one = Int32(1)
            # a tile of 16 rows of static size (with K dynamic), and what is left below it
            matmul(view(tA, (one, one), Val((16, :))), view(tB, (one, one), Val((:, 16))),
               view(tC, (one, one), Val((16, 16))))
            matmul(view(tA, (Int32(17), one)), view(tB, (one, one), Val((:, 16))),
               view(tC, (Int32(17), one)))
            return
        end
        static_air(macos) = sprint() do io
            Metal.code_air(io, static_views, Tuple{Mat, Mat, Mat}; kernel=true, macos,
                           dump_module=true)
        end
        static27, static26 = static_air(v"27"), static_air(v"26")
        # (the extents of B, A and C)
        @test occursin(r"call void @__tensorops_impl_matmul2d_op_run_dv_f32_dv_f32_dv_f32_v2\([^,]+, [^,]+, i32 2, i32 0, i32 0, i32 0, i32 -1, i32 16, [^,]+, i32 2, i32 0, i32 0, i32 0, i32 16, i32 -1, [^,]+, i32 2, i32 16, i32 16, i32 %\d+\)",
                       static27)
        @test occursin(r"call void @__tensorops_impl_matmul2d_op_run_dv_f32_dv_f32_dv_f32_v2\([^,]+, [^,]+, i32 2, i32 0, i32 0, i32 0, i32 -1, i32 16, [^,]+, i32 2, i32 0, i32 0, i32 0, i32 -1, i32 -1, [^,]+, i32 2, i32 -1, i32 -1, i32 %\d+\)",
                       static27)
        # (the original entry point takes no static extents, which are only a hint)
        @test count(r"call void @__tensorops_impl_matmul2d_op_run_dv_f32_dv_f32_dv_f32\([^,]+, [^,]+, i32 2, [^,]+, i32 2, [^,]+, i32 2, i32 %\d+\)",
                    static26) == 2
        @test !occursin("matmul2d_op_run_dv_f32_dv_f32_dv_f32_v2", static26)
        ## a cooperative tensor keeps a product in thread-local memory, in storage that the
        ## back end sizes like that of a tensor descriptor
        function cooperative_axpy(C, A, B)
            tA = Metal.MtlInlineTensor(A); tB = Metal.MtlInlineTensor(B); tC = Metal.MtlInlineTensor(C)
            matmul = Metal.TensorOpsMatmul2D(Metal.matmul2d_descriptor(16, 16), Val(1))
            acc = Metal.MtlCooperativeTensor{Float32}(matmul, tA, tB)
            matmul(tA, tB, acc)
            old = Metal.MtlCooperativeTensor{Float32}(matmul, tA, tB)
            copyto!(old, tC)
            # (each thread has its own share of the elements)
            i = Int32(1)
            while i <= length(acc)
                isassigned(acc, i) && (acc[i] = 2f0 * acc[i] + old[i])
                i += Int32(1)
            end
            copyto!(tC, acc)
            return
        end
        # (with operands of another element type than C, whose data type codes then differ)
        cooperative_air(macos, T=Float32) = sprint() do io
            Op = MtlDeviceMatrix{T, 1}
            Metal.code_air(io, cooperative_axpy, Tuple{Mat, Op, Op}; kernel=true, macos,
                           dump_module=true)
        end
        let ir = cooperative_air(v"27")
            # (the product and the old contents of C)
            m = match(r"(%\d+) = call i64 @metal\.cooperative_tensor_size\.[n\d.]+\(\)", ir)
            @test m !== nothing && count("alloca i8, i64 $(m[1]), align 4", ir) == 2
            @test occursin(r"define linkonce_odr hidden i64 @metal\.cooperative_tensor_size\.[n\d.]+\(\)[^\n]*\{\n[^\n]*\n\s+%\d+ = call i32 @air\.get_simdgroup_size\.i32\(\)\n\s+%\d+ = call i64 @__tensorops_impl_matmul2d_op_cooperative_tensor_data_size\(i32 2, i32 16, i32 16, i32 -1, i8 0, i8 0, i8 0, i32 0, i32 268435488, i32 268435488, i32 268435488, i32 %\d+\)",
                           ir)
            @test !occursin("__tensorops_metaljl", ir)
            # `is_valid_element` returns an `i1`, as Apple's front end declares it
            @test occursin(r"declare [^\n]*\bi1 @__tensorops_impl_matmul2d_op_cooperative_tensor_is_valid_element\(", ir)
            # (which it zero-extends, like the number of elements)
            @test occursin(r"call zeroext i1 @__tensorops_impl_matmul2d_op_cooperative_tensor_is_valid_element\(", ir)
            @test occursin(r"call zeroext i16 @__tensorops_impl_matmul2d_op_cooperative_tensor_num_elements\(", ir)
            @test occursin(r"call void @__tensorops_impl_matmul2d_op_run_cooperative_dv_f32_dv_f32_f32_v2\([^,]+, [^,]+, i32 2, i32 0, i32 0, i32 0, i32 -1, i32 -1, [^,]+, i32 2, i32 0, i32 0, i32 0, i32 -1, i32 -1, [^,]+, i32 %\d+\)",
                           ir)
        end
        @test occursin(r"call void @__tensorops_impl_matmul2d_op_run_cooperative_dv_f32_dv_f32_f32\([^,]+, [^,]+, i32 2, [^,]+, i32 2, [^,]+, i32 %\d+\)",
                       cooperative_air(v"26.2"))
        # (before macOS 26.2, the functions only handle destinations, without the operand
        # index, and loading and storing don't take the element type of the destination)
        let ir = cooperative_air(v"26", Float16)
            # (the data types of B, A and C, of which loading drops the last)
            @test occursin(r"call void @__tensorops_impl_matmul2d_op_cooperative_destination_tensor_load_dv_f32\([^\n]*, i32 2, i32 2, i32 268435472, i32 268435472, i32 %\d+\)",
                           ir)
            @test occursin(r"call i64 @__tensorops_impl_matmul2d_op_cooperative_destination_data_size\([^\n]*, i32 268435472, i32 268435472, i32 268435488, i32 %\d+\)",
                           ir)
        end
        let ir = cooperative_air(v"26")
            @test occursin(r"call i64 @__tensorops_impl_matmul2d_op_cooperative_destination_data_size\(i32 16, i32 16, i32 -1, i8 0, i8 0, i8 0, i32 0, i32 268435488, i32 268435488, i32 268435488, i32 %\d+\)",
                           ir)
            @test occursin(r"call void @__tensorops_impl_matmul2d_op_cooperative_destination_tensor_load_dv_f32\(i32 16, i32 16, i32 -1, i8 0, i8 0, i8 0, i32 0, [^,]+, [^,]+, i32 2, i32 2, i32 268435488, i32 268435488, i32 %\d+\)",
                           ir)
            @test occursin(r"call void @__tensorops_impl_matmul2d_op_cooperative_destination_tensor_store_dv_f32\(i32 16, i32 16, i32 -1, i8 0, i8 0, i8 0, i32 0, [^,]+, [^,]+, i32 2, i32 268435488, i32 268435488, i32 %\d+\)",
                           ir)
            @test occursin(r"declare [^\n]*\bzeroext i1 @__tensorops_impl_matmul2d_op_cooperative_destination_tensor_is_valid_element\(", ir)
            @test occursin(r"call zeroext i1 @__tensorops_impl_matmul2d_op_cooperative_destination_tensor_is_valid_element\(", ir)
            @test occursin(r"call zeroext i16 @__tensorops_impl_matmul2d_op_cooperative_destination_tensor_num_elements\(", ir)
            @test !occursin("@__tensorops_impl_matmul2d_op_cooperative_tensor_", ir)
        end
        if Metal.tensor_matmul_capable()
            @testset "macOS $macos" for macos in filter(<=(Metal.macos_version()), [v"26", v"27"])
                out = MtlArray(zeros(Int32, 1))
                @metal macos=macos tg_tensor(out)
                @test Array(out) == [4]

                @metal macos=macos ranked_tensors(out, MtlArray(zeros(Float32, 16, 16)))
                @test Array(out) == [256 + 8]

                # a tile of static size and what is left below it make up the whole product
                a = rand(Float32, 24, 20); b = rand(Float32, 20, 16)
                C = MtlArray(fill(7f0, 24, 16))
                @metal macos=macos threads=32 static_views(C, MtlArray(a), MtlArray(b))
                @test isapprox(Array(C), a * b; rtol=1f-4)
            end
        end
        if Metal.tensor_matmul_capable()
            @testset "cooperative tensors, $T, macOS $macos" for
                    macos in filter(<=(Metal.macos_version()), [v"26", v"26.2", v"27"]),
                    T in (Float32, Float16)
                a = rand(T, 16, 20); b = rand(T, 20, 16); c0 = rand(Float32, 16, 16)
                C = MtlArray(c0)
                @metal macos=macos threads=32 cooperative_axpy(C, MtlArray(a), MtlArray(b))
                @test isapprox(Array(C), 2 * Float32.(a) * Float32.(b) + c0; rtol=1f-3)
            end
        end
        ## with one operand transposed, matmul2d gets the descriptor with m/n and the transpose
        ## flags swapped (see `apple_descriptor`), also for a cooperative destination
        function transposed_product(C, A, B, ::Val{COOP}) where {COOP}
            tA = Metal.MtlInlineTensor(A); tB = Metal.MtlInlineTensor(B); tC = Metal.MtlInlineTensor(C)
            matmul = Metal.TensorOpsMatmul2D(Metal.matmul2d_descriptor(32, 16; transpose_left = true),
                                             Val(1))
            if COOP
                acc = Metal.MtlCooperativeTensor{Float32}(matmul, tA, tB)
                matmul(tA, tB, acc)
                copyto!(tC, acc)
            else
                matmul(tA, tB, tC)
            end
            return
        end
        transposed_air(coop) = sprint() do io
            Metal.code_air(io, transposed_product, Tuple{Mat, Mat, Mat, Val{coop}}; kernel=true,
                           macos=v"27", dump_module=true)
        end
        @test occursin("constant { i32, i32, i32, i8, i8, i8, i32 } { i32 16, i32 32, i32 -1, i8 0, i8 1, i8 0, i32 0 }",
                       transposed_air(false))
        let ir = transposed_air(true)
            @test occursin("constant { i32, i32, i32, i8, i8, i8, i32 } { i32 16, i32 32, i32 -1, i8 0, i8 1, i8 0, i32 0 }",
                           ir)
            @test occursin(r"call i64 @__tensorops_impl_matmul2d_op_cooperative_tensor_data_size\(i32 2, i32 16, i32 32, i32 -1, i8 0, i8 1, i8 0, i32 0, ",
                           ir)
        end
        if Metal.tensor_matmul_capable()
            @testset "transposed descriptor, $(coop ? "cooperative" : "tensor") destination" for
                    coop in (false, true)
                a = rand(Float32, 20, 32); b = rand(Float32, 20, 16)
                C = MtlArray(zeros(Float32, 32, 16))
                @metal threads=32 transposed_product(C, MtlArray(a), MtlArray(b), Val(coop))
                @test isapprox(Array(C), transpose(a) * b; rtol=1f-4)
            end
        end

        @testset "tile selection" begin
            tiles(M, N; family, kw...) = Metal.gemm_tensor_tiles(M, N; family, kw...)
            # every selection is one that matmul2d accepts
            legal((tm, tn)) = tm in (8, 16, 32, 64) && tn in (8, 16, 32, 64) &&
                              (tm % 16 == 0 || tn % 16 == 0)
            dims = (1, 2, 8, 15, 16, 17, 31, 32, 33, 63, 64, 100, 255, 256, 257, 1000, 1024,
                    1025, 2047, 2048, 2049, 3000, 4096, 16384, 65536)
            @test all(legal(tiles(M, N; family, narrow, transA))
                      for M in dims, N in dims, family in (0, 7, 8, 9, 10, 11, 12),
                          narrow in (false, true), transA in (false, true))

            # families that weren't measured use the rules of the newest one, and the M3/M4
            # only differ from it for 2-byte inputs
            @test all(tiles(M, N; family, narrow, transA) == tiles(M, N; family = 11, narrow, transA)
                      for M in dims, N in dims, family in (0, 6, 10, 12),
                          narrow in (false, true), transA in (false, true))
            @test all(tiles(M, N; family = 9, transA) == tiles(M, N; family = 11, transA)
                      for M in dims, N in dims, transA in (false, true))

            for family in (7, 8, 9, 11)
                old = family <= 8
                fast = family >= 10
                small = family == 7 ? (16, 32) : (32, 16)
                # few columns, like a matrix-vector product
                @test tiles(4096, 16; family) == (64, 16)
                @test tiles(4096, 1; family, transA = true) == (old ? (8, 32) : (64, 16))
                # few rows
                @test tiles(16, 4096; family) == (old ? (8, 16) : (16, 8))
                @test tiles(32, 4096; family) == (old ? (32, 16) : (16, 8))
                @test tiles(33, 4096; family) == (old ? (32, 32) : (32, 16))
                @test tiles(256, 1024; family) == (old ? (32, 32) : (32, 16))
                @test tiles(256, 1024; family, narrow = true) ==
                      (old ? (32, 32) : fast ? (64, 16) : (32, 16))
                @test tiles(257, 1024; family) == small
                # few columns: up to 256, and at most a quarter of the rows
                @test tiles(4096, 17; family) == (16, 64)
                @test tiles(1024, 256; family) == (16, 64)
                @test tiles(1024, 256; family, narrow = true) ==
                      (old ? (32, 32) : fast ? (64, 32) : (16, 16))
                @test tiles(1024, 256; family, transA = true) == (old ? (16, 32) : (16, 64))
                @test tiles(1023, 256; family) == small
                # small and large products
                @test tiles(1024, 1024; family) == small
                @test tiles(1024, 1025; family) == (family == 7 ? (32, 64) : (32, 32))
                @test tiles(4096, 4096; family) ==
                      (family == 7 ? (32, 64) : family == 8 ? (64, 32) : (32, 32))
                @test tiles(4096, 4096; family, narrow = true) == (fast ? (64, 32) : (32, 32))
            end
            # the M2 only switches to 64×32 for more than 2048 rows
            @test tiles(2048, 4096; family = 8) == (32, 32)
            @test tiles(2049, 4096; family = 8) == (64, 32)
        end

        @testset "split-K selection" begin
            splits(M, N, K, groups; cores = 10, kw...) =
                Metal.gemm_tensor_splits(M, N, K, groups; cores, kw...)
            # the threadgroups of all slices stay within five per core
            @test splits(64, 64, 65536, 2) == 25
            @test splits(64, 64, 65536, 3) == 16
            @test splits(64, 64, 65536, 2; cores = 8) == 20
            @test splits(256, 256, 65536, 25) == 2
            @test splits(256, 256, 65536, 26) == 1
            # slices are at least 512 long, and there are at most 32 of them
            @test splits(16, 16, 65536, 1) == 32
            @test splits(64, 64, 2048, 1) == 4
            @test splits(64, 64, 1023, 1) == 1
            # the workspace stays within 32 MiB
            @test splits(2048, 512, 65536, 1) == 8
            @test splits(4096, 4096, 65536, 1) == 1
            # products of 4-byte inputs of 512² to 1024² elements with a long contraction
            @test splits(512, 512, 8192, 128) == 4
            @test splits(1024, 1024, 16384, 512) == 8
            @test splits(1024, 1024, 65536, 512) == 8
            @test splits(1024, 1024, 8191, 512) == 1
            @test splits(512, 511, 8192, 128) == 1
            @test splits(1024, 1025, 8192, 512) == 1
            @test splits(512, 512, 8192, 128; narrow = true) == 1
            # (also when the threadgroups alone would split them less)
            @test splits(1024, 256, 8192, 64; cores = 32) == 4
        end

        @testset "launch plan" begin
            plan(M, N, K; kw...) =
                Metal.gemm_tensor_plan(M, N, K; family = 11, cores = 10, narrow = false,
                                       trA = false, kw...)
            @test plan(4096, 4096, 4096) == (; tile = (32, 32), groups = (64, 64), ks = 4096, slices = 1)
            # with only one of the tiles given, the other is selected to go with it
            @test plan(300, 40, 64; tile_m = 64) == (; tile = (64, 32), groups = (3, 1), ks = 64, slices = 1)
            # slices are a multiple of 32 long, of which the last takes what remains: 2 of 544
            # and 481
            @test plan(1, 1, 1025; narrow = true) == (; tile = (64, 16), groups = (1, 1), ks = 544, slices = 2)
            # (so 16400 asks for 32 slices, but is split into 31)
            @test plan(16, 16, 16400) == (; tile = (64, 16), groups = (1, 1), ks = 544, slices = 31)
        end

        if Metal.tensor_matmul_capable()
            ttol(T) = T === Float32 ? 1.0f-3 : 1.0f-1
            # BFloat16 tensor operands need macOS 26.1
            ttypes = Metal.macos_version() >= v"26.1" ? (Float32, Float16, BFloat16) : (Float32, Float16)
            # edge tiles are partial when a dimension isn't a multiple of the tile, and K needs
            # no particular multiple
            @testset "$T $M×$N×$K" for T in ttypes,
                                       (M, N, K) in ((64, 64, 32), (128, 256, 64), (512, 512, 128),
                                                     (65, 47, 33), (24, 24, 24), (1, 8, 5),
                                                     (17, 1, 65), (100, 300, 7))
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
                # (300×40 is a shape whose tiles depend on the width of the inputs)
                @testset "$M×$N" for (M, N) in ((64, 64), (300, 40))
                    a = tgen(TA, M, 32); b = tgen(TB, 32, N)
                    A = MtlArray(a); B = MtlArray(b); C = MtlArray(zeros(TC, M, N))
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
            end

            # partial edge tiles read and write nothing outside the matrices: C is followed by
            # memory that must stay untouched, and A by NaNs that must not reach C
            let (M, N, K) = (65, 47, 33)
                a = rand(Float32, M, K); b = rand(Float32, K, N)
                # (guards as large as four 32×32 tiles)
                Abuf = MtlArray(fill(NaN32, M * K + 4096)); copyto!(Abuf, 1, MtlArray(vec(a)), 1, M * K)
                Cbuf = MtlArray(fill(-7f0, M * N + 4096))
                A = unsafe_wrap(MtlArray, pointer(Abuf), (M, K))
                C = unsafe_wrap(MtlArray, pointer(Cbuf), (M, N))
                @with (Metal.matmul_alg => :tensor) mul!(C, A, MtlArray(b))
                @test isapprox(Array(C), a * b; rtol=1f-4)
                @test all(==(-7f0), Array(Cbuf)[M*N+1:end])
            end

            # a narrow destination is rounded once, not once per slice of the contraction
            let a = rand(Float16, 256, 4096), b = rand(Float16, 4096, 256)
                C = MtlArray(zeros(Float16, 256, 256))
                @with (Metal.matmul_alg => :tensor) mul!(C, MtlArray(a), MtlArray(b))
                ref = Float64.(a) * Float64.(b)
                @test maximum(abs.(Float64.(Array(C)) .- ref) ./ ref) <= eps(Float16)
            end

            # transposed and adjoint matrices are read in place: matmul2d applies the transpose
            @testset "transposed $T $tA$tB $M×$N×$K" for T in ttypes,
                                                        (tA, tB) in (('T', 'N'), ('N', 'T'), ('C', 'T'), ('T', 'T')),
                                                        (M, N, K) in ((128, 64, 32), (65, 47, 33), (300, 40, 33))
                a = rand(T, (tA == 'N' ? (M, K) : (K, M))...)
                b = rand(T, (tB == 'N' ? (K, N) : (N, K))...)
                A = MtlArray(a); B = MtlArray(b); C = MtlArray(zeros(T, M, N))
                @test Metal.supports_tensor_matmul(C, A, B, tA, tB, true, false)
                Metal.gemm!(C, tA, tB, A, B, true, false; kernel=:tensor)
                opa = tA == 'N' ? Float32.(a) : transpose(Float32.(a))
                opb = tB == 'N' ? Float32.(b) : transpose(Float32.(b))
                @test isapprox(Float32.(Array(C)), opa * opb; rtol=ttol(T))
            end

            # shapes that select each of the rules of `gemm_tensor_tiles`, with partial tiles
            # at the edges of C and simdgroups that lie outside of it
            @testset "ragged $T $M×$N×$K" for T in (Float32, Float16),
                                              (M, N, K) in ((5, 7, 3), (33, 65, 17), (100, 70, 33),
                                                            (530, 520, 40), (1, 1, 1), (70, 1, 9),
                                                            (1, 70, 9), (20, 90, 5), (40, 300, 9),
                                                            (300, 40, 9), (2100, 2050, 3))
                a = rand(T, M, K); b = rand(T, K, N)
                # (β = 0 overwrites whatever C held)
                C = MtlArray(fill(T(7), M, N))
                @with (Metal.matmul_alg => :tensor) mul!(C, MtlArray(a), MtlArray(b))
                @test isapprox(Float32.(Array(C)), Float32.(a) * Float32.(b); rtol=ttol(T))
            end

            # the tile of a simdgroup can be chosen, as long as matmul2d supports it
            @testset "tiles $tile_m×$tile_n" for (tile_m, tile_n) in ((32, 32), (16, 8), (32, 8), (8, 16),
                                                                    (64, 32), (32, 64), (16, 64))
                a = rand(Float32, 100, 20); b = rand(Float32, 20, 90); c = rand(Float32, 100, 90)
                C = MtlArray(zeros(Float32, 100, 90))
                Metal.gemm_tensor!(C, MtlArray(a), MtlArray(b); tile_m, tile_n)
                @test isapprox(Array(C), a * b; rtol=1f-3)
                C = MtlArray(c)
                Metal.gemm_tensor!(C, MtlArray(a), MtlArray(b), 2f0, 0.5f0; tile_m, tile_n)
                @test isapprox(Array(C), 2 * a * b + c / 2; rtol=1f-3)
            end
            # with only one of the tiles given, the other is selected to go with it
            @testset "tile_m=$tile_m, tile_n=$tile_n, $M×$N" for (M, N, tile_m, tile_n) in
                    ((16, 300, 0, 8), (32, 300, 8, 0), (300, 40, 0, 8), (300, 40, 64, 0))
                a = rand(Float32, M, 20); b = rand(Float32, 20, N)
                C = MtlArray(zeros(Float32, M, N))
                Metal.gemm_tensor!(C, MtlArray(a), MtlArray(b); tile_m, tile_n)
                @test isapprox(Array(C), a * b; rtol=1f-3)
            end
            @test_throws ArgumentError Metal.gemm_tensor!(MtlArray(zeros(Float32, 8, 8)),
                MtlArray(zeros(Float32, 8, 8)), MtlArray(zeros(Float32, 8, 8)); tile_m=8, tile_n=8)
            @test_throws ArgumentError Metal.gemm_tensor!(MtlArray(zeros(Float32, 8, 8)),
                MtlArray(zeros(Float32, 8, 8)), MtlArray(zeros(Float32, 8, 8)); tile_m=12)

            # operands outside the tensor path's element types error when it is forced
            Ai = MtlArray(rand(Int32, 64, 64)); Bi = MtlArray(rand(Int32, 64, 64))
            @test_throws Exception (@with (Metal.matmul_alg => :tensor) mul!(MtlArray(zeros(Int32, 64, 64)), Ai, Bi))
            @test !Metal.supports_tensor_matmul(MtlArray(zeros(Int32, 64, 64)), Ai, Bi, 'N', 'N', true, false)

            # Symmetric/Hermitian wrappers are packed, combined with transposes, α/β and
            # ragged shapes
            @testset "wrapped $T $tA$tB $M×$N×$K" for T in (Float32, Float16),
                                                      (tA, tB, M, N, K) in (('T', 'N', 65, 47, 33),
                                                                            ('C', 'N', 40, 24, 9),
                                                                            ('S', 'N', 33, 33, 33),
                                                                            ('s', 'T', 20, 30, 20),
                                                                            ('N', 'h', 20, 20, 20),
                                                                            ('H', 'S', 16, 16, 16))
                α, β = T(2), T(3)
                sA = tA in "TC" ? (K, M) : tA in "SsHh" ? (M, M) : (M, K)
                sB = tB in "TC" ? (N, K) : tB in "SsHh" ? (K, K) : (K, N)
                A = MtlArray(rand(T, sA...)); B = MtlArray(rand(T, sB...)); C0 = rand(T, M, N)
                C = MtlArray(C0)
                Metal.gemm!(C, tA, tB, A, B, α, β; kernel=:tensor)
                opA = Dict('N' => identity, 'T' => transpose, 'C' => adjoint,
                           'S' => X -> Symmetric(X, :U), 's' => X -> Symmetric(X, :L),
                           'H' => X -> Hermitian(X, :U), 'h' => X -> Hermitian(X, :L))
                ref = α * (opA[tA](Float32.(Array(A))) * opA[tB](Float32.(Array(B)))) + β * Float32.(C0)
                @test isapprox(Float32.(Array(C)), ref; rtol=ttol(T))
            end

            # views are read and written in place when their columns are contiguous and in
            # increasing order, and packed otherwise; neighbouring elements of the parents are
            # neither read nor written
            @testset "views $TA×$TB→$TC" for (TA, TB, TC) in ((Float32, Float32, Float32),
                                                              (Float16, Float16, Float16),
                                                              (Float16, Int8, Float32),
                                                              (BFloat16, BFloat16, BFloat16))
                BFloat16 in (TA, TB, TC) && Metal.macos_version() < v"26.1" && continue
                Pa = tgen(TA, 80, 80); Pb = tgen(TB, 80, 80); Pc = rand(TC, 80, 80)
                for (ia, ja, ib, jb, ic, jc) in ((3:50, 1:33, 1:33, 5:40, 3:50, 5:40),      # in place
                                                 (3:2:50, 1:33, 1:33, 5:3:80, 2:25, 2:2:52),  # strided
                                                 (3:50, 33:-1:1, 1:33, 40:-1:5, 3:50, 5:40),  # reversed
                                                 (1:16, 1:16, 1:16, 7:(1 << 30):7, 1:16, 9:9)) # one column
                    poison(T) = T <: AbstractFloat ? T(NaN) : typemax(T)
                    pa = copy(Pa); pa[setdiff(1:80, ia), :] .= poison(TA)
                    pb = copy(Pb); pb[:, setdiff(1:80, jb)] .= poison(TB)
                    A = MtlArray(pa); B = MtlArray(pb); C = MtlArray(Pc)
                    @with (Metal.matmul_alg => :tensor) mul!(view(C, ic, jc), view(A, ia, ja), view(B, ib, jb), 2, 0.5)
                    ref = 2 * Float32.(Pa[ia, ja]) * Float32.(Pb[ib, jb]) + 0.5 * Float32.(Pc[ic, jc])
                    @test isapprox(Float32.(Array(C)[ic, jc]), ref; rtol=ttol(TC))
                    outside = trues(80, 80); outside[ic, jc] .= false
                    @test Array(C)[outside] == Pc[outside]
                    # α = 1 writes the product into C directly
                    C = MtlArray(Pc)
                    @with (Metal.matmul_alg => :tensor) mul!(view(C, ic, jc), view(A, ia, ja), view(B, ib, jb))
                    ref = Float32.(Pa[ia, ja]) * Float32.(Pb[ib, jb])
                    @test isapprox(Float32.(Array(C)[ic, jc]), ref; rtol=ttol(TC))
                    @test Array(C)[outside] == Pc[outside]
                end
            end
            # matrix-vector products
            @testset "matvec $TA→$TC $tA $M×$K" for (TA, TC) in ((Float32, Float32), (Float16, Float32)),
                                                    tA in ('N', 'T'), (M, K) in ((1000, 1000), (33, 65))
                a = rand(TA, (tA == 'N' ? (M, K) : (K, M))...); x = rand(TA, K); y0 = rand(TC, M)
                y = MtlArray(y0)
                @with (Metal.matmul_alg => :tensor) mul!(y, tA == 'N' ? MtlArray(a) : transpose(MtlArray(a)), MtlArray(x), 2, 0.5)
                opa = tA == 'N' ? Float32.(a) : transpose(Float32.(a))
                @test isapprox(Array(y), 2 * opa * Float32.(x) + 0.5 * y0; rtol=1f-3)
            end

            # a transposed view is read in place too
            let P = rand(Float32, 80, 80), b = rand(Float32, 33, 20)
                C = MtlArray(zeros(Float32, 48, 20))
                @with (Metal.matmul_alg => :tensor) mul!(C, transpose(view(MtlArray(P), 1:33, 3:50)), MtlArray(b))
                @test isapprox(Array(C), transpose(P[1:33, 3:50]) * b; rtol=1f-4)
            end

            # α and β of another number type than the operands
            @testset "scaling $T $M×$N×$K α=$α β=$β" for T in ttypes,
                                                        (M, N, K) in ((64, 64, 32), (65, 47, 33)),
                                                        (α, β) in ((true, 0.5), (true, 2), (0.5, false), (2, 0.5))
                # small integers, so the result is exact in every eltype
                a = T.(rand(-1:1, M, K)); b = T.(rand(-1:1, K, N)); c0 = T.(rand(-1:1, M, N))
                C = MtlArray(c0)
                @with (Metal.matmul_alg => :tensor) mul!(C, MtlArray(a), MtlArray(b), α, β)
                ref = α * (Float32.(a) * Float32.(b)) + β * Float32.(c0)
                @test Float32.(Array(C)) == ref
            end
            # β = 0 ignores C's contents
            let a = rand(Float32, 64, 32), b = rand(Float32, 32, 64)
                C = MtlArray(fill(NaN32, 64, 64))
                @with (Metal.matmul_alg => :tensor) mul!(C, MtlArray(a), MtlArray(b), 2, false)
                @test isapprox(Array(C), 2 * a * b; rtol=1f-4)
            end
            # (also a C that goes through the workspace, of which the other rows are left alone)
            let a = rand(Float32, 100, 33), b = rand(Float32, 33, 70)
                P = MtlArray(fill(NaN32, 200, 70))
                Metal.gemm_tensor!(view(P, 1:2:200, :), MtlArray(a), MtlArray(b), 2, false)
                @test isapprox(Array(P)[1:2:200, :], 2 * a * b; rtol=1f-4)
                @test all(isnan, Array(P)[2:2:200, :])
            end
            # α and β are applied by the kernel that computes the product, in cooperative
            # tensors, except for a C that can't be laid out as a tensor (stepped rows): the
            # product then goes through a workspace that a second kernel scales and combines
            # with C.
            # The shapes have partial tiles at the edges.
            @testset "scaling $TA→$TC $M×$N×$K α=$α β=$β$(stepped ? " stepped" : "")" for
                    (TA, TC) in ((Float32, Float32), (Float16, Float16), (Float16, Float32),
                                 (Int8, Int32), (BFloat16, BFloat16)),
                    (M, N, K) in ((100, 70, 33), (530, 520, 9)),
                    (α, β) in ((1, 0), (1, 1), (1, 3), (2, 0), (2, 3)),
                    stepped in (false, true)
                BFloat16 in (TA, TC) && Metal.macos_version() < v"26.1" && continue
                a = tgen(TA, M, K); b = tgen(TA, K, N); c0 = tgen(TC, 2M, N)
                P = MtlArray(c0)
                C = stepped ? view(P, 1:2:2M, :) : view(P, 1:M, :)
                Metal.gemm_tensor!(C, MtlArray(a), MtlArray(b), α, β)
                rows = stepped ? (1:2:2M) : (1:M)
                ref = α * (Float64.(a) * Float64.(b)) + β * Float64.(c0[rows, :])
                @test isapprox(Float64.(Array(C)), ref; rtol=TC <: Integer ? 0 : ttol(TC))
                # (the other rows are left alone)
                @test Array(P)[setdiff(1:2M, rows), :] == c0[setdiff(1:2M, rows), :]
            end
            @testset "integer scaling" begin
                a = rand(Int8(-5):Int8(5), 64, 32); b = rand(Int8(-5):Int8(5), 32, 64)
                c0 = rand(Int32(-5):Int32(5), 64, 64)
                C = MtlArray(c0)
                @with (Metal.matmul_alg => :tensor) mul!(C, MtlArray(a), MtlArray(b), 2, 3)
                @test Array(C) == 2 * (Int32.(a) * Int32.(b)) + 3 * c0
                # a fractional α is applied by the generic kernel, before the result is
                # converted to Int32 (0.5·96 is exact); forcing the tensor kernel errors
                a = fill(Int8(2), 16, 16); b = fill(Int8(3), 16, 16)
                @test !Metal.supports_tensor_matmul(C, MtlArray(a), MtlArray(b), 'N', 'N', 0.5f0, false)
                C = MtlArray(zeros(Int32, 16, 16))
                @with (Metal.matmul_alg => :native) mul!(C, MtlArray(a), MtlArray(b), 0.5f0, false)
                @test all(==(48), Array(C))
                @test_throws "algorithm `:tensor`" (@with (Metal.matmul_alg => :tensor) mul!(C, MtlArray(a), MtlArray(b), 0.5f0, false))
                # so is a β that Int32 can't represent
                C = MtlArray(zeros(Int32, 16, 16))
                @with (Metal.matmul_alg => :native) mul!(C, MtlArray(a), MtlArray(b), true, Int64(1) << 31)
                @test all(==(96), Array(C))
                @test !Metal.supports_tensor_matmul(C, MtlArray(a), MtlArray(b), 'N', 'N', true, BFloat16(2^31))
                @test Metal.supports_tensor_matmul(C, MtlArray(a), MtlArray(b), 'N', 'N', true, 2 + 0im)
            end
            # the unscaled product, or β itself, overflows Float16 while the result fits
            @testset "Float16 intermediate overflow" begin
                A = MtlArray(fill(Float16(100), 64, 64)); C = MtlArray(zeros(Float16, 64, 64))
                @with (Metal.matmul_alg => :tensor) mul!(C, A, A, 1f-3, false)
                @test all(x -> isapprox(x, 640; rtol=1f-2), Array(C))
                A = MtlArray(zeros(Float16, 64, 64)); C = MtlArray(fill(Float16(0.001), 64, 64))
                @with (Metal.matmul_alg => :tensor) mul!(C, A, A, true, 1f5)
                @test all(x -> isapprox(x, 100; rtol=1f-2), Array(C))
                # β·C overflows, but cancels against the product
                A = MtlArray(fill(Float16(-250), 16, 16)); B = MtlArray(fill(Float16(20), 16, 16))
                C = MtlArray(fill(Float16(40000), 16, 16))
                @with (Metal.matmul_alg => :tensor) mul!(C, A, B, true, 2)
                @test all(iszero, Array(C))
                # the product overflows, but C cancels against it
                A = MtlArray(fill(Float16(200), 16, 2)); B = MtlArray(fill(Float16(200), 2, 16))
                C = MtlArray(fill(Float16(-60000), 16, 16))
                @with (Metal.matmul_alg => :tensor) mul!(C, A, B, true, true)
                @test all(==(20000), Array(C))
            end

            # a small C with a long contraction splits it (see `gemm_tensor_splits`): the
            # partial products go to a workspace that is allocated per call, while an unsplit
            # product writes to C directly
            @testset "split-K" begin
                # (ragged: partial tiles, and a last slice that is shorter than the others)
                M, N, K = 65, 47, 12345
                family = Metal.gemm_tensor_family()
                tile_m, tile_n = Metal.gemm_tensor_tiles(M, N; family)
                S = Metal.gemm_tensor_splits(M, N, K, cld(M, 2tile_m) * cld(N, 2tile_n);
                                             cores = Metal.gemm_tensor_cores())
                @test S > 1
                slices = cld(K, cld(cld(K, S), Metal.GEMM_TENSOR_SPLIT_K) * Metal.GEMM_TENSOR_SPLIT_K)
                A = MtlArray(rand(Float32, M, K)); B = MtlArray(rand(Float32, K, N))
                C = MtlArray(zeros(Float32, M, N))
                @test Metal.@allocated(Metal.gemm_tensor!(C, A, B)) == sizeof(Float32) * M * N * slices
                @test isapprox(Array(C), Array(A) * Array(B); rtol=1f-5)
                # (the result is reproducible)
                C2 = MtlArray(zeros(Float32, M, N))
                Metal.gemm_tensor!(C2, A, B)
                @test Array(C2) == Array(C)
                # a short contraction isn't split
                A = MtlArray(rand(Float32, M, 64)); B = MtlArray(rand(Float32, 64, N))
                @test Metal.@allocated(Metal.gemm_tensor!(C, A, B)) == 0
                @test isapprox(Array(C), Array(A) * Array(B); rtol=1f-5)

                # The slices are added up in their order, and the result is scaled and
                # converted to C's element type after: 1×1×1536 is split into three slices,
                # here with partial products 1, 2^24 and -2^24, which add up to 0 in Float32
                # in this order, and to 1 in the reverse one.
                a = zeros(Float32, 1, 1536); b = zeros(Float32, 1536, 1)
                a[[1, 513, 1025]] .= 1; b[[1, 513, 1025]] .= (1, 2^24, -2^24)
                C = MtlArray(zeros(Float32, 1, 1))
                Metal.gemm_tensor!(C, MtlArray(a), MtlArray(b))
                @test only(Array(C)) == 0
                # 1×1×1025 in two slices, of 544 and 481, with partial products 2049 and -2048:
                # the Float16 result 2·1 + 3·3 would be 9 if the partial products were rounded
                # to Float16 (2049 to 2048)
                a = zeros(Float16, 1, 1025); b = zeros(Float16, 1025, 1)
                a[[1, 2, 1025]] .= 1; b[[1, 2, 1025]] .= (2048, 1, -2048)
                C = MtlArray(fill(Float16(3), 1, 1))
                Metal.gemm_tensor!(C, MtlArray(a), MtlArray(b), 2, 3)
                @test only(Array(C)) == 11

                @testset "$TA→$TC $tA$tB α=$α β=$β" for (TA, TC) in ((Float32, Float32), (Float16, Float16),
                                                                  (Float16, Float32), (BFloat16, BFloat16),
                                                                  (Int8, Int32)),
                                                       (tA, tB) in (('N', 'N'), ('T', 'N'), ('C', 'T')),
                                                       (α, β) in ((1, 0), (1, 1), (2, 0), (2, 3))
                    BFloat16 in (TA, TC) && Metal.macos_version() < v"26.1" && continue
                    a = tgen(TA, (tA == 'N' ? (M, K) : (K, M))...)
                    b = tgen(TA, (tB == 'N' ? (K, N) : (N, K))...)
                    # (of the same magnitude as the product, so that β·C counts)
                    c0 = TC <: Integer ? tgen(TC, M, N) : TC.(K / 4 * rand(Float32, M, N))
                    # (β = 0 doesn't read C)
                    C = MtlArray(iszero(β) && TC <: AbstractFloat ? fill(TC(NaN), M, N) : c0)
                    Metal.gemm!(C, tA, tB, MtlArray(a), MtlArray(b), α, β; kernel=:tensor)
                    opa = tA == 'N' ? Float64.(a) : transpose(Float64.(a))
                    opb = tB == 'N' ? Float64.(b) : transpose(Float64.(b))
                    ref = α * (opa * opb) + β * Float64.(c0)
                    @test isapprox(Float64.(Array(C)), ref; rtol=TC <: Integer ? 0 : ttol(TC))
                end

                # views are read and written in place, or packed (stepped rows, a Symmetric
                # wrapper); the neighbouring elements of C's parent are left alone
                P = rand(Float32, 2M, N + 2); a = rand(Float32, 2M, K); b = rand(Float32, K, N)
                @testset "views $rows" for (rows, arows) in ((1:M, 2:M+1), (1:2:2M, 1:2:2M))
                    Pc = MtlArray(P)
                    Cv = view(Pc, rows, 2:N+1)
                    Av = view(MtlArray(a), arows, :)
                    @with (Metal.matmul_alg => :tensor) mul!(Cv, Av, MtlArray(b), 2, 0.5)
                    @test isapprox(Array(Cv), 2 * a[arows, :] * b + 0.5 * P[rows, 2:N+1]; rtol=1f-5)
                    outside = trues(2M, N + 2); outside[rows, 2:N+1] .= false
                    @test Array(Pc)[outside] == P[outside]
                end
                let a = rand(Float32, 2048, 2048), b = rand(Float32, 2048, 4)
                    C = MtlArray(zeros(Float32, 2048, 4))
                    Metal.gemm!(C, 'S', 'N', MtlArray(a), MtlArray(b), true, false; kernel=:tensor)
                    @test isapprox(Array(C), Symmetric(a) * b; rtol=1f-5)
                end
                # with explicit tiles
                let a = rand(Float32, M, K), b = rand(Float32, K, N)
                    C = MtlArray(zeros(Float32, M, N))
                    Metal.gemm_tensor!(C, MtlArray(a), MtlArray(b); tile_m = 16, tile_n = 16)
                    @test isapprox(Array(C), a * b; rtol=1f-5)
                end
            end
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

    # singular matrices report the first zero pivot, like LAPACK
    a = Float32[1 2; 2 4]
    A = MtlMatrix(a)
    @test_throws SingularException(2) lu(A)
    @test_throws SingularException(2) lu!(copy(A))
    @test_throws SingularException(2) A \ MtlVector(Float32[1, 2])
    @test lu(A; check=false).info == lu(a; check=false).info

    # MPS only decomposes Float32 matrices, and aborts the process on others; they use
    # LinearAlgebra's generic implementation instead, which needs CPU access to the array
    if Metal.DefaultStorageMode == Metal.SharedStorage
        a = Float16[4 1; 1 3]
        A = MtlMatrix(a)
        lua = lu(A)
        @test Array(lua.L * lua.U) ≈ a[lua.p, :]
        @test Array(cholesky(A).U) ≈ cholesky(a).U
        @test Array(A \ MtlVector(Float16[1, 2])) ≈ a \ Float16[1, 2]
    end

    altStorage = Metal.DefaultStorageMode != Metal.SharedStorage ? Metal.SharedStorage : Metal.PrivateStorage
    A = MtlMatrix{Float32, altStorage}(rand(Float32, 1024, 1024))
    lua = lu(A)
    @test storagemode(lua.factors) == storagemode(lua.ipiv) == storagemode(A)
    lua = lu!(A)
    @test storagemode(lua.factors) == storagemode(lua.ipiv) == storagemode(A)

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

    Als = rand(T, 8, 7)
    bls = rand(T, 8)
    dAls = MtlMatrix(Als)
    dbls = MtlVector(bls)
    if Metal.DefaultStorageMode == Metal.PrivateStorage
        @test_throws ErrorException dAls \ dbls
    else
        @test dAls \ dbls ≈ Als \ bls rtol=1f-4
    end

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

    @testset "empty $(triangle)" for triangle in (UpperTriangular, UnitLowerTriangular)
        E, e, W = MtlMatrix{T}(undef, 0, 0), MtlVector{T}(undef, 0), MtlMatrix{T}(undef, 0, 3)
        @test size(triangle(E) \ e) == (0,)
        @test size(triangle(E) \ W) == (0, 3)
        @test size(transpose(triangle(E)) \ W) == (0, 3)
        @test size(copy(W') / triangle(E)) == (3, 0)
        @test size(copy(W') / transpose(triangle(E))) == (3, 0)
        @test size(triangle(dA) \ MtlMatrix{T}(undef, n, 0)) == (n, 0)
    end

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
end

@testset "derived" begin
    T = Float32
    n = 16

    A = rand(T, n, n)
    A .+= T(n) .* Matrix{T}(I, n, n)
    dA = MtlMatrix(A)

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
