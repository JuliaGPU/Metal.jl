using Metal: metal_support

@testset "shuffle functions" begin
    shuffle_test_types = [Float32, Float16,# BFloat16,
                          Int32, UInt32, Int16, UInt16,
                          Int8, UInt8]
    @testset "simd_shuffle" begin
        function shuffle_kernel(d)
            i = thread_index_in_simdgroup()
            j = threads_per_simdgroup() - i + 0x1

            d[i] = simd_shuffle(d[i], j)
            return
        end

        threadsPerSimdgroup = 32

        @testset "$T" for T in shuffle_test_types
            a = rand(T, threadsPerSimdgroup)
            d_a = MtlArray(a)
            Metal.@sync @metal threads=threadsPerSimdgroup shuffle_kernel(d_a)
            @test Array(d_a) == reverse(a)
        end
    end

    @testset "simd_shuffle" begin
        function xor_kernel(in)
            i = thread_index_in_simdgroup()

            new_val = simd_shuffle_xor(in[i], 1)

            in[i] = new_val
            return
        end

        threadsPerSimdgroup = 32

        # tests that each pair of values a get swapped using sub_group_shuffle_xor
        @testset "T" for T in shuffle_test_types
            in = rand(T, threadsPerSimdgroup)
            idxs = xor.(0:(threadsPerSimdgroup - 1), 1) .+ 1
            d_in = MtlArray(in)
            Metal.@sync @metal threads=threadsPerSimdgroup xor_kernel(d_in)
            @test Array(d_in) == in[idxs]
        end
    end

    @testset "$f" for (f,res_idx) in [(simd_shuffle_down, 1), (simd_shuffle_up, 32)]
        function kernel(a::MtlDeviceVector{T}, b::MtlDeviceVector{T}) where T
            idx = thread_position_in_grid().x
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
        @testset "$typ" for typ in shuffle_test_types
            dev_a = Metal.zeros(typ, 32; storage=Metal.SharedStorage)
            dev_b = Metal.zeros(typ, 32; storage=Metal.SharedStorage)
            synchronize()
            a = unsafe_wrap(Array{typ}, dev_a, 32)
            b = unsafe_wrap(Array{typ}, dev_b, 32)

            rand!(a, (1:4))
            Metal.@sync @metal threads=32 kernel(dev_a, dev_b)
            @test sum(a) ≈ b[res_idx]
        end
    end
    @testset "$f" for (f,nshift) in [(simd_shuffle_and_fill_down, -4), (simd_shuffle_and_fill_up, 2)]
        function kernel_mod(data::MtlDeviceVector{T}, filling_data::MtlDeviceVector{T}, modulo) where T
            idx = thread_position_in_grid().x
            idx_in_simd = thread_index_in_simdgroup() #simd_lane_id
            simd_idx = simdgroup_index_in_threadgroup() #simd_group_id

            temp_data = MtlThreadGroupArray(T, 16)
            temp_data[idx] = data[idx]
            temp_filling_data = MtlThreadGroupArray(T, 16)
            temp_filling_data[idx] = filling_data[idx]
            simdgroup_barrier(Metal.MemoryFlagThreadGroup)

            if simd_idx == 1
                dat_value = temp_data[idx_in_simd]
                dat_fil_value = temp_filling_data[idx_in_simd]

                value = f(dat_value, dat_fil_value, abs(nshift), modulo)

                data[idx] = value
            end
            return
        end

        @testset "$typ" for typ in shuffle_test_types
            N = 16
            midN = N ÷ 2

            data = Array{typ}(1:N)
            mtldata = MtlArray(data)
            mtlfilling = MtlArray(data)

            Metal.@sync @metal threads=N kernel_mod(mtldata, mtlfilling, N)
            @test Array(mtldata) == circshift(data, nshift)

            mtlfilling2 = MtlArray(data)

            Metal.@sync @metal threads=N kernel_mod(mtlfilling2, mtlfilling, midN)
            @test Array(mtlfilling2) == [circshift(data[1:midN], nshift); circshift(data[midN+1:end], nshift)]
        end
    end

    @testset "simd_ballot" begin
        function ballot_kernel(output, threshold)
            idx = thread_position_in_grid().x
            lane = thread_index_in_simdgroup()

            # Each thread votes true if its lane index is ≤ threshold
            predicate = lane ≤ threshold
            ballot = simd_ballot(predicate)

            output[idx] = ballot
            return
        end

        threads_per_simdgroup = 32

        @testset "threshold=$threshold" for threshold in [0, 1, 8, 16, 31, 32]
            output = MtlArray(zeros(UInt64, threads_per_simdgroup))
            Metal.@sync @metal threads = threads_per_simdgroup ballot_kernel(output, UInt32(threshold))

            # Expected: bits 0..(threshold-1) are set (1-indexed threshold means bits 0 to threshold-1)
            expected_ballot = threshold == 0 ? UInt64(0) : (UInt64(1) << threshold) - 1
            result = Array(output)

            # All threads should see the same ballot result
            @test all(result .== expected_ballot)
        end
    end

    @testset "simd_vote_all" begin
        function all_kernel(output, threshold)
            idx = thread_position_in_grid().x
            lane = thread_index_in_simdgroup()

            # First get a ballot mask based on threshold
            predicate = lane ≤ threshold
            ballot = simd_ballot(predicate)

            # simd_vote_all checks if all bits in the mask are set
            result = simd_vote_all(ballot)

            output[idx] = result
            return
        end

        threads_per_simdgroup = 32

        # simd_vote_all returns true only when all bits in the ballot mask are set
        @testset "threshold=$threshold" for threshold in [0, 16, 31, 32, 33]
            output = MtlArray(zeros(UInt8, threads_per_simdgroup))
            Metal.@sync @metal threads = threads_per_simdgroup all_kernel(output, UInt32(threshold))

            result = Array(output)
            # All bits set means threshold ≥ 32 (all 32 lanes voted true)
            expected = threshold ≥ threads_per_simdgroup

            @test all(result .== expected)
        end
    end

    @testset "simd_vote_any" begin
        function any_kernel(output, threshold)
            idx = thread_position_in_grid().x
            lane = thread_index_in_simdgroup()

            # First get a ballot mask based on threshold
            predicate = lane ≤ threshold
            ballot = simd_ballot(predicate)

            # simd_vote_any checks if any bit in the mask is set
            result = simd_vote_any(ballot)

            output[idx] = result
            return
        end

        threads_per_simdgroup = 32

        # simd_vote_any returns true when any bit in the ballot mask is set
        @testset "threshold=$threshold" for threshold in [0, 1, 16, 32]
            output = MtlArray(zeros(UInt8, threads_per_simdgroup))
            Metal.@sync @metal threads = threads_per_simdgroup any_kernel(output, UInt32(threshold))

            result = Array(output)
            # Any bit set means threshold ≥ 1 (at least lane 1 voted true)
            expected = threshold ≥ 1

            @test all(result .== expected)
        end
    end
end # @testset "shuffle functions"

@testset "matrix functions" begin
    simdgroup_types = [Float16, Float32]#, BFloat16]
    @testset "load_store($typ)" for typ in simdgroup_types
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

    @testset "load_store_tg($typ)" for typ in simdgroup_types
        function kernel(a::MtlDeviceArray{T}, b::MtlDeviceArray{T}) where {T}
            pos = thread_position_in_threadgroup()

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

    @testset "mul($typ)" for typ in simdgroup_types
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

    @testset "mad($typ)" for typ in simdgroup_types
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

    @testset "intrinsic ABI" begin
        # the load/store intrinsics take dims/strides/origin vectors on AIR 2.8, and are
        # downgraded to the legacy scalar+transpose form when targeting older versions
        # (see the downgrade rule in src/compiler/compilation.jl)
        function kernel(a, b)
            sg = simdgroup_load(a, (3, 2))
            simdgroup_store(sg, b, (2, 4))
            return
        end
        a = MtlArray(rand(Float32, 16, 16))
        b = MtlArray(zeros(Float32, 16, 16))
        tt = Tuple{map(typeof ∘ Metal.mtlconvert, (a, b))...}

        # use reflection rather than `@metal launch=false`: the latter still creates a
        # pipeline, and the host runtime may be too old to load a newer library

        # AIR 2.8: dims, strides and origin vectors (always the transposed layout, so
        # the origin is row/column-swapped)
        asm = sprint() do io
            Metal.code_air(io, kernel, tt; kernel=true, macos=v"26")
        end
        @test occursin(r"call <64 x float> @air\.simdgroup_matrix_8x8_load\.v64f32\.p1f32\(float addrspace\(1\)\* %\S+, <2 x i64> %\S+, <2 x i64> %\S+, <2 x i64> <i64 1, i64 2>\)", asm)
        @test occursin(r"call void @air\.simdgroup_matrix_8x8_store\.v64f32\.p1f32\(<64 x float> %\S+, float addrspace\(1\)\* %\S+, <2 x i64> %\S+, <2 x i64> %\S+, <2 x i64> <i64 3, i64 1>\)", asm)

        # AIR < 2.8: scalar elements-per-row, unswapped origin, and a transpose flag
        asm = sprint() do io
            Metal.code_air(io, kernel, tt; kernel=true, macos=v"14")
        end
        @test occursin(r"call <64 x float> @air\.simdgroup_matrix_8x8_load\.v64f32\.p1f32\(float addrspace\(1\)\* %\S+, i64 %\S+, <2 x i64> <i64 2, i64 1>, i1 true\)", asm)
        @test occursin(r"call void @air\.simdgroup_matrix_8x8_store\.v64f32\.p1f32\(<64 x float> %\S+, float addrspace\(1\)\* %\S+, i64 %\S+, <2 x i64> <i64 1, i64 3>, i1 true\)", asm)
        ## the legacy declarations keep the intrinsic attributes
        attrs = match(r"declare.+@air\.simdgroup_matrix_8x8_load\.v64f32\.p1f32\(.+\).* (#\d+)", asm)
        @test attrs !== nothing
        @test occursin(Regex("attributes $(attrs.captures[1]) = \\{[^}]*convergent"), asm)

        # the downgraded form executes correctly
        @metal threads=(8, 8) macos=v"14" kernel(a, b)
        @test Array(a)[3:10, 2:9] == Array(b)[2:9, 4:11]

        # the non-transposed layout (`Val(false)`) swaps the dims/strides/origin vectors,
        # so it downgrades to an *unswapped* origin and a cleared transpose flag rather
        # than the transposed encoding above (regression test: the downgrade used to
        # project every call onto the transposed form)
        function kernel_nt(a, b)
            sg = simdgroup_load(a, (3, 2), Val(false))
            simdgroup_store(sg, b, (2, 4), Val(false))
            return
        end

        # AIR 2.8: the non-transposed origin is *not* row/column-swapped
        asm = sprint() do io
            Metal.code_air(io, kernel_nt, tt; kernel=true, macos=v"26")
        end
        @test occursin(r"call <64 x float> @air\.simdgroup_matrix_8x8_load\.v64f32\.p1f32\(float addrspace\(1\)\* %\S+, <2 x i64> %\S+, <2 x i64> %\S+, <2 x i64> <i64 2, i64 1>\)", asm)
        @test occursin(r"call void @air\.simdgroup_matrix_8x8_store\.v64f32\.p1f32\(<64 x float> %\S+, float addrspace\(1\)\* %\S+, <2 x i64> %\S+, <2 x i64> %\S+, <2 x i64> <i64 1, i64 3>\)", asm)

        # AIR < 2.8: unswapped origin and a `false` transpose flag
        asm = sprint() do io
            Metal.code_air(io, kernel_nt, tt; kernel=true, macos=v"14")
        end
        @test occursin(r"call <64 x float> @air\.simdgroup_matrix_8x8_load\.v64f32\.p1f32\(float addrspace\(1\)\* %\S+, i64 %\S+, <2 x i64> <i64 2, i64 1>, i1 false\)", asm)
        @test occursin(r"call void @air\.simdgroup_matrix_8x8_store\.v64f32\.p1f32\(<64 x float> %\S+, float addrspace\(1\)\* %\S+, i64 %\S+, <2 x i64> <i64 1, i64 3>, i1 false\)", asm)

        # the downgraded non-transposed load executes with transpose semantics
        function kernel_nt_exec(a, b)
            m = simdgroup_load(a, (1, 1), Val(false))
            simdgroup_store(m, b, (1, 1), Val(true))
            return
        end
        c = MtlArray(rand(Float32, 8, 8))
        d = MtlArray(zeros(Float32, 8, 8))
        @metal threads=32 macos=v"14" kernel_nt_exec(c, d)
        @test Array(d) == permutedims(Array(c))
    end

    @testset "MtlSimdgroupMatrix type" begin
        @testset for T in (Float16, Float32)
            @test eltype(MtlSimdgroupMatrix{T,8,8}) === T
            @test size(MtlSimdgroupMatrix{T,8,8}) === (8, 8)
        end
    end

    @testset "MtlSimdgroupMatrix fill($T)" for T in (Float16, Float32)
        function kernel(out::MtlDeviceMatrix{T}, val::T) where {T}
            m = MtlSimdgroupMatrix{T,8,8}(val)
            simdgroup_store(m, out)
            return
        end

        out = MtlArray(zeros(T, 8, 8))
        Metal.@sync @metal threads=(8, 8) kernel(out, T(3.5))
        @test all(Array(out) .== T(3.5))
    end

    @testset "MtlSimdgroupMatrix zero($T)" for T in (Float16, Float32)
        function kernel(out::MtlDeviceMatrix{T}) where {T}
            m = zero(MtlSimdgroupMatrix{T,8,8})
            simdgroup_store(m, out)
            return
        end

        out = MtlArray(ones(T, 8, 8))
        Metal.@sync @metal threads=(8, 8) kernel(out)
        @test all(Array(out) .== zero(T))
    end

    @testset "MtlSimdgroupMatrix load_store($T)" for T in (Float16, Float32)
        function kernel(a::MtlDeviceMatrix{T}, b::MtlDeviceMatrix{T}) where {T}
            m = simdgroup_load(MtlSimdgroupMatrix{T,8,8}, a)
            simdgroup_store(m, b)
            return
        end

        a = MtlArray(rand(T, 8, 8))
        b = MtlArray(zeros(T, 8, 8))
        Metal.@sync @metal threads=(8, 8) kernel(a, b)
        @test Array(a) == Array(b)
    end

    @testset "MtlSimdgroupMatrix load_store with origin($T)" for T in (Float16, Float32)
        function kernel(a::MtlDeviceMatrix{T}, b::MtlDeviceMatrix{T},
                        origin_a::NTuple{2,Int64}, origin_b::NTuple{2,Int64}) where {T}
            m = simdgroup_load(MtlSimdgroupMatrix{T,8,8}, a, origin_a)
            simdgroup_store(m, b, origin_b)
            return
        end

        a = MtlArray(rand(T, 20, 15))
        b = MtlArray(zeros(T, 15, 20))
        Metal.@sync @metal threads=(8, 8) kernel(a, b, (4, 2), (3, 5))
        @test Array(a)[4:11, 2:9] == Array(b)[3:10, 5:12]
    end

    @testset "MtlSimdgroupMatrix multiply($T)" for T in (Float16, Float32)
        function kernel(a::MtlDeviceMatrix{T}, b::MtlDeviceMatrix{T}, c::MtlDeviceMatrix{T}) where {T}
            ma = simdgroup_load(MtlSimdgroupMatrix{T,8,8}, a)
            mb = simdgroup_load(MtlSimdgroupMatrix{T,8,8}, b)
            simdgroup_store(ma * mb, c)
            return
        end

        a = MtlArray(rand(T, 8, 8))
        b = MtlArray(rand(T, 8, 8))
        c = MtlArray(zeros(T, 8, 8))
        Metal.@sync @metal threads=(8, 8) kernel(a, b, c)
        @test Array(a) * Array(b) ≈ Array(c)
    end

    @testset "MtlSimdgroupMatrix muladd($T)" for T in (Float16, Float32)
        function kernel(a::MtlDeviceMatrix{T}, b::MtlDeviceMatrix{T},
                        c::MtlDeviceMatrix{T}, d::MtlDeviceMatrix{T}) where {T}
            ma = simdgroup_load(MtlSimdgroupMatrix{T,8,8}, a)
            mb = simdgroup_load(MtlSimdgroupMatrix{T,8,8}, b)
            mc = simdgroup_load(MtlSimdgroupMatrix{T,8,8}, c)
            simdgroup_store(muladd(ma, mb, mc), d)
            return
        end

        a = MtlArray(rand(T, 8, 8))
        b = MtlArray(rand(T, 8, 8))
        c = MtlArray(rand(T, 8, 8))
        d = MtlArray(zeros(T, 8, 8))
        Metal.@sync @metal threads=(8, 8) kernel(a, b, c, d)
        @test Array(a) * Array(b) + Array(c) ≈ Array(d)
    end

    # Composed K-loop GEMM: C(8×8) = A(8×K) * B(K×8) with K=32, accumulating
    # four 8×8×8 fragment MMAs.
    @testset "MtlSimdgroupMatrix K-loop GEMM($T)" for T in (Float16, Float32)
        function kernel(A::MtlDeviceMatrix{T}, B::MtlDeviceMatrix{T}, C::MtlDeviceMatrix{T}) where {T}
            acc = zero(MtlSimdgroupMatrix{T,8,8})
            for k in 0:3
                ma = simdgroup_load(MtlSimdgroupMatrix{T,8,8}, A, (1, 1 + k*8))
                mb = simdgroup_load(MtlSimdgroupMatrix{T,8,8}, B, (1 + k*8, 1))
                acc = muladd(ma, mb, acc)
            end
            simdgroup_store(acc, C)
            return
        end

        A = MtlArray(rand(T, 8, 32))
        B = MtlArray(rand(T, 32, 8))
        C = MtlArray(zeros(T, 8, 8))
        Metal.@sync @metal threads=(8, 8) kernel(A, B, C)
        @test Array(A) * Array(B) ≈ Array(C) rtol=sqrt(eps(T))
    end

    # Threadgroup-memory variant: stage tiles through threadgroup memory, then
    # load fragments from there. Mirrors how Flash Attention stages K/V tiles.
    @testset "MtlSimdgroupMatrix threadgroup load($T)" for T in (Float16, Float32)
        function kernel(a::MtlDeviceMatrix{T}, b::MtlDeviceMatrix{T}) where {T}
            pos = thread_position_in_threadgroup()
            tg = MtlThreadGroupArray(T, (8, 8))
            tg[pos.x, pos.y] = a[pos.x, pos.y]
            threadgroup_barrier(Metal.MemoryFlagThreadGroup)

            m = simdgroup_load(MtlSimdgroupMatrix{T,8,8}, tg)
            tg2 = MtlThreadGroupArray(T, (8, 8))
            simdgroup_store(m, tg2)
            threadgroup_barrier(Metal.MemoryFlagThreadGroup)

            b[pos.x, pos.y] = tg2[pos.x, pos.y]
            return
        end

        a = MtlArray(rand(T, 8, 8))
        b = MtlArray(zeros(T, 8, 8))
        Metal.@sync @metal threads=(8, 8) kernel(a, b)
        @test Array(a) == Array(b)
    end
end # End Matrix Functions
