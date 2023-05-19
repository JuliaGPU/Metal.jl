module MTL

using CEnum
using ObjectiveC, .Foundation, .Dispatch


## version information

export darwin_version, macos_version

const _darwin_version = Ref{VersionNumber}()
function darwin_version()
    if !isassigned(_darwin_version)
        verstr = read(`uname -r`, String)
        _darwin_version[] = parse(VersionNumber, verstr)
    end
    _darwin_version[]
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
include("family.jl")

end # module
