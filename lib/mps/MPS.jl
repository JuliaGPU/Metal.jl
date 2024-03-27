"""
# MPS

`MPS` is where the Metal Performance Shaders API wrappers are defined.

Not all functionality is currently implemented or documented. For further details,
refer to the [official Apple documentation](https://developer.apple.com/documentation/metalperformanceshaders).
"""
module MPS

using ..Metal
using .MTL

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
include("matrixrandom.jl")
include("decomposition.jl")
include("copy.jl")

# integrations
include("linalg.jl")

end
