n = 128 # NOTE: also hard-coded in MtlThreadGroupArray constructors

# JuliaGPU/Metal.jl#217: threadgroup atomics seem to requires all-atomic operations

@testset "low-level" begin
    # TODO: make these tests actually write to the overlapping memory locations

    atomic_store_load_exch_cmpexch_types = (Int32, UInt32, Float32)

    @testset "store_explicit" begin
        function global_kernel(a, val)
            i = thread_position_in_grid().x
            Metal.atomic_store_explicit(pointer(a, i), val)
            return
        end

        @testset "global $T" for T in atomic_store_load_exch_cmpexch_types
            a = Metal.zeros(T, n)
            @metal threads=n global_kernel(a, T(42))
            @test all(isequal(42), Array(a))
        end

        function local_kernel(a, val::T) where T
            i = thread_position_in_grid().x
            b = MtlThreadGroupArray(T, 128)
            Metal.atomic_store_explicit(pointer(b, i), val)
            a[i] = b[i]
            return
        end

        @testset "local $T" for T in atomic_store_load_exch_cmpexch_types
            a = Metal.zeros(T, n)
            @metal threads=n local_kernel(a, T(42))
            @test all(isequal(42), Array(a))
        end
    end

    @testset "load_explicit" begin
        function global_kernel(a, b)
            i = thread_position_in_grid().x
            val = Metal.atomic_load_explicit(pointer(a, i))
            b[i] = val
            return
        end

        @testset "global $T" for T in atomic_store_load_exch_cmpexch_types
            a = MtlArray(rand(T, n))
            b = Metal.zeros(T, n)
            @metal threads=n global_kernel(a, b)
            @test Array(a) == Array(b)
        end

        function local_kernel(a::AbstractArray{T}, b::AbstractArray{T}) where T
            i = thread_position_in_grid().x
            c = MtlThreadGroupArray(T, 128)
            #c[i] = a[i]
            val = Metal.atomic_load_explicit(pointer(a, i))
            Metal.atomic_store_explicit(pointer(c, i), val)
            val = Metal.atomic_load_explicit(pointer(c, i))
            #b[i] = val
            Metal.atomic_store_explicit(pointer(b, i), val)
            return
        end

        @testset "local $T" for T in atomic_store_load_exch_cmpexch_types
            a = MtlArray(rand(T, n))
            b = Metal.zeros(T, n)
            @metal threads=n local_kernel(a, b)
            @test Array(a) == Array(b)
        end
    end

    @testset "exchange_explicit" begin
        function global_kernel(a, val)
            i = thread_position_in_grid().x
            Metal.atomic_exchange_explicit(pointer(a, i), val)
            return
        end

        @testset "global $T" for T in atomic_store_load_exch_cmpexch_types
            a = MtlArray(rand(T, n))
            @metal threads=n global_kernel(a, T(42))
            @test all(isequal(42), Array(a))
        end

        function local_kernel(a, val::T) where T
            i = thread_position_in_grid().x
            b = MtlThreadGroupArray(T, 128)
            Metal.atomic_exchange_explicit(pointer(b, i), val)
            a[i] = b[i]
            return
        end

        @testset "local $T" for T in atomic_store_load_exch_cmpexch_types
            a = Metal.zeros(T, n)
            @metal threads=n local_kernel(a, T(42))
            @test all(isequal(42), Array(a))
        end
    end

    @testset "compare_exchange_weak_explicit" begin
        function global_kernel(a, expected, desired)
            i = thread_position_in_grid().x
            while Metal.atomic_compare_exchange_weak_explicit(pointer(a, i), expected[i], desired) != expected[i]
                # keep on trying
            end
            return
        end

        @testset "global $T" for T in atomic_store_load_exch_cmpexch_types
            a = MtlArray(rand(T, n))
            expected = copy(a)
            desired = T(42)
            @metal threads=length(a) global_kernel(a, expected, desired)
            @test all(isequal(42), Array(a))
        end

        function local_kernel(a, expected::AbstractArray{T}, desired::T) where T
            i = thread_position_in_grid().x
            b = MtlThreadGroupArray(T, 128)
            #b[i] = a[i]
            val = Metal.atomic_load_explicit(pointer(a, i))
            Metal.atomic_store_explicit(pointer(b, i), val)
            while Metal.atomic_compare_exchange_weak_explicit(pointer(b, i), expected[i], desired) != expected[i]
                # keep on trying
            end
            #a[i] = b[i]
            val = Metal.atomic_load_explicit(pointer(b, i))
            Metal.atomic_store_explicit(pointer(a, i), val)
            return
        end

        @testset "local $T" for T in atomic_store_load_exch_cmpexch_types
            a = Metal.zeros(T, n)
            expected = copy(a)
            desired = T(42)
            @metal threads=n local_kernel(a, expected, desired)
            @test all(isequal(42), Array(a))
        end
    end

    @testset "fetch and modify" begin
        add_sub_types = [Int32, UInt32, Float32]
        other_types = [Int32, UInt32]
        for (jlfun, mtlfun, types) in [(min, Metal.atomic_fetch_min_explicit, other_types),
                                        (max, Metal.atomic_fetch_max_explicit, other_types),
                                        (&,   Metal.atomic_fetch_and_explicit, other_types),
                                        (|,   Metal.atomic_fetch_or_explicit,  other_types),
                                        (⊻,   Metal.atomic_fetch_xor_explicit, other_types),
                                        (+,   Metal.atomic_fetch_add_explicit, add_sub_types),
                                        (-,   Metal.atomic_fetch_sub_explicit, add_sub_types)
                                    ]
            function global_kernel(f, a, arg)
                i = thread_position_in_grid().x
                f(pointer(a, i), arg)
                return
            end

            function local_kernel(f, a, arg::T) where T
                i = thread_position_in_grid().x
                b = MtlThreadGroupArray(T, 128)
                #b[i] = a[i]
                val = Metal.atomic_load_explicit(pointer(a, i))
                Metal.atomic_store_explicit(pointer(b, i), val)
                f(pointer(b, i), arg)
                #a[i] = b[i]
                val = Metal.atomic_load_explicit(pointer(b, i))
                Metal.atomic_store_explicit(pointer(a, i), val)
                return
            end

            @testset "fetch_$(jlfun)_explicit" begin
                @testset "device $T" for T in types
                    a = rand(T, n)
                    b = MtlArray(a)
                    val = rand(T)
                    @metal threads=n global_kernel(mtlfun, b, val)
                    @test jlfun.(a, val) ≈ Array(b)
                end

                threadgroup_types = Metal.metal_target() >= v"4.1" ? types : setdiff(types, [Float32])
                @testset "threadgroup $T" for T in threadgroup_types
                    a = rand(T, n)
                    b = MtlArray(a)
                    val = rand(T)
                    @metal threads=n local_kernel(mtlfun, b, val)
                    @test jlfun.(a, val) ≈ Array(b)
                end
            end
        end
    end

    @testset "generic fetch and modify" begin
        # custom operator that doesn't map onto an atomic intrinsic
        f(a::T, b::T) where {T} = a + b + one(T)

        function global_kernel(a, op, arg)
            i = thread_position_in_grid().x
            Metal.atomic_fetch_op_explicit(pointer(a, i), op, arg)
            return
        end

        @testset "global $T" for T in (Int32, UInt32, Float32)
            a = rand(T, n)
            b = MtlArray(a)
            val = rand(T)
            @metal threads=n global_kernel(b, f, val)
            @test f.(a, val) ≈ Array(b)
        end

        function local_kernel(a, op, arg::T) where T
            i = thread_position_in_grid().x
            b = MtlThreadGroupArray(T, 128)
            #b[i] = a[i]
            val = Metal.atomic_load_explicit(pointer(a, i))
            Metal.atomic_store_explicit(pointer(b, i), val)
            Metal.atomic_fetch_op_explicit(pointer(b, i), op, arg)
            #a[i] = b[i]
            val = Metal.atomic_load_explicit(pointer(b, i))
            Metal.atomic_store_explicit(pointer(a, i), val)
            return
        end

        @testset "local $T" for T in (Int32, UInt32)
            a = rand(T, n)
            b = MtlArray(a)
            val = rand(T)
            @metal threads=n local_kernel(b, f, val)
            @test f.(a, val) ≈ Array(b)
        end
    end

    @testset "explicit ordering arguments" begin
        function ordered_fetch_kernel(a, ::Val{ORDER}) where {ORDER}
            Metal.atomic_fetch_add_explicit(pointer(a, 1), Int32(1), ORDER)
            return
        end

        # The enum value is in the kernel signature, so the public enum overload
        # specializes it to a Val before lowering to AIR.
        for (order, minimum) in (
            (Metal.memory_order_relaxed, v"3.0"),
            (Metal.memory_order_seq_cst, v"4.1"),
            (Metal.memory_order_acquire, v"4.1"),
            (Metal.memory_order_release, v"4.1"),
            (Metal.memory_order_acq_rel, v"4.1"),
        )
            a = Metal.zeros(Int32, 1)
            if Metal.metal_target() >= minimum
                @metal ordered_fetch_kernel(a, Val(order))
                @test Array(a) == Int32[1]
            else
                err = try
                    @metal launch=false ordered_fetch_kernel(a, Val(order))
                    nothing
                catch err
                    err
                end
                @test err isa Metal.InvalidIRError
                @test occursin("Ordered atomics and memory flags require Metal 4.1 or newer.",
                               sprint(showerror, err))
            end
        end

        function flagged_fetch_kernel(a, ::Val{ORDER}, ::Val{FLAGS}) where {ORDER,FLAGS}
            Metal.atomic_fetch_add_explicit(pointer(a, 1), Int32(1), ORDER, FLAGS)
            return
        end

        a = Metal.zeros(Int32, 1)
        if Metal.metal_target() >= v"4.1"
            @metal flagged_fetch_kernel(a, Val(Metal.memory_order_relaxed),
                                        Val(Metal.MemoryFlagDevice | Metal.MemoryFlagThreadGroup))
            @test Array(a) == Int32[1]
        else
            err = try
                @metal launch=false flagged_fetch_kernel(
                    a, Val(Metal.memory_order_relaxed), Val(Metal.MemoryFlagDevice))
                nothing
            catch err
                err
            end
            @test err isa Metal.InvalidIRError
            @test occursin("Ordered atomics and memory flags require Metal 4.1 or newer.",
                           sprint(showerror, err))
        end

        function ordered_flags_abi(ptr::Core.LLVMPtr{Int32,Metal.AS.Device})
            Metal.atomic_fetch_add_explicit(ptr, Int32(1), Metal.memory_order_acq_rel,
                                            Metal.MemoryFlagDevice | Metal.MemoryFlagThreadGroup)
            return
        end
        function default_abi(ptr::Core.LLVMPtr{Int32,Metal.AS.Device})
            Metal.atomic_fetch_add_explicit(ptr, Int32(1))
            return
        end
        ordered_ir = sprint(io -> Metal.code_llvm(io, ordered_flags_abi,
                                                   Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}};
                                                   kernel=true, metal=v"4.1", air=v"2.9",
                                                   dump_module=true))
        relaxed_ir = sprint(io -> Metal.code_llvm(io, default_abi,
                                                   Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}};
                                                   kernel=true, metal=v"4.1", air=v"2.9",
                                                   dump_module=true))
        volatile_ir = sprint(io -> Metal.code_llvm(io, default_abi,
                                                    Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}};
                                                    kernel=true, metal=v"4.0", air=v"2.9",
                                                    dump_module=true))
        legacy_ir = sprint(io -> Metal.code_llvm(io, default_abi,
                                                  Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}};
                                                  kernel=true, metal=v"4.0", air=v"2.8",
                                                  dump_module=true))
        atomic_ptr = raw"(?:ptr addrspace\(1\)|i32 addrspace\(1\)\*)"
        ordered_abi_pattern = Regex(raw"@air\.atomic\.global\.add\.s\.i32\(" * atomic_ptr *
                                    raw", i32, i32, i32, i32, i1\)")
        legacy_abi_pattern = Regex(raw"@air\.atomic\.global\.add\.s\.i32\(" * atomic_ptr *
                                   raw", i32, i32, i32, i1\)")
        @test occursin(ordered_abi_pattern, ordered_ir)
        @test occursin("i32 4, i32 2, i32 3, i1 false", ordered_ir)
        @test occursin(ordered_abi_pattern, relaxed_ir)
        @test occursin("i32 0, i32 2, i32 0, i1 false", relaxed_ir)
        @test occursin(ordered_abi_pattern, volatile_ir)
        @test occursin("i32 0, i32 2, i32 0, i1 true", volatile_ir)
        @test occursin(legacy_abi_pattern, legacy_ir)
        @test occursin("i32 0, i32 2, i1 true", legacy_ir)

        function unavailable_order(a)
            Metal.atomic_fetch_add_explicit(pointer(a, 1), Int32(1),
                                            Metal.memory_order_acquire)
            return
        end
        function unavailable_flags(a)
            Metal.atomic_fetch_add_explicit(pointer(a, 1), Int32(1), Metal.memory_order_relaxed,
                                            Metal.MemoryFlagDevice)
            return
        end
        a = Metal.zeros(Int32, 1)
        for f in (unavailable_order, unavailable_flags)
            err = try
                @metal launch=false metal=v"4.0" f(a)
                nothing
            catch err
                err
            end
            @test err isa Metal.InvalidIRError
            @test occursin("Ordered atomics and memory flags require Metal 4.1 or newer.",
                           sprint(showerror, err))
        end

        function invalid_order(a)
            Metal.atomic_fetch_add_explicit(pointer(a, 1), Int32(1), Val(Int32(42)),
                                            Val(Metal.MemoryFlagNone))
            return
        end
        err = try
            @metal launch=false metal=v"4.1" air=v"2.9" invalid_order(a)
            nothing
        catch err
            err
        end
        @test err isa Metal.InvalidIRError
        @test occursin("Invalid atomic memory ordering.", sprint(showerror, err))

        function threadgroup_float32_add(a)
            Metal.atomic_fetch_add_explicit(pointer(MtlThreadGroupArray(Float32, 1), 1), 1f0)
            a[1] = 1
            return
        end
        err = try
            @metal launch=false metal=v"4.0" air=v"2.8" threadgroup_float32_add(a)
            nothing
        catch err
            err
        end
        @test err isa Metal.InvalidIRError
        @test occursin("Float32 threadgroup atomic operations require Metal 4.1 or newer.",
                       sprint(showerror, err))

        function mixed_abi(ptr::Core.LLVMPtr{Int32,Metal.AS.Device})
            Metal.atomic_load_explicit(ptr)
            Metal.atomic_load_explicit(ptr + 1, Metal.memory_order_acquire)
            return
        end
        mixed_ir = sprint(io -> Metal.code_llvm(
            io, mixed_abi, Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}};
            kernel=true, metal=v"4.1", air=v"2.9", dump_module=true))
        ordered_load_pattern = Regex(raw"@air\.atomic\.global\.load\.i32\(" * atomic_ptr *
                                     raw", i32, i32, i32, i1\)")
        legacy_load_pattern = Regex(raw"@air\.atomic\.global\.load\.i32\(" * atomic_ptr *
                                    raw", i32, i32, i1\)")
        @test occursin(ordered_load_pattern, mixed_ir)
        @test !occursin(legacy_load_pattern, mixed_ir)

        function mixed_kernel(a, b)
            x = Metal.atomic_load_explicit(pointer(a, 1))
            y = Metal.atomic_load_explicit(pointer(a, 2), Metal.memory_order_acquire)
            b[1] = x + y
            return
        end
        if Metal.metal_target() >= v"4.1"
            a = MtlArray(Int32[1, 2])
            b = Metal.zeros(Int32, 1)
            @metal mixed_kernel(a, b)
            @test Array(b) == Int32[3]
        end

        function guarded_ordered_fetch_kernel(a)
            if Metal.metal_version() >= sv"4.1"
                Metal.atomic_fetch_add_explicit(pointer(a, 1), Int32(1),
                                                Metal.memory_order_acq_rel,
                                                Metal.MemoryFlagDevice)
            end
            a[1] += 1
            return
        end
        a = Metal.zeros(Int32, 1)
        @metal guarded_ordered_fetch_kernel(a)
        @test Array(a) == Int32[Metal.metal_target() >= v"4.1" ? 2 : 1]
    end

    @testset "64-bit modify (min/max)" begin
        function max_kernel(a, val)
            i = thread_position_in_grid().x
            Metal.atomic_max_explicit(pointer(a, i), val)
            return
        end

        function min_kernel(a, val)
            i = thread_position_in_grid().x
            Metal.atomic_min_explicit(pointer(a, i), val)
            return
        end

        if MTL.supports_family(device(), MTL.MTLGPUFamilyApple8)
            a = MtlArray(fill(UInt64(1), n))
            @metal threads=n max_kernel(a, UInt64(42))
            @test all(isequal(UInt64(42)), Array(a))

            b = MtlArray(fill(UInt64(100), n))
            @metal threads=n min_kernel(b, UInt64(42))
            @test all(isequal(UInt64(42)), Array(b))
        else
            a = MtlArray(fill(UInt64(1), n))
            @test_throws "MTLGPUFamilyApple8" begin
                kernel = @metal launch=false max_kernel(a, UInt64(42))
                kernel(a, UInt64(42); threads=n)
            end
            @test_throws "MTLGPUFamilyApple8" begin
                kernel = @metal launch=false min_kernel(a, UInt64(42))
                kernel(a, UInt64(42); threads=n)
            end
        end
    end
end

@testset "high-level" begin
    # NOTE: this doesn't test threadgroup atomics, as those are assumed to have been
    #       covered by the low-level tests above, but only the atomic macro functionality.

    @testset "load $T" for T in [Int32, UInt32, Float32]
        function kernel(a, b)
            i = thread_position_in_grid().x
            a[i] = Metal.@atomic b[i]
            return
        end

        a = Metal.zeros(T, n)
        b = MtlArray(rand(T, n))
        @metal threads=n kernel(a, b)
        @test Array(a) == Array(b)
    end

    @testset "store $T" for T in [Int32, UInt32, Float32]
        function kernel(a, b)
            i = thread_position_in_grid().x
            val = b[i]
            Metal.@atomic a[i] = val
            return
        end

        a = Metal.zeros(T, n)
        b = MtlArray(rand(T, n))
        @metal threads=n kernel(a, b)
        @test Array(a) == Array(b)
    end

    @testset "add $T" for T in [Int32, UInt32, Float32]
        function kernel(a)
            Metal.@atomic a[1] = a[1] + 1
            Metal.@atomic a[1] += 1
            return
        end

        a = Metal.zeros(T)
        @metal threads=n kernel(a)
        @test Array(a)[1] == 2*n
    end

    @testset "sub $T" for T in [Int32, UInt32, Float32]
        function kernel(a)
            Metal.@atomic a[1] = a[1] - 1
            Metal.@atomic a[1] -= 1
            return
        end

        a = MtlArray(T[2n])
        @metal threads=n kernel(a)
        @test Array(a)[1] == 0
    end
end

@testset "device-memory publish through fetch_add" begin
    n_leaves = 2048
    n_nodes = 2n_leaves - 1

    child0 = zeros(Int32, n_nodes)
    child1 = zeros(Int32, n_nodes)
    parent = zeros(Int32, n_nodes)
    for node in 1:n_leaves-1
        left = 2node
        right = 2node + 1
        child0[node] = left
        child1[node] = right
        parent[left] = node
        parent[right] = node
    end

    function refit_kernel!(values, flags, child0, child1, parent, n_leaves::Int32)
        leaf = thread_position_in_grid().x
        if leaf <= n_leaves
            leaf_node = n_leaves - Int32(1) + leaf
            values[leaf_node] = UInt32(1)

            parent_node = parent[leaf_node]
            while parent_node != Int32(0)
                old = Metal.atomic_fetch_add_explicit(pointer(flags, parent_node), UInt32(1),
                                                      Metal.memory_order_acq_rel,
                                                      Metal.MemoryFlagDevice)
                if old + UInt32(1) == UInt32(2)
                    left = child0[parent_node]
                    right = child1[parent_node]
                    values[parent_node] = values[left] + values[right]
                    parent_node = parent[parent_node]
                else
                    break
                end
            end
        end
        return
    end

    values = Metal.zeros(UInt32, n_nodes)
    flags = Metal.zeros(UInt32, n_leaves - 1)
    mt_child0 = MtlArray(child0)
    mt_child1 = MtlArray(child1)
    mt_parent = MtlArray(parent)

    if Metal.metal_target() >= v"4.1"
        @metal threads=256 groups=cld(n_leaves, 256) refit_kernel!(
            values,
            flags,
            mt_child0,
            mt_child1,
            mt_parent,
            Int32(n_leaves),
        )
        @test Array(values)[1] == UInt32(n_leaves)
    else
        err = try
            @metal launch=false refit_kernel!(values, flags, mt_child0, mt_child1, mt_parent,
                                              Int32(n_leaves))
            nothing
        catch err
            err
        end
        @test err isa Metal.InvalidIRError
        @test occursin("Ordered atomics and memory flags require Metal 4.1 or newer.",
                       sprint(showerror, err))
    end
end
