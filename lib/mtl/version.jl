# version and support queries

export darwin_version, macos_version, metallib_support, air_support, metal_support

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


## support queries

# these can queried using the Metal compiler:
# $ xcrun metal -mmacosx-version-min=10.12 dummy.metal -o dummy.metallib
#
# what to look for
# - metallib support: in the metallib header (4 bytes at 0x06)
# - air support: first 2 bytes of the VERS tag in the function list,
#                or air.version in the embedded bitcode
# - metal support: last 2 bytes of the VERS tag in the function list,
#                  or air.language_version in the embedded bitcode

# support for the metallib file format
function metallib_support()
    macos = macos_version()
    if macos >= v"13"
        v"1.2.7"
    elseif macos >= v"12"
        v"1.2.6"
    elseif macos >= v"11"
        v"1.2.5"
    elseif macos >= v"10.15"
        v"1.2.4"
    elseif macos >= v"10.14"
        v"1.2.3"
    elseif macos >= v"10.13"
        v"1.2.2"
    else
        error("Metal.jl is not supported on macOS < 10.13")
    end
end

# support for the embedded AIR bitcode format
function air_support()
    macos = macos_version()
    if macos >= v"14"
        v"2.6"
    elseif macos >= v"13"
        v"2.5"
    elseif macos >= v"12"
        v"2.4"
    elseif macos >= v"11"
        v"2.3"
    elseif macos >= v"10.15"
        v"2.2"
    elseif macos >= v"10.14"
        v"2.1"
    elseif macos >= v"10.13"
        v"2.0"
    else
        error("Metal.jl is not supported on macOS < 10.13")
    end
end

# support for the Metal language
function metal_support()
    macos = macos_version()
    if macos >= v"14"
        v"3.1"
    elseif macos >= v"13"
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
        error("Metal.jl is not supported on macOS < 10.13")
    end
end
