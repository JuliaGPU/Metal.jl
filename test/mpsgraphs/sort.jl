@testset "sort ($T)" for T in (Float16, Float32, Int32)
    A = reshape(T[7, 2, 5, 4, 9, 1, 6, 3, 8, 0, 10, 11], 3, 4)

    for dim in 1:2
        out = similar(MtlArray(A))
        MPSGraphs.graph_sort!(out, MtlArray(A); dim)
        @test Array(out) == sort(A; dims=dim)

        MPSGraphs.graph_sort!(out, MtlArray(A); dim, rev=true)
        @test Array(out) == sort(A; dims=dim, rev=true)
    end
end

@testset "sort unsupported input" begin
    A = MtlArray(Int16[2, 1])
    out = similar(A)
    @test_throws ArgumentError MPSGraphs.graph_sort!(out, A)

    parent = MtlArray(Float32[3, 2, 1])
    offset_input = unsafe_wrap(MtlArray, pointer(parent, 2), 2)
    @test_throws ArgumentError MPSGraphs.graph_sort!(similar(offset_input), offset_input)
end

@testset "sortperm ($T)" for T in (Float16, Float32, Int32)
    A = reshape(T[7, 2, 5, 4, 9, 1, 6, 3, 8, 0, 10, 11], 3, 4)

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
