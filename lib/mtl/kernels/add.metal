#include <metal_stdlib>
using namespace metal;

/// This is a Metal Shading Language (MSL) function equivalent to the add_arrays() C function, used to perform the calculation on a GPU.
kernel void add_arrays(device float* inA,
                       device float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]])
{
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
    if (index < 128) {
        inA[index] = 10 * index;
        inB[index] = 100 * index;
        result[index] = 2.0 * index; //index;//inA[index] + inB[index];
    }
}
