@testset "sort ($T)" for T in MPSGraphs.MPSGRAPH_VALID_SORT_TYPES
    A = rand(T, 3, 4)

    for dim in 1:2
        out = similar(MtlArray(A))
        MPSGraphs.sort!(out, MtlArray(A); dims=dim)
        @test Array(out) == sort(A; dims=dim)

        MPSGraphs.sort!(out, MtlArray(A); dims=dim, rev=true)
        @test Array(out) == sort(A; dims=dim, rev=true)
    end
end

@testset "sort NaN ordering ($T)" for T in filter(T -> T <: AbstractFloat, MPSGraphs.MPSGRAPH_VALID_SORT_TYPES)
    A = T[1 NaN 2; -1 0 NaN]

    for dim in 1:2
        out = similar(MtlArray(A))
        MPSGraphs.sort!(out, MtlArray(A); dims=dim)
        @test isequal(Array(out), sort(A; dims=dim))

        index = similar(MtlArray(A), Int)
        MPSGraphs.sortperm!(index, MtlArray(A); dims=dim)
        @test Array(index) == sortperm(A; dims=dim)
        @test isequal(A[Array(index)], sort(A; dims=dim))
    end
end

@testset "sort unsupported input" begin
    A = MtlArray(Complex{Int16}[2, 1])
    @test !MPSGraphs.supports(MPSGraphs.sort!, similar(A), A)
    @test_throws ArgumentError MPSGraphs.sort!(similar(A), A)

    # `dims` is required for matrices
    A = MtlArray(rand(Float32, 3, 4))
    @test MPSGraphs.supports(MPSGraphs.sort!, similar(A), A; dims=2)
    @test !MPSGraphs.supports(MPSGraphs.sort!, similar(A), A)
    @test !MPSGraphs.supports(MPSGraphs.sort!, similar(A, 4, 3), A; dims=1)
    @test_throws DimensionMismatch MPSGraphs.sort!(similar(A, 4, 3), A; dims=1)

    # arrays are bound as MPSNDArrays, which have at most 16 dimensions
    A17 = MtlArray(rand(Float32, 2, ntuple(_ -> 1, 16)...))
    @test !MPSGraphs.supports(MPSGraphs.sort!, similar(A17), A17; dims=1)

    @test !MPSGraphs.supports(MPSGraphs.sortperm!, similar(A, Int16), A; dims=1)
    @test_throws ArgumentError MPSGraphs.sortperm!(similar(A, Int16), A; dims=1)
end

@testset "deprecated graph_sort!" begin
    A = rand(Float32, 3, 4)
    out = MtlArray{Float32}(undef, 3, 4)
    @test_deprecated MPSGraphs.graph_sort!(out, MtlArray(A); dim=2)
    @test Array(out) == sort(A; dims=2)
end

@testset "sortperm ($T)" for T in MPSGraphs.MPSGRAPH_VALID_SORT_TYPES
    A = rand(T, 3, 4)

    for dim in 1:2
        index = similar(MtlArray(A), Int)
        MPSGraphs.sortperm!(index, MtlArray(A); dims=dim)
        @test Array(index) == sortperm(A; dims=dim)
        @test A[Array(index)] == sort(A; dims=dim)

        MPSGraphs.sortperm!(index, MtlArray(A); dims=dim, rev=true)
        @test Array(index) == sortperm(A; dims=dim, rev=true)
        @test A[Array(index)] == sort(A; dims=dim, rev=true)
    end
end
