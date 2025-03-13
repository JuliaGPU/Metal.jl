using Metal: metal_support
using Random
using SpecialFunctions

############################################################################################

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
    Metal.fract, # T fract(T x)
    # ilogb, # Ti ilogb(T x)
    log, # T log(T x)
    log2, # T log2(T x)
    log10, # T log10(T x)
    # Metal.rint, # T rint(T x) # TODO: Add test. Not sure what the behaviour actually is
    round, # T round(T x)
    Metal.rsqrt, # T rsqrt(T x)
    sin, # T sin(T x)
    sinh, # T sinh(T x)
    sinpi, # T sinpi(T x)
    sqrt, # sqrt(T x)
    tan, # T tan(T x)
    tanh, # T tanh(T x)
    tanpi, # T tanpi(T x)
    trunc, # T trunc(T x)
]
Metal.rsqrt(x::Float16) = 1 / sqrt(x)
Metal.rsqrt(x::Float32) = 1 / sqrt(x)
Metal.fract(x::Float16) = mod(x, 1)
Metal.fract(x::Float32) = mod(x, 1)

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

@testset "float math" begin
# 1-arg functions
@testset "$(fun)()::$T" for fun in FLOAT_MATH_INTR_FUNCS_1_ARG, T in (Float32, Float16)
    cpuarr = if fun in [log, log2, log10, Metal.rsqrt, sqrt]
        rand(T, 4)
    else
        T[0.0, -0.0, rand(T), -rand(T)]
    end

    mtlarr = MtlArray(cpuarr)

    mtlout = fill!(similar(mtlarr), 0)

    function kernel(res, arr)
        idx = thread_position_in_grid_1d()
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
        idx = thread_position_in_grid_1d()
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
        idx = thread_position_in_grid_1d()
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

    let # sincos
        N = 4
        arr = rand(T, N)
        bufferA = MtlArray(arr)
        bufferB = MtlArray(arr)
        function intr_test3(arr_sin, arr_cos)
            idx = thread_position_in_grid_1d()
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
            idx = thread_position_in_grid_1d()
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
            idx = thread_position_in_grid_1d()
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
            idx = thread_position_in_grid_1d()
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
            idx = thread_position_in_grid_1d()
            res[idx] = Metal.powr(x[idx], y[idx])
            return nothing
        end
        Metal.@sync @metal threads = N kernel(mtlout, mtlarr1, mtlarr2)
        @test Array(mtlout) ≈ arr1 .^ arr2
    end

    let # log1p
        arr = collect(LinRange(nextfloat(-1.0f0), 10.0f0, 20))
        buffer = MtlArray(arr)
        vec = Array(log1p.(buffer))
        @test vec ≈ log1p.(arr)
    end

    let # erf
        arr = collect(LinRange(nextfloat(-3.0f0), 3.0f0, 20))
        buffer = MtlArray(arr)
        vec = Array(SpecialFunctions.erf.(buffer))
        @test vec ≈ SpecialFunctions.erf.(arr)
    end

    let # erfc
        arr = collect(LinRange(nextfloat(-3.0f0), 3.0f0, 20))
        buffer = MtlArray(arr)
        vec = Array(SpecialFunctions.erfc.(buffer))
        @test vec ≈ SpecialFunctions.erfc.(arr)
    end

    let # erfinv
        arr = collect(LinRange(-1.0f0, 1.0f0, 20))
        buffer = MtlArray(arr)
        vec = Array(SpecialFunctions.erfinv.(buffer))
        @test vec ≈ SpecialFunctions.erfinv.(arr)
    end

    let # expm1
        arr = collect(LinRange(nextfloat(-88.0f0), 88.0f0, 100))
        buffer = MtlArray(arr)
        vec = Array(expm1.(buffer))
        @test vec ≈ expm1.(arr)
    end


    let # nextafter
        function nextafter_test(X, y)
            idx = thread_position_in_grid_1d()
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

        ir = sprint(io->(@device_code_llvm io=io dump_module=true @metal metal = v"3.0" nextafter_out_test()))
        @test occursin(Regex("@air\\.sign\\.f$(8*sizeof(T))"), ir)
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

INT_MATH_INTR_FUNCS_1_ARG = [
    # integer math
    abs,
    Metal.clz, # T clz(T x)
    Metal.ctz, # T ctz(T x)
    Metal.popcount, # T popcount(T x)
    Metal.reverse_bits, # T reverse_bits(T x)
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

@testset "int math" begin
# 1-arg functions
@testset "$(fun)()::$T" for fun in INT_MATH_INTR_FUNCS_1_ARG, T in (Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64)
    cpuarr = T[0.0, -0.0, rand(T), -rand(T)]

    mtlarr = MtlArray(cpuarr)

    mtlout = fill!(similar(mtlarr), 0)

    function kernel(res, arr)
        idx = thread_position_in_grid_1d()
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
        idx = thread_position_in_grid_1d()
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
        idx = thread_position_in_grid_1d()
        res[idx] = fun(x[idx], y[idx], z[idx])
        return nothing
    end
    Metal.@sync @metal threads = N kernel(mtlout, mtlarr1, mtlarr2, mtlarr3)
    @eval @test Array($mtlout) ≈ $fun.($arr1, $arr2, $arr3)
end
end

############################################################################################

@testset "complex" begin
    a = rand(ComplexF32,4)
    bufferA = MtlArray(a)
    vecA = Array(sqrt.(bufferA))
    @test vecA ≈ sqrt.(a)
end
