import KernelAbstractions
using Test

include(joinpath(dirname(pathof(KernelAbstractions)), "..", "test", "testsuite.jl"))

using Metal
using Metal.MetalKernels

# TODO: check if Metal is functional (depends on https://github.com/JuliaGPU/Metal.jl/issues/121)
Metal.versioninfo()
Metal.allowscalar(false)
Testsuite.testsuite(()->MetalBackend(), "Metal", Metal, MtlArray, Metal.MtlDeviceArray; skip_tests=Set([
    "Convert",           # depends on https://github.com/JuliaGPU/Metal.jl/issues/69
    "SpecialFunctions",  # no equivalent Metal intrinsics for gamma, erf, etc
    "sparse",            # not supported yet
]))
