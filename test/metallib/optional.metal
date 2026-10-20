//
// a kernel whose only function constant is optional, so it works without a value for it

#include <metal_stdlib>
using namespace metal;

constant uint value [[function_constant(0)]];

kernel void foo(device uint *a [[buffer(0)]]) {
    a[0] = is_function_constant_defined(value) ? value : 42u;
}
