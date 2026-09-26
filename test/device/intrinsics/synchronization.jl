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
        threads = sync_test.maxthreads
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
        threads = min(n, barrier_test.maxthreads)
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
    end

    # Core.Intrinsics.atomic_fence emits LLVM fences, which crash the macOS 27 back-end
    # unless GPUCompiler lowers them to air.atomic.fence (#968).
    @testset "LLVM fence" begin
        # message passing: thread 1 publishes data guarded by a flag, with release/acquire
        # fences; every observer that sees the flag must see the data
        # Julia 1.14 added a syncscope argument to the intrinsic (JuliaLang/julia#60311)
        @inline function llvm_fence(::Val{order}) where {order}
            @static if VERSION >= v"1.14.0-DEV.1371"
                Core.Intrinsics.atomic_fence(order, :system)
            else
                Core.Intrinsics.atomic_fence(order)
            end
        end
        function fence_kernel(data, flag, observed)
            i = thread_position_in_grid_1d()
            @inbounds if i == 1
                data[1] = Int32(42)
                llvm_fence(Val(:release))
                Metal.atomic_store_explicit(pointer(flag, 1), Int32(1))
            else
                f = Metal.atomic_load_explicit(pointer(flag, 1))
                llvm_fence(Val(:acquire))
                observed[i] = f == Int32(1) ? data[1] : Int32(-1)
            end
            return
        end

        data = Metal.zeros(Int32, 1)
        flag = Metal.zeros(Int32, 1)
        observed = Metal.zeros(Int32, 1024)
        compiled = @metal launch=false fence_kernel(data, flag, observed)
        threads = min(length(observed), compiled.maxthreads)
        compiled(data, flag, observed; threads)
        @test Array(data) == Int32[42]
        @test Array(flag) == Int32[1]
        @test all(x -> x == -1 || x == 42, Array(observed)[2:threads])

        ir = sprint(io -> Metal.code_native(io, fence_kernel,
                                            Tuple{MtlDeviceVector{Int32,1}, MtlDeviceVector{Int32,1}, MtlDeviceVector{Int32,1}};
                                            kernel=true, dump_module=true))
        metal = Metal.metal_target()
        if metal >= v"3.2"
            @test !occursin(r"^\s*fence "m, ir)
            release, acquire = metal >= v"4.1" ? (3, 2) : (5, 5)
            @test occursin("@air.atomic.fence(i32 3, i32 $release, i32 2)", ir)
            @test occursin("@air.atomic.fence(i32 3, i32 $acquire, i32 2)", ir)
        else
            @test occursin("fence release", ir)
            @test occursin("fence acquire", ir)
        end
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
    @on_device MtlDynamicThreadGroupArray(Float32, 1)
    @on_device MtlDynamicThreadGroupArray(Float32, (1,2))
    @on_device MtlDynamicThreadGroupArray(Tuple{Float32, Float32}, 1)
    @on_device MtlDynamicThreadGroupArray(Tuple{Float32, Float32}, (1,2))
    @on_device MtlDynamicThreadGroupArray(Tuple{RGB{Float32}, UInt32}, 1)
    @on_device MtlDynamicThreadGroupArray(Tuple{RGB{Float32}, UInt32}, (1,2))
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

# dynamic threadgroup memory requires macOS 15 or newer
if macos_version() >= v"15"
@testset "dynamic" begin

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
    # used to generate align=12, which is invalid (non pow2)
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

    @metal threads=n shmem=n*sizeof(Float32)+n*sizeof(Int64) kernel(d_a, d_b, n)
    @test reverse(a) == Array(d_a)
    @test reverse(b) == Array(d_b)
end

@testset "offsets" begin
    # all dynamic arrays alias the same allocation, so simultaneously-live arrays
    # must be partitioned manually with a byte offset (like CUDA's `extern __shared__`)
    function kernel(a, b, n)
        t = thread_position_in_threadgroup().x
        tr = n-t+1

        sa = MtlDynamicThreadGroupArray(eltype(a), n)
        sb = MtlDynamicThreadGroupArray(eltype(b), n, n*sizeof(eltype(a)))
        sa[t] = a[t]
        sb[t] = b[t]
        threadgroup_barrier()
        a[t] = sa[tr]
        b[t] = sb[tr]

        return
    end

    a = rand(Float32, n)
    d_a = MtlArray(a)

    b = rand(Int64, n)
    d_b = MtlArray(b)

    @metal threads=n shmem=n*sizeof(Float32)+n*sizeof(Int64) kernel(d_a, d_b, n)
    @test reverse(a) == Array(d_a)
    @test reverse(b) == Array(d_b)
end

@testset "validation" begin
    function kernel(d)
        s = MtlDynamicThreadGroupArray(Float32, 1024)
        s[1] = 1f0
        return
    end

    d_a = MtlArray(rand(Float32, 1))
    maxmem = Metal.max_threadgroup_memory(Metal.device())

    # requesting more than the device limit errors out
    @test_throws ArgumentError @metal shmem=maxmem+16 kernel(d_a)
    # ... also when combined with statically-used threadgroup memory
    function static_kernel(d, n)
        t = thread_position_in_threadgroup().x
        s = MtlThreadGroupArray(Float32, 1024)
        s[t] = d[t]
        threadgroup_barrier()
        d[t] = s[t]
        return
    end
    n_static = 256
    d_b = MtlArray(rand(Float32, n_static))
    compiled = @metal launch=false static_kernel(d_b, n_static)
    if get(ENV, "MTL_SHADER_VALIDATION", "0") != "0"
        # shader validation reserves additional threadgroup memory itself
        @test compiled.tgmem >= 1024*sizeof(Float32)
    else
        @test compiled.tgmem == 1024*sizeof(Float32)
    end
    @test_throws ArgumentError compiled(d_b, n_static; threads=n_static, shmem=maxmem)

    # invalid sizes error out
    @test_throws ArgumentError @metal shmem=-16 kernel(d_a)
    @test_throws TypeError @metal shmem=1.5 kernel(d_a)
    # `shmem` is the combined size of all dynamic allocations, so only an Integer
    @test_throws TypeError @metal shmem=(16, 16) kernel(d_a)
end

end # dynamic
end # if macos_version() >= v"15"
end # threadgroup memory

end # memory
