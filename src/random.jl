using Random

# GPUArrays in-place
Random.rand!(A::MtlArray) = Random.rand!(GPUArrays.default_rng(MtlArray), A)
Random.randn!(A::MtlArray) = Random.randn!(GPUArrays.default_rng(MtlArray), A)

# GPUArrays out-of-place
rand(T::Type, dims::Dims) = Random.rand!(MtlArray{T}(undef, dims...))
randn(T::Type, dims::Dims; kwargs...) = Random.randn!(MtlArray{T}(undef, dims...); kwargs...)

# support all dimension specifications
rand(T::Type, dim1::Integer, dims::Integer...) =
    Random.rand!(MtlArray{T}(undef, dim1, dims...))
randn(T::Type, dim1::Integer, dims::Integer...; kwargs...) =
    Random.randn!(MtlArray{T}(undef, dim1, dims...); kwargs...)

# untyped out-of-place
rand(dim1::Integer, dims::Integer...) = Random.rand!(MtlArray{Float32}(undef, dim1, dims...))
randn(dim1::Integer, dims::Integer...; kwargs...) = Random.randn!(MtlArray{Float32}(undef, dim1, dims...))
