using Metal: metal_support
using SpecialFunctions
using FileCheck
import Base.FastMath

############################################################################################
# codegen
#
# Verify that high-level math/integer operations lower to the expected AIR intrinsics. This
# pins the *lowering* (which AIR intrinsic each operation emits), complementing the numerical
# `execution` tests below. It guards both the operations handled by an explicit
# `@device_override` here (the transcendentals) and the ones whose AIR intrinsic is emitted by
# GPUCompiler rather than Metal.jl — `sqrt`/`fma`/`floor`/`ceil`/`trunc`/`round`, `abs`,
# integer `min`/`max`, the 3-argument `min`/`max` fused to `air.min3`/`air.max3`, the bit
# intrinsics, and the NaN-propagating float `min`/`max` — so a back-end change that stops
# emitting them is caught here instead of silently regressing performance.
#
# The operations handled by a front-end `@device_override` emit their `air.*` intrinsic
# directly into the Julia-generated IR, so we inspect `Metal.code_llvm` (no GPU or metallib
# build needed). The ones lowered by GPUCompiler's back-end keep their generic `llvm.*`
# intrinsic at that stage and only become `air.*` during machine-code generation, so those
# are inspected through `Metal.code_air` (which lowers, downgrades, and disassembles).
# Each function is spliced into the compiled closure via `@eval` so the call is a concrete,
# specializable call (a captured `Function` would dispatch dynamically and never lower).

# integer types paired with their AIR mangling: `iN` width suffix and `s`/`u` signedness.
const INT_TYPES = [(Int8, "i8", "s"), (UInt8, "i8", "u"), (Int16, "i16", "s"),
                   (UInt16, "i16", "u"), (Int32, "i32", "s"), (UInt32, "i32", "u"),
                   (Int64, "i64", "s"), (UInt64, "i64", "u")]

@testset "codegen" begin

############################################################################################
# floating-point

# Group A: `Base.f(::Float32/::Float16)` -> `air.f.{f32,f16}`, and the fast-math variant
# `FastMath.f_fast(::Float32)` -> `air.fast_f.f32`.
FLOAT_A = [acos, acosh, asin, asinh, atan, atanh, cos, cosh,
           exp, exp2, exp10, log, log2, log10, sin, sinh, tan, tanh]
@testset "$f" for f in FLOAT_A
    root = string(f)
    fast = getfield(FastMath, Symbol(root, "_fast"))
    @eval begin
        @test @filecheck begin
            @check $("@air.$root.f32")
            Metal.code_llvm(x -> $f(x), Tuple{Float32})
        end
        @test @filecheck begin
            @check $("@air.$root.f16")
            Metal.code_llvm(x -> $f(x), Tuple{Float16})
        end
        @test @filecheck begin
            @check $("@air.fast_$root.f32")
            Metal.code_llvm(x -> $fast(x), Tuple{Float32})
        end
    end
end

# Group B: precise `Base.f` (f32+f16) but the fast variant is `Metal.f_fast` (no FastMath).
@testset "$root" for root in ("cospi", "sinpi", "tanpi")
    f    = getfield(Base, Symbol(root))
    fast = getfield(Metal, Symbol(root, "_fast"))
    @eval begin
        @test @filecheck begin
            @check $("@air.$root.f32")
            Metal.code_llvm(x -> $f(x), Tuple{Float32})
        end
        @test @filecheck begin
            @check $("@air.$root.f16")
            Metal.code_llvm(x -> $f(x), Tuple{Float16})
        end
        @test @filecheck begin
            @check $("@air.fast_$root.f32")
            Metal.code_llvm(x -> $fast(x), Tuple{Float32})
        end
    end
end

# Group C: Metal-specific functions (no `Base` equivalent), precise f32+f16 + fast f32.
@testset "$root" for root in ("fract", "rint", "rsqrt")
    f    = getfield(Metal, Symbol(root))
    fast = getfield(Metal, Symbol(root, "_fast"))
    @eval begin
        @test @filecheck begin
            @check $("@air.$root.f32")
            Metal.code_llvm(x -> $f(x), Tuple{Float32})
        end
        @test @filecheck begin
            @check $("@air.$root.f16")
            Metal.code_llvm(x -> $f(x), Tuple{Float16})
        end
        @test @filecheck begin
            @check $("@air.fast_$root.f32")
            Metal.code_llvm(x -> $fast(x), Tuple{Float32})
        end
    end
end

# Group D: fast-only Metal helpers (`air.fast_*.f32`, no precise or f16 variant).
@testset "$root" for root in ("ceil", "floor", "round", "trunc")
    fast = getfield(Metal, Symbol(root, "_fast"))
    @eval @test @filecheck begin
        @check $("@air.fast_$root.f32")
        Metal.code_llvm(x -> $fast(x), Tuple{Float32})
    end
end

# two-argument float functions, each with a fast variant.
@testset "atan2" begin
    @eval begin
        @test @filecheck begin
            @check "@air.atan2.f32"
            Metal.code_llvm((x, y) -> atan(x, y), Tuple{Float32,Float32})
        end
        @test @filecheck begin
            @check "@air.atan2.f16"
            Metal.code_llvm((x, y) -> atan(x, y), Tuple{Float16,Float16})
        end
        @test @filecheck begin
            @check "@air.fast_atan2.f32"
            Metal.code_llvm((x, y) -> $(FastMath.atan_fast)(x, y), Tuple{Float32,Float32})
        end
    end
end
@testset "pow" begin
    @eval begin
        @test @filecheck begin
            @check "@air.pow.f32"
            Metal.code_llvm((x, y) -> x^y, Tuple{Float32,Float32})
        end
        @test @filecheck begin
            @check "@air.pow.f16"
            Metal.code_llvm((x, y) -> x^y, Tuple{Float16,Float16})
        end
        @test @filecheck begin
            @check "@air.fast_pow.f32"
            Metal.code_llvm((x, y) -> $(FastMath.pow_fast)(x, y), Tuple{Float32,Float32})
        end
    end
end
@testset "powr" begin
    @eval begin
        @test @filecheck begin
            @check "@air.powr.f32"
            Metal.code_llvm((x, y) -> $(Metal.powr)(x, y), Tuple{Float32,Float32})
        end
        @test @filecheck begin
            @check "@air.powr.f16"
            Metal.code_llvm((x, y) -> $(Metal.powr)(x, y), Tuple{Float16,Float16})
        end
        @test @filecheck begin
            @check "@air.fast_powr.f32"
            Metal.code_llvm((x, y) -> $(Metal.powr_fast)(x, y), Tuple{Float32,Float32})
        end
    end
end

# individually-shaped float intrinsics.
@testset "misc" begin
    @eval begin
        # fma: f16 is a front-end override; f32 is the native llvm.fma the back-end lowers
        # (have_fma(::MetalCompilerTarget) is true).
        @test @filecheck begin
            @check "@air.fma.f16"
            Metal.code_llvm((a, b, c) -> fma(a, b, c), Tuple{Float16,Float16,Float16})
        end
        @test @filecheck begin
            @check "@air.fma.f32"
            Metal.code_air((a, b, c) -> fma(a, b, c), Tuple{Float32,Float32,Float32})
        end
        # sqrt: f16 is a front-end override; f32 (and the fast f32 form) come from the
        # back-end's llvm.sqrt lowering.
        @test @filecheck begin
            @check "@air.sqrt.f16"
            Metal.code_llvm(x -> sqrt(x), Tuple{Float16})
        end
        @test @filecheck begin
            @check "@air.sqrt.f32"
            Metal.code_air(x -> sqrt(x), Tuple{Float32})
        end
        @test @filecheck begin
            @check "@air.fast_sqrt.f32"
            Metal.code_air(x -> $(FastMath.sqrt_fast)(x), Tuple{Float32})
        end
        @test @filecheck begin
            @check "@air.sincos.f32"
            Metal.code_llvm(x -> sincos(x), Tuple{Float32})
        end
        @test @filecheck begin
            @check "@air.sincos.f16"
            Metal.code_llvm(x -> sincos(x), Tuple{Float16})
        end
        @test @filecheck begin
            @check "@air.fast_sincos.f32"
            Metal.code_llvm(x -> $(FastMath.sincos_fast)(x), Tuple{Float32})
        end
    end
end

# floor/ceil/trunc/round moved from front-end `@device_override`s to the back-end's lowering
# of the LLVM intrinsics Julia emits. `round` lowers to `air.rint` (round-to-nearest-even,
# matching Julia's `RoundNearest`), not the ties-away `air.round` the old override emitted.
@testset "rounding $root" for (root, fn) in
        (("floor", floor), ("ceil", ceil), ("trunc", trunc), ("rint", round))
    @eval begin
        @test @filecheck begin
            @check $("@air.$root.f32")
            Metal.code_air(x -> $fn(x), Tuple{Float32})
        end
        @test @filecheck begin
            @check $("@air.$root.f16")
            Metal.code_air(x -> $fn(x), Tuple{Float16})
        end
    end
end

# NaN-propagating float min/max are lowered to air.fmin/air.fmax by GPUCompiler.
@testset "float $name $T" for T in (Float32, Float16), (fn, name) in ((min, "fmin"), (max, "fmax"))
    @eval @test @filecheck begin
        @check $("@air.$name.f$(8*sizeof(T))")
        Metal.code_air((x, y) -> $fn(x, y), Tuple{$T,$T})
    end
end

# clamp and sign use the (correct) Base fallbacks now; they must not emit a phantom AIR
# intrinsic (the dropped air.clamp/air.sign overrides — JuliaGPU/Metal.jl removed these).
@testset "no phantom intrinsic" begin
    @eval begin
        @test @filecheck begin
            @check_not "air.clamp"
            Metal.code_air((x, lo, hi) -> clamp(x, lo, hi), Tuple{Float32,Float32,Float32})
        end
        @test @filecheck begin
            @check_not "air.sign"
            Metal.code_air(x -> sign(x), Tuple{Float32})
        end
    end
end

############################################################################################
# integer

# abs: signed only (Base.abs(::Unsigned) is the identity, no intrinsic) -> air.abs.s.iN
@testset "abs $T" for (T, iN, sgn) in INT_TYPES
    sgn == "s" || continue
    @eval @test @filecheck begin
        @check $("@air.abs.s.$iN")
        Metal.code_air(x -> abs(x), Tuple{$T})
    end
end

# 2-argument min/max -> air.{min,max}.{s,u}.iN
@testset "$name $T" for (T, iN, sgn) in INT_TYPES, (fn, name) in ((min, "min"), (max, "max"))
    @eval @test @filecheck begin
        @check $("@air.$name.$sgn.$iN")
        Metal.code_air((x, y) -> $fn(x, y), Tuple{$T,$T})
    end
end

# 3-argument min/max -> air.{min,max}3.{s,u}.iN (GPUCompiler fuses the chained llvm intrinsics)
@testset "$name 3-arg $T" for (T, iN, sgn) in INT_TYPES, (fn, name) in ((min, "min3"), (max, "max3"))
    @eval @test @filecheck begin
        @check $("@air.$name.$sgn.$iN")
        Metal.code_air((x, y, z) -> $fn(x, y, z), Tuple{$T,$T,$T})
    end
end

# bit intrinsics (no signedness suffix) -> air.{clz,ctz,popcount,reverse_bits}.iN
@testset "$name $T" for (T, iN, sgn) in INT_TYPES,
                        (fn, name) in ((leading_zeros, "clz"), (trailing_zeros, "ctz"),
                                       (count_ones, "popcount"), (bitreverse, "reverse_bits"))
    @eval @test @filecheck begin
        @check $("@air.$name.$iN")
        Metal.code_air(x -> $fn(x), Tuple{$T})
    end
end

# mul_hi: no LLVM intrinsic, so the @device_override here supplies air.mul_hi.{s,u}.iN
@testset "mul_hi $T" for (T, iN, sgn) in INT_TYPES
    @eval @test @filecheck begin
        @check $("@air.mul_hi.$sgn.$iN")
        Metal.code_llvm((x, y) -> $(Metal.mulhi)(x, y), Tuple{$T,$T})
    end
end

end


############################################################################################
# execution
#
# Verify that the GPU results match the host over representative inputs.

FLOAT_MATH_INTR_FUNCS_1_ARG = [
    # Common functions
    # saturate, # T saturate(T x) Clamp between 0.0 and 1.0
    sign, # T sign(T x) returns 0.0 if x is NaN

    # float math
    acos, # T acos(T x)
    asin, # T asin(T x)
    asinh, # T asinh(T x)
    atan, # T atan(T x)
    atanh, # T atanh(T x)
    ceil, # T ceil(T x)
    cos, # T cos(T x)
    cosh, # T cosh(T x)
    cospi, # T cospi(T x)
    exp, # T exp(T x)
    exp2, # T exp2(T x)
    exp10, # T exp10(T x)
    abs, #T [f]abs(T x)
    floor, # T floor(T x)
    # ilogb, # Ti ilogb(T x)
    log, # T log(T x)
    log2, # T log2(T x)
    log10, # T log10(T x)
    round, # T round(T x)
    sin, # T sin(T x)
    sinh, # T sinh(T x)
    sinpi, # T sinpi(T x)
    sqrt, # sqrt(T x)
    tan, # T tan(T x)
    tanh, # T tanh(T x)
    tanpi, # T tanpi(T x)
    trunc, # T trunc(T x)
]

FLOAT_MATH_INTR_FUNCS_2_ARG = [
    # Common function
    # step, # T step(T edge, T x) Returns 0.0 if x < edge, otherwise it returns 1.0

    # float math
    atan, # T atan2(T x, T y) Compute arc tangent of y over x.
    # fdim, # T fdim(T x, T y)
    max, # T [f]max(T x, T y)
    min, # T [f]min(T x, T y)
    # fmod, # T fmod(T x, T y)
    # frexp, # T frexp(T x, Ti &exponent)
    # ldexp, # T ldexp(T x, Ti k)
    # modf, # T modf(T x, T &intval)
    hypot, # NOT MSL but tested the same
]

FLOAT_MATH_INTR_FUNCS_3_ARG = [
    # Common functions
    # mix, # T mix(T x, T y, T a) # x+(y-x)*a
    # smoothstep, # T smoothstep(T edge0, T edge1, T x)
    fma, # T fma(T a, T b, T c)
    max, # T max3(T x, T y, T z)
    # median3, # T median3(T x, T y, T z)
    min, # T min3(T x, T y, T z)
]

INT_MATH_INTR_FUNCS_1_ARG = [
    # integer math
    abs,
    leading_zeros,  # air.clz
    trailing_zeros, # air.ctz
    count_ones,     # air.popcount
    bitreverse,     # air.reverse_bits
]

INT_MATH_INTR_FUNCS_2_ARG = [
    # int math
    # absdiff, # Tu absdiff(T x, T y)
    # addsat, # T addsat(T x, T y)
    # hadd, # T hadd(T x, T y)
    max, # T max(T x, T y)
    min, # T min(T x, T y)
    Metal.mulhi, # T mulhi(T x, T y)
    # rhadd, # T rhadd(T x, T y)
    # rotate, # T rotate(T v, T i)
    # subsat, # T subsat(T x, T y)
]

INT_MATH_INTR_FUNCS_3_ARG = [
    # Common functions
    # clamp, # T clamp(T x, T minval, T maxval)
    # madhi, # T madhi(T a, T b, T c)
    # madsat, # T madsat(T a, T b, T c)
    max, # T max3(T x, T y, T z)
    # median3, # T median3(T x, T y, T z)
    min, # T min3(T x, T y, T z)
]

@testset "execution" begin

@testset "float math" begin
# 1-arg functions
@testset "$(fun)()::$T" for fun in FLOAT_MATH_INTR_FUNCS_1_ARG, T in (Float32, Float16)
    cpuarr = if fun in [log, log2, log10, sqrt]
        rand(T, 4)
    else
        T[0.0, -0.0, rand(T), -rand(T)]
    end

    mtlarr = MtlArray(cpuarr)

    mtlout = fill!(similar(mtlarr), 0)

    function kernel(res, arr)
        idx = thread_position_in_grid().x
        res[idx] = fun(arr[idx])
        return nothing
    end
    Metal.@sync @metal threads = length(mtlout) kernel(mtlout, mtlarr)
    @eval @test Array($mtlout) ≈ $fun.($cpuarr)
end
# 2-arg functions
@testset "$(fun)()::$T" for T in (Float32, Float16), fun in FLOAT_MATH_INTR_FUNCS_2_ARG
    N = 4
    arr1 = randn(T, N)
    arr2 = randn(T, N)
    mtlarr1 = MtlArray(arr1)
    mtlarr2 = MtlArray(arr2)

    mtlout = fill!(similar(mtlarr1), 0)

    function kernel(res, x, y)
        idx = thread_position_in_grid().x
        res[idx] = fun(x[idx], y[idx])
        return nothing
    end
    Metal.@sync @metal threads = N kernel(mtlout, mtlarr1, mtlarr2)
    @eval @test Array($mtlout) ≈ $fun.($arr1, $arr2)
end
# 3-arg functions
@testset "$(fun)()::$T" for T in (Float32, Float16), fun in FLOAT_MATH_INTR_FUNCS_3_ARG
    N = 4
    arr1 = randn(T, N)
    arr2 = randn(T, N)
    arr3 = randn(T, N)

    mtlarr1 = MtlArray(arr1)
    mtlarr2 = MtlArray(arr2)
    mtlarr3 = MtlArray(arr3)

    mtlout = fill!(similar(mtlarr1), 0)

    function kernel(res, x, y, z)
        idx = thread_position_in_grid().x
        res[idx] = fun(x[idx], y[idx], z[idx])
        return nothing
    end
    Metal.@sync @metal threads = N kernel(mtlout, mtlarr1, mtlarr2, mtlarr3)
    @eval @test Array($mtlout) ≈ $fun.($arr1, $arr2, $arr3)
end
end

@testset "unique float math" begin
@testset "$T" for T in (Float32, Float16)
    let # acosh
        arr = T[0, rand(T, 3)...] .+ T(1)
        buffer = MtlArray(arr)
        vec = acosh.(buffer)
        @test Array(vec) ≈ acosh.(arr)
    end

    let # rsqrt (Metal-specific, no Base equivalent; compare the GPU intrinsic to 1/sqrt)
        arr = rand(T, 4)
        d = MtlArray(arr)
        o = similar(d)
        function kernel(res, x)
            idx = thread_position_in_grid().x
            res[idx] = Metal.rsqrt(x[idx])
            return nothing
        end
        Metal.@sync @metal threads = length(arr) kernel(o, d)
        @test Array(o) ≈ 1 ./ sqrt.(arr)
    end

    let # fract (Metal-specific, no Base equivalent; compare the GPU intrinsic to mod(x, 1))
        arr = T[0.0, -0.0, rand(T), -rand(T)]
        d = MtlArray(arr)
        o = similar(d)
        function kernel(res, x)
            idx = thread_position_in_grid().x
            res[idx] = Metal.fract(x[idx])
            return nothing
        end
        Metal.@sync @metal threads = length(arr) kernel(o, d)
        @test Array(o) ≈ mod.(arr, 1)
    end

    let # sincos
        N = 4
        arr = rand(T, N)
        bufferA = MtlArray(arr)
        bufferB = MtlArray(arr)
        function intr_test3(arr_sin, arr_cos)
            idx = thread_position_in_grid().x
            sinres, cosres = sincos(arr_cos[idx])
            arr_sin[idx] = sinres
            arr_cos[idx] = cosres
            return nothing
        end

        Metal.@sync @metal threads = N intr_test3(bufferA, bufferB)
        @test Array(bufferA) ≈ sin.(arr)
        @test Array(bufferB) ≈ cos.(arr)
    end

    let # clamp
        N = 4
        in = randn(T, N)
        minval = fill(T(-0.6), N)
        maxval = fill(T(0.6), N)

        mtlin = MtlArray(in)
        mtlminval = MtlArray(minval)
        mtlmaxval = MtlArray(maxval)

        mtlout = fill!(similar(mtlin), 0)

        function kernel(res, x, y, z)
            idx = thread_position_in_grid().x
            res[idx] = clamp(x[idx], y[idx], z[idx])
            return nothing
        end
        Metal.@sync @metal threads = N kernel(mtlout, mtlin, mtlminval, mtlmaxval)
        @test Array(mtlout) == clamp.(in, minval, maxval)
    end

    let #pow
        N = 4
        arr1 = rand(T, N)
        arr2 = rand(T, N)
        mtlarr1 = MtlArray(arr1)
        mtlarr2 = MtlArray(arr2)

        mtlout = fill!(similar(mtlarr1), 0)

        function kernel(res, x, y)
            idx = thread_position_in_grid().x
            res[idx] = x[idx]^y[idx]
            return nothing
        end
        Metal.@sync @metal threads = N kernel(mtlout, mtlarr1, mtlarr2)
        @test Array(mtlout) ≈ arr1 .^ arr2
    end

    let #pow with Integer exponent (Issue 552)
        N = 4
        arr2 = [-1, 0, 1, 2, 3, rand(-10:10, N)...]
        arr1 = rand(T, length(arr2))
        mtlarr1 = MtlArray(arr1)
        mtlarr2 = MtlArray(arr2)

        mtlout = fill!(similar(mtlarr1), 0)

        function kernel(res, x, y)
            idx = thread_position_in_grid().x
            res[idx] = x[idx]^y[idx]
            return nothing
        end
        Metal.@sync @metal threads = length(mtlout) kernel(mtlout, mtlarr1, mtlarr2)
        @test Array(mtlout) ≈ arr1 .^ arr2
    end

    let #powr
        N = 4
        arr1 = rand(T, N)
        arr2 = rand(T, N)
        mtlarr1 = MtlArray(arr1)
        mtlarr2 = MtlArray(arr2)

        mtlout = fill!(similar(mtlarr1), 0)

        function kernel(res, x, y)
            idx = thread_position_in_grid().x
            res[idx] = Metal.powr(x[idx], y[idx])
            return nothing
        end
        Metal.@sync @metal threads = N kernel(mtlout, mtlarr1, mtlarr2)
        @test Array(mtlout) ≈ arr1 .^ arr2
    end

    let # log1p
        arr = T.(collect(LinRange(nextfloat(-1.0f0), 10.0f0, 20)))
        buffer = MtlArray(arr)
        cpures = log1p.(arr)
        @test Array(log1p.(buffer)) ≈ log1p.(arr)
    end

    let # erf
        arr = T[-1.0, -0.5, 0.0, 1.0e-3, 1.0, 2.0, 5.5]
        buffer = MtlArray(arr)
        cpures = SpecialFunctions.erf.(arr)
        @test Array(SpecialFunctions.erf.(buffer)) ≈ cpures
    end

    let # erfc
        arr = T.(collect(LinRange(nextfloat(-3.0f0), 3.0f0, 20)))
        buffer = MtlArray(arr)
        cpures = SpecialFunctions.erfc.(arr)
        @test Array(SpecialFunctions.erfc.(buffer)) ≈ cpures
    end

    let # erfinv
        arr = T.(collect(LinRange(-1.0f0, 1.0f0, 20)))
        buffer = MtlArray(arr)
        cpures = SpecialFunctions.erfinv.(arr)
        @test Array(SpecialFunctions.erfinv.(buffer)) ≈ cpures
    end

    let # expm1
        arr = T.(collect(LinRange(nextfloat(-88.0f0), 88.0f0, 100)))
        buffer = MtlArray(arr)
        cpures = expm1.(arr)
        @test Array(expm1.(buffer)) ≈ cpures
    end


    let # nextafter
        function nextafter_test(X, y)
            idx = thread_position_in_grid().x
            X[idx] = Metal.nextafter(X[idx], y)
            return nothing
        end

        # Check the code is generated as expected
        outval = T(0)
        function nextafter_out_test()
            Metal.nextafter(outval, outval)
            return
        end

        N = 4
        arr = rand(T, N)

        # test the intrinsic (macOS >= v14)
        if metal_support() >= v"3.1"
            buffer1 = MtlArray(arr)
            Metal.@sync @metal threads = N nextafter_test(buffer1, typemax(T))
            @test Array(buffer1) == nextfloat.(arr)
            Metal.@sync @metal threads = N nextafter_test(buffer1, typemin(T))
            @test Array(buffer1) == arr

            ir = sprint(io->(@device_code_llvm io=io dump_module=true @metal nextafter_out_test()))
            @test occursin(Regex("@air\\.nextafter\\.f$(8*sizeof(T))"), ir)
        end

        # test for metal < 3.1
        buffer2 = MtlArray(arr)
        Metal.@sync @metal threads = N metal = v"3.0" nextafter_test(buffer2, typemax(T))
        @test Array(buffer2) == nextfloat.(arr)
        Metal.@sync @metal threads = N metal = v"3.0" nextafter_test(buffer2, typemin(T))
        @test Array(buffer2) == arr

        # before macOS 14 there is no air.nextafter; the software fallback must be used
        # (it no longer emits air.sign since that override was dropped in favor of Base)
        ir = sprint(io->(@device_code_llvm io=io dump_module=true @metal metal = v"3.0" nextafter_out_test()))
        @test !occursin(Regex("@air\\.nextafter\\.f$(8*sizeof(T))"), ir)
    end

    # Borrowed from the Julia "Irrationals compared with Rationals and Floats" testset
    @testset "Comparisons with $irr" for irr in (π, ℯ)
        @eval function convert_test(res)
            res[1] = $T($irr, RoundDown) < $irr
            res[2] = $T($irr, RoundUp) > $irr
            res[3] = !($T($irr, RoundDown) > $irr)
            res[4] = !($T($irr, RoundUp) < $irr)
            return nothing
        end

        res = MtlArray(zeros(Bool, 4))
        Metal.@sync @metal convert_test(res)
        @test all(Array(res))
    end
end
end

# Ops whose Metal intrinsic has IEEE edge-case behavior that differs from Julia's: Metal's
# `sign` returns 0 for NaN (Julia returns NaN), `air.fmin`/`air.fmax` are non-NaN-propagating
# (Julia's min/max propagate NaN), and `air.round` rounds half away from zero (Julia rounds
# half to even). Metal.jl deliberately routes these through Base / a NaN-correcting back-end
# lowering instead of the raw intrinsic, so the GPU result should match the host. Compare
# against Julia's own result over NaN/±Inf/±0/tie inputs using `isequal` (NaN == NaN, and
# -0.0 != +0.0) rather than hard-coding the expected values, so a regression to the raw-
# intrinsic semantics is caught without baking that behavior into the test.
@testset "edge-case semantics match Julia" begin
@testset "$T" for T in (Float32, Float16)
    let # sign
        x = T[NaN, Inf, -Inf, T(0), T(-0.0), T(1.5), T(-1.5)]
        d = MtlArray(x)
        function kernel(o, a)
            i = thread_position_in_grid().x
            @inbounds o[i] = sign(a[i])
            return
        end
        o = similar(d)
        Metal.@sync @metal threads=length(x) kernel(o, d)
        @test isequal(Array(o), sign.(x))
    end

    # min/max: NaN in either operand, both signed zeros, and ±Inf
    xs = T[NaN, NaN, T(0),    T(-0.0), Inf,  -Inf, T(1), NaN,  T(-0.0)]
    ys = T[T(1), NaN, T(-0.0), T(0),   T(1), T(1), NaN,  -Inf, T(0)]
    @testset "$op" for op in (min, max)
        dx, dy = MtlArray(xs), MtlArray(ys)
        function kernel(o, a, b)
            i = thread_position_in_grid().x
            @inbounds o[i] = op(a[i], b[i])
            return
        end
        o = similar(dx)
        Metal.@sync @metal threads=length(xs) kernel(o, dx, dy)
        @test isequal(Array(o), op.(xs, ys))
    end

    let # clamp
        x  = T[NaN, Inf, -Inf, T(0.5), T(-0.5), T(2), T(-2)]
        lo = fill(T(-1), length(x)); hi = fill(T(1), length(x))
        dx, dlo, dhi = MtlArray(x), MtlArray(lo), MtlArray(hi)
        function kernel(o, a, b, c)
            i = thread_position_in_grid().x
            @inbounds o[i] = clamp(a[i], b[i], c[i])
            return
        end
        o = similar(dx)
        Metal.@sync @metal threads=length(x) kernel(o, dx, dlo, dhi)
        @test isequal(Array(o), clamp.(x, lo, hi))
    end

    let # round: Julia rounds half to even (via air.rint), not half away (air.round)
        x = T[0.5, 1.5, 2.5, 3.5, -0.5, -1.5, -2.5, -3.5]
        d = MtlArray(x)
        function kernel(o, a)
            i = thread_position_in_grid().x
            @inbounds o[i] = round(a[i])
            return
        end
        o = similar(d)
        Metal.@sync @metal threads=length(x) kernel(o, d)
        @test isequal(Array(o), round.(x))
    end
end
end

@testset "int math" begin
# 1-arg functions
@testset "$(fun)()::$T" for fun in INT_MATH_INTR_FUNCS_1_ARG, T in (Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64)
    cpuarr = T[0.0, -0.0, rand(T), -rand(T)]

    mtlarr = MtlArray(cpuarr)

    mtlout = fill!(similar(mtlarr), 0)

    function kernel(res, arr)
        idx = thread_position_in_grid().x
        res[idx] = fun(arr[idx])
        return nothing
    end
    Metal.@sync @metal threads = length(mtlout) kernel(mtlout, mtlarr)
    @eval @test Array($mtlout) ≈ $fun.($cpuarr)
end
# 2-arg functions
@testset "$(fun)()::$T" for T in (Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64), fun in INT_MATH_INTR_FUNCS_2_ARG
    N = 4
    arr1 = rand(T, N)
    arr2 = rand(T, N)
    mtlarr1 = MtlArray(arr1)
    mtlarr2 = MtlArray(arr2)

    mtlout = fill!(similar(mtlarr1), 0)

    function kernel(res, x, y)
        idx = thread_position_in_grid().x
        res[idx] = fun(x[idx], y[idx])
        return nothing
    end
    Metal.@sync @metal threads = N kernel(mtlout, mtlarr1, mtlarr2)
    @eval @test Array($mtlout) ≈ $fun.($arr1, $arr2)
end
# 3-arg functions
@testset "$(fun)()::$T" for T in (Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64), fun in INT_MATH_INTR_FUNCS_3_ARG
    N = 4
    arr1 = rand(T, N)
    arr2 = rand(T, N)
    arr3 = rand(T, N)

    mtlarr1 = MtlArray(arr1)
    mtlarr2 = MtlArray(arr2)
    mtlarr3 = MtlArray(arr3)

    mtlout = fill!(similar(mtlarr1), 0)

    function kernel(res, x, y, z)
        idx = thread_position_in_grid().x
        res[idx] = fun(x[idx], y[idx], z[idx])
        return nothing
    end
    Metal.@sync @metal threads = N kernel(mtlout, mtlarr1, mtlarr2, mtlarr3)
    @eval @test Array($mtlout) ≈ $fun.($arr1, $arr2, $arr3)
end
end

@testset "complex" begin
    a = rand(ComplexF32,4)
    bufferA = MtlArray(a)
    vecA = Array(sqrt.(bufferA))
    @test vecA ≈ sqrt.(a)

    # Division
    let
        N = 10

        x = rand(ComplexF32, N)
        y = rand(ComplexF32, N)

        dx = MtlArray(x)
        dy = MtlArray(y)


        z = x ./ y
        dz = dx ./ dy

        @test Array(dz) ≈ z

        # Over/Underflow tests
        as = MtlArray([Complex{Float32}(2.0e20, 2.0e20), Complex{Float32}(1.0e-25, 1.0e-25)])
        @test all(Array(as ./ as) .≈ Complex{Float32}(1.0, 0.0))
    end
end

end
