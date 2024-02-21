module Metal

using Reexport
using GPUArrays
using Adapt
using GPUCompiler
using LLVM
using LLVM.Interop
import LLVMDowngrader_jll
using Python_jll
using ObjectFile
using ExprTools: splitdef, combinedef
using Artifacts
using ObjectiveC, .CoreFoundation, .Foundation, .Dispatch

if !isdefined(Base, :get_extension)
    using Requires: @require
end

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
include("device/intrinsics/version.jl")
include("device/intrinsics/atomics.jl")
include("device/quirks.jl")

# array essentials
include("pool.jl")
include("memory.jl")
include("array.jl")

# compiler implementation
include("compiler/library.jl")
include("compiler/compilation.jl")
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

# KernelAbstractions
include("MetalKernels.jl")
import .MetalKernels: MetalBackend
export MetalBackend

end # module
