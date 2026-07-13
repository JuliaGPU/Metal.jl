@testset "synchronization" begin
    # host/device synchronization
    let
        function sync_test_kernel(buf)
            idx = thread_position_in_grid().x
            if idx <= length(buf)
                @inbounds buf[idx] += 1
            end
            return nothing
        end
        buf = Metal.zeros(Int, 1024; storage=Metal.SharedStorage)
        vec = unsafe_wrap(Vector{Int}, pointer(buf), size(buf))

        sync_test = @metal launch=false sync_test_kernel(buf)
        threads = sync_test.pipeline.maxTotalThreadsPerThreadgroup
        groups = cld(length(buf), threads)

        sync_test(buf; threads, groups)
        synchronize()
        @test all(vec .== 1)
    end

    # thread synchronization
    let
        function barrier_test_kernel(buf)
            idx = thread_position_in_grid().x
            if thread_position_in_threadgroup().x != 1 && idx <= length(buf)
                @inbounds buf[idx] = 1
            end

            threadgroup_barrier(Metal.MemoryFlagThreadGroup)

            if thread_position_in_threadgroup().x == 1 && idx <= length(buf)
                for i in 2:threads_per_threadgroup().x
                    @inbounds buf[idx] += buf[i]
                end
            end
            return nothing
        end

        n = 1000
        buf = Metal.zeros(Int, n)

        barrier_test = @metal launch=false barrier_test_kernel(buf)
        threads = min(n, barrier_test.pipeline.maxTotalThreadsPerThreadgroup)
        groups = cld(length(buf), threads)

        barrier_test(buf; threads, groups)

        @test Array(buf)[1] == threads - 1
    end

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

    # dynamic
    @on_device shmem=sizeof(Float32) MtlDynamicThreadGroupArray(Float32, 1)
    @on_device shmem=sizeof(Float32)*2 MtlDynamicThreadGroupArray(Float32, (1, 2))
    @on_device shmem=sizeof(Tuple{Float32, Float32}) MtlDynamicThreadGroupArray(Tuple{Float32, Float32}, 1)
    @on_device shmem=sizeof(Tuple{Float32, Float32})*2 MtlDynamicThreadGroupArray(Tuple{Float32, Float32}, (1,2))
    @on_device shmem=sizeof(Tuple{RGB{Float32}, UInt32}) MtlDynamicThreadGroupArray(Tuple{RGB{Float32}, UInt32}, 1)
    @on_device shmem=sizeof(Tuple{RGB{Float32}, UInt32})*2 MtlDynamicThreadGroupArray(Tuple{RGB{Float32}, UInt32}, (1,2))
end


@testset "static" begin

@testset "statically typed" begin
    function kernel(d, n)
        t = thread_position_in_threadgroup().x
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
            t = thread_position_in_threadgroup().x
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

end # static

@testset "dynamic shmem" begin

@testset "statically typed" begin
    function kernel(d, n)
        t = thread_position_in_threadgroup().x
        tr = n-t+1

        s = MtlDynamicThreadGroupArray(Float32, n)
        s[t] = d[t]
        threadgroup_barrier()
        d[t] = s[tr]

        return
    end

    a = rand(Float32, n)
    d_a = MtlArray(a)

    @metal threads=n shmem=n*sizeof(Float32) kernel(d_a, n)
    @test reverse(a) == Array(d_a)
end

@testset "parametrically typed" begin
    @testset for T in [Int32, Int64, Float16, Float32]
        function kernel(d::MtlDeviceArray{T}, n) where {T}
            t = thread_position_in_threadgroup().x
            tr = n-t+1

            s = MtlDynamicThreadGroupArray(T, n)
            s[t] = d[t]
            threadgroup_barrier()
            d[t] = s[tr]

            return
        end

        a = rand(T, n)
        d_a = MtlArray(a)

        @metal threads=n shmem=n*sizeof(T) kernel(d_a, n)
        @test reverse(a) == Array(d_a)
    end
end

@testset "alignment" begin
    # bug: used to generate align=12, which is invalid (non pow2)
    function kernel(v0::T, n) where {T}
        shared = MtlDynamicThreadGroupArray(T, n)
        @inbounds shared[UInt32(1)] = v0
        return
    end

    n = 32
    typ = typeof((0f0, 0f0, 0f0))
    @metal shmem=n*sizeof(typ) kernel((0f0, 0f0, 0f0), n)
end

@testset "multiple arrays" begin
    function kernel(a, b, n)
        t = thread_position_in_threadgroup().x
        tr = n-t+1

        sa = MtlDynamicThreadGroupArray(eltype(a), n)
        sa[t] = a[t]
        threadgroup_barrier()
        a[t] = sa[tr]

        sb = MtlDynamicThreadGroupArray(eltype(b), n)
        sb[t] = b[t]
        threadgroup_barrier()
        b[t] = sb[tr]

        return
    end

    a = rand(Float32, n)
    d_a = MtlArray(a)

    b = rand(Int64, n)
    d_b = MtlArray(b)

    @metal threads=n shmem=(n*sizeof(Float32), n*sizeof(Int64)) kernel(d_a, d_b, n)
    @test reverse(a) == Array(d_a)
    @test reverse(b) == Array(d_b)
end


end # dynamic

end # threadgroup memory

end # memory
