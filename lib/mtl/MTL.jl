module MTL

using ..cmt

using CEnum
using ObjectiveC, .Foundation, .Dispatch


## version information

export darwin_version, macos_version

function darwin_version()
    # extract the trailing `-darwinXXX` bit from the triple
    machine = Sys.MACHINE
    VersionNumber(machine[findfirst("darwin", machine)[end]+1:end])
end

const _macos_version = Ref{VersionNumber}()
function macos_version()
    if !isassigned(_macos_version)
        verstr = read(`sw_vers -productVersion`, String)
        _macos_version[] = parse(VersionNumber, verstr)
    end
    _macos_version[]
end


## source code includes

# low-level wrappers
#include("error.jl")
include("helpers.jl")

# high-level wrappers
include("size.jl")
include("device.jl")
include("resource.jl")
include("storage_type.jl")
include("compile-opts.jl")
include("library.jl")
include("function.jl")
include("events.jl")
include("fences.jl")
include("heap.jl")
include("buffer.jl")
include("command_queue.jl")
include("command_buf.jl")
include("compute_pipeline.jl")
include("command_enc.jl")
include("command_enc/blit.jl")
include("command_enc/compute.jl")
include("binary_archive.jl")
include("capture.jl")

function __init__()
    precompiling = ccall(:jl_generating_output, Cint, ()) != 0
    precompiling && return

    Sys.isapple() || return

    load_framework("CoreGraphics")
end

end # module
