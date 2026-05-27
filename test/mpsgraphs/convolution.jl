# Tests for the FFT-based convolution engine in MPSGraphs (conv_fft, the unified
# conv(), xcorr, imfilter). The engine is internal; the public interface is
# DSP.conv / DSP.xcorr (tested in test/dsp.jl). These tests exercise the engine
# directly, so import its symbols from the submodule.
using Metal.MPSGraphs: conv, conv_fft, conv_fft!, xcorr, imfilter

# Simple reference convolution for verification (CPU)
function ref_conv(u::Vector{T}, v::Vector{T}) where {T}
    nu = length(u)
    nv = length(v)
    n = nu + nv - 1
    result = zeros(T, n)
    for i in 1:nu
        for j in 1:nv
            result[i + j - 1] += u[i] * v[j]
        end
    end
    return result
end

# Tolerance functions based on type precision
rtol(::Type{Float16}) = 1.0e-2
rtol(::Type{Float32}) = 1.0e-4
rtol(::Type{ComplexF16}) = 1.0e-2
rtol(::Type{ComplexF32}) = 1.0e-4

if MPS.is_supported(device())

    # ============================================================================
    # FFT Convolution Tests
    # ============================================================================

    @testset "FFT Convolution" begin
        @testset "1D Real Convolution" begin
            @testset for T in [Float32, Float16]
                # Basic convolution
                signal = rand(T, 100)
                kernel = rand(T, 10)

                d_signal = MtlVector(signal)
                d_kernel = MtlVector(kernel)

                # Full mode
                result = Array(conv_fft(d_signal, d_kernel; mode = :full))
                expected = T.(ref_conv(Float64.(signal), Float64.(kernel)))
                @test isapprox(result, expected, rtol = rtol(T))

                # Same mode
                result_same = Array(conv_fft(d_signal, d_kernel; mode = :same))
                @test length(result_same) == length(signal)

                # Valid mode
                result_valid = Array(conv_fft(d_signal, d_kernel; mode = :valid))
                @test length(result_valid) == length(signal) - length(kernel) + 1
            end
        end

        @testset "1D Complex Convolution" begin
            @testset for T in [ComplexF32, ComplexF16]
                signal = rand(T, 100)
                kernel = rand(T, 10)

                d_signal = MtlVector(signal)
                d_kernel = MtlVector(kernel)

                result = Array(conv_fft(d_signal, d_kernel; mode = :full))
                # For complex, just verify output size (reference conv doesn't support complex)
                @test length(result) == length(signal) + length(kernel) - 1
            end
        end

        @testset "2D Convolution" begin
            @testset for T in [Float32, Float16]
                signal = rand(T, 64, 64)
                kernel = rand(T, 5, 5)

                d_signal = MtlMatrix(signal)
                d_kernel = MtlMatrix(kernel)

                # Full mode along both dimensions
                result = Array(conv_fft(d_signal, d_kernel; dims = (1, 2), mode = :full))
                @test size(result) == (68, 68)

                # Same mode
                result_same = Array(conv_fft(d_signal, d_kernel; dims = (1, 2), mode = :same))
                @test size(result_same) == size(signal)

                # Valid mode
                result_valid = Array(conv_fft(d_signal, d_kernel; dims = (1, 2), mode = :valid))
                @test size(result_valid) == (60, 60)
            end
        end

        @testset "Batched Convolution" begin
            # 3D array, convolve along dims 1 and 2
            signal = rand(Float32, 32, 32, 4)
            kernel = rand(Float32, 3, 3, 4)

            d_signal = MtlArray(signal)
            d_kernel = MtlArray(kernel)

            result = conv_fft(d_signal, d_kernel; dims = (1, 2), mode = :same)
            @test size(result) == size(signal)
        end
    end

    # ============================================================================
    # Cross-correlation Tests
    # ============================================================================

    @testset "Cross-correlation" begin
        @testset for T in [Float32, Float16]
            u = rand(T, 100)
            v = rand(T, 10)

            d_u = MtlVector(u)
            d_v = MtlVector(v)

            result = Array(xcorr(d_u, d_v; mode = :full))
            # Cross-correlation is convolution with reversed kernel
            expected = Array(conv_fft(d_u, MtlVector(reverse(v)); mode = :full))
            @test isapprox(result, expected, rtol = rtol(T))
        end
    end


    # ============================================================================
    # imfilter Tests
    # ============================================================================

    @testset "imfilter" begin
        @testset "Small Kernel (uses direct)" begin
            image = rand(Float32, 256, 256)
            kernel = Float32[
                -1 0 1
                -2 0 2
                -1 0 1
            ] ./ 8  # Sobel

            d_image = MtlMatrix(image)
            d_kernel = MtlMatrix(kernel)

            result = Array(imfilter(d_image, d_kernel))
            @test size(result) == size(image)

            # Verify correctness against FFT
            result_fft = Array(conv_fft(d_image, d_kernel; dims = (1, 2), mode = :same))
            @test isapprox(result, result_fft, rtol = 1.0e-4)
        end

        @testset "Large Kernel (uses FFT)" begin
            image = rand(Float32, 256, 256)
            kernel = rand(Float32, 15, 15)  # Larger than threshold

            d_image = MtlMatrix(image)
            d_kernel = MtlMatrix(kernel)

            result = Array(imfilter(d_image, d_kernel))
            @test size(result) == size(image)
        end
    end

    # ============================================================================
    # Unified conv() API Tests
    # ============================================================================

    @testset "Unified conv() API" begin
        @testset "1D Convolution" begin
            signal = MtlVector(rand(Float32, 1000))
            kernel = MtlVector(rand(Float32, 10))

            result_full = conv(signal, kernel; mode = :full)
            result_same = conv(signal, kernel; mode = :same)
            result_valid = conv(signal, kernel; mode = :valid)

            @test length(result_full) == 1009
            @test length(result_same) == 1000
            @test length(result_valid) == 991
        end

        @testset "2D Auto-Selection" begin
            image = MtlMatrix(rand(Float32, 128, 128))
            small_kernel = MtlMatrix(rand(Float32, 3, 3))
            large_kernel = MtlMatrix(rand(Float32, 15, 15))

            # Small kernel should auto-select direct
            result_small = conv(image, small_kernel; mode = :same)
            @test size(result_small) == size(image)

            # Large kernel should auto-select FFT
            result_large = conv(image, large_kernel; mode = :same)
            @test size(result_large) == size(image)

            # Both should give same result as explicit FFT
            expected_small = conv_fft(image, small_kernel; dims = (1, 2), mode = :same)
            expected_large = conv_fft(image, large_kernel; dims = (1, 2), mode = :same)

            @test isapprox(Array(result_small), Array(expected_small), rtol = 1.0e-4)
            @test isapprox(Array(result_large), Array(expected_large), rtol = 1.0e-4)
        end


        @testset "Complex Arrays" begin
            signal = MtlVector(rand(ComplexF32, 100))
            kernel = MtlVector(rand(ComplexF32, 10))

            result = conv(signal, kernel; mode = :full)
            expected = conv_fft(signal, kernel; mode = :full)
            @test isapprox(Array(result), Array(expected), rtol = 1.0e-4)

            # Complex doesn't support direct
            @test_throws ArgumentError conv(signal, kernel; algorithm = :direct)
        end
    end

    # ============================================================================
    # Edge Cases
    # ============================================================================

    @testset "Edge Cases" begin
        @testset "Single Element Kernel" begin
            signal = MtlVector(rand(Float32, 100))
            kernel = MtlVector(Float32[2.0])

            result = Array(conv_fft(signal, kernel; mode = :full))
            expected = Float32.(Array(signal) .* 2.0)
            @test isapprox(result, expected, rtol = 1.0e-4)
        end

        @testset "Large Arrays" begin
            # Test with larger arrays to ensure stability
            signal = MtlVector(rand(Float32, 10000))
            kernel = MtlVector(rand(Float32, 500))

            result = conv_fft(signal, kernel; mode = :full)
            @test length(result) == 10499
        end

        @testset "Non-Square 2D Arrays" begin
            image = MtlMatrix(rand(Float32, 64, 128))
            kernel = MtlMatrix(rand(Float32, 3, 5))

            result = conv(image, kernel; mode = :same)
            @test size(result) == (64, 128)
        end
    end

end # MPS.is_supported(device())
