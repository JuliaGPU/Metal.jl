using Random

@testset "simd intrinsics" begin

@testset "$f($typ)" for typ in [Float32, Float16, Int32, UInt32, Int16, UInt16, Int8, UInt8], (f,res_idx) in [(simd_shuffle_down, 1), (simd_shuffle_up, 32)]
    function kernel(a::MtlDeviceVector{T}, b::MtlDeviceVector{T}) where T
        idx = thread_position_in_grid_1d()
        idx_in_simd = thread_index_in_simdgroup()
        simd_idx = simdgroup_index_in_threadgroup()

        temp = MtlThreadGroupArray(T, 32)
        temp[idx] = a[idx]
        simdgroup_barrier(Metal.MemoryFlagThreadGroup)

        if simd_idx == 1
            value = temp[idx_in_simd]

            value = value + f(value, 16)
            value = value + f(value,  8)
            value = value + f(value,  4)
            value = value + f(value,  2)
            value = value + f(value,  1)

            b[idx] = value
        end
        return
    end

    dev_a = Metal.zeros(typ, 32; storage=Metal.SharedStorage)
    dev_b = Metal.zeros(typ, 32; storage=Metal.SharedStorage)
    synchronize()
    a = unsafe_wrap(Array{typ}, dev_a, 32)
    b = unsafe_wrap(Array{typ}, dev_b, 32)

    rand!(a, (1:4))
    Metal.@sync @metal threads=32 kernel(dev_a, dev_b)
    @test sum(a) ≈ b[res_idx]
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
            threadgroup_barrier(Metal.MemoryFlagThreadGroup)

            sg_a = simdgroup_load(tg_a)
            tg_b = MtlThreadGroupArray(T, (8, 8))
            simdgroup_store(sg_a, tg_b)

            threadgroup_barrier(Metal.MemoryFlagThreadGroup)
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
