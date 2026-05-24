@testset "type" begin
    @testset for T in (Float16, Float32)
        @test eltype(MtlSimdgroupMatrix{T,8,8}) === T
        @test size(MtlSimdgroupMatrix{T,8,8}) === (8, 8)
    end
end

@testset "fill($T)" for T in (Float16, Float32)
    function kernel(out::MtlDeviceMatrix{T}, val::T) where {T}
        m = MtlSimdgroupMatrix{T,8,8}(val)
        simdgroup_store(m, out)
        return
    end

    out = MtlArray(zeros(T, 8, 8))
    Metal.@sync @metal threads=(8, 8) kernel(out, T(3.5))
    @test all(Array(out) .== T(3.5))
end

@testset "zero($T)" for T in (Float16, Float32)
    function kernel(out::MtlDeviceMatrix{T}) where {T}
        m = zero(MtlSimdgroupMatrix{T,8,8})
        simdgroup_store(m, out)
        return
    end

    out = MtlArray(ones(T, 8, 8))
    Metal.@sync @metal threads=(8, 8) kernel(out)
    @test all(Array(out) .== zero(T))
end

@testset "load_store($T)" for T in (Float16, Float32)
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

@testset "load_store with origin($T)" for T in (Float16, Float32)
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

@testset "multiply($T)" for T in (Float16, Float32)
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

@testset "muladd($T)" for T in (Float16, Float32)
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
@testset "K-loop GEMM($T)" for T in (Float16, Float32)
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
@testset "threadgroup load($T)" for T in (Float16, Float32)
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
