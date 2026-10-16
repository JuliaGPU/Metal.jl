//
// linked with dependencies_helper.metal by the standalone `metallib` tool, which records the
// files each function depends on (DEPF)

float helper(float x);

kernel void foo(device float *a [[buffer(0)]])
{
    a[0] = helper(a[0]);
}

kernel void bar(device float *a [[buffer(0)]])
{
    a[0] = 1.0f;
}
