//
// function constants a function checks with `is_function_constant_defined` are optional

#include <metal_stdlib>
using namespace metal;

constant uint scale [[ function_constant(0) ]];
constant uint offset [[ function_constant(1) ]];
constant uint offset_or_zero = is_function_constant_defined(offset) ? offset : 0;

kernel void affine(device uint* a [[ buffer(0) ]],
                   uint i [[ thread_position_in_grid ]])
{
    a[i] = a[i] * scale + offset_or_zero;
}
