using Random

# Float64 arithmetic is emulated in software (see GPUCompiler.SoftFloat); the tests here
# cover the Metal integration and exercise representative Base functionality on device,
# comparing against the CPU.

function arithmetic_kernel(out, a, b)
    i = thread_position_in_grid_1d()
    i > length(a) && return
    @inbounds begin
        x, y = a[i], b[i]
        out[i, 1] = x + y
        out[i, 2] = x - y
        out[i, 3] = x * y
        out[i, 4] = x / y
        out[i, 5] = sqrt(abs(x))
        out[i, 6] = fma(x, y, 1.25)
        out[i, 7] = x < y ? x : y
        out[i, 8] = Float64(Int32(i))
    end
    return
end

@generated function repeated_add(x, y, ::Val{N}) where {N}
    Expr(:block, [:(x = x + y) for _ in 1:N]..., :(x))
end

@testset "storage" begin
    @test MtlArray(Float64[1]) isa MtlArray{Float64}
    @test MtlArray(ComplexF64[1 + 2im]) isa MtlArray{ComplexF64}
    @test Metal.MetalKernels.KA.supports_float64(MetalBackend())
    # mtl remains opinionated
    @test mtl(Float64[1]) isa MtlArray{Float32}
end

@testset "generated code" begin
    # arithmetic is a call to a shared helper, not inlined into every user
    add_ir = sprint(io -> Metal.code_llvm(io, +, (Float64, Float64)))
    @test occursin("call fastcc i64 @gpu_softfloat_add64", add_ir)
    @test count(==('\n'), add_ir) <= 10
    # trivial bit operations do get inlined
    neg_ir = sprint(io -> Metal.code_llvm(io, -, (Float64,)))
    @test occursin("xor i64", neg_ir)
    @test !occursin("call ", neg_ir)

    small_air = sprint(io -> Metal.code_air(io, repeated_add, (Float64, Float64, Val{1});
                                            dump_module=true, debug_level=0))
    large_air = sprint(io -> Metal.code_air(io, repeated_add, (Float64, Float64, Val{64});
                                            dump_module=true, debug_level=0))
    @test count("define internal fastcc i64 @gpu_softfloat_add64", large_air) == 1
    @test sizeof(large_air) - sizeof(small_air) < 10_000

    # no double-precision values or 128-bit integers may remain in the generated code
    out = Metal.zeros(Float64, 3, 8)
    a, b = Metal.ones(Float64, 3), Metal.ones(Float64, 3)
    llvm = sprint(io -> (@device_code_llvm io=io dump_module=true @metal launch=false arithmetic_kernel(out, a, b)))
    air = sprint(io -> (@device_code_air io=io @metal launch=false arithmetic_kernel(out, a, b)))
    for code in (llvm, air)
        @test !occursin(r"\bdouble\b", code)
        @test !occursin(r"\bi128\b", code)
    end
end

@testset "arithmetic" begin
    # random bit patterns and edge cases through the actual kernel ABI, compared bit for
    # bit against the CPU (except for NaN payloads, which are canonicalized)
    edges = [-0.0, 0.0, nextfloat(0.0), prevfloat(floatmin(Float64)), floatmin(Float64),
             -1.0, 1.0, nextfloat(1.0), floatmax(Float64), -Inf, Inf, NaN]
    rng = Xoshiro(0x5f64)
    xs = vcat(repeat(edges; inner=length(edges)), reinterpret(Float64, rand(rng, UInt64, 2048)))
    ys = vcat(repeat(edges; outer=length(edges)), reinterpret(Float64, rand(rng, UInt64, 2048)))
    out = Metal.zeros(Float64, length(xs), 8)
    @metal threads=64 groups=cld(length(xs), 64) arithmetic_kernel(out, MtlArray(xs), MtlArray(ys))
    expected = hcat(xs .+ ys, xs .- ys, xs .* ys, xs ./ ys, sqrt.(abs.(xs)), fma.(xs, ys, 1.25),
                    map((x, y) -> x < y ? x : y, xs, ys), Float64.(1:length(xs)))
    canonical(x) = isnan(x) ? reinterpret(UInt64, NaN) : reinterpret(UInt64, x)
    @test canonical.(Array(out)) == canonical.(expected)

    # many operations in a single kernel
    av, bv = Float64[1.5, 4.0, 0.25], Float64[2.0, -0.5, 8.0]
    @test Array(broadcast((x, y) -> repeated_add(x, y, Val(64)), MtlArray(av), MtlArray(bv))) == av .+ 64 .* bv

    # complex numbers
    ca = ComplexF64[1 + 2im, -0.5 + 4im]
    cb = ComplexF64[2 - 1im, 3 + 0.25im]
    @test Array(MtlArray(ca) .* MtlArray(cb) .+ MtlArray(ca)) == ca .* cb .+ ca
    @test Array(abs.(MtlArray(ca))) == abs.(ca)
end

@testset "conversions" begin
    xs = Float64[1.0, -2.0, 42.0, 0.1, -1e300, 1e-310]
    @test Array(Float32.(MtlArray(xs))) == Float32.(xs)
    @test Array(Float16.(MtlArray(xs))) == Float16.(xs)
    @test Array(Float64.(MtlArray(Float32.(xs)))) == Float64.(Float32.(xs))
    @test Array(Float64.(MtlArray(Float16.(xs)))) == Float64.(Float16.(xs))
    @test Array(Int64.(MtlArray(xs[1:3]))) == Int64.(xs[1:3])
    @test Array(round.(Int32, MtlArray(xs[1:4]))) == round.(Int32, xs[1:4])
    @test Array(Float64.(MtlArray(Int64[1, -2, typemax(Int64)]))) == Float64.(Int64[1, -2, typemax(Int64)])
    @test Array(Float64.(MtlArray(UInt8[1, 255]))) == Float64.(UInt8[1, 255])
    # Float16 narrowing rounds directly (rounding through Float32 first would round twice)
    ties = [nextfloat(1.0 + 2.0^-11), -nextfloat(1.0 + 2.0^-11), nextfloat(2.0^-25), 65520.0, Inf, -Inf, NaN]
    @test isequal(Array(Float16.(MtlArray(ties))), Float16.(ties))
    halves = reinterpret(Float16, collect(UInt16(0):typemax(UInt16)))
    @test isequal(Array(Float64.(MtlArray(halves))), Float64.(halves))
end

@testset "Base math" begin
    # Base's pure-Julia math functions compile as-is; the emulated primitives are correctly
    # rounded, but the CPU contracts `muladd` to FMA where the emulation does not, so allow
    # a few ulps of difference.
    approx(a, b) = isequal(a, b) || (isfinite(b) && abs(a - b) <= 4eps(abs(b)) + floatmin(Float64))
    xs = [-2.0^20, -3.5, -1.0, -0.1, 0.0, 1e-300, 0.5, 1.0, 2.5, 1e5, 1e100]
    for f in (sin, cos, tan, exp, expm1, sinh, tanh, atan, cbrt, sinpi, cospi, x -> x^2.5, x -> x^3,
              log, log2, log10, log1p, sqrt, acosh, asin, x -> hypot(x, 2.0), x -> rem(x, 0.3),
              x -> mod(x, 0.3), floor, ceil, round, trunc, x -> round(x; digits=2), significand,
              exponent, x -> ldexp(x, 3), abs, sign, x -> clamp(x, -1.0, 1.0), x -> max(x, 0.5),
              x -> muladd(x, x, x), inv, nextfloat, prevfloat, eps, isfinite, isnan, isinteger)
        # skip inputs outside the function's domain (or non-finite ones for the strict checks)
        inputs = filter(x -> try f(x); true catch; false end, xs)
        @test all(map(approx, Array(f.(MtlArray(inputs))), f.(inputs)))
    end
    # trigonometric functions use Payne-Hanek reduction for large arguments
    big = [2.0^20 * pi, 1e20, -1e100, floatmax(Float64)]
    for f in (sin, cos, tan)
        @test Array(f.(MtlArray(big))) == f.(big)
    end
    # reductions
    xs = rand(Xoshiro(1), 1000)
    @test sum(MtlArray(xs)) ≈ sum(xs)
    @test maximum(MtlArray(xs)) == maximum(xs)
    @test Array(cumsum(MtlArray(xs))) ≈ cumsum(xs)
end
