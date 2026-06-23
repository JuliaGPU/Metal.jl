@testset "reductions ($T)" for T in MPSGraphs.MPSGRAPH_VALID_REDUCTION_TYPES
    A = if T <: Integer
        rand(T.(1:3), 3, 4, 2)
    else
        reshape(T.(1:24) ./ T(10), 3, 4, 2)
    end

    for dim in 1:3
        out_size = Base.setindex(size(A), 1, dim)

        out = similar(MtlArray(A), out_size)
        MPSGraphs.graph_mapreducedim!(+, out, MtlArray(A))
        @test Array(out) ≈ sum(A; dims=dim)

        out = similar(MtlArray(A), out_size)
        MPSGraphs.graph_mapreducedim!(*, out, MtlArray(A))
        @test Array(out) ≈ prod(A; dims=dim)

        out = similar(MtlArray(A), out_size)
        MPSGraphs.graph_mapreducedim!(max, out, MtlArray(A))
        @test Array(out) ≈ maximum(A; dims=dim)

        out = similar(MtlArray(A), out_size)
        MPSGraphs.graph_mapreducedim!(min, out, MtlArray(A))
        @test Array(out) ≈ minimum(A; dims=dim)
    end
end

@testset "reduction unsupported input" begin
    # unsupported input types
    A = MtlArray(reshape(Complex{Int32}.(1:6), 3, 2))
    out = similar(A, (1, 2))
    @test_throws ArgumentError MPSGraphs.graph_mapreducedim!(+, out, A)

    # offset input
    parent = MtlArray(Float32[1, 2, 3])
    offset_input = unsafe_wrap(MtlArray, pointer(parent, 2), 2)
    offset_out = similar(offset_input, (1,))
    @test_throws ArgumentError MPSGraphs.graph_mapreducedim!(+, offset_out,
                                                             offset_input)
end
