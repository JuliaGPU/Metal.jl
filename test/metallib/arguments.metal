//
// generates reflection data for the arguments of compute kernels: buffers in device,
// constant and threadgroup memory, nested structs, built-ins and unused arguments, as well
// as a maximum threadgroup size, static threadgroup memory and a visible function reference
#include <metal_stdlib>
using namespace metal;

struct Inner { float scale; uint offset; };
struct Params { Inner inner; float2 shift; float weights[3]; };

[[visible]] float twice(float x)
{
    return 2.0f * x;
}

[[max_total_threads_per_threadgroup(256)]]
kernel void arguments(device float *a [[buffer(0)]],
                      const device float *b [[buffer(1)]],
                      constant uint &n [[buffer(2)]],
                      constant Params &p [[buffer(3)]],
                      device float *unused [[buffer(4)]],
                      threadgroup float *scratch [[threadgroup(0)]],
                      uint i [[thread_position_in_grid]],
                      uint tid [[thread_position_in_threadgroup]],
                      uint lane [[thread_index_in_simdgroup]],
                      uint group [[threadgroup_position_in_grid]])
{
    threadgroup float local[64];
    local[tid % 64] = b[i];
    threadgroup_barrier(mem_flags::mem_threadgroup);
    scratch[tid] = local[(tid + 1) % 64];
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if (i < n)
        a[i] = twice(scratch[tid]) * p.inner.scale + p.shift.x + p.weights[lane % 3] + group;
}
