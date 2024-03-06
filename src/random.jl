using Random

gpuarrays_rng() = GPUArrays.default_rng(MtlArray)

# GPUArrays in-place
Random.rand!(A::MtlArray) = Random.rand!(gpuarrays_rng(), A)
Random.randn!(A::MtlArray) = Random.randn!(gpuarrays_rng(), A)

# GPUArrays out-of-place
rand(T::Type, dims::Dims; storage=DefaultStorageMode) = Random.rand!(MtlArray{T,length(dims),storage}(undef, dims...))
randn(T::Type, dims::Dims; storage=DefaultStorageMode, kwargs...) = Random.randn!(MtlArray{T,length(dims),storage}(undef, dims...); kwargs...)

# support all dimension specifications
rand(T::Type, dim1::Integer, dims::Integer...; storage=DefaultStorageMode) =
    Random.rand!(MtlArray{T,length(dims)+1,storage}(undef, dim1, dims...))
randn(T::Type, dim1::Integer, dims::Integer...; storage=DefaultStorageMode, kwargs...) =
    Random.randn!(MtlArray{T,length(dims)+1,storage}(undef, dim1, dims...); kwargs...)

# untyped out-of-place
rand(dim1::Integer, dims::Integer...; storage=DefaultStorageMode) = Random.rand!(MtlArray{Float32,length(dims)+1,storage}(undef, dim1, dims...))
randn(dim1::Integer, dims::Integer...; storage=DefaultStorageMode, kwargs...) = Random.randn!(MtlArray{Float32,length(dims)+1,storage}(undef, dim1, dims...); kwargs...)

# seeding
seed!(seed=Base.rand(UInt64)) = Random.seed!(gpuarrays_rng(), seed)
