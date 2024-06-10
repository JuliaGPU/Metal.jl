"""
# MPS

`MPS` is where the Metal Performance Shaders API wrappers are defined.

For the full API, refer to Apple's documentation at https://developer.apple.com/documentation/metalperformanceshaders.

Not all functionality is currently implemented.
"""
module MPS

using ..Metal

using CEnum
using ObjectiveC, .Foundation

import GPUArrays

const MtlFloat = Union{Float32, Float16}

is_supported(dev::MTLDevice) = ccall(:MPSSupportsMTLDevice, Bool, (id{MTLDevice},), dev)

include("size.jl")

# high-level wrappers
include("command_buf.jl")
include("kernel.jl")
include("images.jl")
include("matrix.jl")
include("vector.jl")
include("decomposition.jl")
include("copy.jl")

# integrations
include("linalg.jl")

end
