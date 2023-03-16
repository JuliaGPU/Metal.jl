module MPS

using ..Metal

using CEnum
using ObjectiveC, .Foundation

import GPUArrays

is_supported(dev::MTLDevice) = ccall(:MPSSupportsMTLDevice, Bool, (id{MTLDevice},), dev)

# high-level wrappers
include("matrix.jl")

# integrations
include("linalg.jl")

# decompositions
include("decomposition.jl")

# matrix copy
include("copy.jl")

end
