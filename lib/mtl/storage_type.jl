abstract type StorageMode end
export Shared, Managed, Private
export ReadUsage, WriteUsage, ReadWriteUsage

# Metal Has 4 storage types
# Shared  -> Buffer in Host memory, accessed by the GPU. Requires no sync
# Managed -> Mirrored memory buffers in host and GPU. Requires syncing
# Private -> Memory in Device, not accessible by Host.
# Memoryless -> iOS stuff. ignore it
module AS
import ..StorageMode

struct Shared      <: StorageMode end
struct Managed     <: StorageMode end
struct Private     <: StorageMode end
struct Memoryless  <: StorageMode end
end

const CPUStorage = Union{AS.Shared,AS.Managed}
Base.convert(::Type{MTLStorageMode}, ::Type{AS.Shared})     = MTLStorageModeShared
Base.convert(::Type{MTLStorageMode}, ::Type{AS.Managed})    = MTLStorageModeManaged
Base.convert(::Type{MTLStorageMode}, ::Type{AS.Private})    = MTLStorageModePrivate
Base.convert(::Type{MTLStorageMode}, ::Type{AS.Memoryless}) = MTLStorageModeMemoryless

Base.convert(::Type{MTLResourceOptions}, ::Type{AS.Shared})     = MTLResourceStorageModeShared
Base.convert(::Type{MTLResourceOptions}, ::Type{AS.Managed})    = MTLResourceStorageModeManaged
Base.convert(::Type{MTLResourceOptions}, ::Type{AS.Private})    = MTLResourceStorageModePrivate
Base.convert(::Type{MTLResourceOptions}, ::Type{AS.Memoryless}) = MTLResourceStorageModeMemoryless

const Shared                = MTLResourceStorageModeShared
const Managed               = MTLResourceStorageModeManaged
const Private               = MTLResourceStorageModePrivate
const Memoryless            = MTLResourceStorageModeMemoryless

const DefaultCPUCache       = MTLResourceCPUCacheModeDefaultCache
const CombinedWriteCPUCache = MTLResourceCPUCacheModeWriteCombined

const DefaultTracking       = MTLResourceHazardTrackingModeDefault
const Untracked             = MTLResourceHazardTrackingModeUntracked
const Tracked               = MTLResourceHazardTrackingModeTracked

const Default               = DefaultCPUCache

Base.:(==)(a::MTLResourceOptions, b::MTLStorageMode) =
    (UInt(a) >> 4) == UInt(b)

Base.:(==)(a::MTLStorageMode, b::MTLResourceOptions) =
    b == a

##################
Base.convert(::Type{MTLResourceUsage}, val::Integer)    = MTLResourceUsage(val)

const ReadUsage = MTLResourceUsageRead
const WriteUsage = MTLResourceUsageWrite
const ReadWriteUsage = convert(MTLResourceUsage, MTLResourceUsageRead | MTLResourceUsageWrite)
