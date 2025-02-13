module SpecialFunctionsExt # Should be same name as the file (just like a normal package)

using Metal
using SpecialFunctions

# math functionality corresponding to SpecialFunctions.jl

## error function

const tiny = 1.0f-30

# Coefficients for approximation to erf on [0,0.84375]
const efx  =  1.2837916613f-1
const efx8 =  1.027033329f+0

# Domain [0, 0.84375], range ~[-5.4446e-10,5.5197e-10]: |(erf(x) - x)/x - p(x)/q(x)| < 2**-31.
const pp0  =  1.28379166f-1
const pp1  = -3.36030394f-1
const pp2  = -1.86260219f-3
const qq1  =  3.12324286f-1
const qq2  =  2.16070302f-2
const qq3  = -1.98859419f-3

# Domain [0.84375, 1.25], range ~[-1.953e-11,1.940e-11]: |(erf(x) - erx) - p(x)/q(x)| < 2**-36.
const erx  =  8.42697144f-1
const pa0  =  3.64939137f-6
const pa1  =  4.15109694f-1
const pa2  = -1.65179938f-1
const pa3  =  1.10914491f-1
const qa1  =  6.02074385f-1
const qa2  =  5.35934687f-1
const qa3  =  1.68576106f-1
const qa4  =  5.62181212f-2

# Domain [1.25,1/0.35], range ~[-7.043e-10,7.457e-10]: |log(x*erfc(x)) + x**2 + 0.5625 - r(x)/s(x)| < 2**-30
const ra0  = -9.87132732f-3
const ra1  = -5.53605914f-1
const ra2  = -2.17589188f+0
const ra3  = -1.43268085f+0
const sa1  =  5.45995426f+0
const sa2  =  6.69798088f+0
const sa3  =  1.43113089f+0
const sa4  = -5.77397496f-2

# Domain [1/0.35, 11], range ~[-2.264e-13,2.336e-13]: |log(x*erfc(x)) + x**2 + 0.5625 - r(x)/s(x)| < 2**-42
const rb0  = -9.86494310f-03
const rb1  = -6.25171244f-01
const rb2  = -6.16498327f+00
const rb3  = -1.66696873f+01
const rb4  = -9.53764343f+00
const sb1  =  1.26884899f+01
const sb2  =  4.51839523f+01
const sb3  =  4.72810211f+01
const sb4  =  8.93033314f+00


# Implementation of `erf(::Float32)` from openlibm's `erfcf`
# https://github.com/JuliaMath/openlibm/blob/12f5ffcc990e16f4120d4bf607185243f5affcb8/src/s_erff.c
Metal.@device_override function SpecialFunctions.erf(x::Float32)
    hx = reinterpret(Int32, x)
    ix = hx & 0x7fffffff

    if ix >= 0x7f800000 # erf(nan)=nan
        i = (reinterpret(UInt32, hx) >> 31) << 1
        return reinterpret(Float32, 1 - i) + 1.0f0 / x # erf(+-inf)=+-1
    end

    if ix < 0x3f580000 # |x|<0.84375
        if ix < 0x38800000 # |x|<2**-14
            if ix < 0x38800000 #|x|<2**-14
                if ix < 0x04000000 # |x|<0x1p-119
                    return (8 * x + efx8 * x) / 8 # avoid spurious underflow
                end
                return x + efx * x
            end
        end
    end

    if ix < 0x3fa00000 # 0.84375 <= |x| < 1.25
        s = abs(x) - 1.0f0
        P = pa0 + s * (pa1 + s * (pa2 + s * pa3))
        Q = 1.0f0 + s * (qa1 + s * (qa2 + s * (qa3 + s * qa4)))
        if hx >= 0
            return erx + P / Q
        else
            return -erx - P / Q
        end
    end

    if ix >= 0x40800000 # inf>|x|>=4
        if hx >= 0
            return 1.0f0 - tiny
        else
            return tiny - 1.0f0
        end
    end

    x = abs(x)
    s = 1.0f0 / (x * x)

    if ix < 0x4036DB6E # |x| < 1/0.35
        R = ra0 + s * (ra1 + s * (ra2 + s * ra3))
        S = 1.0f0 + s * (sa1 + s * (sa2 + s * (sa3 + s * sa4)))
    else # |x| >= 1/0.35 */
        R = rb0 + s * (rb1 + s * (rb2 + s * (rb3 + s * rb4)))
        S = 1.0f0 + s * (sb1 + s * (sb2 + s * (sb3 + s * sb4)))
    end

    z = reinterpret(Float32, hx & 0xffffe000)
    r = exp(-z * z - 0.5625f0) * exp((z - x) * (z + x) + R / S)

    if hx >= 0
        return 1.0f0 - r / x
    else
        return r / x - 1.0f0
    end
end

# Implementation of `erfc(::Float32)` from openlibm's `erfcf`
# https://github.com/JuliaMath/openlibm/blob/12f5ffcc990e16f4120d4bf607185243f5affcb8/src/s_erff.c
Metal.@device_override function SpecialFunctions.erfc(x::Float32)
    hx = reinterpret(Int32, x)
    ix = hx & 0x7fffffff

    if ix >= 0x7f800000 # erfc(nan)=nan
        # erfc(+-inf)=0,2
        return reinterpret(Float32, (reinterpret(UInt32, hx) >> 31) << 1) + 1.0f0 / x
    end

    if ix < 0x3f580000 # |x|<0.84375
        if ix < 0x33800000 # |x|<2**-56
            return 1.0f0 - x
        end

        z = x * x
        r = pp0 + z * (pp1 + z * pp2)
        s = 1.0f0 + z * (qq1 + z * (qq2 + z * qq3))
        y = r / s

        if hx < 0x3e800000 # x<1/4
            return 1.0f0 - (x + x * y)
        else
            r = x * y
            r += (x - 0.5f0)
            return 0.5f0 - r
        end
    end

    if ix < 0x3fa00000 # 0.84375 <= |x| < 1.25
        s = abs(x) - 1.0f0
        P = pa0 + s * (pa1 + s * (pa2 + s * pa3))
        Q = 1.0f0 + s * (qa1 + s * (qa2 + s * (qa3 + s * qa4)))
        if hx >= 0
            z = 1.0f0 - erx
            return z - P / Q
        else
            z = erx + P / Q
            return 1.0f0 + z
        end
    end

    if ix < 0x41300000 # |x|<28
        x = abs(x)
        s = 1.0f0 / (x * x)
        if ix < 0x4036DB6D # |x| < 1/.35 ~ 2.857143
            R = ra0 + s * (ra1 + s * (ra2 + s * ra3))
            S = 1.0f0 + s * (sa1 + s * (sa2 + s * (sa3 + s * sa4)))
        else # |x| >= 1/.35 ~ 2.857143
            if hx < 0 && ix >= 0x40a00000
                return 2.0f0 - tiny # x < -5
            end
            R = rb0 + s * (rb1 + s * (rb2 + s * (rb3 + s * rb4)))
            S = 1.0f0 + s * (sb1 + s * (sb2 + s * (sb3 + s * sb4)))
        end
        z = reinterpret(Float32, hx & 0xffffe000)
        r = exp(-z * z - 0.5625f0) * exp((z - x) * (z + x) + R / S)
        if hx > 0
            return r / x
        else
            return 2.0f0 - r / x
        end
    else
        if hx > 0
            return tiny * tiny
        else
            return 2.0f0 - tiny
        end
    end
end

#
#  Approximation to the error function.
#  Based on code from:
#  https://stackoverflow.com/questions/35148198/efficient-faithfully-rounded-implementation-of-error-function-erff#answer-35148199
#

Metal.@device_override function SpecialFunctions.erfinv(a::Float32)
    t = fma(a, 0.0f0 - a, 1.0f0)
    t = log(t)

    if abs(t) > 6.125f0
        p = 3.03697567f-10
        p = fma(p, t, 2.93243101f-8)
        p = fma(p, t, 1.22150334f-6)
        p = fma(p, t, 2.84108955f-5)
        p = fma(p, t, 3.93552968f-4)
        p = fma(p, t, 3.02698812f-3)
        p = fma(p, t, 4.83185798f-3)
        p = fma(p, t, -2.64646143f-1)
        p = fma(p, t, 8.40016484f-1)
        return a * p
    else
        p = 5.43877832f-9
        p = fma(p, t, 1.43285448f-7)
        p = fma(p, t, 1.22774793f-6)
        p = fma(p, t, 1.12963626f-7)
        p = fma(p, t, -5.6153076f-5)
        p = fma(p, t, -1.47697632f-4)
        p = fma(p, t, 2.31468678f-3)
        p = fma(p, t, 1.15392581f-2)
        p = fma(p, t, -2.32015476f-1)
        p = fma(p, t, 8.86226892f-1)
        return a * p
    end
end


end # module
