//
// a dynamic library (dynamic header, exported symbols), imported by imports.metal

[[visible]] float scale(float x)
{
    return x * 3.0f;
}

float offset(float x)
{
    return x + 1.0f;
}
