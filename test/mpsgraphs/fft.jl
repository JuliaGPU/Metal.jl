using FFTW
using AbstractFFTs
using LinearAlgebra: mul!
# Alias for GPU fft with shift support
const mtl_fft = Metal.MPSGraphs.fft
const mtl_ifft = Metal.MPSGraphs.ifft
const mtl_bfft = Metal.MPSGraphs.bfft
const mtl_fft! = Metal.MPSGraphs.fft!
const mtl_ifft! = Metal.MPSGraphs.ifft!
const mtl_bfft! = Metal.MPSGraphs.bfft!

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

                    @test isapprox(y_cpu, y_gpu, rtol = 1.0e-4)
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

                    @test isapprox(y_cpu, y_gpu, rtol = 1.0e-4)
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

                    @test isapprox(y_cpu, y_gpu, rtol = 1.0e-4)
                end
            end
        end

        @testset "single axis FFT" begin
            x_cpu = randn(ComplexF32, 64, 128)
            x_gpu = MtlArray(x_cpu)

            # FFT along dimension 1
            y_cpu_1 = fft(x_cpu, 1)
            y_gpu_1 = Array(fft(x_gpu, 1))
            @test isapprox(y_cpu_1, y_gpu_1, rtol = 1.0e-4)

            # FFT along dimension 2
            y_cpu_2 = fft(x_cpu, 2)
            y_gpu_2 = Array(fft(x_gpu, 2))
            @test isapprox(y_cpu_2, y_gpu_2, rtol = 1.0e-4)
        end

        @testset "multi-axis FFT" begin
            x_cpu = randn(ComplexF32, 32, 32, 8)
            x_gpu = MtlArray(x_cpu)

            # FFT along dimensions (1,2)
            y_cpu = fft(x_cpu, (1, 2))
            y_gpu = Array(fft(x_gpu, (1, 2)))

            @test isapprox(y_cpu, y_gpu, rtol = 1.0e-4)
        end

        @testset "3D FFT" begin
            x_cpu = randn(ComplexF32, 16, 16, 16)
            x_gpu = MtlArray(x_cpu)

            y_cpu = fft(x_cpu)
            y_gpu = Array(fft(x_gpu))

            @test isapprox(y_cpu, y_gpu, rtol = 1.0e-4)
        end

        @testset "roundtrip fft -> ifft" begin
            x_cpu = randn(ComplexF32, 64, 64)
            x_gpu = MtlArray(x_cpu)

            y_gpu = ifft(fft(x_gpu))

            @test isapprox(x_cpu, Array(y_gpu), rtol = 1.0e-4)
        end

        @testset "plan reuse" begin
            x1 = MtlArray(randn(ComplexF32, 64, 64))
            x2 = MtlArray(randn(ComplexF32, 64, 64))

            plan = plan_fft(x1)

            y1 = plan * x1
            y2 = plan * x2

            @test isapprox(Array(y1), fft(Array(x1)), rtol = 1.0e-4)
            @test isapprox(Array(y2), fft(Array(x2)), rtol = 1.0e-4)
        end

        @testset "mul! interface" begin
            x = MtlArray(randn(ComplexF32, 64, 64))
            y = similar(x)

            plan = plan_fft(x)
            mul!(y, plan, x)

            @test isapprox(Array(y), fft(Array(x)), rtol = 1.0e-4)
        end

        @testset "type restrictions" begin
            # ComplexF32 should work
            x32 = MtlArray(randn(ComplexF32, 32, 32))
            @test plan_fft(x32) isa MPSGraphs.MtlFFTPlan

            # ComplexF16 should also work
            x16 = MtlArray(ComplexF16.(randn(ComplexF32, 32, 32)))
            @test plan_fft(x16) isa MPSGraphs.MtlFFTPlan
        end

        @testset "ComplexF16 correctness" begin
            # ComplexF16 FFT should produce reasonable results
            x16 = MtlArray(ComplexF16.(randn(ComplexF32, 32, 32)))
            x32 = MtlArray(ComplexF32.(Array(x16)))

            y16 = Array(fft(x16))
            y32 = Array(fft(x32))

            # Float16 has ~3 decimal digits precision, so allow larger tolerance
            @test isapprox(ComplexF32.(y16), y32, rtol = 0.1)
        end

        @testset "invalid dimension" begin
            x = MtlArray(randn(ComplexF32, 32, 32))
            @test_throws ArgumentError plan_fft(x, 3)  # Only 2 dimensions
            @test_throws ArgumentError plan_fft(x, 0)  # Invalid dimension
        end

        @testset "1D FFT" begin
            x_cpu = randn(ComplexF32, 64)
            x_gpu = MtlArray(x_cpu)

            y_cpu = fft(x_cpu)
            y_gpu = Array(fft(x_gpu))

            @test size(y_gpu) == (64,)
            @test isapprox(y_cpu, y_gpu, rtol = 1.0e-4)
        end

        @testset "1D ifft roundtrip" begin
            x_cpu = randn(ComplexF32, 128)
            x_gpu = MtlArray(x_cpu)

            y_gpu = ifft(fft(x_gpu))

            @test isapprox(x_cpu, Array(y_gpu), rtol = 1.0e-4)
        end
    end

    # ============================================================================
    # In-Place FFT Tests
    # ============================================================================

    @testset "In-Place FFT" begin
        @testset "fft! basic" begin
            x_cpu = randn(ComplexF32, 64, 64)
            x_gpu = MtlArray(copy(x_cpu))

            plan = plan_fft!(x_gpu)
            result = plan * x_gpu

            @test result === x_gpu  # Should return the same array
            @test isapprox(fft(x_cpu), Array(x_gpu), rtol = 1.0e-4)
        end

        @testset "ifft!" begin
            x_cpu = randn(ComplexF32, 64, 64)
            x_gpu = MtlArray(copy(x_cpu))

            plan = plan_ifft!(x_gpu)
            plan * x_gpu

            @test isapprox(ifft(x_cpu), Array(x_gpu), rtol = 1.0e-4)
        end

        @testset "bfft!" begin
            x_cpu = randn(ComplexF32, 64, 64)
            x_gpu = MtlArray(copy(x_cpu))

            plan = plan_bfft!(x_gpu)
            plan * x_gpu

            @test isapprox(bfft(x_cpu), Array(x_gpu), rtol = 1.0e-3)
        end

        @testset "fft! -> ifft! roundtrip" begin
            x_orig = randn(ComplexF32, 64, 64)
            x_gpu = MtlArray(copy(x_orig))

            plan_fwd = plan_fft!(x_gpu)
            plan_fwd * x_gpu

            plan_inv = plan_ifft!(x_gpu)
            plan_inv * x_gpu

            @test isapprox(x_orig, Array(x_gpu), rtol = 1.0e-4)
        end

        @testset "single axis fft!" begin
            x_cpu = randn(ComplexF32, 64, 128)
            x_gpu = MtlArray(copy(x_cpu))

            plan = plan_fft!(x_gpu, 2)
            plan * x_gpu

            @test isapprox(fft(x_cpu, 2), Array(x_gpu), rtol = 1.0e-4)
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
                    @test isapprox(y_cpu, y_gpu, rtol = 1.0e-4)
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
            @test isapprox(y_cpu_1, y_gpu_1, rtol = 1.0e-4)

            # rfft along dimension 2
            y_cpu_2 = rfft(x_cpu, 2)
            y_gpu_2 = Array(rfft(x_gpu, 2))
            @test size(y_gpu_2) == size(y_cpu_2)
            @test isapprox(y_cpu_2, y_gpu_2, rtol = 1.0e-4)
        end

        @testset "irfft correctness vs FFTW" begin
            x_cpu = randn(Float32, 64, 64)
            y_cpu = rfft(x_cpu)
            y_gpu = MtlArray(y_cpu)

            z_cpu = irfft(y_cpu, 64)
            z_gpu = Array(irfft(y_gpu, 64))

            @test size(z_gpu) == size(z_cpu)
            @test isapprox(z_cpu, z_gpu, rtol = 1.0e-4)
        end

        @testset "roundtrip rfft -> irfft" begin
            x_cpu = randn(Float32, 64, 64)
            x_gpu = MtlArray(x_cpu)

            y_gpu = rfft(x_gpu)
            z_gpu = irfft(y_gpu, 64)

            @test isapprox(x_cpu, Array(z_gpu), rtol = 1.0e-4)
        end

        @testset "brfft correctness vs FFTW" begin
            # Single axis
            x_cpu = randn(Float32, 64, 32)
            y_cpu = rfft(x_cpu, 1)
            y_gpu = MtlArray(y_cpu)

            z_cpu = brfft(y_cpu, 64, 1)
            z_gpu = Array(brfft(y_gpu, 64, 1))

            @test isapprox(z_cpu, z_gpu, rtol = 1.0e-3)
        end

        @testset "irfft odd output size" begin
            x_cpu = randn(Float32, 63, 64)  # odd first dimension
            y_cpu = rfft(x_cpu, 1)
            y_gpu = MtlArray(y_cpu)

            z_cpu = irfft(y_cpu, 63, 1)
            z_gpu = Array(irfft(y_gpu, 63, 1))

            @test size(z_gpu) == (63, 64)
            @test isapprox(z_cpu, z_gpu, rtol = 1.0e-4)
        end

        @testset "type restrictions" begin
            # Float32 should work
            x32 = MtlArray(randn(Float32, 32, 32))
            @test plan_rfft(x32) isa MPSGraphs.MtlRFFTPlan

            # Float16 should also work
            x16 = MtlArray(Float16.(randn(Float32, 32, 32)))
            @test plan_rfft(x16) isa MPSGraphs.MtlRFFTPlan
        end

        @testset "1D rfft" begin
            x_cpu = randn(Float32, 64)
            x_gpu = MtlArray(x_cpu)

            y_cpu = rfft(x_cpu)
            y_gpu = Array(rfft(x_gpu))

            @test size(y_gpu) == (33,)  # n÷2+1
            @test isapprox(y_cpu, y_gpu, rtol = 1.0e-4)
        end

        @testset "1D rfft -> irfft roundtrip" begin
            x_cpu = randn(Float32, 128)
            x_gpu = MtlArray(x_cpu)

            y_gpu = rfft(x_gpu)
            z_gpu = irfft(y_gpu, 128)

            @test isapprox(x_cpu, Array(z_gpu), rtol = 1.0e-4)
        end
    end

    # ============================================================================
    # Fused fftshift Tests
    # ============================================================================

    @testset "Fused fftshift" begin
        @testset "fft with shift=true vs fftshift(fft(x))" begin
            # Test 1D
            x_cpu = randn(ComplexF32, 128)
            x_gpu = MtlArray(x_cpu)

            expected = fftshift(fft(x_cpu))
            result_gpu = Array(mtl_fft(x_gpu; shift = true))

            @test isapprox(expected, result_gpu, rtol = 1.0e-4)

            # Test 2D
            x_cpu_2d = randn(ComplexF32, 64, 64)
            x_gpu_2d = MtlArray(x_cpu_2d)

            expected_2d = fftshift(fft(x_cpu_2d))
            result_gpu_2d = Array(mtl_fft(x_gpu_2d; shift = true))

            @test isapprox(expected_2d, result_gpu_2d, rtol = 1.0e-4)
        end

        @testset "fft with shift=true single axis" begin
            x_cpu = randn(ComplexF32, 64, 128)
            x_gpu = MtlArray(x_cpu)

            # FFT along axis 1 with shift
            expected_1 = fftshift(fft(x_cpu, 1), 1)
            result_1 = Array(mtl_fft(x_gpu, 1; shift = true))
            @test isapprox(expected_1, result_1, rtol = 1.0e-4)

            # FFT along axis 2 with shift
            expected_2 = fftshift(fft(x_cpu, 2), 2)
            result_2 = Array(mtl_fft(x_gpu, 2; shift = true))
            @test isapprox(expected_2, result_2, rtol = 1.0e-4)
        end

        @testset "ifft with shift=true vs ifft(ifftshift(x))" begin
            # Start with shifted frequency domain data
            x_cpu = randn(ComplexF32, 128)
            x_gpu = MtlArray(x_cpu)

            # ifft with shift should apply ifftshift before the transform
            expected = ifft(ifftshift(x_cpu))
            result_gpu = Array(mtl_ifft(x_gpu; shift = true))

            @test isapprox(expected, result_gpu, rtol = 1.0e-4)
        end

        @testset "fft/ifft roundtrip with shift" begin
            x_cpu = randn(ComplexF32, 64, 64)
            x_gpu = MtlArray(x_cpu)

            # Forward FFT with shift
            y_gpu = mtl_fft(x_gpu; shift = true)

            # Inverse FFT with shift should recover the original
            z_gpu = mtl_ifft(y_gpu; shift = true)

            @test isapprox(x_cpu, Array(z_gpu), rtol = 1.0e-4)
        end

        @testset "shift=false preserves original behavior" begin
            x_cpu = randn(ComplexF32, 64, 64)
            x_gpu = MtlArray(x_cpu)

            # shift=false should give same result as default
            result_default = Array(fft(x_gpu))
            result_explicit = Array(mtl_fft(x_gpu; shift = false))

            @test isapprox(result_default, result_explicit, rtol = 1.0e-6)
        end

        @testset "fft! with shift (in-place)" begin
            x_cpu = randn(ComplexF32, 64, 64)
            x_gpu = MtlArray(copy(x_cpu))

            expected = fftshift(fft(x_cpu))
            mtl_fft!(x_gpu; shift = true)

            @test isapprox(expected, Array(x_gpu), rtol = 1.0e-4)
        end

        @testset "bfft with shift" begin
            x_cpu = randn(ComplexF32, 64, 64)
            x_gpu = MtlArray(x_cpu)

            expected = bfft(ifftshift(x_cpu))
            result_gpu = Array(mtl_bfft(x_gpu; shift = true))

            @test isapprox(expected, result_gpu, rtol = 1.0e-4)
        end

        @testset "shift with odd sizes" begin
            # Odd size handling - fftshift with odd n
            x_cpu = randn(ComplexF32, 65)
            x_gpu = MtlArray(x_cpu)

            expected = fftshift(fft(x_cpu))
            result_gpu = Array(mtl_fft(x_gpu; shift = true))

            @test isapprox(expected, result_gpu, rtol = 1.0e-4)
        end

        @testset "plan with shift" begin
            x_cpu = randn(ComplexF32, 64, 64)
            x_gpu = MtlArray(x_cpu)

            # Create plan with shift
            p = plan_fft(x_gpu; shift = true)
            result = p * x_gpu

            expected = fftshift(fft(x_cpu))
            @test isapprox(expected, Array(result), rtol = 1.0e-4)

            # Plan should be reusable
            x_gpu2 = MtlArray(randn(ComplexF32, 64, 64))
            result2 = p * x_gpu2
            expected2 = fftshift(fft(Array(x_gpu2)))
            @test isapprox(expected2, Array(result2), rtol = 1.0e-4)
        end

        @testset "3D FFT with shift" begin
            x_cpu = randn(ComplexF32, 16, 16, 16)
            x_gpu = MtlArray(x_cpu)

            expected = fftshift(fft(x_cpu))
            result_gpu = Array(mtl_fft(x_gpu; shift = true))

            @test isapprox(expected, result_gpu, rtol = 1.0e-4)
        end

        @testset "ComplexF16 with shift" begin
            x_cpu = ComplexF16.(randn(ComplexF32, 32, 32))
            x_gpu = MtlArray(x_cpu)

            # Lower tolerance for Float16
            expected = fftshift(fft(ComplexF32.(x_cpu)))
            result_gpu = ComplexF32.(Array(mtl_fft(x_gpu; shift = true)))

            @test isapprox(expected, result_gpu, rtol = 1.0e-2)
        end
    end

end # MPS.is_supported(device())
