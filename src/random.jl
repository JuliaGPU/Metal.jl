using Random

Random.rand!(A::MtlArray) = Random.rand!(GPUArrays.default_rng(MtlArray), A)
Random.randn!(A::MtlArray) = Random.randn!(GPUArrays.default_rng(MtlArray), A)