//
// Core Image kernels: a METALLIB_CI library where all functions share one module

#include <CoreImage/CoreImage.h>

extern "C" { namespace coreimage {

float4 brighten(sample_t s, float amount)
{
    return float4(s.rgb * amount, s.a);
}

float4 invert(sample_t s)
{
    return float4(1.0 - s.rgb, s.a);
}

}}
