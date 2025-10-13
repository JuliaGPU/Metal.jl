using Random
using ..MPS: MPSVector, _mpsmat_rand!, MPSMatrixRandomUniformDistributionDescriptor,
             MPSMatrixRandomNormalDistributionDescriptor

gpuarrays_rng() = GPUArrays.default_rng(MtlArray)
mpsrand_rng() = MPS.default_rng()

# GPUArrays in-place
Random.rand!(A::MtlArray) = Random.rand!(gpuarrays_rng(), A)
Random.randn!(A::MtlArray) = Random.randn!(gpuarrays_rng(), A)

# Use MPS random functionality where possible
function Random.rand!(A::MPS.UniformArray)
    return Random.rand!(mpsrand_rng(), A)
end
function Random.randn!(A::MPS.NormalArray)
    return Random.randn!(mpsrand_rng(), A)
end

# GPUArrays out-of-place
function rand(T::MPS.UniformType, dims::Dims; storage=DefaultStorageMode)
    return Random.rand!(mpsrand_rng(), MtlArray{T,length(dims),storage}(undef, dims...))
end
function randn(T::MPS.NormalType, dims::Dims; storage=DefaultStorageMode)
    return Random.randn!(mpsrand_rng(), MtlArray{T,length(dims),storage}(undef, dims...))
end
rand(T::Type, dims::Dims; storage=DefaultStorageMode) =
    Random.rand!(gpuarrays_rng(), MtlArray{T,length(dims),storage}(undef, dims...))
randn(T::Type, dims::Dims; storage=DefaultStorageMode) =
    Random.randn!(gpuarrays_rng(), MtlArray{T,length(dims),storage}(undef, dims...))

# support all dimension specifications
function rand(T::MPS.UniformType, dim1::Integer, dims::Integer...; storage=DefaultStorageMode)
    return Random.rand!(mpsrand_rng(), MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))
end
function randn(T::MPS.NormalType, dim1::Integer, dims::Integer...; storage=DefaultStorageMode)
    return Random.randn!(mpsrand_rng(), MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))
end

rand(T::Type, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.rand!(gpuarrays_rng(), MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))
randn(T::Type, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.randn!(gpuarrays_rng(), MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))

# untyped out-of-place
rand(dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.rand!(mpsrand_rng(), MtlArray{Float32,length(dims) + 1,storage}(undef, dim1, dims...))
randn(dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.randn!(mpsrand_rng(), MtlArray{Float32,length(dims) + 1,storage}(undef, dim1, dims...))

# scalars
rand(T::Type=Float32; storage=SharedStorage) = rand(T, 1; storage)[1]
randn(T::Type=Float32; storage=SharedStorage) = randn(T, 1; storage)[1]

# seeding
function seed!(seed=Base.rand(UInt64))
    Random.seed!(gpuarrays_rng(), seed)
    Random.seed!(mpsrand_rng(), seed)
end
