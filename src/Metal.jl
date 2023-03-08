module Metal

using Reexport
using GPUArrays
using Adapt
using GPUCompiler
using LLVM
using LLVM.Interop
using Metal_LLVM_Tools_jll
using ExprTools: splitdef, combinedef
using ObjectiveC, .Foundation, .Dispatch

# core library
include("../lib/mtl/MTL.jl")
@reexport using .MTL

# essential stuff
include("state.jl")
include("initialization.jl")

# device functionality
include("device/utils.jl")
include("device/pointer.jl")
include("device/array.jl")
include("device/runtime.jl")
include("device/intrinsics/arguments.jl")
include("device/intrinsics/math.jl")
include("device/intrinsics/synchronization.jl")
include("device/intrinsics/memory.jl")
include("device/intrinsics/simd.jl")
include("device/quirks.jl")

# array essentials
include("memory.jl")
include("array.jl")

# compiler implementation
include("compiler/gpucompiler.jl")
include("compiler/execution.jl")
include("compiler/reflection.jl")

# array implementation
include("utilities.jl")
include("broadcast.jl")
include("mapreduce.jl")
include("random.jl")
include("gpuarrays.jl")

# libraries
include("../lib/mps/MPS.jl")
export MPS

end # module
