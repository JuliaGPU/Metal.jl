using Random

@testset "atomics" begin

n = 128 # NOTE: also hard-coded in MtlThreadGroupArray constructors

# JuliaGPU/Metal.jl#217: threadgroup atomics seem to requires all-atomic operations

@testset "low-level" begin
    # TODO: make these tests actually write to the overlapping memory locations

    atomic_store_load_exch_cmpexch_types = (Int32, UInt32, Float32)
    # The Metal Shading Language spec states: "Metal 3 supports the atomic_float for device memory only"
    local_atomic_store_load_exch_cmpexch_types = setdiff(atomic_store_load_exch_cmpexch_types, [Float32])

    @testset "store_explicit" begin
        function global_kernel(a, val)
            i = thread_position_in_grid_1d()
            Metal.atomic_store_explicit(pointer(a, i), val)
            return
        end

        @testset for T in atomic_store_load_exch_cmpexch_types
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

        @testset for T in local_atomic_store_load_exch_cmpexch_types
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

        @testset for T in atomic_store_load_exch_cmpexch_types
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

        @testset for T in local_atomic_store_load_exch_cmpexch_types
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

        @testset for T in atomic_store_load_exch_cmpexch_types
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

        @testset for T in local_atomic_store_load_exch_cmpexch_types
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

        @testset for T in atomic_store_load_exch_cmpexch_types
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

        @testset for T in local_atomic_store_load_exch_cmpexch_types
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

        @testset for T in (Int32, UInt32, Float32)
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
        types = [Int32, UInt32, Float32]

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
        types = [Int32, UInt32, Float32]

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
        types = [Int32, UInt32, Float32]

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
        types = [Int32, UInt32, Float32]

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
