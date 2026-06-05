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
    Metal.metallib_support(macos=macos_version())::VersionNumber

Returns the highest metallib file-format version supported by `macos` (defaulting to the
host macOS version).

See also [`Metal.air_support`](@ref) and [`Metal.metal_support`](@ref).
"""
function metallib_support(macos::VersionNumber = macos_version())
    if macos >= v"16" # Tahoe is v"26" but can report v"16" with julia versions not compiled with the Tahoe SDK
        v"1.2.9"
    elseif macos >= v"15"
        v"1.2.8"
    else # macOS 13-14
        v"1.2.7"
    end
end

"""
    Metal.air_support(macos=macos_version())::VersionNumber

Returns the highest embedded-AIR-bitcode version supported by `macos` (defaulting to the
host macOS version).

See also [`Metal.metallib_support`](@ref) and [`Metal.metal_support`](@ref).
"""
function air_support(macos::VersionNumber = macos_version())
    if macos >= v"16" # Tahoe is v"26" but can report v"16" with julia versions not compiled with the Tahoe SDK
        v"2.8"
    elseif macos >= v"15"
        v"2.7"
    else # macOS 14
        v"2.6"
    end
end

"""
    Metal.metal_support(macos=macos_version())::VersionNumber

Returns the highest Metal Shading Language version supported by `macos` (defaulting to the
host macOS version).

See also [`Metal.metallib_support`](@ref) and [`Metal.air_support`](@ref).
"""
function metal_support(macos::VersionNumber = macos_version())
    if macos >= v"16" # Tahoe is v"26" but can report v"16" with julia versions not compiled with the Tahoe SDK
        v"4"
    elseif macos >= v"15"
        v"3.2"
    else # macOS 14
        v"3.1"
    end
end

# The versions Metal.jl emits by default. These mirror the `*_support` ceilings but
# capture what the toolchain actually targets: MSL tracks the host-supported version
# to expose the newest intrinsics, while AIR and the metallib file format are pinned
# to conservative baselines for backward compatibility. `versioninfo` reports these,
# and the compiler uses them as defaults (see `_compiler_config` and `MetalLib`).

"""
    Metal.metal_target(macos=macos_version())::VersionNumber

Returns the Metal Shading Language version Metal.jl emits by default, which tracks the
host-supported version (see [`Metal.metal_support`](@ref)) to expose the newest intrinsics.
"""
metal_target(macos::VersionNumber = macos_version()) = metal_support(macos)

"""
    Metal.air_target()::VersionNumber

Returns the embedded-AIR-bitcode version Metal.jl emits by default. Pinned to the macOS 14
baseline (v2.6) for backward compatibility, regardless of what the host supports (see
[`Metal.air_support`](@ref)).
"""
air_target() = v"2.6"

"""
    Metal.metallib_target()::VersionNumber

Returns the metallib file-format version Metal.jl emits by default. Pinned to a conservative
baseline (v1.2.6) for backward compatibility, regardless of what the host supports (see
[`Metal.metallib_support`](@ref)).
"""
metallib_target() = v"1.2.6"
