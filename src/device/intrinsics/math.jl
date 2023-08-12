# Math function mappings to Metal intrinsics

using Base: FastMath
using Base.Math: @horner

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

@device_override FastMath.min_fast(x::Float32) = ccall("extern air.fast_fmin.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.min(x::Float32) = ccall("extern air.fmin.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.min(x::Float16) = ccall("extern air.fmin.f16", llvmcall, Float16, (Float16,), x)

@device_override FastMath.max_fast(x::Float32) = ccall("extern air.fast_fmax.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.max(x::Float32) = ccall("extern air.fmax.f32", llvmcall, Cfloat, (Cfloat,), x)
@device_override Base.max(x::Float16) = ccall("extern air.fmax.f16", llvmcall, Float16, (Float16,), x)

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

# Re-implementation of Base.Math.log_proc1 and Base.Math.log_proc2 without upcasting to Float64

const t_log_Float32 = [0.0f0, 0.0077821403f0, 0.015504187f0, 0.023167059f0,
    0.030771658f0, 0.038318865f0, 0.045809537f0, 0.053244516f0, 0.06062462f0, 0.06795066f0,
    0.07522342f0, 0.08244367f0, 0.089612156f0, 0.09672963f0, 0.103796795f0, 0.11081436f0,
    0.11778303f0, 0.12470348f0, 0.13157636f0, 0.13840233f0, 0.14518201f0, 0.15191604f0,
    0.15860502f0, 0.16524957f0, 0.17185026f0, 0.17840765f0, 0.18492234f0, 0.19139485f0,
    0.19782574f0, 0.20421554f0, 0.21056476f0, 0.21687394f0, 0.22314355f0, 0.2293741f0, 0.23556606f0,
    0.24171993f0, 0.24783616f0, 0.25391522f0, 0.25995752f0, 0.26596355f0, 0.2719337f0, 0.27786845f0,
    0.28376818f0, 0.2896333f0, 0.29546422f0, 0.30126134f0, 0.30702505f0, 0.3127557f0, 0.31845373f0,
    0.32411948f0, 0.32975328f0, 0.33535555f0, 0.3409266f0, 0.34646678f0, 0.35197642f0, 0.35745588f0,
    0.3629055f0, 0.36832556f0, 0.3737164f0, 0.37907836f0, 0.3844117f0, 0.38971674f0, 0.3949938f0,
    0.40024316f0, 0.4054651f0, 0.41065994f0, 0.4158279f0, 0.4209693f0, 0.4260844f0, 0.43117347f0,
    0.43623677f0, 0.44127455f0, 0.4462871f0, 0.45127463f0, 0.45623744f0, 0.4611757f0, 0.46608973f0,
    0.47097972f0, 0.4758459f0, 0.48068854f0, 0.48550782f0, 0.490304f0, 0.49507725f0, 0.49982786f0,
    0.504556f0, 0.5092619f0, 0.51394576f0, 0.51860774f0, 0.52324814f0, 0.5278671f0, 0.5324648f0,
    0.5370415f0, 0.5415973f0, 0.54613245f0, 0.55064714f0, 0.5551415f0, 0.5596158f0, 0.56407017f0,
    0.56850475f0, 0.5729197f0, 0.5773154f0, 0.58169174f0, 0.586049f0, 0.59038746f0, 0.59470713f0,
    0.5990082f0, 0.60329086f0, 0.60755527f0, 0.61180156f0, 0.61602986f0, 0.6202404f0, 0.6244333f0,
    0.62860864f0, 0.63276666f0, 0.63690746f0, 0.6410312f0, 0.64513797f0, 0.6492279f0, 0.6533013f0,
    0.65735805f0, 0.6613985f0, 0.6654226f0, 0.6694307f0, 0.6734227f0, 0.6773988f0, 0.68135923f0,
    0.685304f0, 0.6892333f0, 0.6931472f0]

@inline logb(::Val{2})  = 1.442695f0
@inline logb(::Val{:ℯ}) = 1f0
@inline logb(::Val{10}) = 0.4342945f0

@device_override function Base.Math.log_proc1(y::Float32,mf::Float32,F::Float32,f::Float32,base=Val(:ℯ))
    jp = unsafe_trunc(Int,128.0f0*F)-127

    ## Steps 1 and 2
    hi = t_log_Float32[jp]
    l = mf*t_log_Float32[129] + hi

    ## Step 3
    # @inbounds u = f*c_invF[jp]
    # q = u*u*@horner(u,
    #                 Float32(-0x1.00006p-1),
    #                 Float32(0x1.55546cp-2))

    ## Step 3' (alternative)
    u = (2f0f)/(y+F)
    v = u*u
    q = u*v*0.08333351f0

    ## Step 4
    logb(base)*(l + (u + q))
end

@device_override function Base.Math.log_proc2(f::Float32,base=Val(:ℯ))
    ## Step 1
    g = 1f0/(2f0+f)
    u = 2(f*g)
    v = u*u

    ## Step 2
    q = u*v*@horner(v,
                    0.08333332f0,
                    0.012512346f0)

    ## Step 3
    @inline function truncate(x)
      reinterpret(Float32,
                  reinterpret(Int32, 0.012512346f0) & 0b11111111111100000000000000000000)
    end
    u₁ = truncate(u)
    f₁ = truncate(f)
    f₂ = f-f₁
    u₂ = ((2(f-u₁)-u₁*f₁) - u₁*f₂)*g

    ## Step 4
    logb(base)*(u₁ + (u₂ + q))
end

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

@device_override function FastMath.sincos_fast(x::Float32) 
    c = Ref{Cfloat}()
    s = ccall("extern air.fast_sincos.f32", llvmcall, Cfloat, (Cfloat, Ptr{Cfloat}), x, c)
    (s, c[])
end
@device_override function Base.sincos(x::Float32) 
    c = Ref{Cfloat}()
    s = ccall("extern air.sincos.f32", llvmcall, Cfloat, (Cfloat, Ptr{Cfloat}), x, c)
    (s, c[])
end
@device_override function Base.sincos(x::Float16) 
    c = Ref{Float16}()
    s = ccall("extern air.sincos.f16", llvmcall, Float16, (Float16, Ptr{Float16}), x, c)
    (s, c[])
end

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

# hypot without use of double
#
# taken from Cosmopolitan Libc
# Copyright 2021 Justine Alexandra Roberts Tunney
@inline function _hypot(a::T, b::T) where T <: AbstractFloat
    if isinf(a) || isinf(b)
        return T(Inf)
    end
    a = abs(a)
    b = abs(b)
    if a < b
        b, a = a, b
    end
    if iszero(a)
        return b
    end
    r = b / a
    return a * sqrt(one(T) + r * r)
end
@device_override Base.hypot(x::Float32, y::Float32) = _hypot(x, y)
@device_override Base.hypot(x::Float16, y::Float16) = _hypot(x, y)


### Integer Intrinsics

@device_override Base.abs(x::Int64)   = ccall("extern air.abs.s.i64", llvmcall, Int64, (Int64,), x)
@device_override Base.abs(x::UInt64)  = ccall("extern air.abs.u.i64", llvmcall, UInt64, (UInt64,), x)
@device_override Base.abs(x::Int32)   = ccall("extern air.abs.s.i32", llvmcall, Int32, (Int32,), x)
@device_override Base.abs(x::UInt32)  = ccall("extern air.abs.u.i32", llvmcall, UInt32, (UInt32,), x)
@device_override Base.abs(x::Int16)   = ccall("extern air.abs.s.i16", llvmcall, Int16, (Int16,), x)
@device_override Base.abs(x::UInt16)  = ccall("extern air.abs.u.i16", llvmcall, UInt16, (UInt16,), x)
@device_override Base.abs(x::Int8)    = ccall("extern air.abs.s.i8", llvmcall, Int8, (Int8,), x)
@device_override Base.abs(x::UInt8)   = ccall("extern air.abs.u.i8", llvmcall, UInt8, (UInt8,), x)

@device_override Base.min(x::Int64)   = ccall("extern air.min.s.i64", llvmcall, Int64, (Int64,), x)
@device_override Base.min(x::UInt64)  = ccall("extern air.min.u.i64", llvmcall, UInt64, (UInt64,), x)
@device_override Base.min(x::Int32)   = ccall("extern air.min.s.i32", llvmcall, Int32, (Int32,), x)
@device_override Base.min(x::UInt32)  = ccall("extern air.min.u.i32", llvmcall, UInt32, (UInt32,), x)
@device_override Base.min(x::Int16)   = ccall("extern air.min.s.i16", llvmcall, Int16, (Int16,), x)
@device_override Base.min(x::UInt16)  = ccall("extern air.min.u.i16", llvmcall, UInt16, (UInt16,), x)
@device_override Base.min(x::Int8)    = ccall("extern air.min.s.i8", llvmcall, Int8, (Int8,), x)
@device_override Base.min(x::UInt8)   = ccall("extern air.min.u.i8", llvmcall, UInt8, (UInt8,), x)

@device_override Base.max(x::Int64)   = ccall("extern air.max.s.i64", llvmcall, Int64, (Int64,), x)
@device_override Base.max(x::UInt64)  = ccall("extern air.max.u.i64", llvmcall, UInt64, (UInt64,), x)
@device_override Base.max(x::Int32)   = ccall("extern air.max.s.i32", llvmcall, Int32, (Int32,), x)
@device_override Base.max(x::UInt32)  = ccall("extern air.max.u.i32", llvmcall, UInt32, (UInt32,), x)
@device_override Base.max(x::Int16)   = ccall("extern air.max.s.i16", llvmcall, Int16, (Int16,), x)
@device_override Base.max(x::UInt16)  = ccall("extern air.max.u.i16", llvmcall, UInt16, (UInt16,), x)
@device_override Base.max(x::Int8)    = ccall("extern air.max.s.i8", llvmcall, Int8, (Int8,), x)
@device_override Base.max(x::UInt8)   = ccall("extern air.max.u.i8", llvmcall, UInt8, (UInt8,), x)

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
