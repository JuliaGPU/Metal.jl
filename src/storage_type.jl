# Uncomment once all supported julia versions support public
# public SharedStorage, ManagedStorage, PrivateStorage

# Metal Has 4 storage types
# SharedStorage  -> Buffer in Host memory, accessed by the GPU. Requires no sync
# ManagedStorage -> Mirrored memory buffers in host and GPU. Requires syncing
# PrivateStorage -> Memory in Device, not accessible by Host.
# Memoryless -> render pipeline stuff. ignore it (for now)

abstract type StorageMode end

"""
    struct Metal.SharedStorage <: Metal.StorageMode

Used to indicate that the resource is stored using `MTLStorageModeShared` in memory.

For more information on Metal storage modes, refer to the official Metal documentation.

See also [`Metal.PrivateStorage`](@ref).
"""
struct SharedStorage  <: StorageMode end

"""
    struct Metal.ManagedStorage <: Metal.StorageMode

Used to indicate that the resource is stored using `MTLStorageModeManaged` in memory.

For more information on Metal storage modes, refer to the official Metal documentation.

!!! warning
    `ManagedStorage` is no longer supported with `MtlArray`s. Instead, use `SharedStorage` or use the Metal api directly from `Metal.MTL`.

See also [`Metal.SharedStorage`](@ref) and [`Metal.PrivateStorage`](@ref).
"""
struct ManagedStorage <: StorageMode end

"""
    struct Metal.PrivateStorage <: Metal.StorageMode

Used to indicate that the resource is stored using `MTLStorageModePrivate` in memory.

For more information on Metal storage modes, refer to the official Metal documentation.

See also [`Metal.SharedStorage`](@ref).
"""
struct PrivateStorage <: StorageMode end
struct Memoryless     <: StorageMode end

"""
    Metal.CPUStorage

Union type of [`Metal.SharedStorage`](@ref) and [`Metal.ManagedStorage`](@ref) storage modes.

Represents storage modes where the resource is accessible via the CPU.
"""
const CPUStorage = Union{SharedStorage,ManagedStorage}
