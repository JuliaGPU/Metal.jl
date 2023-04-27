module MTL

using CEnum
using ObjectiveC, .Foundation, .Dispatch


## version information

export darwin_version, macos_version, metal_version

@noinline function _syscall_version(name)
    size = Ref{Csize_t}()
    err = @ccall sysctlbyname(name::Cstring, C_NULL::Ptr{Cvoid}, size::Ptr{Csize_t},
                              C_NULL::Ptr{Cvoid}, 0::Csize_t)::Cint
    Base.systemerror("sysctlbyname", err != 0)

    osrelease = Vector{UInt8}(undef, size[])
    err = @ccall sysctlbyname(name::Cstring, osrelease::Ptr{Cvoid}, size::Ptr{Csize_t},
                              C_NULL::Ptr{Cvoid}, 0::Csize_t)::Cint
    Base.systemerror("sysctlbyname", err != 0)

    verstr = view(String(osrelease), 1:size[]-1)
    parse(VersionNumber, verstr)
end

const _darwin_version = Ref{VersionNumber}()
function darwin_version()
    if !isassigned(_darwin_version)
        _darwin_version[] = _syscall_version("kern.osrelease")
    end
    _darwin_version[]
end

const _macos_version = Ref{VersionNumber}()
function macos_version()
    if !isassigned(_macos_version)
        _macos_version[] = _syscall_version("kern.osproductversion")
    end
    _macos_version[]
end

function metal_version()
    macos = macos_version()
    if macos >= v"13"
        v"3.0"
    elseif macos >= v"12"
        v"2.4"
    elseif macos v> v"11"
        v"2.3"
    elseif macos >= v"10.15"
        v"2.2"
    elseif macos >= v"10.14"
        v"2.1"
    elseif macos >= v"10.13"
        v"2.0"
    else
        error("Metal is not supported on macOS < 10.13")
    end
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
