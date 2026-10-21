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

    @testset "barrier order and scope" begin
        # (a smoke test: weaker orders and narrower scopes don't make writes visible to the
        # whole threadgroup, so every thread only accesses its own element)
        function barrier_kernel(buf, ::Val{ORDER}, ::Val{SCOPE}) where {ORDER,SCOPE}
            i = thread_position_in_threadgroup().x
            @inbounds buf[i] = i
            threadgroup_barrier(Metal.MemoryFlagDevice, ORDER, SCOPE)
            simdgroup_barrier(Metal.MemoryFlagDevice, ORDER, SCOPE)
            @inbounds buf[i] += 1
            return
        end
        @testset "$order, $scope" for order in instances(Metal.memory_order),
                                      scope in instances(Metal.thread_scope)
            buf = Metal.zeros(Int32, 64)
            @metal threads=64 barrier_kernel(buf, Val(order), Val(scope))
            @test Array(buf) == 2:65
        end

        function barrier_abi(::Core.LLVMPtr{Int32,Metal.AS.Device})
            threadgroup_barrier(Metal.MemoryFlagDevice, Metal.memory_order_release,
                                Metal.thread_scope_device)
            simdgroup_barrier(Metal.MemoryFlagThreadGroup, Metal.thread_scope_simdgroup)
            simdgroup_barrier(Metal.MemoryFlagDevice, Metal.memory_order_acquire,
                              Metal.thread_scope_device)
            threadgroup_barrier()
            simdgroup_barrier(Metal.MemoryFlagThreadGroup)
            return
        end
        # the AIR 2.9 form, with an order, legalized for the target
        @testset "Metal $metal, AIR $air" for (metal, air) in ((v"3.2", v"2.7"),
                                                              (v"4.0", v"2.9"),
                                                              (v"4.1", v"2.9"))
            ir = sprint(io -> Metal.code_air(io, barrier_abi,
                                             Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}};
                                             kernel=true, metal, air))
            # (before MSL 4.1, barriers are sequentially consistent)
            release, acquire = metal >= v"4.1" ? (3, 2) : (5, 5)
            if air >= v"2.9"
                @test occursin("@air.wg.barrier(i32 1, i32 $release, i32 2)", ir)
                @test occursin("@air.simdgroup.barrier(i32 1, i32 $acquire, i32 2)", ir)
                @test occursin("@air.simdgroup.barrier(i32 2, i32 5, i32 4)", ir)
                @test occursin("@air.wg.barrier(i32 0, i32 5, i32 1)", ir)
                # (like in MSL, simdgroup_barrier defaults to the SIMD-group scope)
                @test count("@air.simdgroup.barrier(i32 2, i32 5, i32 4)", ir) == 2
            else
                @test occursin("@air.wg.barrier(i32 1, i32 2)", ir)
                @test occursin("@air.simdgroup.barrier(i32 1, i32 2)", ir)
                @test occursin("@air.simdgroup.barrier(i32 2, i32 4)", ir)
                @test occursin("@air.wg.barrier(i32 0, i32 1)", ir)
                @test count("@air.simdgroup.barrier(i32 2, i32 4)", ir) == 2
            end
        end

        # MSL has no barrier scopes before 3.2
        function scoped_barrier(a)
            threadgroup_barrier(Metal.MemoryFlagDevice, Metal.thread_scope_device)
            return
        end
        a = Metal.zeros(Int32, 1)
        err = try
            @metal launch=false metal=v"3.1" air=v"2.7" scoped_barrier(a)
            nothing
        catch err
            err
        end
        @test err isa Metal.InvalidIRError
        @test occursin("Barrier scopes need Metal 3.2.", sprint(showerror, err))

        # before MSL 3.2, simdgroup_barrier has the threadgroup scope by default
        function default_barrier(::Core.LLVMPtr{Int32,Metal.AS.Device})
            simdgroup_barrier(Metal.MemoryFlagThreadGroup)
            return
        end
        ir = sprint(io -> Metal.code_air(io, default_barrier,
                                         Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}};
                                         kernel=true, metal=v"3.1", air=v"2.7"))
        @test occursin("@air.simdgroup.barrier(i32 2, i32 1)", ir)
    end

    # TODO: Actually test for races
    @testset "atomic thread fence" begin
        function fence_kernel(buf, ::Val{ORDER}, ::Val{FLAGS}, ::Val{SCOPE}) where {ORDER,FLAGS,SCOPE}
            Metal.atomic_thread_fence(FLAGS, ORDER, SCOPE)
            buf[1] += 1
            return
        end

        orders = [Metal.memory_order_relaxed, Metal.memory_order_seq_cst]
        # (before MSL 4.1, GPUCompiler makes these sequentially consistent)
        Metal.metal_target() >= v"3.2" && append!(orders, [Metal.memory_order_acquire, Metal.memory_order_release, Metal.memory_order_acq_rel])
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
        # an LLVM fence, with the flags in its scope
        ir = sprint(io -> Metal.code_llvm(io, fence_abi,
                                            Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}};
                                            kernel=true, metal=v"3.2"))
        @test occursin("fence syncscope(\"subgroup-mem-global+image\") seq_cst", ir)
        ir = sprint(io -> Metal.code_air(io, fence_abi,
                                           Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}};
                                           kernel=true, metal=v"3.2", air=v"2.7"))
        @test occursin("@air.atomic.fence(i32 5, i32 5, i32 4)", ir)
    end

    # Core.Intrinsics.atomic_fence emits LLVM fences, which crash the macOS 27 back-end
    # unless GPUCompiler lowers them to air.atomic.fence (#968).
    @testset "LLVM fence" begin
        # message passing: thread 1 publishes data guarded by a flag, with release/acquire
        # fences; every observer that sees the flag must see the data
        # UnsafeAtomics emits a bare LLVM fence through Julia's `atomic_fence` intrinsic, or
        # through `llvmcall` where inference deletes that intrinsic (Julia < 1.12, before
        # JuliaLang/julia#57806)
        @inline llvm_fence(::Val{order}) where {order} =
            Metal.UnsafeAtomics.fence(getfield(Metal.UnsafeAtomics, order))
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
