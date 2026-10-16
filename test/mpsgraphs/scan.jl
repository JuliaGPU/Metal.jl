using .MPSGraphs: accumulate!, supports

# exclusive and reverse scans, built from Base's inclusive forward scan
function ref_scan(op, A; dims, init=nothing, inclusive=true, rev=false)
    B = rev ? reverse(A; dims) : A
    B = init === nothing ? accumulate(op, B; dims) : accumulate(op, B; dims, init)
    if !inclusive
        # shift by one along `dims`, starting from the identity (or `init`)
        T = eltype(A)
        first = init !== nothing ? init : op === max ? typemin(T) :
                op === min ? typemax(T) : Base.reduce_empty(op, T)
        B = cat(fill(first, Base.setindex(size(A), 1, dims)),
                selectdim(B, dims, 1:size(A, dims)-1); dims)
    end
    return rev ? reverse(B; dims) : B
end

@testset "accumulate! ($T)" for T in MPSGraphs.MPSGRAPH_VALID_SCAN_TYPES
    A, ops = if T <: Integer
        rand(T.(1:3), 3, 4), (+, *, min, max)
    else
        reshape(T[2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37], 3, 4) ./ T(10), (+, *)
    end

    @testset "$op, dims=$dims" for op in ops, dims in 1:2
        B = similar(MtlArray(A))
        @test accumulate!(op, B, MtlArray(A); dims) === B
        @test Array(B) ≈ accumulate(op, A; dims)
    end
end

@testset "accumulate! options" begin
    A = rand(Int32(1):Int32(5), 4, 3, 2)
    @testset "$op, dims=$dims, inclusive=$inclusive, rev=$rev, init=$init" for
            op in (+, max), dims in 1:3, inclusive in (true, false), rev in (false, true),
            init in (nothing, Int32(2))
        B = MtlArray{Int32}(undef, size(A))
        accumulate!(op, B, MtlArray(A); dims, init, inclusive, rev)
        @test Array(B) == ref_scan(op, A; dims, init, inclusive, rev)
    end

    # vectors don't need `dims`, and can be scanned in place
    v = rand(Float32, 100_000)
    v_d = MtlArray(v)
    accumulate!(+, v_d, v_d)
    @test Array(v_d) ≈ cumsum(v)

    # `init` is represented exactly, which an exclusive scan exposes
    v = rand(Int64(-5):Int64(5), 10)
    B = MtlArray{Int64}(undef, 10)
    init = Int64(2)^60 + 1
    accumulate!(+, B, MtlArray(v); init, inclusive=false)
    @test Array(B)[1] == init
    @test Array(B) == ref_scan(+, v; dims=1, init, inclusive=false)

    # many dimensions
    A = rand(Float32, 2, 3, 2, 3, 2, 3)
    for dims in (1, 4, 6)
        B = MtlArray{Float32}(undef, size(A))
        accumulate!(+, B, MtlArray(A); dims)
        @test Array(B) ≈ cumsum(A; dims)
    end

    # empty input
    B = MtlArray{Float32}(undef, 0, 3)
    @test accumulate!(+, B, MtlArray{Float32}(undef, 0, 3); dims=1) === B
end

@testset "accumulate! ordering" begin
    A = MtlArray(ones(Float32, 1000))
    B = similar(A)
    A .*= 2
    accumulate!(+, B, A)
    B .+= 1
    @test Array(B) == 2 .* (1:1000) .+ 1
end

@testset "accumulate! unsupported" begin
    A = MtlArray(rand(Float32, 3, 4))
    for (op, B, A, kwargs, E) in (
            # cumulative max and min ignore NaN, so they're only supported for integers
            (max, similar(A), A, (; dims=1), ArgumentError),
            (-, similar(A), A, (; dims=1), ArgumentError),
            (+, similar(A, ComplexF32), MtlArray(rand(ComplexF32, 3, 4)), (; dims=1), ArgumentError),
            (+, similar(A, Float16), A, (; dims=1), ArgumentError),
            (+, similar(A), A, (; dims=1, init=1), ArgumentError),
            (+, similar(A, 4, 3), A, (; dims=1), DimensionMismatch),
            # `dims` is required for matrices, and must be one of their dimensions
            (+, similar(A), A, (;), ArgumentError),
            (+, similar(A), A, (; dims=3), ArgumentError),
            (+, similar(A), Array(A), (; dims=1), ArgumentError),
        )
        @test !supports(accumulate!, op, B, A; kwargs...)
        @test_throws E accumulate!(op, B, A; kwargs...)
    end
    @test supports(accumulate!, +, similar(A), A; dims=2)
end

@testset "deprecated graph_scan!" begin
    A = rand(Float32, 3, 4)
    B = MtlArray{Float32}(undef, 3, 4)
    @test_deprecated MPSGraphs.graph_scan!(+, B, MtlArray(A); dim=2)
    @test Array(B) ≈ cumsum(A; dims=2)
end
