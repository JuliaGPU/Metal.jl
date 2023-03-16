module MPS

using ..Metal

using CEnum
using ObjectiveC, .Foundation

import GPUArrays

is_supported(dev::MTLDevice) = ccall(:MPSSupportsMTLDevice, Bool, (id{MTLDevice},), dev)

# MPS kernel base clases
include("kernel.jl")

# high-level wrappers
include("matrix.jl")

# integrations
include("linalg.jl")

# decompositions
include("decomposition.jl")

# matrix copy
include("copy.jl")

end
