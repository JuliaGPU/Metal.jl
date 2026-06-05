@test Metal.darwin_version() isa VersionNumber
@test Metal.macos_version() isa VersionNumber
@test Metal.is_macos(Metal.macos_version())

@test Metal.metallib_support() isa VersionNumber
@test Metal.air_support() isa VersionNumber
@test Metal.metal_support() isa VersionNumber

@test Metal.metallib_target() isa VersionNumber
@test Metal.air_target() isa VersionNumber
@test Metal.metal_target() isa VersionNumber

# we never emit a version the host can't handle
@test Metal.metal_target() <= Metal.metal_support()
@test Metal.air_target() <= Metal.air_support()
@test Metal.metallib_target() <= Metal.metallib_support()

# the version mapping, as derived from the offline compiler (see src/version.jl)
@test Metal.metallib_support(v"13") == v"1.2.7"
@test Metal.air_support(v"13") == v"2.5"
@test Metal.metal_support(v"13") == v"3.0"
@test Metal.metallib_support(v"14") == v"1.2.7"
@test Metal.air_support(v"14") == v"2.6"
@test Metal.metal_support(v"14") == v"3.1"
@test Metal.metallib_support(v"15") == v"1.2.8"
@test Metal.air_support(v"15") == v"2.7"
@test Metal.metal_support(v"15") == v"3.2"
for tahoe in [v"16", v"26"]
    @test Metal.metallib_support(tahoe) == v"1.2.9"
    @test Metal.air_support(tahoe) == v"2.8"
    @test Metal.metal_support(tahoe) == v"4"
end

# compatibility versions, as reported by pre-Tahoe SDK builds, normalize to marketing
# versions
@test Metal.normalize_macos(v"16") == v"26"
@test Metal.normalize_macos(v"16.2.1") == v"26.2.1"
@test Metal.normalize_macos(v"15.5") == v"15.5"
@test Metal.normalize_macos(v"26.1") == v"26.1"

# paravirtualized GPUs don't expose an AGXAccelerator IOService to query the core count
@test Metal.num_gpu_cores() > 0 broken=Metal.MTL.is_virtual(Metal.device())
