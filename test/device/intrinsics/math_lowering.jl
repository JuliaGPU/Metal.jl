# Verify that high-level math/integer operations lower to the expected AIR intrinsics.
#
# This pins the *lowering* (which AIR intrinsic each operation emits), complementing the
# numerical tests in `math.jl`. It guards the operations whose AIR intrinsic is emitted by
# GPUCompiler rather than by an explicit `@device_override` here — `abs`, integer `min`/`max`,
# `leading_zeros`/`trailing_zeros`/`count_ones`/`bitreverse`, the 3-argument `min`/`max` fused
# to `air.min3`/`air.max3`, and the NaN-propagating float `min`/`max` — so a back-end change
# that stops emitting them is caught here instead of silently regressing performance.
#
# We inspect `Metal.code_llvm` (the IR after GPUCompiler's `finish_ir!`, where the `air.*`
# intrinsics appear); no GPU or metallib build is needed. Each function is spliced into the
# compiled closure via `@eval` so the call is a concrete, specializable call (a captured
# `Function` would dispatch dynamically and never lower).

using FileCheck
import Base.FastMath

# integer types paired with their AIR mangling: `iN` width suffix and `s`/`u` signedness.
const INT_TYPES = [(Int8, "i8", "s"), (UInt8, "i8", "u"), (Int16, "i16", "s"),
                   (UInt16, "i16", "u"), (Int32, "i32", "s"), (UInt32, "i32", "u"),
                   (Int64, "i64", "s"), (UInt64, "i64", "u")]

@testset "intrinsic lowering" begin

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
        # only f16 fma is overridden (f32 fma is a native llvm.fma the back-end handles)
        @test @filecheck begin
            @check "@air.fma.f16"
            Metal.code_llvm((a, b, c) -> fma(a, b, c), Tuple{Float16,Float16,Float16})
        end
        # only f16 sqrt is overridden
        @test @filecheck begin
            @check "@air.sqrt.f16"
            Metal.code_llvm(x -> sqrt(x), Tuple{Float16})
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

# NaN-propagating float min/max are lowered to air.fmin/air.fmax by GPUCompiler.
@testset "float $name $T" for T in (Float32, Float16), (fn, name) in ((min, "fmin"), (max, "fmax"))
    @eval @test @filecheck begin
        @check $("@air.$name.f$(8*sizeof(T))")
        Metal.code_llvm((x, y) -> $fn(x, y), Tuple{$T,$T})
    end
end

# clamp and sign use the (correct) Base fallbacks now; they must not emit a phantom AIR
# intrinsic (the dropped air.clamp/air.sign overrides — JuliaGPU/Metal.jl removed these).
@testset "no phantom intrinsic" begin
    @eval begin
        @test @filecheck begin
            @check_not "air.clamp"
            Metal.code_llvm((x, lo, hi) -> clamp(x, lo, hi), Tuple{Float32,Float32,Float32})
        end
        @test @filecheck begin
            @check_not "air.sign"
            Metal.code_llvm(x -> sign(x), Tuple{Float32})
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
        Metal.code_llvm(x -> abs(x), Tuple{$T})
    end
end

# 2-argument min/max -> air.{min,max}.{s,u}.iN
@testset "$name $T" for (T, iN, sgn) in INT_TYPES, (fn, name) in ((min, "min"), (max, "max"))
    @eval @test @filecheck begin
        @check $("@air.$name.$sgn.$iN")
        Metal.code_llvm((x, y) -> $fn(x, y), Tuple{$T,$T})
    end
end

# 3-argument min/max -> air.{min,max}3.{s,u}.iN (GPUCompiler fuses the chained llvm intrinsics)
@testset "$name 3-arg $T" for (T, iN, sgn) in INT_TYPES, (fn, name) in ((min, "min3"), (max, "max3"))
    @eval @test @filecheck begin
        @check $("@air.$name.$sgn.$iN")
        Metal.code_llvm((x, y, z) -> $fn(x, y, z), Tuple{$T,$T,$T})
    end
end

# bit intrinsics (no signedness suffix) -> air.{clz,ctz,popcount,reverse_bits}.iN
@testset "$name $T" for (T, iN, sgn) in INT_TYPES,
                        (fn, name) in ((leading_zeros, "clz"), (trailing_zeros, "ctz"),
                                       (count_ones, "popcount"), (bitreverse, "reverse_bits"))
    @eval @test @filecheck begin
        @check $("@air.$name.$iN")
        Metal.code_llvm(x -> $fn(x), Tuple{$T})
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
