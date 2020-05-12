abstract type StorageMode end
export MtStorageMode, Shared, Managed, Private

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
Base.convert(::Type{MtStorageMode}, ::Type{AS.Shared})     = MtStorageModeShared
Base.convert(::Type{MtStorageMode}, ::Type{AS.Managed})    = MtStorageModeManaged
Base.convert(::Type{MtStorageMode}, ::Type{AS.Private})    = MtStorageModePrivate
Base.convert(::Type{MtStorageMode}, ::Type{AS.Memoryless}) = MtStorageModeMemoryless

Base.convert(::Type{MtResourceOptions}, ::Type{AS.Shared})     = MtResourceStorageModeShared
Base.convert(::Type{MtResourceOptions}, ::Type{AS.Managed})    = MtResourceStorageModeManaged
Base.convert(::Type{MtResourceOptions}, ::Type{AS.Private})    = MtResourceStorageModePrivate
Base.convert(::Type{MtResourceOptions}, ::Type{AS.Memoryless}) = MtResourceStorageModeMemoryless

# Broken because multiple zeros
#@enum_without_prefix MtResourceOptions MtResource
const MtlResourceOptions    = MtResourceOptions

const Shared                = MtResourceStorageModeShared
const Managed               = MtResourceStorageModeManaged
const Private               = MtResourceStorageModePrivate
const Memoryless            = MtResourceStorageModeMemoryless

const DefaultCPUCache       = MtResourceCPUCacheModeDefaultCache
const CombinedWriteCPUCache = MtResourceCPUCacheModeWriteCombined

const DefaultTracking       = MtResourceHazardTrackingModeDefault
const Untracked             = MtResourceHazardTrackingModeUntracked
const Tracked               = MtResourceHazardTrackingModeTracked

const Default               = DefaultCPUCache

Base.:(==)(a::MtlResourceOptions, b::MtStorageMode) =
    (UInt(a) >> 4) == UInt(b)

Base.:(==)(a::MtStorageMode, b::MtlResourceOptions) =
    b == a
