#include <metal_stdlib>

template <typename N>
struct Array {
  uint32 size[N];
  buffer data;
}


kernel void((reqd_work_group_size(BLOCK_SIZE, BLOCK_SIZE, 1)))
void transpose(__global float *a_t,
               __global float *a,
               unsigned a_width,
               unsigned a_height,
               __local float *a_local)
{
  int base_idx_a = get_group_id(0) * BLOCK_SIZE +
    get_group_id(1) * (BLOCK_SIZE * a_width);
  int base_idx_a_t = get_group_id(1) * BLOCK_SIZE +
    get_group_id(0) * (BLOCK_SIZE * a_height);

  int glob_idx_a   = base_idx_a + get_local_id(0) + a_width * get_local_id(1);
  int glob_idx_a_t = base_idx_a_t + get_local_id(0) + a_height * get_local_id(1);

  a_local[get_local_id(1) * BLOCK_SIZE + get_local_id(0)] = a[glob_idx_a];

  barrier(CLK_LOCAL_MEM_FENCE);

  a_t[glob_idx_a_t] = a_local[get_local_id(0) * BLOCK_SIZE + get_local_id(1)];
}
