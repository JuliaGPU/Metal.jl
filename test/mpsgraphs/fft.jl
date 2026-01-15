using FFTW
using AbstractFFTs
using LinearAlgebra

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
struct WrappedFloat16Operator
    op
end
Base.:*(A::WrappedFloat16Operator, b::Array{Float16}) = Array{Float16}(A.op * Array{Float32}(b))
Base.:*(A::WrappedFloat16Operator, b::Array{Complex{Float16}}) = Array{Complex{Float16}}(A.op * Array{Complex{Float32}}(b))
function LinearAlgebra.mul!(C::Array{Float16}, A::WrappedFloat16Operator, B::Array{Float16}, α, β)
    C32 = Array{Float32}(C)
    B32 = Array{Float32}(B)
    mul!(C32, A.op, B32, α, β)
    C .= C32
end
function LinearAlgebra.mul!(C::Array{Complex{Float16}}, A::WrappedFloat16Operator, B::Array{Complex{Float16}}, α, β)
    C32 = Array{Complex{Float32}}(C)
    B32 = Array{Complex{Float32}}(B)
    mul!(C32, A.op, B32, α, β)
    C .= C32
end

function AbstractFFTs.plan_fft!(x::Array{Complex{Float16}}, dims...)
    y = similar(x, Complex{Float32})
    WrappedFloat16Operator(plan_fft!(y, dims...))
end
function AbstractFFTs.plan_bfft!(x::Array{Complex{Float16}}, dims...)
    y = similar(x, Complex{Float32})
    WrappedFloat16Operator(plan_bfft!(y, dims...))
end
function AbstractFFTs.plan_ifft!(x::Array{Complex{Float16}}, dims...)
    y = similar(x, Complex{Float32})
    WrappedFloat16Operator(plan_ifft!(y, dims...))
end

function AbstractFFTs.plan_fft(x::Array{Complex{Float16}}, dims...)
    y = similar(x, Complex{Float32})
    WrappedFloat16Operator(plan_fft(y, dims...))
end
function AbstractFFTs.plan_bfft(x::Array{Complex{Float16}}, dims...)
    y = similar(x, Complex{Float32})
    WrappedFloat16Operator(plan_bfft(y, dims...))
end
function AbstractFFTs.plan_ifft(x::Array{Complex{Float16}}, dims...)
    y = similar(x, Complex{Float32})
    WrappedFloat16Operator(plan_ifft(y, dims...))
end
function AbstractFFTs.plan_rfft(x::Array{Float16}, dims...)
    y = similar(x, Float32)
    WrappedFloat16Operator(plan_rfft(y, dims...))
end
function AbstractFFTs.plan_irfft(x::Array{Complex{Float16}}, dims...)
    y = similar(x, Complex{Float32})
    WrappedFloat16Operator(plan_irfft(y, dims...))
end
function AbstractFFTs.plan_brfft(x::Array{Complex{Float16}}, dims...)
    y = similar(x, Complex{Float32})
    WrappedFloat16Operator(plan_brfft(y, dims...))
end

# Tolerance functions based on type precision
rtol(::Type{Float16}) = 1.0e-2
rtol(::Type{Float32}) = 1.0e-5
rtol(::Type{Float64}) = 1.0e-12
rtol(::Type{I}) where {I<:Integer} = rtol(float(I))
atol(::Type{Float16}) = 1.0e-3
atol(::Type{Float32}) = 1.0e-8
atol(::Type{Float64}) = 1.0e-15
atol(::Type{I}) where {I<:Integer} = atol(float(I))
rtol(::Type{Complex{T}}) where {T} = rtol(T)
atol(::Type{Complex{T}}) where {T} = atol(T)
# Test dimensions
N1 = 8
N2 = 32
N3 = 64
N4 = 8

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
        @test isapprox(Y, fftw_X, rtol = rtol(T), atol = atol(T))

        # Inverse FFT
        pinv = plan_ifft(d_Y)
        d_Z = pinv * d_Y
        Z = Array(d_Z)
        @test isapprox(Z, X, rtol = rtol(T), atol = atol(T))

        # pinv2 = inv(p)
        # d_Z = pinv2 * d_Y
        # Z = Array(d_Z)
        # @test isapprox(Z, X, rtol = rtol(T), atol = atol(T))

        # Backward FFT (unnormalized inverse)
        pinvb = @inferred plan_bfft(d_Y)
        d_Z = pinvb * d_Y
        Z = Array(d_Z) ./ length(d_Z)
        @test isapprox(Z, X, rtol = rtol(T), atol = atol(T))
    end

    function test_complex_in_place(X::AbstractArray{T, N}) where {T <: Complex, N}
        fftw_X = fft(X)
        d_X = MtlArray(copy(X))

        # In-place forward FFT
        p = @inferred plan_fft!(d_X)
        p * d_X
        Y = Array(d_X)
        @test isapprox(Y, fftw_X, rtol = rtol(T), atol = atol(T))

        # In-place inverse FFT
        pinv = plan_ifft!(d_X)
        pinv * d_X
        Z = Array(d_X)
        @test isapprox(Z, X, rtol = rtol(T), atol = atol(T))

        # Reset and test bfft!
        p * d_X
        pinvb = @inferred plan_bfft!(d_X)
        pinvb * d_X
        Z = Array(d_X) ./ length(X)
        @test isapprox(Z, X, rtol = rtol(T), atol = atol(T))
    end

    function test_complex_batched(X::AbstractArray{T, N}, region) where {T <: Complex, N}
        fftw_X = fft(X, region)
        d_X = MtlArray(X)

        p = plan_fft(d_X, region)
        d_Y = p * d_X
        d_X2 = reshape(d_X, (size(d_X)..., 1))
        @test_throws ArgumentError p * d_X2

        Y = Array(d_Y)
        @test isapprox(Y, fftw_X, rtol = rtol(T), atol = atol(T))

        pinv = plan_ifft(d_Y, region)
        d_Z = pinv * d_Y
        Z = Array(d_Z)
        @test isapprox(Z, X, rtol = rtol(T), atol = atol(T))

        # ldiv!(d_Z, p, d_Y)
        # Z = collect(d_Z)
        # @test isapprox(Z, X, rtol = rtol(T), atol = atol(T))
    end

    @testset "Complex FFT" begin
        @testset for T in [ComplexF16, ComplexF32]
            @testset "simple" begin
                @testset "$(n)D" for n = 1:3
                    sz = 40
                    dims = ntuple(i -> sz, n)
                    @test testf(fft!, rand(T, dims))
                    @test testf(ifft!, rand(T, dims))

                    @test testf(fft, rand(T, dims))
                    @test testf(ifft, rand(T, dims))
                end
            end

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

                X = rand(T, dims)
                @test_throws ArgumentError test_complex_batched(X, (3, 1))
            end
            @testset "Batch 2D (in 4D)" begin
                dims = (N1, N2, N3, N4)
                for region in [(1, 2), (1, 4), (3, 4), (1, 3), (2, 3), (2,), (3,)]
                    X = rand(T, dims)
                    test_complex_batched(X, region)
                end
                for region in [(2, 4)]
                    X = rand(T, dims)
                    @test_throws ArgumentError test_complex_batched(X, region)
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
        @test isapprox(Y, fftw_X, rtol = rtol(T), atol = atol(T))

        # Inverse rfft
        pinv = plan_irfft(d_Y, size(X, 1))
        d_Z = pinv * d_Y
        Z = Array(d_Z)
        @test isapprox(Z, X, rtol = rtol(T), atol = atol(T))

        # pinv2 = inv(p)
        # d_Z = pinv2 * d_Y
        # Z = Array(d_Z)
        # @test isapprox(Z, X, rtol = rtol(T), atol = atol(T))

        # pinv3 = inv(pinv)
        # d_W = pinv3 * d_X
        # W = Array(d_W)
        # @test isapprox(W, Y, rtol = rtol(T), atol = atol(T))

        # Backward rfft (unnormalized)
        pinvb = @inferred plan_brfft(d_Y, size(X, 1))
        d_Z = pinvb * d_Y
        Z = Array(d_Z) ./ length(X)
        @test isapprox(Z, X, rtol = rtol(T), atol = atol(T))
    end

    function test_real_batched(X::AbstractArray{T, N}, region) where {T <: Real, N}
        fftw_X = rfft(X, region)
        d_X = MtlArray(X)

        p = plan_rfft(d_X, region)
        d_Y = p * d_X
        Y = Array(d_Y)
        @test isapprox(Y, fftw_X, rtol = rtol(T), atol = atol(T))

        pinv = plan_irfft(d_Y, size(X, region[1]), region)
        d_Z = pinv * d_Y
        Z = Array(d_Z)
        @test isapprox(Z, X, rtol = rtol(T), atol = atol(T))
    end

    @testset "Real FFT" begin
        @testset for T in [Float16, Float32]
            @testset "1D" begin
                X = rand(T, N1)
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

            @testset "2D" begin
                X = rand(T, N1, N2)
                test_real_out_of_place(X)
            end

            @testset "Batch 2D (in 3D)" begin
                dims = (N1, N2, N3)
                for region in [(1, 2), (2, 3), (1, 3)]
                    X = rand(T, dims)
                    test_real_batched(X, region)
                end

                X = rand(T, dims)
                @test_throws ArgumentError test_real_batched(X, (3, 1))
            end

            @testset "Batch 2D (in 4D)" begin
                dims = (N1,N2,N3,N4)
                for region in [(1,2),(1,4),(3,4),(1,3),(2,3)]
                    X = rand(T, dims)
                    test_real_batched(X, region)
                end
                for region in [(2,4)]
                    X = rand(T, dims)
                    @test_throws ArgumentError test_real_batched(X, region)
                end
            end

            @testset "3D" begin
                X = rand(T, N1, N2, N3)
                test_real_out_of_place(X)
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
