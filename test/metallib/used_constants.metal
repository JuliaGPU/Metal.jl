//
// functions only list the function constants they use, even through program-scope
// constants that are computed for all functions by the same static initializer

#include <metal_stdlib>
using namespace metal;

constant uint c1 [[ function_constant(0) ]];
constant uint c2 [[ function_constant(1) ]];
constant uint c3 [[ function_constant(2) ]];
constant uint d1 = c1 + 1;
constant uint d2 = is_function_constant_defined(c3) ? c2 * c3 : c2;

constant bool c4 [[ function_constant(3) ]];
constant uint c5 [[ function_constant(4) ]];
constant uint c6 [[ function_constant(5) ]];
constant uint d3 = c4 ? c5 + 1 : c6 + 2;

struct pair { uint x; uint y; };
constant uint c7 [[ function_constant(6) ]];
constant pair d4 = {1, c7};
constant uint c8 [[ function_constant(7) ]];
constant uint c9 [[ function_constant(8) ]];
constant pair d5 = {c8, c9};

uint helper(uint x) { return x + c3; }

// c1
kernel void derived(device uint* a [[ buffer(0) ]]) { a[0] = d1; }
// c2, optional c3
kernel void checked(device uint* a [[ buffer(0) ]]) { a[0] = d2; }
// none
kernel void unrelated(device uint* a [[ buffer(0) ]]) { a[0] = 42; }
// c3 (required, as this use does not check it)
kernel void called(device uint* a [[ buffer(0) ]]) { a[0] = helper(a[1]); }
// c4, c5, c6 (without optimization, the initializer branches on c4)
kernel void selected(device uint* a [[ buffer(0) ]]) { a[0] = d3; }
// c7
kernel void field(device uint* a [[ buffer(0) ]]) { a[0] = d4.y; }
// c9 (the store to the first field is to the address of the struct)
kernel void second_field(device uint* a [[ buffer(0) ]]) { a[0] = d5.y; }
