export SharedStorage, ManagedStorage, PrivateStorage
export ReadUsage, WriteUsage, ReadWriteUsage

Base.convert(::Type{MTLStorageMode}, ::Type{SharedStorage})     = MTLStorageModeShared
Base.convert(::Type{MTLStorageMode}, ::Type{ManagedStorage})    = MTLStorageModeManaged
Base.convert(::Type{MTLStorageMode}, ::Type{PrivateStorage})    = MTLStorageModePrivate
Base.convert(::Type{MTLStorageMode}, ::Type{Memoryless}) = MTLStorageModeMemoryless

Base.convert(::Type{MTLResourceOptions}, ::Type{SharedStorage})     = MTLResourceStorageModeShared
Base.convert(::Type{MTLResourceOptions}, ::Type{ManagedStorage})    = MTLResourceStorageModeManaged
Base.convert(::Type{MTLResourceOptions}, ::Type{PrivateStorage})    = MTLResourceStorageModePrivate
Base.convert(::Type{MTLResourceOptions}, ::Type{Memoryless}) = MTLResourceStorageModeMemoryless

Base.convert(::Type{MTLResourceOptions}, SM::MTLStorageMode)     = MTLResourceOptions(UInt(SM) << 4)

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
