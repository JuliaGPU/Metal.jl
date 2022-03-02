using Random

# Random.rand!(A::oneWrappedArray) = Random.rand!(GPUArrays.default_rng(oneArray), A)
# Random.randn!(A::oneWrappedArray) = Random.randn!(GPUArrays.default_rng(oneArray), A)