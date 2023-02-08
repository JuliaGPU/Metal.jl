module MPS

using ..Metal

using ..cmt

import GPUArrays

# high-level wrappers
include("matrix.jl")

# integrations
include("linalg.jl")

end
