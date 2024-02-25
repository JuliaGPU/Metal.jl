//
// generates CNST header tag for function constants

constant float foo [[ function_constant(0) ]];
constant float bar [[ function_constant(2) ]];
using namespace metal;

kernel void vadd(device const float* a,
                 device const float* b,
                 device float* c,
                 uint i [[thread_position_in_grid]])
{
    c[i] = a[i] * foo + b[i] + bar;
}
