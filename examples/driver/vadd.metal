#include <metal_stdlib>

using namespace metal;

kernel void add_vectors(device float *arrA,
                        device float *arrB,
                        device float *result,
                       uint index [[thread_position_in_grid]])
{
    result[index] = arrA[index] + arrB[index];
}