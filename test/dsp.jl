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
