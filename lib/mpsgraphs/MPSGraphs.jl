"""
# MPSGraphs

`MPSGraphs` is where the Metal Performance Shaders Graph API wrappers are defined.

Not all functionality is currently implemented or documented. For further details,
refer to the [official Apple documentation](https://developer.apple.com/documentation/metalperformanceshadersgraph).
"""
module MPSGraphs

using ..Metal
using .MTL
using .MPS
using .MPS: MPSDataType, MPSShape, exportDataWithCommandBuffer
using .MPS: MPSMatrixLike, MPSVectorLike
using BFloat16s

using CEnum
using GPUToolbox: @memoize
using ObjectiveC, .Foundation, .Dispatch

# Valid combination of input (A and B matrices) and output (C) types
#   The commented type combinations work but are slower than with MPSMatrixMultiplicatiom
const MPSGRAPH_VALID_MATMUL_TYPES =
    [
     (Int8, Float16),
     (Int8, Float32),
     (Int16, Float32),
     (Float16, Float16),
     (Float16, Float32),
     (Float32, Float32),
     (BFloat16, BFloat16),
     (Float16, ComplexF16),
     (Float16, ComplexF32),
     (Float32, ComplexF32),
     (ComplexF16, ComplexF16),
     (ComplexF16, ComplexF32),
     (ComplexF32, ComplexF32),
    ]

const MPSGRAPH_VALID_MATVECMUL_TYPES = MPSGRAPH_VALID_MATMUL_TYPES

include("libmpsgraph.jl")

include("core.jl")
include("tensor.jl")
include("execution.jl")
include("operations.jl")
include("random.jl")

include("matmul.jl")
include("fft.jl")
include("nn.jl")
include("sort.jl")
include("scan.jl")
include("reductions.jl")

end
