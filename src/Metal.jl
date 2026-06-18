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
using BFloat16s: BFloat16
using ScopedValues

using Reexport: @reexport

# `@public foo, bar` → `public foo, bar` on Julia ≥ 1.11, nothing on older.
# `public` is only parseable at module top-level on all Julia versions, so a
# bare `@static if ...; public foo; end` would fail at parse time. Taking the
# names through a macro sidesteps that: `foo, bar` parses as a plain tuple,
# and we splice its members into an `Expr(:public, ...)` the lowerer accepts.
macro public(names)
    @static if VERSION >= v"1.11"
        syms = names isa Symbol ? (names,) :
               Meta.isexpr(names, :tuple) ? names.args :
               error("@public expects a symbol or a comma-separated list of symbols")
        return esc(Expr(:public, syms...))
    else
        return nothing
    end
end

include("version.jl")
include("storage_type.jl")

# core library
include("../lib/mtl/MTL.jl")
using .MTL
export MTL

# essential stuff
include("state.jl")
include("synchronization.jl")
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
include("device/intrinsics/tensor.jl")
include("device/intrinsics/atomics.jl")
include("device/malloc.jl")
include("device/intrinsics/output.jl")
include("device/random.jl")
include("device/quirks.jl")

# array essentials
include("pool.jl")
include("memory.jl")
include("array.jl")

# compiler implementation
include("compiler/library.jl")
include("compiler/compilation.jl")
include("compiler/exceptions.jl")
include("compiler/execution.jl")
include("compiler/reflection.jl")

# libraries
include("../lib/mps/MPS.jl")
export MPS
include("../lib/mpsgraphs/MPSGraphs.jl")
export MPSGraphs

# LinearAlgebra
include("gemm.jl")
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
