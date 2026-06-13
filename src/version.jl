export macos_version, darwin_version

# Julia binaries built against a pre-Tahoe SDK observe compatibility versions (macOS 26
# reports as 16); normalize user-provided versions to the marketing version, like the
# offline compiler normalizes the deployment target. ObjectiveC.macos_version() already
# normalizes the host query, so this only matters for user input.
function normalize_macos(version::VersionNumber)
    if v"16" <= version < v"26"
        version = VersionNumber(version.major + 10, version.minor, version.patch)
    end
    return version
end

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
    if macos >= v"16" # macos 26-27
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
    if macos >= v"27"
        v"2.9"
    elseif macos >= v"16" # Tahoe is v"26" but can report v"16" with julia versions not compiled with the Tahoe SDK
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
    Metal.metal_support(macos=macos_version())::VersionNumber

Returns the highest Metal Shading Language version supported by `macos` (defaulting to the
host macOS version).

See also [`Metal.metallib_support`](@ref) and [`Metal.air_support`](@ref).
"""
function metal_support(macos::VersionNumber = macos_version())
    if macos >= v"27"
        v"4.1"
    elseif macos >= v"16" # Tahoe is v"26" but can report v"16" with julia versions not compiled with the Tahoe SDK
        v"4"
    elseif macos >= v"15"
        v"3.2"
    elseif macos >= v"14"
        v"3.1"
    else # macOS 13
        v"3.0"
    end
end

# The versions Metal.jl emits by default. These track the `*_support` ceilings, which is
# also what the offline `metal` compiler does: compiling with `-mmacosx-version-min=N`
# yields the AIR, MSL and metallib versions that `N` supports. Since we compile for the
# host device only, the deployment target is the host. `versioninfo` reports these, and
# the compiler uses them as defaults (see `_compiler_config` and `MetalLib`).

"""
    Metal.metal_target(macos=macos_version())::VersionNumber

Returns the Metal Shading Language version Metal.jl emits by default, which tracks the
host-supported version (see [`Metal.metal_support`](@ref)) to expose the newest intrinsics.
"""
metal_target(macos::VersionNumber = macos_version()) = metal_support(macos)

"""
    Metal.air_target(macos=macos_version())::VersionNumber

Returns the embedded-AIR-bitcode version Metal.jl emits by default, which tracks the
host-supported version (see [`Metal.air_support`](@ref)).
"""
air_target(macos::VersionNumber = macos_version()) = air_support(macos)

"""
    Metal.metallib_target(macos=macos_version())::VersionNumber

Returns the metallib file-format version Metal.jl emits by default, which tracks the
host-supported version (see [`Metal.metallib_support`](@ref)).
"""
metallib_target(macos::VersionNumber = macos_version()) = metallib_support(macos)
