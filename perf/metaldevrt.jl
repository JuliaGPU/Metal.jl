module metaldevrt

using Metal, BenchmarkTools, Random

const threads = 256
#simple add matrix and vector kernel
function kernel_add_mat_vec(m, x1, x2, y)
    # one block per column
    offset = (threadgroup_position_in_grid_2d().x-1) * m
    @inbounds xtmp = x2[threadgroup_position_in_grid_2d().x]
    for i = thread_position_in_threadgroup_2d().x : threadgroups_per_grid_2d().x : m
        @inbounds y[offset + i] = x1[offset + i] + xtmp
    end
    return
end

function add!(y, x1, x2)
    m, n = size(x1)
    @metal groups = n, 1 threads = threads kernel_add_mat_vec(m, x1, x2, y)
end

function main()
    Random.seed!(1)
    m, n = 3072, 1536    # 256 multiplier
    x1 = mtl(randn(Float32, (m, n)) .+ Float32(0.5))
    x2 = mtl(randn(Float32, (1, n)) .+ Float32(0.5))
    y1 = similar(x1)

    results = @benchmark Metal.@sync add!($y1, $x1, $x2)

    # BenchmarkTools captures inputs, JuliaCI/BenchmarkTools.jl#127, so forcibly free them
    Metal.unsafe_free!(x1)
    Metal.unsafe_free!(x2)
    Metal.unsafe_free!(y1)

    return results
end

end

metaldevrt.main()

