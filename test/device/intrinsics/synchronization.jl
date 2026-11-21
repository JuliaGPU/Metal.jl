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


@testset "dynamic" begin

@testset "constructors" begin
    @on_device threadgroup_memory=16 MtlDynamicThreadGroupArray(Float32, 1)
    @on_device threadgroup_memory=16 MtlDynamicThreadGroupArray(Float32, (1,2))
    @on_device threadgroup_memory=32 MtlDynamicThreadGroupArray(Tuple{Float32, Float32}, (1,2), 16)
    @on_device threadgroup_memory=32 MtlDynamicThreadGroupArray(Tuple{RGB{Float32}, UInt32}, 1, 16)
    # empty arrays need no memory
    @on_device MtlDynamicThreadGroupArray(Float32, 0)
end

# reverse the values of every threadgroup through an array sized by the launch, with a
# second array behind it and static threadgroup memory next to it to catch aliasing
function dynamic_kernel(d::MtlDeviceArray{T}, len) where {T}
    t = thread_position_in_threadgroup().x
    n = threads_per_threadgroup().x
    i = thread_position_in_grid().x
    tr = n - t + 1

    s = MtlDynamicThreadGroupArray(T, n)
    s2 = MtlDynamicThreadGroupArray(T, n, n * sizeof(T))
    s3 = MtlThreadGroupArray(T, 64)

    s[t] = d[i]
    s2[t] = 2 * d[i]
    s3[t] = 3 * d[i]
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)
    d[i] = s[tr]
    len[i] = dynamic_threadgroup_memory_length()

    return
end

@testset "$typ" for typ in [Int32, Int64, Float32]
    @testset "$threads threads" for threads in (1, 7, 64)
        groups = 3
        a = rand(typ, threads * groups)
        d_a = MtlArray(a)
        len = Metal.zeros(Int, length(a))
        bytes = 2 * threads * sizeof(typ)

        @metal threads groups threadgroup_memory=bytes dynamic_kernel(d_a, len)
        @test Array(d_a) == vcat((reverse(a[(g*threads+1):((g+1)*threads)]) for g in 0:groups-1)...)
        # the kernel sees the size that was asked for, not the multiple of 16 bytes
        # that was allocated
        @test all(==(bytes), Array(len))
    end
end

@testset "launch" begin
    function length_kernel(len)
        len[1] = dynamic_threadgroup_memory_length()
        return
    end
    function first_kernel(len, n)
        t = thread_position_in_threadgroup().x
        s = MtlDynamicThreadGroupArray(Int32, n)
        if t <= n
            s[t] = 42
        end
        threadgroup_barrier(Metal.MemoryFlagThreadGroup)
        len[1] = dynamic_threadgroup_memory_length() + (n > 0 ? s[1] : Int32(0))
        return
    end

    len = Metal.zeros(Int, 1)

    # a kernel that only asks for the size has no memory to set the length of
    kernel = @metal launch=false length_kernel(len)
    @test !kernel.dynamic_tgmem
    @test kernel.tgmem == 0
    kernel(len)
    @test Array(len) == [0]
    kernel(len; threadgroup_memory=24)
    @test Array(len) == [24]

    # a kernel that uses the memory can be launched without asking for any: the length
    # still has to be set
    kernel = @metal launch=false first_kernel(len, 0)
    @test kernel.dynamic_tgmem
    kernel(len, 0)
    @test Array(len) == [0]
    kernel(len, 1; threadgroup_memory=5)
    @test Array(len) == [47]

    # the limit is the threadgroup memory of the device
    limit = Metal.max_dynamic_threadgroup_memory(kernel)
    @test limit == device().maxThreadgroupMemoryLength - kernel.tgmem
    kernel(len, 1; threadgroup_memory=limit)
    @test Array(len) == [limit + 42]
    @test_throws "threadgroupMemoryLength" kernel(len, 1; threadgroup_memory=limit + 1)
    @test_throws ArgumentError kernel(len, 1; threadgroup_memory=-1)

    # which static threadgroup memory counts towards
    function static_kernel(len)
        t = thread_position_in_threadgroup().x
        s = MtlThreadGroupArray(Int32, 100)
        d = MtlDynamicThreadGroupArray(Int32, 1)
        s[t] = 1
        d[t] = 2
        threadgroup_barrier(Metal.MemoryFlagThreadGroup)
        len[1] = dynamic_threadgroup_memory_length() + s[1] + d[1]
        return
    end
    kernel = @metal launch=false static_kernel(len)
    @test kernel.tgmem >= 400
    @test Metal.max_dynamic_threadgroup_memory(kernel) <= limit - 400
    @test Metal.max_dynamic_threadgroup_memory(kernel) % 16 == 0
    kernel(len; threadgroup_memory=Metal.max_dynamic_threadgroup_memory(kernel))
    @test Array(len) == [Metal.max_dynamic_threadgroup_memory(kernel) + 3]
    @test_throws "threadgroupMemoryLength" kernel(len; threadgroup_memory=limit)
end

@testset "bounds" begin
    function bounds_kernel(len, n)
        s = MtlDynamicThreadGroupArray(Int32, n)
        len[1] = length(s)
        return
    end

    len = Metal.zeros(Int, 1)
    @metal threadgroup_memory=16 bounds_kernel(len, 4)
    @test Array(len) == [4]

    # arrays have to fit in what the launch asked for
    exc = try
        @metal threadgroup_memory=15 bounds_kernel(len, 4)
        synchronize()
        nothing
    catch err
        err
    end
    @test exc isa Metal.KernelException
end

@testset "code generation" begin
    function codegen_kernel(a)
        s = MtlDynamicThreadGroupArray(Float32, 4)
        @inbounds s[1] = 1
        @inbounds a[1] = s[1]
        return
    end
    tt = Tuple{MtlDeviceVector{Float32,1}}

    # the memory is a kernel parameter in the threadgroup address space, described like
    # MSL's `threadgroup float4 *ptr [[threadgroup(0)]]`
    air = sprint(io->Metal.code_air(io, codegen_kernel, tt; kernel=true, dump_module=true))
    @test occursin(r"addrspace\(3\)\*? %dynamic_threadgroup_memory", air)
    @test occursin("!\"air.buffer\", !\"air.location_index\", i32 0, i32 1, " *
                   "!\"air.read_write\", !\"air.address_space\", i32 3, " *
                   "!\"air.arg_type_size\", i32 16, !\"air.arg_type_align_size\", i32 16, " *
                   "!\"air.arg_type_name\", !\"float4\", " *
                   "!\"air.arg_name\", !\"dynamic_threadgroup_memory\"", air)
    @test !occursin("julia.metal.dynamic_threadgroup_memory", air)

    # kernels that don't use it are unchanged
    function plain_kernel(a)
        @inbounds a[1] = 1
        return
    end
    air = sprint(io->Metal.code_air(io, plain_kernel, tt; kernel=true, dump_module=true))
    @test !occursin("dynamic_threadgroup_memory", air)
    @test !occursin("\"air.address_space\", i32 3", air)
end

end # dynamic

end # threadgroup memory

end # memory
