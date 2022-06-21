@testset "arguments" begin
    @on_device dispatch_quadgroups_per_threadgroup()
    @on_device dispatch_simdgroups_per_threadgroup()
    @on_device quadgroup_index_in_threadgroup()
    @on_device quadgroups_per_threadgroup()
    @on_device simdgroup_index_in_threadgroup()
    @on_device simdgroups_per_threadgroup()
    @on_device thread_index_in_quadgroup()
    @on_device thread_index_in_simdgroup()
    @on_device thread_index_in_threadgroup()
    @on_device thread_execution_width()
    @on_device threads_per_simdgroup()

    @on_device dispatch_threads_per_threadgroup_1d()
    @on_device dispatch_threads_per_threadgroup_2d()
    @on_device dispatch_threads_per_threadgroup_3d()

    @on_device grid_origin_1d()
    @on_device grid_origin_2d()
    @on_device grid_origin_3d()

    @on_device grid_size_1d()
    @on_device grid_size_2d()
    @on_device grid_size_3d()

    @on_device thread_position_in_grid_1d()
    @on_device thread_position_in_grid_2d()
    @on_device thread_position_in_grid_3d()

    @on_device thread_position_in_threadgroup_1d()
    @on_device thread_position_in_threadgroup_2d()
    @on_device thread_position_in_threadgroup_3d()

    @on_device threadgroup_position_in_grid_1d()
    @on_device threadgroup_position_in_grid_2d()
    @on_device threadgroup_position_in_grid_3d()

    @on_device threadgroups_per_grid_1d()
    @on_device threadgroups_per_grid_2d()
    @on_device threadgroups_per_grid_3d()

    @on_device threads_per_grid_1d()
    @on_device threads_per_grid_2d()
    @on_device threads_per_grid_3d()

    @on_device threads_per_threadgroup_1d()
    @on_device threads_per_threadgroup_2d()
    @on_device threads_per_threadgroup_3d()
end

############################################################################################

@testset "math" begin
    a = ones(Float32,1)
    a .* Float32(3.14)
    bufferA = MtlArray(a)
    vecA = unsafe_wrap(Vector{Float32}, pointer(bufferA), 1)

    function intr_test(arr)
        idx = thread_position_in_grid_1d()
        arr[idx] = cos(arr[idx])
        return nothing
    end
    @metal intr_test(bufferA)
    synchronize()
    @test vecA ≈ cos.(a)

    function intr_test2(arr)
        idx = thread_position_in_grid_1d()
        arr[idx] = Metal.rsqrt(arr[idx])
        return nothing
    end
    @metal intr_test2(bufferA)
end

############################################################################################

@testset "synchronization" begin
    function sync_test_kernel(buf)
        idx = thread_position_in_grid_1d()
        buf[idx] += UInt8(1)
        return nothing
    end
    buf = MtlArray{UInt8,1}(undef, tuple(1024); storage=Shared)
    vec = unsafe_wrap(Vector{UInt8}, pointer(buf), (1024))
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
    vec = unsafe_wrap(Vector{Int}, pointer(buf), (1024))
    @metal threads=1024 barrier_test_kernel(buf)
    synchronize()
    @test vec[1] == 992

    # TODO: simdgroup barrier test
end

############################################################################################

@testset "memory" begin

# a composite type to test for more complex element types
@eval struct RGB{T}
    r::T
    g::T
    b::T
end

@testset "threadgroup memory" begin

n = 256

@testset "constructors" begin
    # static
    @on_device MtlThreadGroupArray(Float32, 1)
    @on_device MtlThreadGroupArray(Float32, (1,2))
    @on_device MtlThreadGroupArray(Tuple{Float32, Float32}, 1)
    @on_device MtlThreadGroupArray(Tuple{Float32, Float32}, (1,2))
    @on_device MtlThreadGroupArray(Tuple{RGB{Float32}, UInt32}, 1)
    @on_device MtlThreadGroupArray(Tuple{RGB{Float32}, UInt32}, (1,2))
end


@testset "static" begin

@testset "statically typed" begin
    function kernel(d, n)
        t = thread_position_in_threadgroup_1d()
        tr = n-t+1

        s = MtlThreadGroupArray(Float32, 1024)
        s2 = MtlThreadGroupArray(Float32, 1024)  # catch aliasing

        s[t] = d[t]
        s2[t] = 2*d[t]
        threadgroup_barrier()
        d[t] = s[tr]

        return
    end

    a = rand(Float32, n)
    d_a = MtlArray(a)

    @metal threads=n kernel(d_a, n)
    @test reverse(a) == Array(d_a)
end

@testset "parametrically typed" begin
    typs = [Int32, Int64, Float32]
    @testset for typ in typs
        function kernel(d::MtlDeviceArray{T}, n) where {T}
            t = thread_position_in_threadgroup_1d()
            tr = n-t+1

            s = MtlThreadGroupArray(T, 1024)
            s2 = MtlThreadGroupArray(T, 1024)  # catch aliasing

            s[t] = d[t]
            s2[t] = d[t]
            threadgroup_barrier()
            d[t] = s[tr]

            return
        end

        a = rand(typ, n)
        d_a = MtlArray(a)

        @metal threads=n kernel(d_a, n)
        @test reverse(a) == Array(d_a)
    end
end

end

end

end
