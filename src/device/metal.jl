# wrappers for functionality provided by the Metal library toolkit


# functionality from libdevice
#
# > The libdevice library is a collection of NVVM bitcode functions that implement common
# > functions for Metal GPU devices, including math primitives and bit-manipulation
# > functions. These functions are optimized for particular GPU architectures, and are
# > intended to be linked with an NVVM IR module during compilation to PTX.
include("metal/math.jl")
