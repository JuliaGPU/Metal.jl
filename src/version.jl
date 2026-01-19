export macos_version, darwin_version

"""
    macos_version()::VersionNumber

Returns the host macOS version.

See also [`Metal.darwin_version`](@ref).
"""
const macos_version = ObjectiveC.macos_version

"""
    darwin_version()::VersionNumber

Returns the host Darwin kernel version.

See also [`Metal.macos_version`](@ref).
"""
const darwin_version = ObjectiveC.darwin_version

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
    Metal.metallib_support()::VersionNumber

Returns the highest supported version for the metallib file format.

See also [`Metal.air_support`](@ref) and [`Metal.metal_support`](@ref).
"""
function metallib_support()
    macos = macos_version()
    if macos >= v"16" # Tahoe is v"26" but can report v"16" with julia versions not compiled with the Tahoe SDK
        v"1.2.9"
    elseif macos >= v"15"
        v"1.2.8"
    else # macOS 13-14
        v"1.2.7"
    end
end

"""
    Metal.air_support()::VersionNumber

Returns the highest supported version for the embedded AIR bitcode format.

See also [`Metal.metallib_support`](@ref) and [`Metal.metal_support`](@ref).
"""
function air_support()
    macos = macos_version()
    if macos >= v"16" # Tahoe is v"26" but can report v"16" with julia versions not compiled with the Tahoe SDK
        v"2.8"
    elseif macos >= v"15"
        v"2.7"
    elseif macos >= v"14"
        v"2.6"
    else # macOS 13
        v"2.5"
    end
end

"""
    Metal.metal_support()::VersionNumber

Returns the highest supported version for the Metal Shading Language.

See also [`Metal.metallib_support`](@ref) and [`Metal.air_support`](@ref).
"""
function metal_support()
    macos = macos_version()
    if macos >= v"16" # Tahoe is v"26" but can report v"16" with julia versions not compiled with the Tahoe SDK
        v"4"
    elseif macos >= v"15"
        v"3.2"
    elseif macos >= v"14"
        v"3.1"
    else # macOS 13
        v"3.0"
    end
end
