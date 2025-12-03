using FFTW
using AbstractFFTs

if MPS.is_supported(device())

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

end # MPS.is_supported(device())
