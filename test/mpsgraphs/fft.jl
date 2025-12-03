using FFTW
using AbstractFFTs

if MPS.is_supported(device())

# ============================================================================
# Complex FFT Tests
# ============================================================================

@testset "FFT" begin
    @testset "plan_fft basic" begin
        x_cpu = randn(ComplexF32, 64, 64)
        x_gpu = MtlArray(x_cpu)

        plan = plan_fft(x_gpu)
        y_gpu = plan * x_gpu

        @test y_gpu isa MtlArray{ComplexF32}
        @test size(y_gpu) == size(x_gpu)
    end

    @testset "fft correctness vs FFTW" begin
        # 2D FFT
        for sz in [(32, 32), (64, 64), (128, 128), (64, 128)]
            @testset "size $sz" begin
                x_cpu = randn(ComplexF32, sz...)
                x_gpu = MtlArray(x_cpu)

                y_cpu = fft(x_cpu)
                y_gpu = Array(fft(x_gpu))

                @test isapprox(y_cpu, y_gpu, rtol=1e-4)
            end
        end
    end

    @testset "ifft correctness vs FFTW" begin
        for sz in [(32, 32), (64, 64)]
            @testset "size $sz" begin
                x_cpu = randn(ComplexF32, sz...)
                x_gpu = MtlArray(x_cpu)

                y_cpu = ifft(x_cpu)
                y_gpu = Array(ifft(x_gpu))

                @test isapprox(y_cpu, y_gpu, rtol=1e-4)
            end
        end
    end

    @testset "bfft correctness vs FFTW" begin
        for sz in [(32, 32), (64, 64)]
            @testset "size $sz" begin
                x_cpu = randn(ComplexF32, sz...)
                x_gpu = MtlArray(x_cpu)

                y_cpu = bfft(x_cpu)
                y_gpu = Array(bfft(x_gpu))

                @test isapprox(y_cpu, y_gpu, rtol=1e-4)
            end
        end
    end

    @testset "single axis FFT" begin
        x_cpu = randn(ComplexF32, 64, 128)
        x_gpu = MtlArray(x_cpu)

        # FFT along dimension 1
        y_cpu_1 = fft(x_cpu, 1)
        y_gpu_1 = Array(fft(x_gpu, 1))
        @test isapprox(y_cpu_1, y_gpu_1, rtol=1e-4)

        # FFT along dimension 2
        y_cpu_2 = fft(x_cpu, 2)
        y_gpu_2 = Array(fft(x_gpu, 2))
        @test isapprox(y_cpu_2, y_gpu_2, rtol=1e-4)
    end

    @testset "multi-axis FFT" begin
        x_cpu = randn(ComplexF32, 32, 32, 8)
        x_gpu = MtlArray(x_cpu)

        # FFT along dimensions (1,2)
        y_cpu = fft(x_cpu, (1, 2))
        y_gpu = Array(fft(x_gpu, (1, 2)))

        @test isapprox(y_cpu, y_gpu, rtol=1e-4)
    end

    @testset "3D FFT" begin
        x_cpu = randn(ComplexF32, 16, 16, 16)
        x_gpu = MtlArray(x_cpu)

        y_cpu = fft(x_cpu)
        y_gpu = Array(fft(x_gpu))

        @test isapprox(y_cpu, y_gpu, rtol=1e-4)
    end

    @testset "roundtrip fft -> ifft" begin
        x_cpu = randn(ComplexF32, 64, 64)
        x_gpu = MtlArray(x_cpu)

        y_gpu = ifft(fft(x_gpu))

        @test isapprox(x_cpu, Array(y_gpu), rtol=1e-4)
    end

    @testset "plan reuse" begin
        x1 = MtlArray(randn(ComplexF32, 64, 64))
        x2 = MtlArray(randn(ComplexF32, 64, 64))

        plan = plan_fft(x1)

        y1 = plan * x1
        y2 = plan * x2

        @test isapprox(Array(y1), fft(Array(x1)), rtol=1e-4)
        @test isapprox(Array(y2), fft(Array(x2)), rtol=1e-4)
    end

    @testset "mul! interface" begin
        x = MtlArray(randn(ComplexF32, 64, 64))
        y = similar(x)

        plan = plan_fft(x)
        mul!(y, plan, x)

        @test isapprox(Array(y), fft(Array(x)), rtol=1e-4)
    end

    @testset "type restrictions" begin
        # ComplexF64 should error
        x64 = MtlArray(randn(ComplexF64, 32, 32))
        @test_throws ArgumentError plan_fft(x64)

        # ComplexF32 should work
        x32 = MtlArray(randn(ComplexF32, 32, 32))
        @test plan_fft(x32) isa MPSGraphs.MtlFFTPlan
    end

    @testset "invalid dimension" begin
        x = MtlArray(randn(ComplexF32, 32, 32))
        @test_throws ArgumentError plan_fft(x, 3)  # Only 2 dimensions
        @test_throws ArgumentError plan_fft(x, 0)  # Invalid dimension
    end
end

# ============================================================================
# Real FFT Tests
# ============================================================================

@testset "Real FFT" begin
    @testset "rfft basic" begin
        x_cpu = randn(Float32, 64, 32)
        x_gpu = MtlArray(x_cpu)

        y_gpu = rfft(x_gpu)

        @test y_gpu isa MtlArray{ComplexF32}
        @test size(y_gpu) == (33, 32)  # First dim reduced to n÷2+1
    end

    @testset "rfft correctness vs FFTW" begin
        for sz in [(64, 64), (128, 64), (64, 128)]
            @testset "size $sz" begin
                x_cpu = randn(Float32, sz...)
                x_gpu = MtlArray(x_cpu)

                y_cpu = rfft(x_cpu)
                y_gpu = Array(rfft(x_gpu))

                @test size(y_gpu) == size(y_cpu)
                @test isapprox(y_cpu, y_gpu, rtol=1e-4)
            end
        end
    end

    @testset "rfft single axis" begin
        x_cpu = randn(Float32, 64, 128)
        x_gpu = MtlArray(x_cpu)

        # rfft along dimension 1
        y_cpu_1 = rfft(x_cpu, 1)
        y_gpu_1 = Array(rfft(x_gpu, 1))
        @test size(y_gpu_1) == size(y_cpu_1)
        @test isapprox(y_cpu_1, y_gpu_1, rtol=1e-4)

        # rfft along dimension 2
        y_cpu_2 = rfft(x_cpu, 2)
        y_gpu_2 = Array(rfft(x_gpu, 2))
        @test size(y_gpu_2) == size(y_cpu_2)
        @test isapprox(y_cpu_2, y_gpu_2, rtol=1e-4)
    end

    @testset "irfft correctness vs FFTW" begin
        x_cpu = randn(Float32, 64, 64)
        y_cpu = rfft(x_cpu)
        y_gpu = MtlArray(y_cpu)

        z_cpu = irfft(y_cpu, 64)
        z_gpu = Array(irfft(y_gpu, 64))

        @test size(z_gpu) == size(z_cpu)
        @test isapprox(z_cpu, z_gpu, rtol=1e-4)
    end

    @testset "roundtrip rfft -> irfft" begin
        x_cpu = randn(Float32, 64, 64)
        x_gpu = MtlArray(x_cpu)

        y_gpu = rfft(x_gpu)
        z_gpu = irfft(y_gpu, 64)

        @test isapprox(x_cpu, Array(z_gpu), rtol=1e-4)
    end

    @testset "brfft correctness vs FFTW" begin
        # Single axis
        x_cpu = randn(Float32, 64, 32)
        y_cpu = rfft(x_cpu, 1)
        y_gpu = MtlArray(y_cpu)

        z_cpu = brfft(y_cpu, 64, 1)
        z_gpu = Array(brfft(y_gpu, 64, 1))

        @test isapprox(z_cpu, z_gpu, rtol=1e-3)
    end

    @testset "irfft odd output size" begin
        x_cpu = randn(Float32, 63, 64)  # odd first dimension
        y_cpu = rfft(x_cpu, 1)
        y_gpu = MtlArray(y_cpu)

        z_cpu = irfft(y_cpu, 63, 1)
        z_gpu = Array(irfft(y_gpu, 63, 1))

        @test size(z_gpu) == (63, 64)
        @test isapprox(z_cpu, z_gpu, rtol=1e-4)
    end

    @testset "type restrictions" begin
        # Float64 should error
        x64 = MtlArray(randn(Float64, 32, 32))
        @test_throws ArgumentError plan_rfft(x64)

        # Float32 should work
        x32 = MtlArray(randn(Float32, 32, 32))
        @test plan_rfft(x32) isa MPSGraphs.MtlRFFTPlan
    end
end

end # MPS.is_supported(device())
