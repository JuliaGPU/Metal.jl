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

    # TODO: Actually test for races
    @testset "atomic thread fence" begin
        function fence_kernel(buf, ::Val{ORDER}, ::Val{FLAGS}, ::Val{SCOPE}) where {ORDER,FLAGS,SCOPE}
            Metal.atomic_thread_fence(FLAGS, ORDER, SCOPE)
            buf[1] += 1
            return
        end

        orders = [Metal.memory_order_relaxed, Metal.memory_order_seq_cst]
        macos_version() >= v"27" && append!(orders, [Metal.memory_order_acquire, Metal.memory_order_release, Metal.memory_order_acq_rel])
        for order in orders
            buf = Metal.zeros(Int32, 1)
            @metal fence_kernel(buf, Val(order),
                                Val(Metal.MemoryFlagDevice | Metal.MemoryFlagTexture),
                                Val(Metal.thread_scope_simdgroup))
            @test Array(buf) == Int32[1]
        end

        function fence_abi(::Core.LLVMPtr{Int32,Metal.AS.Device})
            Metal.atomic_thread_fence(Metal.MemoryFlagDevice | Metal.MemoryFlagTexture,
                                        Metal.memory_order_seq_cst,
                                        Metal.thread_scope_simdgroup)
            return
        end
        ir = sprint(io -> Metal.code_llvm(io, fence_abi,
                                            Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}};
                                            kernel=true, metal=v"3.2", dump_module=true))
        @test occursin("@air.atomic.fence(i32, i32, i32)", ir)
        @test occursin("i32 5, i32 5, i32 4", ir)

        function unavailable_fence(buf)
            Metal.atomic_thread_fence(Metal.MemoryFlagDevice, Metal.memory_order_relaxed)
            return
        end
        err = try
            @metal launch=false metal=v"3.1" unavailable_fence(Metal.zeros(Int32, 1))
            nothing
        catch err
            err
        end
        @test err isa Metal.InvalidIRError
        @test occursin("atomic_thread_fence requires Metal 3.2 or newer.",
                        sprint(showerror, err))
    end

    # TODO: simdgroup barrier test

    @testset "atomic thread fence" begin
        function fence_kernel(buf, ::Val{ORDER}, ::Val{FLAGS}, ::Val{SCOPE}) where {ORDER,FLAGS,SCOPE}
            Metal.atomic_thread_fence(FLAGS, ORDER, SCOPE)
            buf[1] += 1
            return
        end

        for order in (Metal.memory_order_relaxed, Metal.memory_order_seq_cst)
            buf = Metal.zeros(Int32, 1)
            @metal fence_kernel(buf, Val(order),
                                Val(Metal.MemoryFlagDevice | Metal.MemoryFlagTexture),
                                Val(Metal.thread_scope_simdgroup))
            @test Array(buf) == Int32[1]
        end

        function fence_abi(::Core.LLVMPtr{Int32,Metal.AS.Device})
            Metal.atomic_thread_fence(Metal.MemoryFlagDevice | Metal.MemoryFlagTexture,
                                      Metal.memory_order_seq_cst,
                                      Metal.thread_scope_simdgroup)
            return
        end
        ir = sprint(io -> Metal.code_llvm(io, fence_abi,
                                           Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}};
                                           kernel=true, metal=v"3.2", dump_module=true))
        @test occursin("@air.atomic.fence(i32, i32, i32)", ir)
        @test occursin("i32 5, i32 5, i32 4", ir)

        function unavailable_fence(buf)
            Metal.atomic_thread_fence(Metal.MemoryFlagDevice, Metal.memory_order_relaxed)
            return
        end
        err = try
            @metal launch=false metal=v"3.1" unavailable_fence(Metal.zeros(Int32, 1))
            nothing
        catch err
            err
        end
        @test err isa Metal.InvalidIRError
        @test occursin("atomic_thread_fence requires Metal 3.2 or newer.",
                       sprint(showerror, err))
    end
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

end # threadgroup memory

end # memory
