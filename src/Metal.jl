module Metal

using GPUArrays
using Adapt
using GPUCompiler
using GPUToolbox
using LLVM
using LLVM.Interop
import LLVMDowngrader_jll
using Preferences: @load_preference, load_preference
using ExprTools: splitdef, combinedef
using ObjectiveC, .CoreFoundation, .Foundation, .Dispatch, .OS
import ObjectiveC: is_macos
import KernelAbstractions
using ScopedValues

using Reexport: @reexport

include("version.jl")
include("storage_type.jl")

# core library
include("../lib/mtl/MTL.jl")
using .MTL
export MTL

# essential stuff
include("state.jl")
include("initialization.jl")

# device functionality
include("device/utils.jl")
include("device/pointer.jl")
include("device/array.jl")
include("device/runtime.jl")
include("device/intrinsics/version.jl")
include("device/intrinsics/arguments.jl")
include("device/intrinsics/math.jl")
include("device/intrinsics/synchronization.jl")
include("device/intrinsics/memory.jl")
include("device/intrinsics/simd.jl")
include("device/intrinsics/atomics.jl")
include("device/malloc.jl")
include("device/random.jl")
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

# libraries
include("../lib/mps/MPS.jl")
export MPS
include("../lib/mpsgraphs/MPSGraphs.jl")
export MPSGraphs
# Re-export the public convolution API to the top-level Metal namespace.
# Internal helpers (conv_direct, imfilter, plan-cache management) stay in MPSGraphs.
using .MPSGraphs: conv, conv_fft, conv_fft!, conv_fft_fused, xcorr, plan_conv_fft, ConvFFTPlan
export conv, conv_fft, conv_fft!, conv_fft_fused, xcorr, plan_conv_fft, ConvFFTPlan

# LinearAlgebra
include("linalg.jl")

# array implementation
include("utilities.jl")
include("broadcast.jl")
include("mapreduce.jl")
include("accumulate.jl")
include("indexing.jl")
include("random.jl")
include("fft.jl")

# KernelAbstractions
include("MetalKernels.jl")
import .MetalKernels: MetalBackend
export MetalBackend

include("deprecated.jl")

include("precompile.jl")

end # module
