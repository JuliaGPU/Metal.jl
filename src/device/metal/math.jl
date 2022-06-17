# Math function mappings to Metal intrinsics

using Base: FastMath

# TODO:
# - wrap all intrinsics from include/metal/metal_math
# - add support for vector types
# - consider emitting LLVM intrinsics and lowering those in the back-end

### Floating Point Intrinsics

## Metal only supports single and half-precision floating-point types (and their vector counterparts)
## For single precision types, there are precise and fast variants

@device_override FastMath.abs_fast(x::Float32) = ccall("extern air.fast_fabs.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.abs(x::Float32) = ccall("extern air.fabs.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.abs(x::Float16) = ccall("extern air.fabs.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.acos_fast(x::Float32) = ccall("extern air.fast_acos.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.acos(x::Float32) = ccall("extern air.acos.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.acos(x::Float16) = ccall("extern air.acos.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.acosh_fast(x::Float32) = ccall("extern air.fast_acosh.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.acosh(x::Float32) = ccall("extern air.acosh.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.acosh(x::Float16) = ccall("extern air.acosh.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.asin_fast(x::Float32) = ccall("extern air.fast_asin.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.asin(x::Float32) = ccall("extern air.asin.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.asin(x::Float16) = ccall("extern air.asin.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.asinh_fast(x::Float32) = ccall("extern air.fast_asinh.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.asinh(x::Float32) = ccall("extern air.asinh.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.asinh(x::Float16) = ccall("extern air.asinh.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.atan_fast(x::Float32) = ccall("extern air.fast_atan.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.atan(x::Float32) = ccall("extern air.atan.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.atan(x::Float16) = ccall("extern air.atan.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.atanh_fast(x::Float32) = ccall("extern air.fast_atanh.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.atanh(x::Float32) = ccall("extern air.atanh.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.atanh(x::Float16) = ccall("extern air.atanh.f16", llvmcall, Float16, (Float16,), x)

@device_function ceil_fast(x::Float32) = ccall("extern air.fast_ceil.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.ceil(x::Float32) = ccall("extern air.ceil.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.ceil(x::Float16) = ccall("extern air.ceil.f16", llvmcall, Float16, (Float16,), x)

@device_function copysign_fast(x::Float32) = ccall("extern air.fast_copysign.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.copysign(x::Float32) = ccall("extern air.copysign.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.copysign(x::Float16) = ccall("extern air.copysign.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.cos_fast(x::Float32) = ccall("extern air.fast_cos.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.cos(x::Float32) = ccall("extern air.cos.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.cos(x::Float16) = ccall("extern air.cos.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.cosh_fast(x::Float32) = ccall("extern air.fast_cosh.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.cosh(x::Float32) = ccall("extern air.cosh.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.cosh(x::Float16) = ccall("extern air.cosh.f16", llvmcall, Float16, (Float16,), x)

@device_function cospi_fast(x::Float32) = ccall("extern air.fast_cospi.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.cospi(x::Float32) = ccall("extern air.cospi.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.cospi(x::Float16) = ccall("extern air.cospi.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.exp_fast(x::Float32) = ccall("extern air.fast_exp.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.exp(x::Float32) = ccall("extern air.exp.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.exp(x::Float16) = ccall("extern air.exp.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.exp2_fast(x::Float32) = ccall("extern air.fast_exp2.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.exp2(x::Float32) = ccall("extern air.exp2.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.exp2(x::Float16) = ccall("extern air.exp2.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.exp10_fast(x::Float32) = ccall("extern air.fast_exp10.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.exp10(x::Float32) = ccall("extern air.exp10.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.exp10(x::Float16) = ccall("extern air.exp10.f16", llvmcall, Float16, (Float16,), x)

@device_function floor_fast(x::Float32) = ccall("extern air.fast_floor.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.floor(x::Float32) = ccall("extern air.floor.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.floor(x::Float16) = ccall("extern air.floor.f16", llvmcall, Float16, (Float16,), x)

# half/regular -> air.fma.f16
# half/(precise or fast) -> air.fma.f32
@device_override Base.fma(a::Float32, b::Float32, c::Float32) = ccall("extern air.fma.f32", llvmcall, Float32, (Float32,Float32,Float32,), a,b,c)
@device_override Base.fma(a::Float16, b::Float16, c::Float16) = ccall("extern air.fma.f32", llvmcall, Float16, (Float16,Float16,Float16,), a,b,c)

@device_function fract_fast(x::Float32) = ccall("extern air.fast_fract.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_function fract(x::Float32) = ccall("extern air.fract.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_function fract(x::Float16) = ccall("extern air.fract.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.log_fast(x::Float32) = ccall("extern air.fast_log.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.log(x::Float32) = ccall("extern air.log.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.log(x::Float16) = ccall("extern air.log.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.log2_fast(x::Float32) = ccall("extern air.fast_log2.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.log2(x::Float32) = ccall("extern air.log2.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.log2(x::Float16) = ccall("extern air.log2.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.log10_fast(x::Float32) = ccall("extern air.fast_log10.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.log10(x::Float32) = ccall("extern air.log10.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.log10(x::Float16) = ccall("extern air.log10.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.pow_fast(x::Float32, y::Float32) = ccall("extern air.fast_pow.f32", llvmcall, Cfloat, (Cfloat, Cfloat), x, y)
@device_override Base.:(^)(x::Float32, y::Float32) = ccall("extern air.pow.f32", llvmcall, Cfloat, (Cfloat, Cfloat), x, y)
@device_override Base.:(^)(x::Float16, y::Float16) = ccall("extern air.pow.f16", llvmcall, Float16, (Float16, Float16), x, y)

@device_function powr_fast(x::Float32, y::Float32) = ccall("extern air.fast_powr.f32", llvmcall, Cfloat, (Cfloat, Cfloat), x, y)
@device_function powr(x::Float32, y::Float32) = ccall("extern air.powr.f32", llvmcall, Cfloat, (Cfloat, Cfloat), x, y)
@device_function powr(x::Float16, y::Float16) = ccall("extern air.powr.f16", llvmcall, Float16, (Float16, Float16), x, y)

@device_function rint_fast(x::Float32) = ccall("extern air.fast_rint.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_function rint(x::Float32) = ccall("extern air.rint.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_function rint(x::Float16) = ccall("extern air.rint.f16", llvmcall, Float16, (Float16,), x)

@device_function round_fast(x::Float32) = ccall("extern air.fast_round.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.round(x::Float32) = ccall("extern air.round.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.round(x::Float16) = ccall("extern air.round.f16", llvmcall, Float16, (Float16,), x)

@device_function rsqrt_fast(x::Float32) = ccall("extern air.fast_rsqrt.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_function rsqrt(x::Float32) = ccall("extern air.rsqrt.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_function rsqrt(x::Float16) = ccall("extern air.rsqrt.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.sin_fast(x::Float32) = ccall("extern air.fast_sin.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.sin(x::Float32) = ccall("extern air.sin.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.sin(x::Float16) = ccall("extern air.sin.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.sincos_fast(x::Float32) = ccall("extern air.fast_sincos.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.sincos(x::Float32) = ccall("extern air.sincos.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.sincos(x::Float16) = ccall("extern air.sincos.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.sinh_fast(x::Float32) = ccall("extern air.fast_sinh.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.sinh(x::Float32) = ccall("extern air.sinh.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.sinh(x::Float16) = ccall("extern air.sinh.f16", llvmcall, Float16, (Float16,), x)

@device_function sinpi_fast(x::Float32) = ccall("extern air.fast_sinpi.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.sinpi(x::Float32) = ccall("extern air.sinpi.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.sinpi(x::Float16) = ccall("extern air.sinpi.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.sqrt_fast(x::Float32) = ccall("extern air.fast_sqrt.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.sqrt(x::Float32) = ccall("extern air.sqrt.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.sqrt(x::Float16) = ccall("extern air.sqrt.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.tan_fast(x::Float32) = ccall("extern air.fast_tan.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.tan(x::Float32) = ccall("extern air.tan.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.tan(x::Float16) = ccall("extern air.tan.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.tanh_fast(x::Float32) = ccall("extern air.fast_tanh.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.tanh(x::Float32) = ccall("extern air.tanh.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.tanh(x::Float16) = ccall("extern air.tanh.f16", llvmcall, Float16, (Float16,), x)

@device_function tanpi_fast(x::Float32) = ccall("extern air.fast_tanpi.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_function tanpi(x::Float32) = ccall("extern air.tanpi.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_function tanpi(x::Float16) = ccall("extern air.tanpi.f16", llvmcall, Float16, (Float16,), x)

@device_function trunc_fast(x::Float32) = ccall("extern air.fast_trunc.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.trunc(x::Float32) = ccall("extern air.trunc.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.trunc(x::Float16) = ccall("extern air.trunc.f16", llvmcall, Float16, (Float16,), x)


### Integer Intrinsics

@device_override Base.abs(x::Int64)   = ccall("extern air.abs.s.i64", llvmcall, Int64, (Int64,), x)
@device_override Base.abs(x::UInt64)  = ccall("extern air.abs.u.i64", llvmcall, UInt64, (UInt64,), x)
@device_override Base.abs(x::Int32)   = ccall("extern air.abs.s.i32", llvmcall, Int32, (Int32,), x)
@device_override Base.abs(x::UInt32)  = ccall("extern air.abs.u.i32", llvmcall, UInt32, (UInt32,), x)
@device_override Base.abs(x::Int16)   = ccall("extern air.abs.s.i16", llvmcall, Int16, (Int16,), x)
@device_override Base.abs(x::UInt16)  = ccall("extern air.abs.u.i16", llvmcall, UInt16, (UInt16,), x)
@device_override Base.abs(x::Int8)    = ccall("extern air.abs.s.i8", llvmcall, Int8, (Int8,), x)
@device_override Base.abs(x::UInt8)   = ccall("extern air.abs.u.i8", llvmcall, UInt8, (UInt8,), x)

@device_function clz(x::Int64)   = ccall("extern air.clz.i64", llvmcall, Int64, (Int64,), x)
@device_function clz(x::UInt64)  = ccall("extern air.clz.i64", llvmcall, UInt64, (UInt64,), x)
@device_function clz(x::Int32)   = ccall("extern air.clz.i32", llvmcall, Int32, (Int32,), x)
@device_function clz(x::UInt32)  = ccall("extern air.clz.i32", llvmcall, UInt32, (UInt32,), x)
@device_function clz(x::Int16)   = ccall("extern air.clz.i16", llvmcall, Int16, (Int16,), x)
@device_function clz(x::UInt16)  = ccall("extern air.clz.i16", llvmcall, UInt16, (UInt16,), x)
@device_function clz(x::Int8)    = ccall("extern air.clz.i8", llvmcall, Int8, (Int8,), x)
@device_function clz(x::UInt8)   = ccall("extern air.clz.i8", llvmcall, UInt8, (UInt8,), x)

@device_function ctz(x::Int64)   = ccall("extern air.ctz.i64", llvmcall, Int64, (Int64,), x)
@device_function ctz(x::UInt64)  = ccall("extern air.ctz.i64", llvmcall, UInt64, (UInt64,), x)
@device_function ctz(x::Int32)   = ccall("extern air.ctz.i32", llvmcall, Int32, (Int32,), x)
@device_function ctz(x::UInt32)  = ccall("extern air.ctz.i32", llvmcall, UInt32, (UInt32,), x)
@device_function ctz(x::Int16)   = ccall("extern air.ctz.i16", llvmcall, Int16, (Int16,), x)
@device_function ctz(x::UInt16)  = ccall("extern air.ctz.i16", llvmcall, UInt16, (UInt16,), x)
@device_function ctz(x::Int8)    = ccall("extern air.ctz.i8", llvmcall, Int8, (Int8,), x)
@device_function ctz(x::UInt8)   = ccall("extern air.ctz.i8", llvmcall, UInt8, (UInt8,), x)

@device_function popcount(x::Int64)   = ccall("extern air.popcount.i64", llvmcall, Int64, (Int64,), x)
@device_function popcount(x::UInt64)  = ccall("extern air.popcount.i64", llvmcall, UInt64, (UInt64,), x)
@device_function popcount(x::Int32)   = ccall("extern air.popcount.i32", llvmcall, Int32, (Int32,), x)
@device_function popcount(x::UInt32)  = ccall("extern air.popcount.i32", llvmcall, UInt32, (UInt32,), x)
@device_function popcount(x::Int16)   = ccall("extern air.popcount.i16", llvmcall, Int16, (Int16,), x)
@device_function popcount(x::UInt16)  = ccall("extern air.popcount.i16", llvmcall, UInt16, (UInt16,), x)
@device_function popcount(x::Int8)    = ccall("extern air.popcount.i8", llvmcall, Int8, (Int8,), x)
@device_function popcount(x::UInt8)   = ccall("extern air.popcount.i8", llvmcall, UInt8, (UInt8,), x)

@device_function reverse_bits(x::Int64)   = ccall("extern air.reverse_bits.i64", llvmcall, Int64, (Int64,), x)
@device_function reverse_bits(x::UInt64)  = ccall("extern air.reverse_bits.i64", llvmcall, UInt64, (UInt64,), x)
@device_function reverse_bits(x::Int32)   = ccall("extern air.reverse_bits.i32", llvmcall, Int32, (Int32,), x)
@device_function reverse_bits(x::UInt32)  = ccall("extern air.reverse_bits.i32", llvmcall, UInt32, (UInt32,), x)
@device_function reverse_bits(x::Int16)   = ccall("extern air.reverse_bits.i16", llvmcall, Int16, (Int16,), x)
@device_function reverse_bits(x::UInt16)  = ccall("extern air.reverse_bits.i16", llvmcall, UInt16, (UInt16,), x)
@device_function reverse_bits(x::Int8)    = ccall("extern air.reverse_bits.i8", llvmcall, Int8, (Int8,), x)
@device_function reverse_bits(x::UInt8)   = ccall("extern air.reverse_bits.i8", llvmcall, UInt8, (UInt8,), x)
