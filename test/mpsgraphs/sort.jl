@testset "sort ($T)" for T in MPSGraphs.MPSGRAPH_VALID_SORT_TYPES
    A = rand(T, 3, 4)

    for dim in 1:2
        out = similar(MtlArray(A))
        MPSGraphs.graph_sort!(out, MtlArray(A); dim)
        @test Array(out) == sort(A; dims=dim)

        MPSGraphs.graph_sort!(out, MtlArray(A); dim, rev=true)
        @test Array(out) == sort(A; dims=dim, rev=true)
    end
end

@testset "sort NaN ordering ($T)" for T in filter(T -> T <: AbstractFloat, MPSGraphs.MPSGRAPH_VALID_SORT_TYPES)
    A = T[1 NaN 2; -1 0 NaN]

    for dim in 1:2
        out = similar(MtlArray(A))
        MPSGraphs.graph_sort!(out, MtlArray(A); dim)
        @test isequal(Array(out), sort(A; dims=dim))

        index = similar(MtlArray(A), Int)
        MPSGraphs.graph_sortperm!(index, MtlArray(A); dim)
        @test Array(index) == sortperm(A; dims=dim)
        @test isequal(A[Array(index)], sort(A; dims=dim))
    end
end

@testset "sort unsupported input" begin
    # unsupported input types
    A = MtlArray(Complex{Int16}[2, 1])
    out = similar(A)
    @test_throws ArgumentError MPSGraphs.graph_sort!(out, A)

    # offset input
    parent = MtlArray(Float32[3, 2, 1])
    offset_input = unsafe_wrap(MtlArray, pointer(parent, 2), 2)
    @test_throws ArgumentError MPSGraphs.graph_sort!(similar(offset_input), offset_input)
end

@testset "sortperm ($T)" for T in MPSGraphs.MPSGRAPH_VALID_SORT_TYPES
    A = rand(T, 3, 4)

    for dim in 1:2
        index = similar(MtlArray(A), Int)
        MPSGraphs.graph_sortperm!(index, MtlArray(A); dim)
        @test Array(index) == sortperm(A; dims=dim)
        @test A[Array(index)] == sort(A; dims=dim)

        MPSGraphs.graph_sortperm!(index, MtlArray(A); dim, rev=true)
        @test Array(index) == sortperm(A; dims=dim, rev=true)
        @test A[Array(index)] == sort(A; dims=dim, rev=true)
    end
end
