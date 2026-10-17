//
// linked against dylib.metallib: generates an imported symbol list (ILST)

float offset(float x);

kernel void foo(device float *a [[buffer(0)]])
{
    a[0] = offset(a[0]);
}
