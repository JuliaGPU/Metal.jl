//
// generates a TYPE tag for a visible function

[[visible]] float twice(float x)
{
    return x * 2.0f;
}

kernel void foo(device float *a [[buffer(0)]], uint i [[thread_position_in_grid]])
{
    a[i] = a[i] + 1.0f;
}
