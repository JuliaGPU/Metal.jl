module Metal

import Libdl
using CEnum

const cmt_lib = joinpath(@__DIR__, "..", "..", "deps", "libcmt_lib.dylib")

## source code includes

# Basic types
include("api/libcmt_common.jl")
#include("pointer.jl")
include("error.jl")
# convert from 1 based indexing to 0 based indexing
Base.convert(::Type{NsRange}, range::UnitRange{T}) where T <: Integer =
	NsRange(first(range), length(range))
# used for byte ranges.
Base.convert(::Type{NsRange}, range::StepRange{T}) where T <: Integer =
	NsRange(first(range)-step(range), length(range)*step(range))

# low-level autogeneraed wrappers
export MtSize
include("api/libcmt_aliases.jl")
include("api/libcmt.jl")

# julia wrappers
include("wrappers/_base.jl")
include("wrappers/storage_type.jl")
include("wrappers/resource.jl")
include("wrappers/device.jl")
include("wrappers/compile-options.jl")
include("wrappers/library.jl")
include("wrappers/function.jl")
include("wrappers/events.jl")
include("wrappers/heap.jl")
include("wrappers/buffer.jl")
include("wrappers/cmd-queue.jl")
include("wrappers/cmd-buffer.jl")
include("wrappers/compute-pipeline-state.jl")

include("wrappers/command_enc.jl")
include("wrappers/command_enc_blit.jl")
include("wrappers/command_enc_compute.jl")

# high-level operations

end # module
