using Test
using Metal

@testset "Large array copy (>4GB)" begin
    # Skip if not enough memory
    if Sys.total_memory() < 20 * 2^30  # Need ~20GB RAM
        @warn "Skipping large array test - insufficient memory"
        return
    end

    n = 537501696  # ~4.3 GB
    bytes = n * sizeof(ComplexF32)

    @testset "CPU -> GPU -> CPU roundtrip" begin
        cpu_data = randn(ComplexF32, n)

        # Transfer to GPU (default Private storage)
        gpu_data = MtlArray(cpu_data)
        Metal.synchronize()

        # Transfer back
        result = Array(gpu_data)

        @test result[1] == cpu_data[1]
        @test result[end] == cpu_data[end]
        @test result == cpu_data
    end

    @testset "GPU -> GPU copy (Shared -> Private)" begin
        cpu_data = randn(ComplexF32, n)

        # Put in Shared storage first
        gpu_shared = MtlArray{ComplexF32,1,Metal.SharedStorage}(undef, n)
        copyto!(gpu_shared, cpu_data)
        Metal.synchronize()

        # Copy to Private storage
        gpu_private = MtlArray{ComplexF32,1,Metal.PrivateStorage}(undef, n)
        copyto!(gpu_private, gpu_shared)
        Metal.synchronize()

        # Copy back to check
        result = Array(gpu_private)

        @test result[1] == cpu_data[1]
        @test result[end] == cpu_data[end]
        @test result == cpu_data
    end

    @testset "Boundary check around 4GB" begin
        cpu_data = randn(ComplexF32, n)
        gpu_data = MtlArray(cpu_data)
        Metal.synchronize()
        result = Array(gpu_data)

        # Check around the 2^32 byte boundary
        boundary_element = 2^32 ÷ sizeof(ComplexF32)
        for i in [boundary_element - 1, boundary_element, boundary_element + 1]
            if i <= n
                @test result[i] == cpu_data[i]
            end
        end
    end
end

println("All large array copy tests passed!")
