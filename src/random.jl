using Random

# Metal.jl ships three RNGs:
#
# - `Metal.RNG` (an alias for `GPUArrays.RNG{MtlArray}`): the default
#   Philox4x32-10 counter-based RNG, returned by `Metal.default_rng()`.
#   Used by `rand`/`randn`/`rand!`/`randn!`.
#
# - `MPS.RNG`: a Metal Performance Shaders-backed Philox RNG. Reachable as
#   `Metal.mps_rng()`. Kept available for users who explicitly want to use the
#   MPS path (and seeded by `Metal.seed!` so it stays in sync).
#
# - `Metal.KernelRNG`: a custom kernel that calls Metal's on-device Philox2x32.
#   Kept around for testing and performance comparison; see `Metal.kernel_rng`.

const RNG = GPUArrays.RNG{MtlArray}

function default_rng()
    dev = device()

    # every task maintains library state per device
    LibraryState = @NamedTuple{rng::RNG}
    states = get!(task_local_storage(), :MetalRNG) do
        Dict{MTLDevice,LibraryState}()
    end::Dict{MTLDevice,LibraryState}

    # get library state
    @noinline function new_state(dev)
        rng = RNG()
        Random.seed!(rng)
        (; rng)
    end
    state = get!(states, dev) do
        new_state(dev)
    end

    return state.rng
end

# accessors for the alternative RNGs
mps_rng() = MPS.default_rng()
kernel_rng() = _default_kernel_rng()


## Kernel-based RNG (uses Metal's on-device Philox2x32 generator)

"""
    Metal.KernelRNG()

A random number generator that launches a Metal kernel which calls the
device-side `rand()`/`randn()` on Metal's Philox2x32 generator.

!!! warning
    This RNG is kept for testing and performance comparison against the
    default `Metal.RNG` (the GPUArrays RNG). For production use prefer
    `Metal.RNG`.
"""
mutable struct KernelRNG <: AbstractRNG
    seed::UInt32
    counter::UInt32

    function KernelRNG(seed::Integer)
        new(seed%UInt32, 0)
    end
    KernelRNG(seed::UInt32, counter::UInt32) = new(seed, counter)
end

kernel_make_seed() = Base.rand(RandomDevice(), UInt32)

KernelRNG() = KernelRNG(kernel_make_seed())

Base.copy(rng::KernelRNG) = KernelRNG(rng.seed, rng.counter)
Base.hash(rng::KernelRNG, h::UInt) = hash(rng.seed, hash(rng.counter, h))
Base.:(==)(a::KernelRNG, b::KernelRNG) = (a.seed == b.seed) && (a.counter == b.counter)

function Random.seed!(rng::KernelRNG, seed::Integer)
    rng.seed = seed % UInt32
    rng.counter = 0
end

Random.seed!(rng::KernelRNG) = Random.seed!(rng, kernel_make_seed())

function Random.rand!(rng::KernelRNG, A::WrappedMtlArray)
    isempty(A) && return A

    ## COV_EXCL_START
    function kernel(A::AbstractArray{T}, seed::UInt32, counter::UInt32) where {T}
        device_rng = Random.default_rng()

        # initialize the state
        @inbounds Random.seed!(device_rng, seed, counter)

        # grid-stride loop
        threadId = thread_position_in_threadgroup().x
        window = widemul(threads_per_threadgroup().x, threadgroups_per_grid().x)
        offset = widemul(threadgroup_position_in_grid().x - 1i32, threads_per_threadgroup().x)
        while offset < length(A)
            i = threadId + offset
            if i <= length(A)
                @inbounds A[i] = Random.rand(device_rng, T)
            end

            offset += window
        end

        return
    end
    ## COV_EXCL_STOP

    # XXX: because of how random numbers are generated, the launch configuration
    #      affects the results. as such, use a constant number of threads, set
    #      very low for compatibility, and a deterministic number of groups.
    #      this is not ideal, but otherwise generated numbers have observed to
    #      be different between otherwise identical inputs (eltype, dims)
    #      depending on whether it was a direct MtlArray or a wrapped SubArray.
    threads = 32
    groups = cld(length(A), threads)

    @metal threads groups name="rand!" kernel(A, rng.seed, rng.counter)

    new_counter = Int64(rng.counter) + length(A)
    overflow, remainder = fldmod(new_counter, typemax(UInt32))
    rng.seed += overflow     # XXX: is this OK?
    rng.counter = remainder

    A
end

function Random.randn!(rng::KernelRNG, A::WrappedMtlArray{<:Union{AbstractFloat,Complex{<:AbstractFloat}}})
    isempty(A) && return A

    ## COV_EXCL_START
    function kernel(A::AbstractArray{T}, seed::UInt32, counter::UInt32) where {T<:Real}
        device_rng = Random.default_rng()

        # initialize the state
        @inbounds Random.seed!(device_rng, seed, counter)

        # grid-stride loop
        threadId = thread_position_in_threadgroup().x
        window = widemul(threads_per_threadgroup().x, threadgroups_per_grid().x)
        offset = widemul(threadgroup_position_in_grid().x - 1i32, threads_per_threadgroup().x)
        while offset < length(A)
            i = threadId + offset
            j = threadId + offset + window
            if i <= length(A)
                # Box–Muller transform
                U1 = Random.rand(device_rng, T)
                while U1 == zero(T)
                    U1 = Random.rand(device_rng, T)
                end
                U2 = Random.rand(device_rng, T)
                Z0 = sqrt(T(-2.0)*log(U1))*cos(T(2pi)*U2)
                Z1 = sqrt(T(-2.0)*log(U1))*sin(T(2pi)*U2)
                @inbounds A[i] = Z0
                if j <= length(A)
                    @inbounds A[j] = Z1
                end
            end

            offset += 2*window
        end
        return
    end

    function kernel(A::AbstractArray{Complex{T}}, seed::UInt32, counter::UInt32) where {T<:Real}
        device_rng = Random.default_rng()

        # initialize the state
        @inbounds Random.seed!(device_rng, seed, counter)

        # grid-stride loop
        threadId = thread_position_in_threadgroup().x
        window = widemul(threads_per_threadgroup().x, threadgroups_per_grid().x)
        offset = widemul(threadgroup_position_in_grid().x - 1i32, threads_per_threadgroup().x)
        while offset < length(A)
            i = threadId + offset
            if i <= length(A)
                # Complex Box–Muller transform
                U1 = Random.rand(device_rng, T)
                while U1 == zero(T)
                    U1 = Random.rand(device_rng, T)
                end
                U2 = Random.rand(device_rng, T)
                Z0 = sqrt(-log(U1))*cos(T(2pi)*U2)
                Z1 = sqrt(-log(U1))*sin(T(2pi)*U2)
                @inbounds A[i] = complex(Z0, Z1)
            end

            offset += window
        end
        return
    end
    ## COV_EXCL_STOP

    # see note in `rand!` about the launch configuration
    threads = 32
    groups = cld(cld(length(A), 2), threads)

    @metal threads groups name="randn!" kernel(A, rng.seed, rng.counter)

    new_counter = Int64(rng.counter) + length(A)
    overflow, remainder = fldmod(new_counter, typemax(UInt32))
    rng.seed += overflow     # XXX: is this OK?
    rng.counter = remainder

    A
end

# GPU arrays
Random.rand(rng::KernelRNG, T::Type, dims::Dims) =
    Random.rand!(rng, MtlArray{T}(undef, dims))
Random.randn(rng::KernelRNG, T::Type, dims::Dims) =
    Random.randn!(rng, MtlArray{T}(undef, dims))

# specify default types
Random.rand(rng::KernelRNG, dims::Dims) = Random.rand(rng, Float32, dims)
Random.randn(rng::KernelRNG, dims::Dims) = Random.randn(rng, Float32, dims)

# support all dimension specifications
Random.rand(rng::KernelRNG, dim1::Integer, dims::Integer...) =
    Random.rand(rng, Dims((dim1, dims...)))
Random.randn(rng::KernelRNG, dim1::Integer, dims::Integer...) =
    Random.randn(rng, Dims((dim1, dims...)))
# ... and with a type
Random.rand(rng::KernelRNG, T::Type, dim1::Integer, dims::Integer...) =
    Random.rand(rng, T, Dims((dim1, dims...)))
Random.randn(rng::KernelRNG, T::Type, dim1::Integer, dims::Integer...) =
    Random.randn(rng, T, Dims((dim1, dims...)))

# CPU arrays
function Random.rand!(rng::KernelRNG, A::AbstractArray{T}) where {T}
    B = MtlArray{T}(undef, size(A))
    Random.rand!(rng, B)
    copyto!(A, B)
end
function Random.randn!(rng::KernelRNG, A::AbstractArray{T}) where {T}
    B = MtlArray{T}(undef, size(A))
    Random.randn!(rng, B)
    copyto!(A, B)
end

# scalars
Random.rand(rng::KernelRNG, T::Type=Float32) = Random.rand(rng, T, 1)[]
Random.randn(rng::KernelRNG, T::Type=Float32) = Random.randn(rng, T, 1)[]
# resolve ambiguities
Random.randn(rng::KernelRNG, T::Random.BitFloatType) = Random.randn(rng, T, 1)[]

# task-local cache for the kernel-based RNG
function _default_kernel_rng()
    dev = device()

    LibraryState = @NamedTuple{rng::KernelRNG}
    states = get!(task_local_storage(), :MetalKernelRNG) do
        Dict{MTLDevice,LibraryState}()
    end::Dict{MTLDevice,LibraryState}

    @noinline function new_state(dev)
        (; rng = KernelRNG())
    end
    state = get!(states, dev) do
        new_state(dev)
    end

    return state.rng
end


############################################
#            RNG-less API                  #
# Routes through Metal.default_rng() (the  #
# GPUArrays RNG); MPS is reachable through #
# Metal.mps_rng() and used by Metal.seed!. #
############################################

# in-place
Random.rand!(A::MtlArray) = Random.rand!(default_rng(), A)
Random.randn!(A::MtlArray) = Random.randn!(default_rng(), A)

# out-of-place
rand(T::Type, dims::Dims; storage=DefaultStorageMode) =
    Random.rand!(default_rng(), MtlArray{T,length(dims),storage}(undef, dims...))
randn(T::Type, dims::Dims; storage=DefaultStorageMode) =
    Random.randn!(default_rng(), MtlArray{T,length(dims),storage}(undef, dims...))

rand(T::Type, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.rand!(default_rng(), MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))
randn(T::Type, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.randn!(default_rng(), MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))

# untyped out-of-place (defaults to Float32)
rand(dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.rand!(default_rng(), MtlArray{Float32,length(dims) + 1,storage}(undef, dim1, dims...))
randn(dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.randn!(default_rng(), MtlArray{Float32,length(dims) + 1,storage}(undef, dim1, dims...))

# scalars
rand(T::Type=Float32; storage=SharedStorage) = rand(T, 1; storage)[1]
randn(T::Type=Float32; storage=SharedStorage) = randn(T, 1; storage)[1]

# seeding
function seed!(seed=Base.rand(UInt64))
    Random.seed!(default_rng(), seed)
    Random.seed!(mps_rng(), seed)
end
