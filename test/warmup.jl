@testset "warmup" begin
    @testset "warmup API" begin
        # warmup() should always return nothing, regardless of thread configuration
        @test Metal.warmup() === nothing
        @test Metal.warmup(blocking = false) === nothing
        @test Metal.warmup(blocking = true) === nothing

        # Multiple calls should be safe
        @test Metal.warmup() === nothing
        @test Metal.warmup() === nothing
    end

    @testset "kernel compilation after warmup" begin
        Metal.warmup()

        # Define and compile a test kernel
        function test_kernel!(a)
            i = thread_position_in_grid().x
            if i <= length(a)
                a[i] = Float32(i)
            end
            return nothing
        end

        a = MtlArray{Float32}(undef, 256)
        @metal threads = 256 test_kernel!(a)
        synchronize()

        # Verify the kernel executed correctly
        result = Array(a)
        @test result[1] == 1.0f0
        @test result[128] == 128.0f0
        @test result[256] == 256.0f0
    end

    @testset "concurrent kernel compilation" begin
        Metal.warmup()

        # Define two distinct kernels
        function kernel_add!(a)
            i = thread_position_in_grid().x
            if i <= length(a)
                a[i] += 1.0f0
            end
            return nothing
        end

        function kernel_mul!(a)
            i = thread_position_in_grid().x
            if i <= length(a)
                a[i] *= 2.0f0
            end
            return nothing
        end

        a = MtlArray(ones(Float32, 64))
        b = MtlArray(ones(Float32, 64))

        # Compile and run both kernels
        @metal threads = 64 kernel_add!(a)
        @metal threads = 64 kernel_mul!(b)
        synchronize()

        # Verify both executed correctly
        @test Array(a)[1] == 2.0f0
        @test Array(b)[1] == 2.0f0
    end
end
