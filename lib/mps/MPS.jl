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
