@testset "intrinsics" begin

@testset "math" begin
    a = ones(Float32,1)
    a .* Float32(3.14)
    bufferA = MtlArray(a)
    vecA = unsafe_wrap(Vector{Float32}, bufferA.buffer, 1)

    function intr_test(buf)
        idx = thread_position_in_grid_1d()
        buf[idx] = cos(buf[idx])
        return nothing
    end
    @metal intr_test(bufferA.buffer)
    synchronize()
    @test vecA ≈ cos.(a)

    function intr_test2(buf)
        idx = thread_position_in_grid_1d()
        buf[idx] = Metal.rsqrt(buf[idx])
        return nothing
    end
    @metal intr_test2(bufferA.buffer)
end

@testset "sync" begin
    function sync_test_kernel(buf)
        idx = thread_position_in_grid_1d()
        buf[idx] += UInt8(1)
        return nothing
    end
    buf = MtlArray{UInt8,1}(undef, tuple(1024); storage=Shared)
    vec = unsafe_wrap(Vector{UInt8}, buf.buffer, (1024))
    @metal threads=1024 sync_test_kernel(buf)
    synchronize()
    @test all(vec .== UInt8(1))

    function barrier_test_kernel(buf)
        idx = thread_position_in_grid_1d()
        if thread_position_in_threadgroup_1d() != UInt32(1)
            for i in range(1,threads_per_threadgroup_1d())
                buf[idx] += UInt32(i)
            end
            buf[idx] = 1
        end

        threadgroup_barrier()

        if thread_position_in_threadgroup_1d() == UInt32(1)
            for i in range(1,threads_per_threadgroup_1d())
                buf[idx] += buf[idx+i-1]
            end
        end
        return nothing
    end

    buf = MtlArray{Int,1}(undef, tuple(1024); storage=Shared)
    vec = unsafe_wrap(Vector{Int}, buf.buffer, (1024))
    @metal threads=1024 barrier_test_kernel(buf)
    synchronize()
    @test vec[1] == 992

    # TODO: simdgroup barrier test
end

end
