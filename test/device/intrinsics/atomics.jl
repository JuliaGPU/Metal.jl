n = 128 # NOTE: also hard-coded in MtlThreadGroupArray constructors

# the (MSL, AIR) versions of each supported macOS; code for an older target also runs on
# newer systems, so we can execute each of the lowerings GPUCompiler selects for them
const targets = ((v"3.2", v"2.7"), (v"4.0", v"2.8"), (v"4.1", v"2.9"))

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

                @testset "threadgroup $T" for T in types
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

        # every target supports ordered atomics: MSL 4.1 has them, and GPUCompiler brackets
        # relaxed ones with fences before that
        orders = (Metal.memory_order_relaxed, Metal.memory_order_seq_cst,
                  Metal.memory_order_acquire, Metal.memory_order_release,
                  Metal.memory_order_acq_rel)
        @testset "Metal $metal" for (metal, air) in targets
            Metal.metal_target() >= metal || continue
            for order in orders
                a = Metal.zeros(Int32, 1)
                @metal metal=metal air=air ordered_fetch_kernel(a, Val(order))
                @test Array(a) == Int32[1]
            end
        end

        # memory orders can also be passed as run-time values (loads and stores only get the
        # part of an order they can have, like with Clang)
        function dynamic_order_kernel(a, order)
            Metal.atomic_fetch_add_explicit(pointer(a, 1), Int32(1), order)
            x = Metal.atomic_load_explicit(pointer(a, 1), order)
            Metal.atomic_store_explicit(pointer(a, 2), x, order)
            Metal.atomic_compare_exchange_weak_explicit(pointer(a, 3), x - Int32(1), x, order,
                                                        order)
            return
        end
        a = Metal.zeros(Int32, 3)
        for order in orders
            @metal dynamic_order_kernel(a, order)
        end
        @test Array(a) == fill(Int32(length(orders)), 3)

        # explicit memory flags need the MSL 4.1 intrinsics
        function flagged_fetch_kernel(a, ::Val{ORDER}, ::Val{FLAGS}) where {ORDER,FLAGS}
            Metal.atomic_fetch_add_explicit(pointer(a, 1), Int32(1), ORDER, FLAGS)
            return
        end

        a = Metal.zeros(Int32, 1)
        if Metal.metal_target() >= v"4.1"
            @metal flagged_fetch_kernel(a, Val(Metal.memory_order_relaxed),
                                        Val(Metal.MemoryFlagDevice | Metal.MemoryFlagThreadGroup))
            @test Array(a) == Int32[1]
        end
        err = try
            @metal launch=false metal=v"4.0" air=v"2.8" flagged_fetch_kernel(
                a, Val(Metal.memory_order_relaxed), Val(Metal.MemoryFlagDevice))
            nothing
        catch err
            err
        end
        @test err isa Metal.InvalidIRError
        @test occursin("Ordered atomics and memory flags require Metal 4.1 or newer.",
                       sprint(showerror, err))

        # the flags reach the MSL 4.1 intrinsic (how GPUCompiler lowers LLVM atomics, and
        # legalizes these intrinsics for older targets, is tested there)
        function ordered_flags_abi(ptr::Core.LLVMPtr{Int32,Metal.AS.Device})
            Metal.atomic_fetch_add_explicit(ptr, Int32(1), Metal.memory_order_acq_rel,
                                            Metal.MemoryFlagDevice | Metal.MemoryFlagThreadGroup)
            return
        end
        ir = sprint(io -> Metal.code_air(io, ordered_flags_abi,
                                         Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}};
                                         kernel=true, metal=v"4.1", air=v"2.9"))
        @test occursin(r"call i32 @air\.atomic\.global\.add\.s\.i32\([^,]+, i32 1, i32 4, i32 2, i32 3, i1 false\)", ir)

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

        # threadgroup floating-point add needs MSL 4.1; before that it's a compare-exchange loop
        function threadgroup_float32_add(a)
            tg = MtlThreadGroupArray(Float32, 1)
            i = thread_position_in_threadgroup().x
            i == 1 && (tg[1] = 0f0)
            threadgroup_barrier(Metal.MemoryFlagThreadGroup)
            Metal.atomic_fetch_add_explicit(pointer(tg, 1), 1f0)
            threadgroup_barrier(Metal.MemoryFlagThreadGroup)
            i == 1 && (a[1] = tg[1])
            return
        end
        @testset "Metal $metal" for (metal, air) in targets
            Metal.metal_target() >= metal || continue
            a = Metal.zeros(Float32, 1)
            @metal threads=n metal=metal air=air threadgroup_float32_add(a)
            @test Array(a) == Float32[n]
        end

        function mixed_kernel(a, b)
            x = Metal.atomic_load_explicit(pointer(a, 1))
            y = Metal.atomic_load_explicit(pointer(a, 2), Metal.memory_order_acquire)
            b[1] = x + y
            return
        end
        a = MtlArray(Int32[1, 2])
        b = Metal.zeros(Int32, 1)
        @metal mixed_kernel(a, b)
        @test Array(b) == Int32[3]

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
        function modify_kernel(f, a, val)
            i = thread_position_in_grid().x
            f(pointer(a, i), val)
            return
        end
        modify_ops = ((Metal.atomic_max_explicit, UInt64(1)),
                      (Metal.atomic_min_explicit, UInt64(100)))

        # like other atomics, they can take memory flags (from MSL 4.1)
        function u64_flagged(a)
            Metal.atomic_max_explicit(pointer(a, 1), UInt64(1), Metal.memory_order_release,
                                      Metal.MemoryFlagDevice)
            return
        end
        a = Metal.zeros(UInt64, 1)
        ir = sprint(io -> Metal.code_air(io, u64_flagged, Tuple{typeof(Metal.mtlconvert(a))};
                                         kernel=true, gpufamily=MTL.MTLGPUFamilyApple8,
                                         metal=v"4.1", air=v"2.9"))
        @test occursin(r"call void @air\.atomic\.global\.max\.u\.i64\([^,]+, i64 1, i32 3, i32 2, i32 1, i1 false\)", ir)

        for (f, init) in modify_ops
            a = MtlArray(fill(init, n))
            if MTL.supports_family(device(), MTL.MTLGPUFamilyApple8)
                @metal threads=n modify_kernel(f, a, UInt64(42))
                @test all(isequal(UInt64(42)), Array(a))
            end

            # the intrinsic statically asserts the targeted family, which can be overridden
            err = try
                @metal launch=false gpufamily=MTL.MTLGPUFamilyApple7 modify_kernel(f, a, UInt64(42))
                nothing
            catch err
                err
            end
            @test err isa Metal.InvalidIRError
            @test occursin("64-bit atomic min/max requires Apple8 or newer.",
                           sprint(showerror, err))
        end

        # device code can guard on the family itself
        function guarded_max_kernel(a, val)
            i = thread_position_in_grid().x
            if Metal.apple_family() >= 8
                Metal.atomic_max_explicit(pointer(a, i), val)
            else
                a[i] = val
            end
            return
        end
        a = MtlArray(fill(UInt64(1), n))
        @metal threads=n guarded_max_kernel(a, UInt64(42))
        @test all(isequal(UInt64(42)), Array(a))
        b = MtlArray(fill(UInt64(1), n))
        @metal threads=n gpufamily=MTL.MTLGPUFamilyApple7 guarded_max_kernel(b, UInt64(42))
        @test all(isequal(UInt64(42)), Array(b))
    end
end

@testset "LLVM atomics" begin
    # atomics emitted as plain LLVM atomics (here through UnsafeAtomics, as Atomix and
    # KernelAbstractions do), which GPUCompiler lowers for the targeted Metal version:
    # with fences before MSL 4.1, compare-exchange loops for operations AIR lacks, and masked
    # operations on the containing word for 8- and 16-bit values.
    function contend(a)
        # sequentially consistent at system scope: what Atomix's generic path emits
        Metal.UnsafeAtomics.modify!(pointer(a, 1), +, one(eltype(a)))
        return
    end
    function contend_max(a)
        i = thread_position_in_grid().x
        Metal.UnsafeAtomics.modify!(pointer(a, 1), max, eltype(a)(i % 200))
        return
    end
    function contend_nand(a)
        Metal.UnsafeAtomics.modify!(pointer(a, 1), ⊼, eltype(a)(-1))   # flips all bits
        return
    end
    function contend_bytes(a)
        # neighbouring bytes of the same word
        i = thread_position_in_grid().x
        Metal.UnsafeAtomics.modify!(pointer(a, (i - 1) % 8 + 1), +, UInt8(1))
        return
    end
    function message_passing(data, flag, out)
        # the first lane of the second threadgroup publishes, the one of the first waits
        tg = threadgroup_position_in_grid().x
        thread_position_in_threadgroup().x == 1 || return
        if tg == 2
            data[1] = Int32(42)
            Metal.UnsafeAtomics.store!(pointer(flag, 1), Int32(1), Metal.UnsafeAtomics.release)
        else
            while Metal.UnsafeAtomics.load(pointer(flag, 1), Metal.UnsafeAtomics.acquire) == Int32(0)
            end
            out[1] = data[1]
        end
        return
    end

    m = 4096
    @testset "Metal $metal" for (metal, air) in targets
        Metal.metal_target() >= metal || continue
        for T in (Int8, UInt16, Int32, UInt32, Float16, Float32)
            a = Metal.zeros(T, 1)
            @metal threads=256 groups=m÷256 metal=metal air=air contend(a)
            @test Array(a)[1] == foldl((x, _) -> x + one(T), 1:m; init=zero(T))
        end
        for T in (Int32, Float32)
            a = Metal.zeros(T, 1)
            @metal threads=256 groups=m÷256 metal=metal air=air contend_max(a)
            @test Array(a)[1] == T(199)
        end
        a = MtlArray(Int16[0x0f0f])
        @metal threads=256 groups=m÷256 metal=metal air=air contend_nand(a)
        @test Array(a)[1] == Int16(0x0f0f)
        a = Metal.zeros(UInt8, 8)
        @metal threads=256 groups=m÷256 metal=metal air=air contend_bytes(a)
        @test Array(a) == fill(UInt8(m ÷ 8 % 256), 8)
        # a single byte of threadgroup memory (padded to a word, see `emit_threadgroup_memory`)
        function threadgroup_byte(a)
            tg = MtlThreadGroupArray(UInt8, 1)
            i = thread_position_in_threadgroup().x
            i == 1 && (tg[1] = 0x00)
            threadgroup_barrier(Metal.MemoryFlagThreadGroup)
            Metal.UnsafeAtomics.modify!(pointer(tg, 1), +, 0x01, Metal.UnsafeAtomics.monotonic)
            threadgroup_barrier(Metal.MemoryFlagThreadGroup)
            i == 1 && (a[1] = tg[1])
            return
        end
        a = Metal.zeros(UInt8, 1)
        @metal threads=200 metal=metal air=air threadgroup_byte(a)
        @test Array(a)[1] == 200
        for _ in 1:10
            data = Metal.zeros(Int32, 1)
            flag = Metal.zeros(Int32, 1)
            out = Metal.zeros(Int32, 1)
            @metal threads=32 groups=2 metal=metal air=air message_passing(data, flag, out)
            @test Array(out)[1] == 42
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

    @testset "max $T" for T in [Int32, UInt32, UInt64]
        function kernel(a)
            i = thread_position_in_grid().x
            Metal.@atomic a[1] = max(a[1], eltype(a)(i))
            return
        end

        a = Metal.zeros(T)
        if T !== UInt64 || MTL.supports_family(device(), MTL.MTLGPUFamilyApple8)
            @metal threads=n kernel(a)
            @test Array(a)[1] == n
        end

        if T === UInt64
            # the 64-bit operation should be native, not the compare-and-swap fallback
            ir = sprint(io -> Metal.code_air(
                io, kernel, Tuple{typeof(Metal.mtlconvert(a))};
                kernel=true, gpufamily=MTL.MTLGPUFamilyApple8))
            @test occursin("air.atomic.global.max.u.i64", ir)
        end
    end

    @testset "min $T" for T in [Int32, UInt32, UInt64]
        function kernel(a)
            i = thread_position_in_grid().x
            Metal.@atomic a[1] = min(a[1], eltype(a)(i))
            return
        end

        a = MtlArray(T[n+1])
        if T !== UInt64 || MTL.supports_family(device(), MTL.MTLGPUFamilyApple8)
            @metal threads=n kernel(a)
            @test Array(a)[1] == 1
        end

        if T === UInt64
            ir = sprint(io -> Metal.code_air(
                io, kernel, Tuple{typeof(Metal.mtlconvert(a))};
                kernel=true, gpufamily=MTL.MTLGPUFamilyApple8))
            @test occursin("air.atomic.global.min.u.i64", ir)
        end
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

    # the same without memory flags, i.e., with LLVM atomics, on every target
    function llvm_refit_kernel!(values, flags, child0, child1, parent, n_leaves::Int32)
        leaf = thread_position_in_grid().x
        if leaf <= n_leaves
            leaf_node = n_leaves - Int32(1) + leaf
            values[leaf_node] = UInt32(1)

            parent_node = parent[leaf_node]
            while parent_node != Int32(0)
                old = Metal.atomic_fetch_add_explicit(pointer(flags, parent_node), UInt32(1),
                                                      Metal.memory_order_acq_rel)
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
    @testset "Metal $metal" for (metal, air) in targets
        Metal.metal_target() >= metal || continue
        values .= 0
        flags .= 0
        @metal threads=256 groups=cld(n_leaves, 256) metal=metal air=air llvm_refit_kernel!(
            values, flags, mt_child0, mt_child1, mt_parent, Int32(n_leaves))
        @test Array(values)[1] == UInt32(n_leaves)
    end
end

# Relaxed loads of device memory can keep returning a cached value; like MSL, Metal.jl's are
# only guaranteed to observe stores from the same threadgroup, while acquire loads and LLVM's
# device-scope relaxed loads observe those of other threadgroups too. The waits are bounded,
# as a GPU hang can require a reboot.
@testset "waiting on another threadgroup" begin
    function wait_kernel(load, flag, dummy, out, cap)
        lane = thread_position_in_threadgroup().x
        lane == 1 || return
        if threadgroup_position_in_grid().x == 2
            # let the waiting threadgroup read (and cache) the flag first
            s = Int32(0)
            for _ in 1:2000
                s += Metal.atomic_load_explicit(pointer(dummy, 1), Metal.memory_order_acquire)
            end
            Metal.atomic_store_explicit(pointer(flag, 1), Int32(1) + s)
        else
            i = Int32(0)
            v = Int32(0)
            while v == Int32(0) && i < cap
                v = load(pointer(flag, 1))
                i += Int32(1)
            end
            @inbounds out[1] = i
            @inbounds out[2] = v
        end
        return
    end
    acquire(p) = Metal.atomic_load_explicit(p, Metal.memory_order_acquire)
    relaxed_device(p) = Metal.UnsafeAtomics.load(p, Metal.UnsafeAtomics.monotonic)

    cap = Int32(10_000_000)
    @testset "Metal $metal" for (metal, air) in targets
        Metal.metal_target() >= metal || continue
        @testset "$(nameof(load))" for load in (acquire, relaxed_device)
            flag = Metal.zeros(Int32, 1)
            dummy = Metal.zeros(Int32, 1)
            out = Metal.zeros(Int32, 2)
            @metal threads=32 groups=2 metal=metal air=air wait_kernel(load, flag, dummy, out, cap)
            i, v = Array(out)
            @test v == 1
            @test i < cap
        end
    end

    # Metal.jl's relaxed loads keep MSL's semantics, so they aren't made acquire loads
    function relaxed_wait(flag, out, cap)
        i = Int32(0)
        while Metal.atomic_load_explicit(pointer(flag, 1)) == Int32(0) && i < cap
            i += Int32(1)
        end
        @inbounds out[1] = i
        return
    end
    ir = sprint(io -> Metal.code_air(io, relaxed_wait,
                                     Tuple{MtlDeviceVector{Int32,1}, MtlDeviceVector{Int32,1},
                                           Int32}; kernel=true, metal=v"4.1", air=v"2.9"))
    @test occursin(r"call i32 @air\.atomic\.global\.load\.i32\([^,]+, i32 0, i32 2, i32 0, i1 true\)", ir)
    @test !occursin(r"call i32 @air\.atomic\.global\.load\.i32\([^,]+, i32 2,", ir)
end

# JuliaGPU/GPUCompiler.jl#934: an object with `@atomic` fields that doesn't escape is moved to
# the stack, keeping its compare-exchange loops, which Metal has no atomics for
mutable struct StackAtomics
    @atomic n::Int32
    @atomic x::Float32
end
function stack_atomics(x::Float32)
    acc = StackAtomics(0, 0f0)
    @atomic acc.n += Int32(1)
    @atomic acc.n += Int32(1)
    @atomic acc.x += x
    @atomic acc.x += 1f0
    return (@atomic acc.n), (@atomic acc.x)
end
@testset "atomics on thread-private objects" begin
    function kernel(out_n, out_x, xs)
        i = thread_position_in_grid().x
        @inbounds out_n[i], out_x[i] = stack_atomics(xs[i])
        return
    end
    xs = MtlArray(Float32.(1:64))
    @testset "Metal $metal" for (metal, air) in targets
        Metal.metal_target() >= metal || continue
        out_n = MtlArray(zeros(Int32, 64))
        out_x = MtlArray(zeros(Float32, 64))
        @metal threads=64 metal=metal air=air kernel(out_n, out_x, xs)
        @test all(==(2), Array(out_n))
        @test Array(out_x) == Array(xs) .+ 1f0
    end
end
