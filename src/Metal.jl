module Metal

using Reexport
using GPUArrays
using Adapt
using GPUCompiler
using LLVM
using LLVM.Interop
using Metal_LLVM_Tools_jll
using ExprTools: splitdef, combinedef

# core library
include("../lib/core/MTL.jl")
@reexport using .MTL

# device functionality
include("device/utils.jl")
include("device/pointer.jl")
include("device/array.jl")
include("device/metal/arguments.jl")
include("device/metal/math.jl")
include("device/metal/synchronization.jl")

# compiler
include("compiler/gpucompiler.jl")
include("compiler/execution.jl")
include("compiler/reflection.jl")

include("state.jl")
include("utilities.jl")
include("initialization.jl")

# array abstraction
include("array.jl")
include("memory.jl")
include("broadcast.jl")
include("random.jl")
include("gpuarrays.jl")

end # module
