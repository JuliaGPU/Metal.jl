#include <metal_stdlib>

template <typename T, uint N>
struct Array {
  uint size[N] [[]];
  device T* data [[buffer(N)]];
};

using namespace metal;
/// This is a Metal Shading Language (MSL) function equivalent to the add_arrays() C function, used to perform the calculation on a GPU.
kernel void add_vectors(device const Array<float,1> &arrA [[buffer(0)]],
                        device const Array<float,1> &arrB [[buffer(1)]],
                        device Array<float,1> &result [[buffer(2)]],
                       uint index [[thread_position_in_grid]])
{
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
    result.data[index] = arrA.data[index] + arrB.data[index];
}
