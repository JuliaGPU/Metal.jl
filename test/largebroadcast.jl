const N = Int(typemax(UInt32)) + 1
const T = Int8

@testset "len = $n" for n in ((N÷2) - 4, (N÷2), (N÷2) + 4, N - 1024, N - 3, N - 1, N, N + 4)
    A = MtlArray{T}(undef, n)
    # Known working method to zero out array
    Metal.unsafe_fill!(device(A), pointer(A), T(0), n * sizeof(T); async = false)

    _dims = [(n,), (n, 1), (1, n), (n, 1, 1), (1, n, 1), (1, 1, n),
             (n, 1, 1, 1), (1, n, 1, 1), (1, 1, n, 1), (1, 1, 1, n),]
    if n == 2^32
        push!(_dims, (2^16, 2^16))
        push!(_dims, (2^16, 2^8, 2^8))
    end

    @testset "$dims" for (i, dims) in enumerate(_dims)
        # These must be run first to ensure we test
        # the unspecialized broadcast kernels
        Metal._broadcast_shapes[CartesianIndices(dims)] = Metal.BROADCAST_SPECIALIZATION_THRESHOLD - 1
        unspec_val = T((i-1) * 2 + 1)
        arr = reshape(A, dims)
        arr .= unspec_val
        @test all(==(unspec_val), arr)

        # Test specialized compiled kernel
        # Not necessary but just in case
        Metal._broadcast_shapes[CartesianIndices(dims)] = Metal.BROADCAST_SPECIALIZATION_THRESHOLD
        spec_val = T(unspec_val + 1)
        arr .= spec_val
        @test all(==(spec_val), arr)
    end
    A = nothing
    GC.gc()
    GC.gc()
end
