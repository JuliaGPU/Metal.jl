module MTL

using CEnum
using ObjectiveC, .Foundation, .Dispatch


## version information

export darwin_version, macos_version

const _darwin_version = Ref{VersionNumber}()
function darwin_version()
    if !isassigned(_darwin_version)
        size = Ref{Csize_t}()
        err = @ccall sysctlbyname("kern.osrelease"::Cstring, C_NULL::Ptr{Cvoid}, size::Ptr{Csize_t}, C_NULL::Ptr{Cvoid}, 0::Csize_t)::Cint
        Base.systemerror("sysctlbyname", err != 0)
        osrelease = Vector{Cchar}(undef, size[])
        err = @ccall sysctlbyname("kern.osrelease"::Cstring, osrelease::Ptr{Cvoid}, size::Ptr{Csize_t}, C_NULL::Ptr{Cvoid}, 0::Csize_t)::Cint
        Base.systemerror("sysctlbyname", err != 0)
        osrelease[end] = 0
        verstr = GC.@preserve osrelease unsafe_string(pointer(osrelease))
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
