module MetalCore

using Reexport
using GPUArrays
using Adapt
using GPUCompiler
using LLVM
using LLVM.Interop

# Analogous do MetalApi .
# API and julian wrappers defined here
include("Metal/Metal.jl")
@reexport using .Metal

# Device-side types and conversion
include("device/pointer_abstract.jl")
include("device/pointer_ptr.jl")
include("device/pointer_buf.jl")
include("device/array.jl")
include("device/metal.jl")

# Compiler stuff
include("execution/mtl_type_conversion.jl")
include("execution/device_type_conversion.jl")
include("execution/kernel.jl")

include("context.jl")


# MtlArrays stuff
include("host/array.jl")
include("host/memory.jl")


end # module
