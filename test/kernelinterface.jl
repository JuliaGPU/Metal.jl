import KernelInterface
using Metal.MetalInterface

include(joinpath(dirname(pathof(KernelInterface)), "..", "test", "testsuite.jl"))

Testsuite.testsuite(MetalInterface.MetalBackend, "Metal", Metal, MtlArray, Metal.MtlDeviceArray)
