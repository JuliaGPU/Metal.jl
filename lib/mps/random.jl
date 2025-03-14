using Random
using Metal: DefaultStorageMode

"""
    MPS.RNG()

A random number generator using `rand()` in a device kernel.
"""
mutable struct RNG <: AbstractRNG
    device::MTLDevice
    uniformInteger::MPSMatrixRandomPhilox
    uniformFloat32::MPSMatrixRandomPhilox
    normalFloat32::MPSMatrixRandomPhilox
end


make_seed() = Base.rand(RandomDevice(), UInt)

function RNG(device::MTLDevice, seed::Integer)
    seed = seed%UInt
    RNG(device,
        MPSMatrixRandomPhilox(device, UInt32, seed, MPSMatrixRandomDefaultDistributionDescriptor()),
        MPSMatrixRandomPhilox(device, Float32, seed, MPSMatrixRandomUniformDistributionDescriptor(0, 1)),
        MPSMatrixRandomPhilox(device, Float32, seed, MPSMatrixRandomNormalDistributionDescriptor(0, 1)),)
end
@autoreleasepool RNG(seed::Integer) = RNG(device(), seed)
RNG(device::MTLDevice) = RNG(device, make_seed())

@autoreleasepool RNG() = RNG(device(), make_seed())

Base.copy(rng::RNG) = RNG(copy(rng.device), copy(rng.uniformInteger), copy(rng.uniformFloat32), copy(rng.normalFloat32))

@autoreleasepool function Random.seed!(rng::RNG, seed::Integer)
    rng.uniformInteger = MPSMatrixRandomPhilox(rng.device, UInt32, seed, MPSMatrixRandomDefaultDistributionDescriptor())
    rng.uniformFloat32 = MPSMatrixRandomPhilox(rng.device, Float32, seed, MPSMatrixRandomUniformDistributionDescriptor(0, 1))
    rng.normalFloat32  = MPSMatrixRandomPhilox(rng.device, Float32, seed, MPSMatrixRandomNormalDistributionDescriptor(0, 1))
    return rng
end

Random.seed!(rng::RNG) = Random.seed!(rng, make_seed())

const GLOBAL_RNGs = Dict{MTLDevice,MPS.RNG}()
@autoreleasepool function default_rng()
    dev = device()
    get!(GLOBAL_RNGs, dev) do
        RNG(dev)
    end
end

const UniformTypes = [Float32,UInt8,Int8,UInt16,Int16,UInt32,Int32,UInt64,Int64]
const UniformType = Union{[Type{T} for T in UniformTypes]...}
const UniformArray = MtlArray{<:Union{Float32,UInt8,Int8,UInt16,Int16,UInt32,Int32,UInt64,Int64}}
@autoreleasepool function Random.rand!(rng::RNG, A::MtlArray{T}) where {T<:Union{UInt8,Int8,UInt16,Int16,UInt32,Int32,UInt64,Int64}}
    isempty(A) && return A
    _mpsmat_rand!(rng.uniformInteger, A, UInt32)
    return A
end

@autoreleasepool function Random.rand!(rng::RNG, A::MtlArray{Float32})
    isempty(A) && return A
    _mpsmat_rand!(rng.uniformFloat32, A, Float32)
    return A
end

const NormalType = Type{Float32}
const NormalArray = MtlArray{<:Float32}
@autoreleasepool function Random.randn!(rng::RNG, A::MtlArray{Float32})
    isempty(A) && return A
    _mpsmat_rand!(rng.normalFloat32, A, Float32)
    return A
end

# CPU arrays
# TODO: use unsafe_wrap when possible
function Random.rand!(rng::RNG, A::AbstractArray{T, N}) where {T <: Union{UniformTypes...}, N}
    isempty(A) && return A
    B = MtlArray{T, N, SharedStorage}(undef, size(A))
    rand!(rng, B)
    return copyto!(A, B)
end
function Random.randn!(rng::RNG, A::AbstractArray{T, N}) where {T <: Float32, N}
    isempty(A) && return A
    B = MtlArray{T, N, SharedStorage}(undef, size(A))
    randn!(rng, B)
    return copyto!(A, B)
end

# Out of place
Random.rand(rng::RNG, T::UniformType, dims::Dims; storage=DefaultStorageMode) =
    Random.rand!(rng, MtlArray{T,length(dims),storage}(undef, dims...))
Random.randn(rng::RNG, T::NormalType, dims::Dims; storage=DefaultStorageMode) =
    Random.randn!(rng, MtlArray{T,length(dims),storage}(undef, dims...))

# support all dimension specifications
Random.rand(rng::RNG, T::UniformType, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.rand!(rng, MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))
Random.randn(rng::RNG, T::NormalType, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.randn!(rng, MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))

# untyped out-of-place
Random.rand(rng::RNG, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.rand!(rng, MtlArray{Float32,length(dims) + 1,storage}(undef, dim1, dims...))
Random.randn(rng::RNG, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.randn!(rng, MtlArray{Float32,length(dims) + 1,storage}(undef, dim1, dims...))

# scalars
Random.rand(rng::RNG, T::UniformType=Float32; storage=SharedStorage) = rand(rng, T, 4; storage)[1]
Random.randn(rng::RNG, T::NormalType=Float32; storage=SharedStorage) = randn(rng, T, 4; storage)[1]
