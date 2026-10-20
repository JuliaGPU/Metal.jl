# Metal Has 4 storage types
# SharedStorage  -> Buffer in Host memory, accessed by the GPU. Requires no sync
# ManagedStorage -> Mirrored memory buffers in host and GPU. Requires syncing
# PrivateStorage -> Memory in Device, not accessible by Host.
# Memoryless -> render pipeline stuff. ignore it (for now)

abstract type StorageMode end

@public SharedStorage, PrivateStorage

"""
    Metal.SharedStorage

The shared storage mode ([`MTLStorageModeShared`](https://developer.apple.com/documentation/metal/mtlstoragemode/shared)),
the default for `MtlArray`s: the memory is accessible from both the CPU and the GPU. Indexing
such an array from the CPU, or wrapping it as an `Array`, accesses the memory directly,
waiting for GPU work that uses the array to finish first.

See [Choosing a resource storage mode for Apple GPUs](https://developer.apple.com/documentation/metal/choosing-a-resource-storage-mode-for-apple-gpus),
and [`Metal.PrivateStorage`](@ref).
"""
struct SharedStorage  <: StorageMode end

"""
    Metal.ManagedStorage

The managed storage mode (`MTLStorageModeManaged`), which keeps separate CPU and GPU copies
of the memory. Apple silicon GPUs don't need it, and `MtlArray`s don't support it: use
[`Metal.SharedStorage`](@ref) instead.
"""
struct ManagedStorage <: StorageMode end

"""
    Metal.PrivateStorage

The private storage mode ([`MTLStorageModePrivate`](https://developer.apple.com/documentation/metal/mtlstoragemode/private)):
the memory is only accessible from the GPU, and indexing such an array from the CPU makes a
slow copy, subject to `allowscalar`. Use it for data that
only the GPU accesses, or to make sure that operations on an array execute on the GPU.
Create private arrays with, e.g., `MtlArray{Float32,1,Metal.PrivateStorage}(undef, n)`, or
`mtl(A; storage=Metal.PrivateStorage)`.

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
