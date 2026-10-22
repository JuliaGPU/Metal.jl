"""
    MPSGraphs

Operations on `MtlArray`s implemented with Apple's
[Metal Performance Shaders Graph](https://developer.apple.com/documentation/metalperformanceshadersgraph)
framework, such as [`MPSGraphs.reduce!`](@ref) and [`MPSGraphs.matmul!`](@ref), and
low-level wrappers of the framework itself, which follow Apple's API closely.
"""
module MPSGraphs

using ..Metal
using .MTL
using .MPS
using .MPS: MPSDataType, MPSShape
using .MPS: MPSMatrixLike, MPSVectorLike
using BFloat16s

using CEnum
using GPUToolbox: @memoize
using ObjectiveC, .Foundation, .Dispatch

"""
    MPSGraphs.MPSGRAPH_VALID_MATMUL_TYPES

The combinations of input element type (of `A` and `B`) and output element type (of `C`),
as `(input, output)` tuples, that [`MPSGraphs.matmul!`](@ref) supports.
"""
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

"""
    MPSGraphs.MPSGRAPH_VALID_MATVECMUL_TYPES

The combinations of input element type (of `A` and `x`) and output element type (of `y`),
as `(input, output)` tuples, that [`MPSGraphs.matvecmul!`](@ref) supports.
"""
const MPSGRAPH_VALID_MATVECMUL_TYPES = MPSGRAPH_VALID_MATMUL_TYPES

# array-level operations, distinct from the functions of the same name in Base and MPS
function reduce! end
function accumulate! end
function sort! end
function sortperm! end
function matmul! end
function matvecmul! end

include("libmpsgraph.jl")

include("core.jl")
include("tensor.jl")
include("execution.jl")
include("operations.jl")
include("interface.jl")
include("random.jl")

include("matmul.jl")
include("fft.jl")
include("nn.jl")
include("sort.jl")
include("scan.jl")
include("reductions.jl")

include("deprecated.jl")

Metal.@public supports, reduce!, accumulate!, sort!, sortperm!, matmul!, matvecmul!,
               softmax!, logsoftmax!, softmax_grad!, logsoftmax_grad!, conv!,
               conv_data_grad!, conv_filter_grad!, maxpool!, maxpool_grad!, meanpool!,
               meanpool_grad!, MPSGRAPH_VALID_MATMUL_TYPES, MPSGRAPH_VALID_MATVECMUL_TYPES

end
