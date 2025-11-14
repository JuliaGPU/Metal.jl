import KernelAbstractions
using Metal.MetalKernels

include(joinpath(dirname(pathof(KernelAbstractions)), "..", "test", "testsuite.jl"))

Testsuite.testsuite(()->MetalBackend(), "Metal", Metal, MtlArray, Metal.MtlDeviceArray; skip_tests=Set([
    "Convert",           # depends on https://github.com/JuliaGPU/Metal.jl/issues/69
    "SpecialFunctions",  # no equivalent Metal intrinsics for gamma, erf, etc
    "sparse",            # not supported yet
    "CPU synchronization",
    "fallback test: callable types",
]))
