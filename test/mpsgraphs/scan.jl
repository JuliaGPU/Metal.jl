@testset "scan ($T)" for T in (Float16, Float32)
    A = reshape(T[2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37], 3, 4)

    for op in (+, *), dim in 1:2
        out = similar(MtlArray(A))
        MPSGraphs.graph_scan!(op, out, MtlArray(A); dim)
        @test Array(out) ≈ accumulate(op, A; dims=dim)
    end
end

@testset "scan unsupported input" begin
    A = MtlArray(Int32[1, 2])
    @test_throws ArgumentError MPSGraphs.graph_scan!(+, similar(A), A)

    B = MtlArray(Float32[1, 2])
    @test_throws ArgumentError MPSGraphs.graph_scan!(max, similar(B), B)
    @test_throws ArgumentError MPSGraphs.graph_scan!(min, similar(B), B)

    parent = MtlArray(Float32[1, 2, 3])
    offset_input = unsafe_wrap(MtlArray, pointer(parent, 2), 2)
    @test_throws ArgumentError MPSGraphs.graph_scan!(+, similar(offset_input),
                                                     offset_input)
end
