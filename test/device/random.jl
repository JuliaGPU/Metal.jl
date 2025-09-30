@testset "device-side rng" begin
    function rand_kernel!(a)
        i = thread_position_in_grid_1d()
        a[i] = rand(Float32)
        return
    end

    n = 128
    a = Metal.fill(-1f0, n)
    @metal threads=n rand_kernel!(a)
    @test all(0 .<= a .< 1)
    @test length(unique(Array(a))) == n

    b = Metal.fill(-1f0, n)
    @metal threads=n rand_kernel!(b)
    @test Array(a) != Array(b)
end
