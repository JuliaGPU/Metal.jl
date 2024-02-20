using SpecialFunctions

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

    global const CPU_ONLY_ERR = "This function is not intended for use on the CPU"

    @test_throws CPU_ONLY_ERR dispatch_quadgroups_per_threadgroup()
    @test_throws CPU_ONLY_ERR dispatch_simdgroups_per_threadgroup()
    @test_throws CPU_ONLY_ERR quadgroup_index_in_threadgroup()
    @test_throws CPU_ONLY_ERR quadgroups_per_threadgroup()
    @test_throws CPU_ONLY_ERR simdgroup_index_in_threadgroup()
    @test_throws CPU_ONLY_ERR simdgroups_per_threadgroup()
    @test_throws CPU_ONLY_ERR thread_index_in_quadgroup()
    @test_throws CPU_ONLY_ERR thread_index_in_simdgroup()
    @test_throws CPU_ONLY_ERR thread_index_in_threadgroup()
    @test_throws CPU_ONLY_ERR thread_execution_width()
    @test_throws CPU_ONLY_ERR threads_per_simdgroup()

    @test_throws CPU_ONLY_ERR dispatch_threads_per_threadgroup_1d()
    @test_throws CPU_ONLY_ERR dispatch_threads_per_threadgroup_2d()
    @test_throws CPU_ONLY_ERR dispatch_threads_per_threadgroup_3d()

    @test_throws CPU_ONLY_ERR grid_origin_1d()
    @test_throws CPU_ONLY_ERR grid_origin_2d()
    @test_throws CPU_ONLY_ERR grid_origin_3d()

    @test_throws CPU_ONLY_ERR grid_size_1d()
    @test_throws CPU_ONLY_ERR grid_size_2d()
    @test_throws CPU_ONLY_ERR grid_size_3d()

    @test_throws CPU_ONLY_ERR thread_position_in_grid_1d()
    @test_throws CPU_ONLY_ERR thread_position_in_grid_2d()
    @test_throws CPU_ONLY_ERR thread_position_in_grid_3d()

    @test_throws CPU_ONLY_ERR thread_position_in_threadgroup_1d()
    @test_throws CPU_ONLY_ERR thread_position_in_threadgroup_2d()
    @test_throws CPU_ONLY_ERR thread_position_in_threadgroup_3d()

    @test_throws CPU_ONLY_ERR threadgroup_position_in_grid_1d()
    @test_throws CPU_ONLY_ERR threadgroup_position_in_grid_2d()
    @test_throws CPU_ONLY_ERR threadgroup_position_in_grid_3d()

    @test_throws CPU_ONLY_ERR threadgroups_per_grid_1d()
    @test_throws CPU_ONLY_ERR threadgroups_per_grid_2d()
    @test_throws CPU_ONLY_ERR threadgroups_per_grid_3d()

    @test_throws CPU_ONLY_ERR threads_per_grid_1d()
    @test_throws CPU_ONLY_ERR threads_per_grid_2d()
    @test_throws CPU_ONLY_ERR threads_per_grid_3d()

    @test_throws CPU_ONLY_ERR threads_per_threadgroup_1d()
    @test_throws CPU_ONLY_ERR threads_per_threadgroup_2d()
    @test_throws CPU_ONLY_ERR threads_per_threadgroup_3d()
end

############################################################################################

@testset "math" begin
    a = ones(Float32,1)
    a .* Float32(3.14)
    bufferA = MtlArray{eltype(a),length(size(a)),Shared}(a)
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
    synchronize()

    bufferB = MtlArray{eltype(a),length(size(a)),Shared}(a)
    vecB = unsafe_wrap(Vector{Float32}, pointer(bufferB), 1)

    function intr_test3(arr_sin, arr_cos)
        idx = thread_position_in_grid_1d()
        s, c = sincos(arr_cos[idx])
        arr_sin[idx] = s
        arr_cos[idx] = c
        return nothing
    end

    @metal intr_test3(bufferA, bufferB)
    synchronize()
    @test vecA ≈ sin.(a)
    @test vecB ≈ cos.(a)

    b = collect(LinRange(nextfloat(-1f0), 10f0, 20))
    bufferC = MtlArray(b)
    vecC = Array(log1p.(bufferC))
    @test vecC ≈ log1p.(b)


    d = collect(LinRange(nextfloat(-3.0f0), 3.0f0, 20))
    bufferD = MtlArray(d)
    vecD = Array(SpecialFunctions.erf.(bufferD))
    @test vecD ≈ SpecialFunctions.erf.(d)


    e = collect(LinRange(nextfloat(-3.0f0), 3.0f0, 20))
    bufferE = MtlArray(e)
    vecE = Array(SpecialFunctions.erfc.(bufferE))
    @test vecE ≈ SpecialFunctions.erfc.(e)
end

############################################################################################

@testset "synchronization" begin
    # host/device synchronization
    let
        function sync_test_kernel(buf)
            idx = thread_position_in_grid_1d()
            @inbounds buf[idx] += 1
            return nothing
        end
        buf = Metal.zeros(Int, 1024; storage=Shared)
        vec = unsafe_wrap(Vector{Int}, pointer(buf), size(buf))
        @metal threads=length(buf) sync_test_kernel(buf)
        synchronize()
        @test all(vec .== 1)
    end

    # thread synchronization
    let
        function barrier_test_kernel(buf)
            idx = thread_position_in_grid_1d()
            if thread_position_in_threadgroup_1d() != 1
                @inbounds buf[idx] = 1
            end

            threadgroup_barrier(Metal.MemoryFlagThreadGroup)

            if thread_position_in_threadgroup_1d() == 1
                for i in 2:threads_per_threadgroup_1d()
                    @inbounds buf[idx] += buf[i]
                end
            end
            return nothing
        end

        buf = Metal.zeros(Int, 1000)
        @metal threads=length(buf) barrier_test_kernel(buf)
        @test Array(buf)[1] == 999
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

############################################################################################

@testset "simd intrinsics" begin

@testset "shuffle($typ)" for typ in [Float32, Float16, Int32, UInt32, Int16, UInt16, Int8, UInt8]
    function kernel(a::MtlDeviceVector{T}, b::MtlDeviceVector{T}) where T
        idx = thread_position_in_grid_1d()
        idx_in_simd = thread_index_in_simdgroup()
        simd_idx = simdgroup_index_in_threadgroup()

        temp = MtlThreadGroupArray(T, 32)
        temp[idx] = a[idx]
        simdgroup_barrier(Metal.MemoryFlagThreadGroup)

        if simd_idx == 1
            value = temp[idx_in_simd]

            value = value + simd_shuffle_down(value, 16)
            value = value + simd_shuffle_down(value,  8)
            value = value + simd_shuffle_down(value,  4)
            value = value + simd_shuffle_down(value,  2)
            value = value + simd_shuffle_down(value,  1)

            b[idx] = value
        end
        return
    end

    dev_a = Metal.zeros(typ, 32; storage=Shared)
    dev_b = Metal.zeros(typ, 32; storage=Shared)
    a = unsafe_wrap(Array{typ}, dev_a, 32)
    b = unsafe_wrap(Array{typ}, dev_b, 32)

    rand!(a, (1:4))
    Metal.@sync @metal threads=32 kernel(dev_a, dev_b)
    @test sum(a) ≈ b[1]
end

@testset "matrix functions" begin
    @testset "load_store($typ)" for typ in [Float16, Float32]
        function kernel(a::MtlDeviceArray{T}, b::MtlDeviceArray{T},
                            origin_a=(1, 1), origin_b=(1, 1)) where {T}
            sg_a = simdgroup_load(a, origin_a)
            simdgroup_store(sg_a, b, origin_b)
            return
        end

        let
            a = MtlArray(rand(typ, 8, 8))
            b = MtlArray(zeros(typ, 8, 8))
            @metal threads=(8, 8) kernel(a, b)
            @test Array(a) == Array(b)
        end

        let
            a = MtlArray(rand(typ, 20, 15))
            b = MtlArray(zeros(typ, 15, 20))
            @metal threads=(8, 8) kernel(a, b, (4, 2), (3, 5))
            @test Array(a)[4:11, 2:9] == Array(b)[3:10, 5:12]
        end
    end

    @testset "load_store_tg($typ)" for typ in [Float16, Float32]
        function kernel(a::MtlDeviceArray{T}, b::MtlDeviceArray{T}) where {T}
            pos = thread_position_in_threadgroup_2d()

            tg_a = MtlThreadGroupArray(T, (8, 8))
            tg_a[pos.x, pos.y] = a[pos.x, pos.y]
            sg_a = simdgroup_load(tg_a)

            tg_b = MtlThreadGroupArray(T, (8, 8))
            simdgroup_store(sg_a, tg_b)
            b[pos.x, pos.y] = tg_b[pos.x, pos.y]

            return
        end

        a = MtlArray(rand(typ, 8, 8))
        b = MtlArray(zeros(typ, 8, 8))
        @metal threads=(8, 8) kernel(a, b)
        @test Array(a) == Array(b)
    end

    @testset "mul($typ)" for typ in [Float16, Float32]
        function kernel(a::MtlDeviceArray{T}, b::MtlDeviceArray{T}, c::MtlDeviceArray{T}) where {T}
            sg_a = simdgroup_load(a)
            sg_b = simdgroup_load(b)
            sg_c = simdgroup_multiply(sg_a, sg_b)
            simdgroup_store(sg_c, c)
            return
        end

        a = MtlArray(rand(typ, 8, 8))
        b = MtlArray(rand(typ, 8, 8))
        c = MtlArray(zeros(typ, 8, 8))
        @metal threads=(8, 8) kernel(a, b, c)
        @test Array(a) * Array(b) ≈ Array(c)
    end

    @testset "mad($typ)" for typ in [Float16, Float32]
        function kernel(a::MtlDeviceArray{T}, b::MtlDeviceArray{T}, c::MtlDeviceArray{T},
                    d::MtlDeviceArray{T}) where {T}
            sg_a = simdgroup_load(a)
            sg_b = simdgroup_load(b)
            sg_c = simdgroup_load(c)
            sg_d = simdgroup_multiply_accumulate(sg_a, sg_b, sg_c)
            simdgroup_store(sg_d, d)
            return
        end

        a = MtlArray(rand(typ, 8, 8))
        b = MtlArray(rand(typ, 8, 8))
        c = MtlArray(rand(typ, 8, 8))
        d = MtlArray(zeros(typ, 8, 8))
        @metal threads=(8, 8) kernel(a, b, c, d)
        @test Array(a) * Array(b) + Array(c) ≈ Array(d)
    end
end # End Matrix Functions

end # End SIMD Intrinsics


############################################################################################

@testset "atomics" begin

n = 128 # NOTE: also hard-coded in MtlThreadGroupArray constructors

# JuliaGPU/Metal.jl#217: threadgroup atomics seem to requires all-atomic operations

@testset "low-level" begin
    # TODO: make these tests actually write to the overlapping memory locations

    # XXX: according to the docs, Float32 atomics should also work on threadgroup memory

    @testset "store_explicit" begin
        function global_kernel(a, val)
            i = thread_position_in_grid_1d()
            Metal.atomic_store_explicit(pointer(a, i), val)
            return
        end

        types = [Int32]
        metal_support() >= v"3.0" && push!(types, Float32)
        @testset for T in types
            a = Metal.zeros(T, n)
            @metal threads=n global_kernel(a, T(42))
            @test all(isequal(42), Array(a))
        end

        function local_kernel(a, val::T) where T
            i = thread_position_in_grid_1d()
            b = MtlThreadGroupArray(T, 128)
            Metal.atomic_store_explicit(pointer(b, i), val)
            a[i] = b[i]
            return
        end

        @testset for T in [Int32,]
            a = Metal.zeros(T, n)
            @metal threads=n local_kernel(a, T(42))
            @test all(isequal(42), Array(a))
        end
    end

    @testset "load_explicit" begin
        function global_kernel(a, b)
            i = thread_position_in_grid_1d()
            val = Metal.atomic_load_explicit(pointer(a, i))
            b[i] = val
            return
        end

        types = [Int32]
        metal_support() >= v"3.0" && push!(types, Float32)
        @testset for T in types
            a = MtlArray(rand(T, n))
            b = Metal.zeros(T, n)
            @metal threads=n global_kernel(a, b)
            @test Array(a) == Array(b)
        end

        function local_kernel(a::AbstractArray{T}, b::AbstractArray{T}) where T
            i = thread_position_in_grid_1d()
            c = MtlThreadGroupArray(T, 128)
            #c[i] = a[i]
            val = Metal.atomic_load_explicit(pointer(a, i))
            Metal.atomic_store_explicit(pointer(c, i), val)
            val = Metal.atomic_load_explicit(pointer(c, i))
            #b[i] = val
            Metal.atomic_store_explicit(pointer(b, i), val)
            return
        end

        @testset for T in [Int32,]
            a = MtlArray(rand(T, n))
            b = Metal.zeros(T, n)
            @metal threads=n local_kernel(a, b)
            @test Array(a) == Array(b)
        end
    end

    @testset "exchange_explicit" begin
        function global_kernel(a, val)
            i = thread_position_in_grid_1d()
            Metal.atomic_exchange_explicit(pointer(a, i), val)
            return
        end

        types = [Int32]
        metal_support() >= v"3.0" && push!(types, Float32)
        @testset for T in types
            a = MtlArray(rand(T, n))
            @metal threads=n global_kernel(a, T(42))
            @test all(isequal(42), Array(a))
        end

        function local_kernel(a, val::T) where T
            i = thread_position_in_grid_1d()
            b = MtlThreadGroupArray(T, 128)
            Metal.atomic_exchange_explicit(pointer(b, i), val)
            a[i] = b[i]
            return
        end

        @testset for T in [Int32,]
            a = Metal.zeros(T, n)
            @metal threads=n local_kernel(a, T(42))
            @test all(isequal(42), Array(a))
        end
    end

    @testset "compare_exchange_weak_explicit" begin
        function global_kernel(a, expected, desired)
            i = thread_position_in_grid_1d()
            while Metal.atomic_compare_exchange_weak_explicit(pointer(a, i), expected[i], desired) != expected[i]
                # keep on trying
            end
            return
        end

        types = [Int32]
        metal_support() >= v"3.0" && push!(types, Float32)
        @testset for T in types
            a = MtlArray(rand(T, n))
            expected = copy(a)
            desired = T(42)
            @metal threads=length(a) global_kernel(a, expected, desired)
            @test all(isequal(42), Array(a))
        end

        function local_kernel(a, expected::AbstractArray{T}, desired::T) where T
            i = thread_position_in_grid_1d()
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

        @testset for T in [Int32,]
            a = Metal.zeros(T, n)
            expected = copy(a)
            desired = T(42)
            @metal threads=n local_kernel(a, expected, desired)
            @test all(isequal(42), Array(a))
        end
    end

    @testset "fetch and modify" begin
        add_sub_types = [Int32, UInt32]
        metal_support() >= v"3.0" && push!(add_sub_types, Float32)
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
                i = thread_position_in_grid_1d()
                f(pointer(a, i), arg)
                return
            end

            function local_kernel(f, a, arg::T) where T
                i = thread_position_in_grid_1d()
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

                @testset "threadgroup $T" for T in setdiff(types, [Float32])
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
            i = thread_position_in_grid_1d()
            Metal.atomic_fetch_op_explicit(pointer(a, i), op, arg)
            return
        end

        @testset for T in (Int32, UInt32)
            a = rand(T, n)
            b = MtlArray(a)
            val = rand(T)
            @metal threads=n global_kernel(b, f, val)
            @test f.(a, val) ≈ Array(b)
        end

        function local_kernel(a, op, arg::T) where T
            i = thread_position_in_grid_1d()
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

        @testset for T in (Int32, UInt32)
            a = rand(T, n)
            b = MtlArray(a)
            val = rand(T)
            @metal threads=n local_kernel(b, f, val)
            @test f.(a, val) ≈ Array(b)
        end
    end
end

@testset "high-level" begin
    # NOTE: this doesn't test threadgroup atomics, as those are assumed to have been
    #       covered by the low-level tests above, but only the atomic macro functionality.

    @testset "load" begin
        types = [Int32, UInt32]
        metal_support() >= v"3.0" && append!(types, [Float32])

        function kernel(a, b)
            i = thread_position_in_grid_1d()
            a[i] = Metal.@atomic b[i]
            return
        end

        @testset for T in types
            a = Metal.zeros(T, n)
            b = MtlArray(rand(T, n))
            @metal threads=n kernel(a, b)
            @test Array(a) == Array(b)
        end
    end

    @testset "store" begin
        types = [Int32, UInt32]
        metal_support() >= v"3.0" && append!(types, [Float32])

        function kernel(a, b)
            i = thread_position_in_grid_1d()
            val = b[i]
            Metal.@atomic a[i] = val
            return
        end

        @testset for T in types
            a = Metal.zeros(T, n)
            b = MtlArray(rand(T, n))
            @metal threads=n kernel(a, b)
            @test Array(a) == Array(b)
        end
    end

    @testset "add" begin
        types = [Int32, UInt32]
        metal_support() >= v"3.0" && append!(types, [Float32])

        function kernel(a)
            Metal.@atomic a[1] = a[1] + 1
            Metal.@atomic a[1] += 1
            return
        end

        @testset for T in types
            a = Metal.zeros(T)
            @metal threads=n kernel(a)
            @test Array(a)[1] == 2*n
        end
    end

    @testset "sub" begin
        types = [Int32, UInt32]
        metal_support() >= v"3.0" && append!(types, [Float32])

        function kernel(a)
            Metal.@atomic a[1] = a[1] - 1
            Metal.@atomic a[1] -= 1
            return
        end

        @testset for T in types
            a = MtlArray(T[2n])
            @metal threads=n kernel(a)
            @test Array(a)[1] == 0
        end
    end
end

end
