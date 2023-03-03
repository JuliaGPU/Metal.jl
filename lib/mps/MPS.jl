module MPS

using ..Metal

using ..cmt

import GPUArrays

is_supported(dev::MTLDevice) = mtMPSSupportsMTLDevice(dev)

# high-level wrappers
include("matrix.jl")

# integrations
include("linalg.jl")

end
