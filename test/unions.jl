# Arrays of isbits unions keep one selector byte per element past the data, like `Array`
# does (see `typetagdata` in src/array.jl).

import KernelInterface as KI
using Metal.MetalKernels: MetalBackend

# a struct with a union field is stored inline, with its own selector inside the element
struct UnionField
    x::Union{Int32, Float32}
end

const STORAGEMODES = [Metal.SharedStorage, Metal.PrivateStorage]

@testset "size" begin
    a = MtlArray(Union{Int, Nothing}[1, nothing, 3])
    @test sizeof(a) == 3 * sizeof(Int)  # excludes the selector bytes
end

@testset "round trips ($S)" for S in STORAGEMODES
    @testset "$T" for (T, xs) in (
            (Union{Int, Nothing},                [1, nothing, 3]),
            (Union{Int8, Float32},               [Int8(1), 2f0, Int8(3)]),
            # elements that are smaller than their stride
            (Union{NTuple{3, Int8}, Int16},      [(Int8(1), Int8(2), Int8(3)), Int16(4)]),
            (Union{Int64, NTuple{3, Int32}},     [(Int32(1), Int32(2), Int32(3)), 4]),
            # unions of singletons have no data, only selector bytes
            (Union{Nothing, Missing},            [nothing, missing, missing, nothing]),
            # nested unions are flattened
            (Union{Union{Missing, Nothing}, Int}, [missing, 1, nothing]))
        a = convert(Vector{T}, xs)
        b = MtlArray{T, 1, S}(a)
        @test isequal(Array(b), a)
        @test isequal(Array(copy(b)), a)

        # copies between device arrays, also across storage modes
        for S′ in STORAGEMODES
            c = MtlArray{T, 1, S′}(undef, length(a))
            copyto!(c, b)
            @test isequal(Array(c), a)
            copyto!(c, 2, b, 1, length(a) - 1)
            @test isequal(Array(c), [a[1]; a[1:end-1]])
        end

        # partial copies from and to the host
        c = Vector{T}(undef, length(a) + 1)
        copyto!(c, 2, b, 1, length(a))
        @test isequal(c[2:end], a)
        copyto!(b, 2, reverse(a), 1, length(a) - 1)
        @test isequal(Array(b), [a[1]; reverse(a)[1:end-1]])
    end
end

@testset "host arrays with an offset" begin
    # removing the first element offsets the memory of an `Array`, and its selector bytes
    a = Union{Int, Nothing}[nothing, 1, nothing, 3]
    popfirst!(a)
    @test Array(MtlArray(a)) == [1, nothing, 3]
    copyto!(a, MtlArray(Union{Int, Nothing}[nothing, 2, nothing]))
    @test a == [nothing, 2, nothing]
end

@testset "scalar indexing" begin
    # shared arrays can be indexed without allowing scalar indexing
    a = MtlArray{Union{Int, Nothing}, 1, Metal.SharedStorage}([1, nothing, 3])
    @test a[1] === 1
    @test a[2] === nothing
    a[1] = nothing
    a[2] = 2
    @test Array(a) == [nothing, 2, 3]

    b = MtlArray{Union{Nothing, Missing}, 1, Metal.SharedStorage}([nothing, missing])
    @test b[2] === missing
    b[1] = missing
    @test isequal(Array(b), [missing, missing])

    c = MtlArray{Union{Int, Nothing}, 1, Metal.PrivateStorage}([1, nothing, 3])
    Metal.@allowscalar begin
        @test c[1] === 1
        @test c[2] === nothing
        c[1] = nothing
        c[2] = 2
    end
    @test Array(c) == [nothing, 2, 3]
end

function bump!(x)
    i = thread_position_in_grid().x
    val = x[i]
    if val !== nothing
        x[i] = val + 1
    end
    return
end

@testset "views" begin
    # the parent's first selector bytes differ from the view's
    a = Union{Int, Nothing}[nothing, nothing, 1, nothing, 3, 5]
    b = MtlArray(a)
    v = view(b, 3:5)
    @test Array(v) == a[3:5]
    @test Array(copy(v)) == a[3:5]
    @test Metal.@allowscalar v[1] === 1

    # kernels see the view's own selector bytes, and leave the parent alone outside of it
    @metal threads=length(v) bump!(v)
    @test Array(v) == [2, nothing, 4]
    @test Array(b) == [nothing, nothing, 2, nothing, 4, 5]

    # a non-contiguous view indexes into its parent
    @metal threads=3 bump!(view(b, 1:2:5))
    @test Array(b) == [nothing, nothing, 3, nothing, 5, 5]

    # views of views, and reshapes of views
    w = view(view(b, 2:6), 2:4)
    @test Array(w) == [3, nothing, 5]
    @metal threads=length(w) bump!(w)
    @test Array(b) == [nothing, nothing, 4, nothing, 6, 5]
    @test Array(reshape(view(b, 3:6), 2, 2)) == [4 6; nothing 5]
    function bump_reshaped!(x)
        bump!(reshape(x, 2, 2))
        return
    end
    @metal threads=4 bump_reshaped!(view(b, 3:6))
    @test Array(b) == [nothing, nothing, 5, nothing, 7, 6]

    # copies into a view
    copyto!(view(b, 1:2), MtlArray(Union{Int, Nothing}[7, 8]))
    @test Array(b) == [7, 8, 5, nothing, 7, 6]
    copyto!(view(b, 5:6), Union{Int, Nothing}[nothing, 9])
    @test Array(b) == [7, 8, 5, nothing, nothing, 9]

    # views of unions of singletons have no byte offset
    c = MtlArray([nothing, nothing, missing, missing])
    @test isequal(Array(view(c, 3:4)), [missing, missing])
    @test isequal(Array(copy(view(c, 2:3))), [nothing, missing])
end

@testset "kernels" begin
    function kernel_singletons!(ok, x)
        i = thread_position_in_grid().x
        ok[i] = x[i] === (i == 1 ? nothing : missing)
        return
    end
    c = MtlArray([nothing, nothing, missing, missing])
    ok = MtlArray(falses(3))
    @metal threads=3 kernel_singletons!(ok, view(c, 2:4))
    @test all(Array(ok))

    function kernel_flip!(x)
        i = thread_position_in_grid().x
        x[i] = x[i] === nothing ? missing : nothing
        return
    end
    @metal threads=3 kernel_flip!(view(c, 2:4))
    @test isequal(Array(c), [nothing, missing, nothing, nothing])

    function kernel_nested!(x)
        i = thread_position_in_grid().x
        val = x[i]
        if val isa Int
            x[i] = val + 1
        end
        return
    end
    d = MtlArray{Union{Union{Missing, Nothing}, Int}}([0, missing, nothing])
    @metal threads=length(d) kernel_nested!(d)
    @test isequal(Array(d), [1, missing, nothing])

    # elements that are smaller than their stride
    function kernel_swap!(x)
        i = thread_position_in_grid().x
        val = x[i]
        x[i] = val isa Int64 ? (Int32(val), Int32(0), Int32(0)) : Int64(val[1])
        return
    end
    e = MtlArray(Union{Int64, NTuple{3, Int32}}[1, (Int32(2), Int32(3), Int32(4)), 5])
    @metal threads=length(e) kernel_swap!(e)
    @test Array(e) == [(Int32(1), Int32(0), Int32(0)), 2, (Int32(5), Int32(0), Int32(0))]

    # read-only arrays
    function kernel_const!(y, x)
        i = thread_position_in_grid().x
        val = Base.Experimental.Const(x)[i]
        y[i] = val === nothing ? 0 : val
        return
    end
    x = MtlArray(Union{Int, Nothing}[nothing, 1, nothing, 2])
    y = MtlArray{Int}(undef, 3)
    @metal threads=3 kernel_const!(y, view(x, 2:4))
    @test Array(y) == [1, 0, 2]

    # threadgroup memory
    function kernel_threadgroup!(x)
        i = thread_position_in_threadgroup().x
        tmp = MtlThreadGroupArray(Union{Int, Nothing}, 4)
        tmp[i] = x[i]
        threadgroup_barrier(Metal.MemoryFlagThreadGroup)
        x[i] = tmp[5 - i]
        return
    end
    z = MtlArray(Union{Int, Nothing}[1, nothing, 3, nothing])
    @metal threads=4 kernel_threadgroup!(z)
    @test Array(z) == [nothing, 3, nothing, 1]

    function kernel_localmemory!(x)
        i = KI.get_local_id().x
        tmp = KI.localmemory(Union{Int, Nothing}, Val((4,)))
        tmp[i] = x[i]
        KI.barrier()
        x[i] = tmp[5 - i]
        return
    end
    KI.@launch MetalBackend() workgroupsize=4 kernel_localmemory!(z)
    KI.synchronize(MetalBackend())
    @test Array(z) == [1, nothing, 3, nothing]

    # a struct with a union field
    function kernel_struct!(x::AbstractArray{T}) where {T}
        i = thread_position_in_grid().x
        x[i] = isodd(i) ? T(Int32(i)) : T(Float32(i))
        return
    end
    f = MtlArray{UnionField}(undef, 2)
    @metal threads=2 kernel_struct!(f)
    @test Array(f) == [UnionField(Int32(1)), UnionField(2f0)]
end

@testset "array operations" begin
    x = MtlArray(Union{Missing, Bool}[missing, true, false])
    @test isequal(Array(x .| false), [missing, true, false])
    @test isequal(Array(map(!, x)), [missing, false, true])
    @test any(x) === true
    @test all(x) === false
    @test isequal(Array(x[2:3]), [true, false])
    @test isequal(Array(reverse(x)), [false, true, missing])
    @test isequal(Array(vcat(x, x)), [missing, true, false, missing, true, false])

    y = similar(x)
    fill!(y, missing)
    @test all(ismissing, Array(y))
    fill!(y, true)
    @test Array(y) == [true, true, true]

    # Metal can fill buffers with bytes, but not their selectors
    w = MtlArray(Union{Int8, UInt8}[Int8(1), UInt8(2)])
    fill!(w, UInt8(255))
    @test Array(w) == [0xff, 0xff]
    @test all(v -> v isa UInt8, Array(w))
    fill!(w, Int8(-1))
    @test all(v -> v === Int8(-1), Array(w))

    z = MtlArray(Union{Int, Nothing}[1, nothing, 3, nothing])
    @test sum(v -> something(v, 0), z) == 4
    @test Array(reshape(z, 2, 2)) == [1 3; nothing nothing]
end

@testset "resize! ($S)" for S in STORAGEMODES
    a = MtlArray{Union{Int, Nothing}, 1, S}([1, nothing, 3])
    resize!(a, 5)
    @test length(a) == 5
    @test Array(a)[1:3] == [1, nothing, 3]
    resize!(a, 2)
    @test Array(a) == [1, nothing]

    # offset arrays (contiguous views of an `MtlArray` are `MtlArray`s)
    b = MtlArray{Union{Int, Nothing}, 1, S}([nothing, nothing, 1, nothing, 3])
    c = view(b, 3:5)
    @test c isa MtlArray
    resize!(c, 4)
    @test Array(c)[1:3] == [1, nothing, 3]
    @test Array(b) == [nothing, nothing, 1, nothing, 3]

    d = MtlArray{Union{Nothing, Missing}, 1, S}([nothing, missing, missing])
    e = view(d, 2:3)
    resize!(e, 1)
    @test isequal(Array(e), [missing])
    resize!(d, 4)
    @test isequal(Array(d)[1:3], [nothing, missing, missing])
end

@testset "KernelInterface.copyto!" begin
    backend = MetalBackend()
    host = Union{Int, Nothing}[nothing, 1, nothing, 3]
    dev = MtlArray{Union{Int, Nothing}}(undef, 3)
    KI.copyto!(backend, dev, view(host, 2:4))
    KI.synchronize(backend)
    @test Array(dev) == [1, nothing, 3]
    KI.copyto!(backend, view(host, 1:3), MtlArray(Union{Int, Nothing}[nothing, 2, nothing]))
    KI.synchronize(backend)
    @test host == [nothing, 2, nothing, 3]
end

@testset "unsupported operations" begin
    a = Union{Int, Nothing}[1, nothing]
    @test_throws ArgumentError unsafe_wrap(MtlArray, a)
    b = MtlArray{Union{Int, Nothing}, 1, Metal.SharedStorage}(a)
    @test_throws ArgumentError unsafe_wrap(Array, b)
    @test_throws ArgumentError unsafe_wrap(MtlArray, pointer(b), (2,))
    @test_throws "not all types are bitstypes" reinterpret(Float64, b)
    @test_throws "Float64" MtlArray(Union{Float64, Nothing}[1.0, nothing])
end
