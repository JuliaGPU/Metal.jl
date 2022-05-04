using Test
using Metal

function vadd(a, b, c)
    i = thread_position_in_grid_1d()
    c[i] = a[i] + b[i]
    return
end

dims = (3,4)
a = round.(rand(Float32, dims) * 100)
b = round.(rand(Float32, dims) * 100)
c = similar(a)

d_a = MtlArray(a)
d_b = MtlArray(b)
d_c = MtlArray(c)

len = prod(dims)
@metal threads=len vadd(d_a, d_b, d_c)
c = Array(d_c)
@test a+b ≈ c