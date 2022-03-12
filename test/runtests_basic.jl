using Test
using Metal

@testset "MTL" begin
    @testset "devices" begin

    devs = devices()
    @test length(devs) > 0

    dev = first(devs)
    @test dev == devs[1]

        if length(devs) > 1
            @test dev != devs[2]
        end

    end

    @testset "buffers" begin

    dev = first(devices())
    buf = MtlBuffer{Int}(dev, 1)

    @test sizeof(buf) == 8
    @test length(buf) == 1
    @test buf.device == dev
    free(buf)

    mtl_arr = MtlArray{Int}(undef, 1)
    arr = Array(mtl_arr)

    @test sizeof(arr) == 8
    @test length(arr) == 1
    @test eltype(arr) == Int

    free(mtl_arr.buffer)
    end
end

@testset "Kernels" begin
    function tester(A)
        idx = thread_position_in_grid_1d()
        A[idx] = Int(5)
        return nothing
    end

    bufferSize = 8
    bufferA = MtlArray{Int,1}(undef, tuple(bufferSize), storage=Shared)
    vecA = unsafe_wrap(Vector{Int}, bufferA.buffer, tuple(bufferSize))

    @metal threads=(bufferSize) tester(bufferA.buffer)
    @test all(vecA .== Int(5))



    @testset "Launch params" begin
        vecA .= 0
        @metal threads=(2) tester(bufferA.buffer)
        @test all(vecA == Int.([5, 5, 0, 0, 0, 0, 0, 0]))
        vecA .= 0
        
        @metal grid=(3) threads=(2) tester(bufferA.buffer)
        @test all(vecA == Int.([5, 5, 5, 5, 5, 5, 0, 0]))
        vecA .= 0
    end

end
