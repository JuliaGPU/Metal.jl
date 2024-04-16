using Random
using ..MPS: MPSVector, _mpsmat_rand!, MPSMatrixRandomUniformDistributionDescriptor,
             MPSMatrixRandomNormalDistributionDescriptor

gpuarrays_rng() = GPUArrays.default_rng(MtlArray)
mpsrand_rng() = MPS.default_rng()

# GPUArrays in-place
Random.rand!(A::MtlArray) = Random.rand!(gpuarrays_rng(), A)
Random.randn!(A::MtlArray) = Random.randn!(gpuarrays_rng(), A)

@inline function can_use_mpsrandom(A::MtlArray{T}) where {T}
    return A.offset * sizeof(T) % 4 == 0 && sizeof(A) % 4 == 0
end

# Use MPS random functionality where possible
function Random.rand!(A::MPS.UniformArray)
    if can_use_mpsrandom(A)
        @inline Random.rand!(mpsrand_rng(), A)
    else
        @inline Random.rand!(gpuarrays_rng(), A)
    end
    return A
end
function Random.randn!(A::MPS.NormalArray)
    if can_use_mpsrandom(A)
        @inline Random.randn!(mpsrand_rng(), A)
    else
        @inline Random.randn!(gpuarrays_rng(), A)
    end
    return A
end

# GPUArrays out-of-place
rand(T::MPS.UniformType, dims::Dims; storage=DefaultStorageMode) =
    Random.rand!(mpsrand_rng(), MtlArray{T,length(dims),storage}(undef, dims...))
randn(T::MPS.NormalType, dims::Dims; storage=DefaultStorageMode) =
    Random.randn!(mpsrand_rng(), MtlArray{T,length(dims),storage}(undef, dims...))
rand(T::Type, dims::Dims; storage=DefaultStorageMode) =
    Random.rand!(gpuarrays_rng(), MtlArray{T,length(dims),storage}(undef, dims...))
randn(T::Type, dims::Dims; storage=DefaultStorageMode) =
    Random.randn!(gpuarrays_rng(), MtlArray{T,length(dims),storage}(undef, dims...))

# support all dimension specifications
rand(T::MPS.UniformType, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.rand!(mpsrand_rng(), MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))
randn(T::MPS.NormalType, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.randn!(mpsrand_rng(), MtlArray{T,length(dims) + 1,storage}(undef, dim1, dims...))

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
rand(T::Type=Float32; storage=Shared) = rand(T, 1; storage)[]
randn(T::Type=Float32; storage=Shared) = randn(T, 1; storage)[]

# seeding
function seed!(seed=Base.rand(UInt64))
    Random.seed!(gpuarrays_rng(), seed)
    Random.seed!(mpsrand_rng(), seed)
end
