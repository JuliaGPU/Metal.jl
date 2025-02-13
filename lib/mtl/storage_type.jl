export SharedStorage, ManagedStorage, PrivateStorage
export ReadUsage, WriteUsage, ReadWriteUsage

# Metal Has 4 storage types
# SharedStorage  -> Buffer in Host memory, accessed by the GPU. Requires no sync
# ManagedStorage -> Mirrored memory buffers in host and GPU. Requires syncing
# PrivateStorage -> Memory in Device, not accessible by Host.
# Memoryless -> iOS stuff. ignore it

abstract type StorageMode end

"""
    struct Metal.SharedStorage <: MTL.StorageMode

Used to indicate that the resource is stored using `MTLStorageModeShared` in memory.

For more information on Metal storage modes, refer to the official Metal documentation.

See also [`Metal.PrivateStorage`](@ref) and [`Metal.ManagedStorage`](@ref).
"""
struct SharedStorage <: StorageMode end

"""
    struct Metal.ManagedStorage <: MTL.StorageMode

Used to indicate that the resource is stored using `MTLStorageModeManaged` in memory.

For more information on Metal storage modes, refer to the official Metal documentation.

See also [`Metal.SharedStorage`](@ref) and [`Metal.PrivateStorage`](@ref).
"""
struct ManagedStorage <: StorageMode end

"""
    struct Metal.PrivateStorage <: MTL.StorageMode

Used to indicate that the resource is stored using `MTLStorageModePrivate` in memory.

For more information on Metal storage modes, refer to the official Metal documentation.

See also [`Metal.SharedStorage`](@ref) and [`Metal.ManagedStorage`](@ref).
"""
struct PrivateStorage <: StorageMode end
struct Memoryless <: StorageMode end

# Remove the ".MTL" when printing
Base.show(io::IO, ::Type{<:PrivateStorage}) = print(io, "Metal.PrivateStorage")
Base.show(io::IO, ::Type{<:SharedStorage}) = print(io, "Metal.SharedStorage")
Base.show(io::IO, ::Type{<:ManagedStorage}) = print(io, "Metal.ManagedStorage")

"""
    MTL.CPUStorage

Union type of [`Metal.SharedStorage`](@ref) and [`Metal.ManagedStorage`](@ref) storage modes.

Represents storage modes where the resource is accessible via the CPU.
"""
const CPUStorage = Union{SharedStorage, ManagedStorage}

Base.convert(::Type{MTLStorageMode}, ::Type{SharedStorage}) = MTLStorageModeShared
Base.convert(::Type{MTLStorageMode}, ::Type{ManagedStorage}) = MTLStorageModeManaged
Base.convert(::Type{MTLStorageMode}, ::Type{PrivateStorage}) = MTLStorageModePrivate
Base.convert(::Type{MTLStorageMode}, ::Type{Memoryless}) = MTLStorageModeMemoryless

Base.convert(::Type{MTLResourceOptions}, ::Type{SharedStorage}) = MTLResourceStorageModeShared
Base.convert(::Type{MTLResourceOptions}, ::Type{ManagedStorage}) = MTLResourceStorageModeManaged
Base.convert(::Type{MTLResourceOptions}, ::Type{PrivateStorage}) = MTLResourceStorageModePrivate
Base.convert(::Type{MTLResourceOptions}, ::Type{Memoryless}) = MTLResourceStorageModeMemoryless

Base.convert(::Type{MTLResourceOptions}, SM::MTLStorageMode) = MTLResourceOptions(UInt(SM) << 4)

const DefaultCPUCache = MTLResourceCPUCacheModeDefaultCache
const CombinedWriteCPUCache = MTLResourceCPUCacheModeWriteCombined

const DefaultTracking = MTLResourceHazardTrackingModeDefault
const Untracked = MTLResourceHazardTrackingModeUntracked
const Tracked = MTLResourceHazardTrackingModeTracked

const Default = DefaultCPUCache

Base.:(==)(a::MTLResourceOptions, b::MTLStorageMode) =
    (UInt(a) >> 4) == UInt(b)

Base.:(==)(a::MTLStorageMode, b::MTLResourceOptions) =
    b == a

##################
Base.convert(::Type{MTLResourceUsage}, val::Integer) = MTLResourceUsage(val)

const ReadUsage = MTLResourceUsageRead
const WriteUsage = MTLResourceUsageWrite
const ReadWriteUsage = convert(MTLResourceUsage, MTLResourceUsageRead | MTLResourceUsageWrite)
