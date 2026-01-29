using Random
using ..MPS: MPSVector, _mpsmat_rand!, MPSMatrixRandomUniformDistributionDescriptor,
             MPSMatrixRandomNormalDistributionDescriptor

"""
    Metal.RNG()

A random number generator using `rand()` in a device kernel.
"""
mutable struct RNG <: AbstractRNG
    seed::UInt32
    counter::UInt32

    function RNG(seed::Integer)
        new(seed%UInt32, 0)
    end
    RNG(seed::UInt32, counter::UInt32) = new(seed, counter)
end

make_seed() = Base.rand(RandomDevice(), UInt32)

RNG() = RNG(make_seed())

Base.copy(rng::RNG) = RNG(rng.seed, rng.counter)
Base.hash(rng::RNG, h::UInt) = hash(rng.seed, hash(rng.counter, h))
Base.:(==)(a::RNG, b::RNG) = (a.seed == b.seed) && (a.counter == b.counter)

function Random.seed!(rng::RNG, seed::Integer)
    rng.seed = seed % UInt32
    rng.counter = 0
end

Random.seed!(rng::RNG) = Random.seed!(rng, make_seed())

function Random.rand!(rng::RNG, A::WrappedMtlArray)
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

function Random.randn!(rng::RNG, A::WrappedMtlArray{<:Union{AbstractFloat,Complex{<:AbstractFloat}}})
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

function default_rng()
    dev = device()

    # every task maintains library state per device
    LibraryState = @NamedTuple{rng::RNG}
    states = get!(task_local_storage(), :RNG) do
        Dict{MTLDevice,LibraryState}()
    end::Dict{MTLDevice,LibraryState}

    # get library state
    @noinline function new_state(dev)
        # Metal RNG objects are cheap, so we don't need to cache them
        (; rng = RNG())
    end
    state = get!(states, dev) do
        new_state(dev)
    end

    return state.rng
end

gpuarrays_rng() = GPUArrays.default_rng(MtlArray)
mtl_rng() = default_rng()
mpsrand_rng() = MPS.default_rng()

# RNG interface

# GPU arrays
Random.rand(rng::RNG, T::Type, dims::Dims) =
    rand!(rng, MtlArray{T}(undef, dims))
Random.randn(rng::RNG, T::Type, dims::Dims) =
    randn!(rng, MtlArray{T}(undef, dims))

# specify default types
Random.rand(rng::RNG, dims::Dims) =
    Random.rand(rng, Float32, dims)
Random.randn(rng::RNG, dims::Dims) =
    Random.randn(rng, Float32, dims)

# support all dimension specifications
Random.rand(rng::RNG, dim1::Integer, dims::Integer...) =
    Random.rand(rng, Dims((dim1, dims...)))
Random.randn(rng::RNG, dim1::Integer, dims::Integer...) =
    Random.randn(rng, Dims((dim1, dims...)))
# ... and with a type
Random.rand(rng::RNG, T::Type, dim1::Integer, dims::Integer...) =
    Random.rand(rng, T, Dims((dim1, dims...)))
Random.randn(rng::RNG, T::Type, dim1::Integer, dims::Integer...) =
    Random.randn(rng, T, Dims((dim1, dims...)))

# CPU arrays
function Random.rand!(rng::RNG, A::AbstractArray{T}) where {T}
    B = MtlArray{T}(undef, size(A))
    rand!(rng, B)
    copyto!(A, B)
end
function Random.randn!(rng::RNG, A::AbstractArray{T}) where {T}
    B = MtlArray{T}(undef, size(A))
    randn!(rng, B)
    copyto!(A, B)
end

# scalars
Random.rand(rng::RNG, T::Type=Float32) = Random.rand(rng, T, 1)[]
Random.randn(rng::RNG, T::Type=Float32) = Random.randn(rng, T, 1)[]
# resolve ambiguities
Random.randn(rng::RNG, T::Random.BitFloatType) = Random.randn(rng, T, 1)[]

############################################
#            RNG-less API                  #
# Use MPS for uniformly distributed RNG,   #
# but native rand for normally distributed #
# to work around JuliaGPU/Metal.jl#474     #
############################################

# GPUArrays in-place
Random.rand!(A::MtlArray) = Random.rand!(mtl_rng(), A)
Random.randn!(A::MtlArray) = Random.randn!(mtl_rng(), A)

# Use MPS random functionality where possible for uniformly distributed RNG
function Random.rand!(A::MPS.UniformArray)
    return Random.rand!(mpsrand_rng(), A)
end

# GPUArrays out-of-place
function rand(T::MPS.UniformType, dims::Dims; storage=DefaultStorageMode)
    return Random.rand!(mpsrand_rng(), MtlArray{T,length(dims),storage}(undef, dims...))
end

rand(T::Type, dims::Dims; storage=DefaultStorageMode) =
    Random.rand!(mtl_rng(), MtlArray{T,length(dims),storage}(undef, dims...))
randn(T::Type, dims::Dims; storage=DefaultStorageMode) =
    Random.randn!(mtl_rng(), MtlArray{T,length(dims),storage}(undef, dims...))

# support all dimension specifications
function rand(T::MPS.UniformType, dim1::Integer, dims::Integer...; storage=DefaultStorageMode)
    return Random.rand!(mpsrand_rng(), MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))
end

rand(T::Type, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.rand!(mtl_rng(), MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))
randn(T::Type, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.randn!(mtl_rng(), MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))

# untyped out-of-place
rand(dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.rand!(mpsrand_rng(), MtlArray{Float32,length(dims) + 1,storage}(undef, dim1, dims...))
randn(dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.randn!(mtl_rng(), MtlArray{Float32,length(dims) + 1,storage}(undef, dim1, dims...))

# scalars
rand(T::Type=Float32; storage=SharedStorage) = rand(T, 1; storage)[1]
randn(T::Type=Float32; storage=SharedStorage) = randn(T, 1; storage)[1]

# seeding
function seed!(seed=Base.rand(UInt64))
    Random.seed!(mtl_rng(), seed)
    Random.seed!(mpsrand_rng(), seed)
end
