module MetalCore

import Libdl

# Load in `deps.jl`, complaining if it does not exist
#const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
#const depsjl_path = joinpath(@__DIR__, "..", "deps", "libcmt_lib.dylib")
#const libcmt_path = joinpath(@__DIR__, "..", "deps", "libcmt_lib.dylib")

#const cmt_lib = joinpath(@__DIR__, "..", "cmt", "build", "libcmt_lib.dylib")
const cmt_lib = joinpath(@__DIR__, "..", "deps", "libcmt_lib.dylib")

#include(depsjl_path)
# Module initialization function
function __init__()
    #check_deps()
    #cmt_lib = Libdl.dlopen(libcmt_path)
end

using CEnum


## source code includes

# essential functionality
include("pointer.jl")
const MTLdeviceptr = MtlPtr{Cvoid}

# low-level autogeneraed wrappers
include("libcmt_common.jl")
include("error.jl")
include("libcmt_aliases.jl")
include("libcmt.jl")

# export everything
#foreach(names(@__MODULE__, all=true)) do s
#    if startswith(string(s), "SOME_PREFIX")
#        @eval export $s
#    end
#end

#
Base.convert(::Type{NsRange}, range::UnitRange{T}) where T<:Integer = 
	NsRange(first(range), length(range))
#

include("wrappers/_base.jl")
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
include("wrappers/compute-comm-enc.jl")

end # module
