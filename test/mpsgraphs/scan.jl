@testset "scan ($T)" for T in MPSGraphs.MPSGRAPH_VALID_SCAN_TYPES
    A, ops = if T <: Integer
        rand(T.(1:3), 3, 4), (+, *, min, max)
    else
        reshape(T[2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37], 3, 4), (+, *)
    end

    for op in ops, dim in 1:2
        out = similar(MtlArray(A))
        MPSGraphs.graph_scan!(op, out, MtlArray(A); dim)
        @test Array(out) ≈ accumulate(op, A; dims=dim)
    end
end

@testset "scan unsupported input" begin
    # unsupported input
    A = MtlArray(Complex{Int32}[1, 2])
    @test_throws ArgumentError MPSGraphs.graph_scan!(+, similar(A), A)

    # offset input
    parent = MtlArray(Float32[1, 2, 3])
    offset_input = unsafe_wrap(MtlArray, pointer(parent, 2), 2)
    @test_throws ArgumentError MPSGraphs.graph_scan!(+, similar(offset_input),
                                                     offset_input)
end
