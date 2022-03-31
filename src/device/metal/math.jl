# Valid Metal floating point types
const float_types = [(Float32, "f32", Cfloat), (Float16, "f16", Float16)]
# Metal's single-argument, floating point intrinsics
const float_intr = [:abs, :acos, :acosh, :asin, :asinh, :atan, :atanh,
                    :ceil, :copysign, :cos, :cosh, :cospi, :exp,
                    :exp2, :exp10, :floor, :fract#=no base equiv=#, :log, 
                    :log2, :log10, :rint#=no base equiv=#, :round, :rsqrt#=no base equiv=#, :sin,
                    :sincos, :sinh, :sinpi, :sqrt, :tan, :tanh,
                    :tanpi#=no base equiv=#, :trunc]

# Generatively create intrinsic wrappers
for (typ_jl, typ_str, typ_c) in float_types
    for intr in float_intr
        # Precise intrinsic
        extern_str = "extern julia.air.$(string(intr)).$(typ_str)"
        @eval @inline ($intr)(data::$typ_jl) = ccall($extern_str, llvmcall, $typ_c, ($typ_c,), data)
        # Fast intrinsic only for single-precision
        if typ_jl == Float32
            extern_str_fast = "extern julia.air.fast_$(string(intr)).$typ_str"
            intr_str_fast = Symbol("$(intr)_fast")
            @eval @inline $(intr_str_fast)(data::$typ_jl) = ccall($extern_str_fast, llvmcall, Cfloat, (Cfloat,), data)
        end
    end
end
