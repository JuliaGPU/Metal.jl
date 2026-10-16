using .MPSGraphs: reduce!, supports

const REDUCTION_OPS = ((+, sum), (*, prod), (max, maximum), (min, minimum))

function reduction_input(T, dims...)
    T <: Integer ? rand(T.(1:3), dims...) : T.(rand(1:30, dims...) ./ 10)
end

@testset "reduce! ($T)" for T in MPSGraphs.MPSGRAPH_VALID_REDUCTION_TYPES
    A = reduction_input(T, 3, 4, 2)
    @testset "$f, dims=$dims" for (op, f) in REDUCTION_OPS, dims in (1, 2, 3, (1, 3), (1, 2, 3))
        R = MtlArray{T}(undef, length.(Base.reduced_indices(axes(A), dims)))
        @test reduce!(op, R, MtlArray(A)) === R
        @test Array(R) ≈ reduce(op, A; dims)  # wraps around like `op`, unlike `prod`
    end
end

@testset "reduce! with init ($T)" for T in (Float32, Int64)
    A = reduction_input(T, 4, 3)
    @testset "$f" for (op, f) in REDUCTION_OPS
        init = T(2)
        R = MtlArray{T}(undef, 1, 3)
        reduce!(op, R, MtlArray(A); init)
        @test Array(R) ≈ reduce(op, A; dims=1, init)
    end

    # `init` is represented exactly, even where Float64 can't
    if T === Int64
        R = MtlArray{T}(undef, 1, 3)
        reduce!(min, R, MtlArray(A); init=typemax(Int64))
        @test Array(R) == minimum(A; dims=1)
        reduce!(min, R, MtlArray(fill(typemax(Int64), 4, 3)); init=typemax(Int64))
        @test all(==(typemax(Int64)), Array(R))
    end
end

@testset "reduce! shapes" begin
    # many dimensions, alternating between reduced and kept ones
    A = rand(Float32, 2, 3, 2, 3, 2, 3)
    for dims in ((1, 3, 5), (2, 4, 6), (1, 2, 5), (6,))
        R = MtlArray{Float32}(undef, length.(Base.reduced_indices(axes(A), dims)))
        reduce!(+, R, MtlArray(A))
        @test Array(R) ≈ sum(A; dims)
    end

    # singleton dimensions
    A = rand(Float32, 1, 5, 1, 4)
    R = MtlArray{Float32}(undef, 1, 1, 1, 4)
    reduce!(+, R, MtlArray(A))
    @test Array(R) ≈ sum(A; dims=2)

    # nothing to reduce: a copy, with `init` applied once
    A = rand(Float32, 3, 4)
    R = MtlArray{Float32}(undef, 3, 4)
    reduce!(+, R, MtlArray(A))
    @test Array(R) == A
    reduce!(+, R, MtlArray(A); init=1f0)
    @test Array(R) ≈ A .+ 1
    A_d = MtlArray(A)
    reduce!(max, A_d, A_d)
    @test Array(A_d) == A

    # which wraps around for narrow integers, also for Base's widening operators
    A = fill(Int8(120), 2)
    R = MtlArray{Int8}(undef, 2)
    reduce!(Base.add_sum, R, MtlArray(A); init=Int8(20))
    @test Array(R) == A .+ Int8(20)
    reduce!(Base.mul_prod, R, MtlArray(A); init=Int8(2))
    @test Array(R) == A .* Int8(2)
end

@testset "reduce! empty arrays" begin
    A = MtlArray{Float32}(undef, 0, 3)

    # reduced dimensions without elements
    R = MtlArray(fill(42f0, 1, 3))
    reduce!(+, R, A)
    @test Array(R) == zeros(Float32, 1, 3)
    reduce!(*, R, A)
    @test Array(R) == ones(Float32, 1, 3)
    reduce!(max, R, A; init=-1f0)
    @test Array(R) == fill(-1f0, 1, 3)
    @test !supports(reduce!, max, R, A)
    @test_throws ArgumentError reduce!(max, R, A)

    # empty output
    R = MtlArray{Float32}(undef, 0, 1)
    @test reduce!(max, R, A) === R
end

@testset "reduce! NaN" begin
    for T in (Float16, Float32)
        A = MtlArray(T[1 NaN; 2 3])
        R = MtlArray{T}(undef, 1, 2)
        reduce!(max, R, A)
        @test isequal(Array(R), T[2 NaN])
        reduce!(min, R, A)
        @test isequal(Array(R), T[1 NaN])
        reduce!(max, R, MtlArray(T[1 2; 2 3]); init=T(NaN))
        @test all(isnan, Array(R))
    end
end

@testset "reduce! ordering" begin
    # work before and after the reduction, without synchronizing in between
    A = MtlArray(ones(Float32, 512, 1000))
    R = MtlArray{Float32}(undef, 1, 1000)
    A .*= 2
    reduce!(+, R, A)
    R .+= 1
    @test all(==(1025f0), Array(R))
end

@testset "reduce! unsupported" begin
    A = MtlArray(rand(Float32, 3, 4))
    for (op, R, A, kwargs, E) in (
            # operator, element types
            (-, similar(A, 1, 4), A, (;), ArgumentError),
            (+, MtlArray{ComplexF32}(undef, 1, 2), MtlArray(rand(ComplexF32, 3, 2)), (;), ArgumentError),
            (+, MtlArray{Bool}(undef, 1, 2), MtlArray(rand(Bool, 3, 2)), (;), ArgumentError),
            (+, similar(A, Float16, 1, 4), A, (;), ArgumentError),
            (+, similar(A, 1, 4), A, (; init=0), ArgumentError),
            # shapes
            (+, similar(A, 2, 4), A, (;), DimensionMismatch),
            (+, similar(A, 4), A, (;), DimensionMismatch),
            # array types
            (+, zeros(Float32, 1, 4), A, (;), ArgumentError),
            (+, similar(A, 1, 4), Array(A), (;), ArgumentError),
        )
        @test !supports(reduce!, op, R, A; kwargs...)
        @test_throws E reduce!(op, R, A; kwargs...)
    end
    @test supports(reduce!, +, similar(A, 1, 4), A)
end

@testset "deprecated graph_mapreducedim!" begin
    A = rand(Float32, 3, 4)
    R = MtlArray{Float32}(undef, 1, 4)
    @test_deprecated MPSGraphs.graph_mapreducedim!(+, R, MtlArray(A))
    @test Array(R) ≈ sum(A; dims=1)
end
