import KernelAbstractions
using Metal.MetalKernels
using Test

@test KernelAbstractions.supports_atomics(MetalBackend())

include(joinpath(dirname(pathof(KernelAbstractions)), "..", "test", "testsuite.jl"))

skip_tests = Set([
    "Convert",           # depends on https://github.com/JuliaGPU/Metal.jl/issues/69
    "SpecialFunctions",  # gamma and erfc not currently supported on Metal.jl
    "sparse",            # not supported yet
])
if Metal.is_virtual(Metal.device())
    # device-side printing needs GPU logging, which is unsupported on virtualized GPUs
    push!(skip_tests, "Printing")
end

Testsuite.testsuite(MetalBackend, "Metal", Metal, MtlArray, Metal.MtlDeviceArray; skip_tests)
