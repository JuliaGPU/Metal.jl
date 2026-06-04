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

# paravirtualized GPUs don't expose an AGXAccelerator IOService to query the core count
@test Metal.num_gpu_cores() > 0 broken=Metal.MTL.is_virtual(Metal.device())
