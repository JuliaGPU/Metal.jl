# version and support queries

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

@static if isdefined(Base, :OncePerProcess) # VERSION >= v"1.12.0-DEV.1421"
    const darwin_version = OncePerProcess{VersionNumber}() do
        _syscall_version("kern.osrelease")
    end
    const macos_version = OncePerProcess{VersionNumber}() do
        _syscall_version("kern.osproductversion")
    end
else
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
end

@doc """
    Metal.darwin_version() -> VersionNumber

Returns the host Darwin kernel version.

See also [`Metal.macos_version`](@ref).
""" darwin_version

@doc """
    Metal.macos_version() -> VersionNumber

Returns the host macOS version.

See also [`Metal.darwin_version`](@ref).
""" macos_version

# macOS version lower bound that doesn't error on non-macOS
_safe_minversion(ver) = Sys.isapple() && macos_version() >= ver

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

"""
    Metal.metallib_support() -> VersionNumber

Returns the highest supported version for the metallib file format.

See also [`Metal.air_support`](@ref) and [`Metal.metal_support`](@ref).
"""
function metallib_support()
    macos = macos_version()
    if macos >= v"15"
       v"1.2.8"
    elseif macos >= v"13"
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

"""
    Metal.air_support() -> VersionNumber

Returns the highest supported version for the embedded AIR bitcode format.

See also [`Metal.metallib_support`](@ref) and [`Metal.metal_support`](@ref).
"""
function air_support()
    macos = macos_version()
    if macos >= v"15"
        v"2.7"
    elseif macos >= v"14"
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

"""
    Metal.metal_support() -> VersionNumber

Returns the highest supported version for the Metal Shading Language.

See also [`Metal.metallib_support`](@ref) and [`Metal.air_support`](@ref).
"""
function metal_support()
    macos = macos_version()
    if macos >= v"15"
        v"3.2"
    elseif macos >= v"14"
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
