using DSP

# Public interface for GPU convolution: DSP.conv / DSP.xcorr on MtlArrays, provided
# by the MetalDSPExt package extension. The underlying engine (modes, dims, direct
# path, plan caching) is tested in mpsgraphs/convolution.jl.

@testset "DSP.conv" begin
    @testset "1-D" begin
        a = rand(Float32, 64)
        b = rand(Float32, 7)
        @test Array(conv(MtlArray(a), MtlArray(b))) ≈ conv(a, b) rtol = 1.0f-3
    end

    @testset "2-D" begin
        a = rand(Float32, 16, 16)
        b = rand(Float32, 3, 3)
        @test Array(conv(MtlArray(a), MtlArray(b))) ≈ conv(a, b) rtol = 1.0f-2
    end

    @testset "3-D" begin
        a = rand(Float32, 8, 8, 8)
        b = rand(Float32, 3, 3, 3)
        @test Array(conv(MtlArray(a), MtlArray(b))) ≈ conv(a, b) rtol = 1.0f-2
    end

    @testset "algorithm = :fft" begin
        a = rand(Float32, 32, 32)
        b = rand(Float32, 5, 5)
        @test Array(conv(MtlArray(a), MtlArray(b); algorithm = :fft)) ≈ conv(a, b) rtol = 1.0f-2
    end
end

@testset "DSP.xcorr" begin
    u = rand(Float32, 32)
    v = rand(Float32, 20)
    @test Array(xcorr(MtlArray(u), MtlArray(v))) ≈ xcorr(u, v) rtol = 1.0f-3
end

@testset "unsupported inputs" begin
    # Unsupported element types error clearly instead of a silent slow CPU fallback.
    @test_throws ArgumentError conv(MtlArray(rand(Int32, 16)), MtlArray(rand(Int32, 4)))
    # xcorr supports only padmode = :none and scaling = :none.
    u = MtlVector(rand(Float32, 16))
    v = MtlVector(rand(Float32, 8))
    @test_throws ArgumentError xcorr(u, v; padmode = :longest)
    @test_throws ArgumentError xcorr(u, v; scaling = :biased)
end

@testset "graph cache is bounded" begin
    Metal.MPSGraphs.clear_fused_conv_cache!()
    for n in 100:140  # 41 distinct sizes, cap is 32
        conv(MtlVector(rand(Float32, n)), MtlVector(rand(Float32, 5)))
    end
    @test length(Metal.MPSGraphs._fused_conv_graph_cache) <= 32
    @test length(Metal.MPSGraphs._fused_conv_buffer_pool) <= 32
end
