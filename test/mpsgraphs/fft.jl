using FFTW
using AbstractFFTs
using LinearAlgebra: mul!

# FFTW does not support Float16, so we provide shims for CPU reference

function AbstractFFTs.fft(x::Array{ComplexF16}, dims...)
    return Array{ComplexF16}(fft(Array{ComplexF32}(x), dims...))
end
function AbstractFFTs.ifft(x::Array{ComplexF16}, dims...)
    return Array{ComplexF16}(ifft(Array{ComplexF32}(x), dims...))
end
function AbstractFFTs.bfft(x::Array{ComplexF16}, dims...)
    return Array{ComplexF16}(bfft(Array{ComplexF32}(x), dims...))
end
function AbstractFFTs.rfft(x::Array{Float16}, dims...)
    return Array{ComplexF16}(rfft(Array{Float32}(x), dims...))
end
function AbstractFFTs.irfft(x::Array{ComplexF16}, d::Integer, dims...)
    return Array{Float16}(irfft(Array{ComplexF32}(x), d, dims...))
end
function AbstractFFTs.brfft(x::Array{ComplexF16}, d::Integer, dims...)
    return Array{Float16}(brfft(Array{ComplexF32}(x), d, dims...))
end

# Tolerance functions based on type precision
rtol(::Type{Float16}) = 1.0e-2
rtol(::Type{Float32}) = 1.0e-4
rtol(::Type{ComplexF16}) = 1.0e-2
rtol(::Type{ComplexF32}) = 1.0e-4

# Test dimensions
N1 = 8
N2 = 32
N3 = 16

if MPS.is_supported(device())

    # ============================================================================
    # Complex FFT Tests
    # ============================================================================

    function test_complex_out_of_place(X::AbstractArray{T, N}) where {T <: Complex, N}
        fftw_X = fft(X)
        d_X = MtlArray(X)

        # Forward FFT with @inferred
        p = @inferred plan_fft(d_X)
        d_Y = p * d_X
        Y = Array(d_Y)
        @test isapprox(Y, fftw_X, rtol = rtol(T))

        # Inverse FFT
        pinv = plan_ifft(d_Y)
        d_Z = pinv * d_Y
        Z = Array(d_Z)
        @test isapprox(Z, X, rtol = rtol(T))

        # Backward FFT (unnormalized inverse)
        pinvb = @inferred plan_bfft(d_Y)
        d_Z = pinvb * d_Y
        Z = Array(d_Z) ./ length(d_Z)
        return @test isapprox(Z, X, rtol = rtol(T))
    end

    function test_complex_in_place(X::AbstractArray{T, N}) where {T <: Complex, N}
        fftw_X = fft(X)
        d_X = MtlArray(copy(X))

        # In-place forward FFT
        p = @inferred plan_fft!(d_X)
        p * d_X
        Y = Array(d_X)
        @test isapprox(Y, fftw_X, rtol = rtol(T))

        # In-place inverse FFT
        pinv = plan_ifft!(d_X)
        pinv * d_X
        Z = Array(d_X)
        @test isapprox(Z, X, rtol = rtol(T))

        # Reset and test bfft!
        p * d_X
        pinvb = @inferred plan_bfft!(d_X)
        pinvb * d_X
        Z = Array(d_X) ./ length(X)
        return @test isapprox(Z, X, rtol = rtol(T))
    end

    function test_complex_batched(X::AbstractArray{T, N}, region) where {T <: Complex, N}
        fftw_X = fft(X, region)
        d_X = MtlArray(X)

        p = plan_fft(d_X, region)
        d_Y = p * d_X
        Y = Array(d_Y)
        @test isapprox(Y, fftw_X, rtol = rtol(T))

        pinv = plan_ifft(d_Y, region)
        d_Z = pinv * d_Y
        Z = Array(d_Z)
        return @test isapprox(Z, X, rtol = rtol(T))
    end

    @testset "Complex FFT" begin
        @testset for T in [ComplexF16, ComplexF32]
            @testset "1D" begin
                X = rand(T, N1)
                test_complex_out_of_place(X)
            end

            @testset "1D in-place" begin
                X = rand(T, N1)
                test_complex_in_place(X)
            end

            @testset "2D" begin
                X = rand(T, N1, N2)
                test_complex_out_of_place(X)
            end

            @testset "2D in-place" begin
                X = rand(T, N1, N2)
                test_complex_in_place(X)
            end

            @testset "3D" begin
                X = rand(T, N1, N2, N3)
                test_complex_out_of_place(X)
            end

            @testset "3D in-place" begin
                X = rand(T, N1, N2, N3)
                test_complex_in_place(X)
            end

            @testset "Batch 1D" begin
                dims = (N1, N2)
                X = rand(T, dims)
                test_complex_batched(X, 1)

                X = rand(T, dims)
                test_complex_batched(X, 2)

                X = rand(T, dims)
                test_complex_batched(X, (1, 2))
            end

            @testset "Batch 2D (in 3D)" begin
                dims = (N1, N2, N3)
                for region in [(1, 2), (2, 3), (1, 3)]
                    X = rand(T, dims)
                    test_complex_batched(X, region)
                end
            end
        end
    end

    # ============================================================================
    # Real FFT Tests
    # ============================================================================

    function test_real_out_of_place(X::AbstractArray{T, N}) where {T <: Real, N}
        fftw_X = rfft(X)
        d_X = MtlArray(X)

        # Forward rfft with @inferred
        p = @inferred plan_rfft(d_X)
        d_Y = p * d_X
        Y = Array(d_Y)
        @test isapprox(Y, fftw_X, rtol = rtol(T))

        # Inverse rfft
        pinv = plan_irfft(d_Y, size(X, 1))
        d_Z = pinv * d_Y
        Z = Array(d_Z)
        @test isapprox(Z, X, rtol = rtol(T))

        # Backward rfft (unnormalized)
        pinvb = @inferred plan_brfft(d_Y, size(X, 1))
        d_Z = pinvb * d_Y
        Z = Array(d_Z) ./ length(X)
        return @test isapprox(Z, X, rtol = rtol(T))
    end

    function test_real_batched(X::AbstractArray{T, N}, region) where {T <: Real, N}
        fftw_X = rfft(X, region)
        d_X = MtlArray(X)

        p = plan_rfft(d_X, region)
        d_Y = p * d_X
        Y = Array(d_Y)
        @test isapprox(Y, fftw_X, rtol = rtol(T))

        pinv = plan_irfft(d_Y, size(X, region[1]), region)
        d_Z = pinv * d_Y
        Z = Array(d_Z)
        return @test isapprox(Z, X, rtol = rtol(T))
    end

    @testset "Real FFT" begin
        @testset for T in [Float16, Float32]
            @testset "1D" begin
                X = rand(T, N1)
                test_real_out_of_place(X)
            end

            @testset "2D" begin
                X = rand(T, N1, N2)
                test_real_out_of_place(X)
            end

            @testset "3D" begin
                X = rand(T, N1, N2, N3)
                test_real_out_of_place(X)
            end

            @testset "Batch 1D" begin
                dims = (N1, N2)
                X = rand(T, dims)
                test_real_batched(X, 1)

                X = rand(T, dims)
                test_real_batched(X, 2)

                X = rand(T, dims)
                test_real_batched(X, (1, 2))
            end

            @testset "Batch 2D (in 3D)" begin
                dims = (N1, N2, N3)
                for region in [(1, 2), (2, 3), (1, 3)]
                    X = rand(T, dims)
                    test_real_batched(X, region)
                end
            end
        end
    end

    # ============================================================================
    # Additional Tests
    # ============================================================================

    @testset "Plan Properties" begin
        x = MtlArray(randn(ComplexF32, 64, 64))
        p = plan_fft(x)
        @test size(p) == (64, 64)
        @test fftdims(p) == (1, 2)

        p2 = plan_fft(x, 1)
        @test fftdims(p2) == (1,)
    end

    @testset "mul! Interface" begin
        x = MtlArray(randn(ComplexF32, 32, 32))
        y = similar(x)
        p = plan_fft(x)
        mul!(y, p, x)
        @test isapprox(Array(y), fft(Array(x)), rtol = 1.0e-4)

        # Real FFT mul!
        xr = MtlArray(randn(Float32, 32, 32))
        yr = MtlArray{ComplexF32}(undef, 17, 32)
        pr = plan_rfft(xr)
        mul!(yr, pr, xr)
        @test isapprox(Array(yr), rfft(Array(xr)), rtol = 1.0e-4)
    end

    @testset "Plan Reuse" begin
        x1 = MtlArray(randn(ComplexF32, 64, 64))
        x2 = MtlArray(randn(ComplexF32, 64, 64))

        p = plan_fft(x1)
        y1 = p * x1
        y2 = p * x2

        @test isapprox(Array(y1), fft(Array(x1)), rtol = 1.0e-4)
        @test isapprox(Array(y2), fft(Array(x2)), rtol = 1.0e-4)
    end

    @testset "Type Restrictions" begin
        # ComplexF32 should work
        x32 = MtlArray(randn(ComplexF32, 32, 32))
        @test plan_fft(x32) isa MPSGraphs.MtlFFTPlan

        # ComplexF16 should work
        x16 = MtlArray(ComplexF16.(randn(ComplexF32, 32, 32)))
        @test plan_fft(x16) isa MPSGraphs.MtlFFTPlan

        # Float32 rfft should work
        xr32 = MtlArray(randn(Float32, 32, 32))
        @test plan_rfft(xr32) isa MPSGraphs.MtlRFFTPlan

        # Float16 rfft should work
        xr16 = MtlArray(Float16.(randn(Float32, 32, 32)))
        @test plan_rfft(xr16) isa MPSGraphs.MtlRFFTPlan
    end

    @testset "Invalid Dimensions" begin
        x = MtlArray(randn(ComplexF32, 32, 32))
        @test_throws ArgumentError plan_fft(x, 3)  # Only 2 dimensions
        @test_throws ArgumentError plan_fft(x, 0)  # Invalid dimension
    end

    @testset "Odd Sizes" begin
        # Odd-sized irfft
        x_cpu = randn(Float32, 63, 64)
        y_cpu = rfft(x_cpu, 1)
        y_gpu = MtlArray(y_cpu)

        z_cpu = irfft(y_cpu, 63, 1)
        z_gpu = Array(irfft(y_gpu, 63, 1))

        @test size(z_gpu) == (63, 64)
        @test isapprox(z_cpu, z_gpu, rtol = 1.0e-4)
    end

end # MPS.is_supported(device())
