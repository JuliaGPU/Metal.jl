module MPS

using ..Metal

import GPUArrays

# low-level API: part of cmt, so accessed through MTL

# high-level wrappers
include("matrix.jl")

# integrations
include("linalg.jl")

end
