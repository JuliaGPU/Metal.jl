using Test
using Metal

function vadd(a, b, c)
    i0 = Tuple(thread_position_in_grid_3d())
    stride = Tuple(threads_per_grid_3d())
    is = i0
    while 1 <= is[1] <= size(a, 1) &&
          1 <= is[2] <= size(a, 2) &&
          1 <= is[3] <= size(a, 3)
        I = CartesianIndex(is)
        c[I] = a[I] + b[I]
        is = (is[1] + stride[1],
              is[2] + stride[2],
              is[3] + stride[3])
    end
    return
end

function main()
    dims = (3,4,5)
    a = round.(rand(Float32, dims) * 100)
    b = round.(rand(Float32, dims) * 100)
    c = similar(a)

    d_a = MtlArray(a)
    d_b = MtlArray(b)
    d_c = MtlArray(c)

    len = prod(dims)
    @metal threads=dims vadd(d_a, d_b, d_c)
    c = Array(d_c)
    @test a+b ≈ c
end
