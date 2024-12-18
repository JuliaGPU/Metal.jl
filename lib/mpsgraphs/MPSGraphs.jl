"""
# MPSGraphs

`MPSGraphs` is where the Metal Performance Shaders Graph API wrappers are defined.

Not all functionality is currently implemented or documented. For further details,
refer to the [official Apple documentation](https://developer.apple.com/documentation/metalperformanceshadersgraph).
"""
module MPSGraphs

using ..Metal
using .MTL
using .MPS: MPSDataType, MPSMatrix, MPSVector, MPSShape, MPSNDArray

using CEnum
using ObjectiveC, .Foundation, .Dispatch

include("libmpsgraph.jl")

include("core.jl")
include("tensor.jl")
include("operations.jl")
include("random.jl")

end
