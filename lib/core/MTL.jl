module MTL

import Libdl
using CEnum
using Scratch
using JSON

const libcmt = joinpath(@get_scratch!("cmt"), "lib", "libcmt.dylib")

## source code includes

# Basic types
include("libcmt_common.jl")
include("error.jl")
# convert from 1 based indexing to 0 based indexing
Base.convert(::Type{NsRange}, range::UnitRange{T}) where T <: Integer =
	NsRange(first(range), length(range))
# used for byte ranges.
Base.convert(::Type{NsRange}, range::StepRange{T}) where T <: Integer =
	NsRange(first(range)-step(range), length(range)*step(range))

# low-level autogeneraed wrappers
export MtSize, MtlDim, MtlDim3
include("libcmt_aliases.jl")
include("libcmt.jl")

include("helpers.jl")

# julia wrappers
include("storage_type.jl")
include("resource.jl")
include("device.jl")
include("compile-opts.jl")
include("library.jl")
include("function.jl")
include("events.jl")
include("fences.jl")
include("heap.jl")
include("buffer.jl")
include("command_queue.jl")
include("command_buf.jl")
include("compute-pipeline.jl")
include("argument_encoder.jl")

include("command_enc.jl")
include("command_enc_blit.jl")
include("command_enc_compute.jl")

include("reflection/reflection_compute.jl")

include("size.jl")

end # module
