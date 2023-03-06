export MTLResource

@objcwrapper MTLResource <: NSObject

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtResource}}, obj::MTLResource) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLResource(ptr::Ptr{MtResource}) = MTLResource(reinterpret(id{MTLResource}, ptr))


## properties

@cenum MTLCPUCacheMode::NSUInteger begin
    MTLCPUCacheModeDefaultCache = 0
    MTLCPUCacheModeWriteCombined = 1
end

@cenum MTLHazardTrackingMode::NSUInteger begin
    MTLHazardTrackingModeDefault = 0
    MTLHazardTrackingModeUntracked = 1
    MTLHazardTrackingModeTracked = 2
end

@cenum MTLStorageMode::NSUInteger begin
    MTLStorageModeShared = 0
    MTLStorageModeManaged = 1
    MTLStorageModePrivate = 2
    MTLStorageModeMemoryless = 3
end

@cenum MTLResourceOptions::NSUInteger begin
    MTLResourceCPUCacheModeDefaultCache = 0
    MTLResourceCPUCacheModeWriteCombined = 1
    MTLResourceStorageModeShared = 0
    MTLResourceStorageModeManaged = 16
    MTLResourceStorageModePrivate = 32
    MTLResourceStorageModeMemoryless = 48
    MTLResourceHazardTrackingModeDefault = 0
    MTLResourceHazardTrackingModeUntracked = 256
    MTLResourceHazardTrackingModeTracked = 512
end

@objcproperties MTLResource begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
    @autoproperty cpuCacheMode::MTLCPUCacheMode
    @autoproperty storageMode::MTLStorageMode
    @autoproperty hazardTrackingMode::MTLHazardTrackingMode
    @autoproperty resourceOptions::MTLResourceOptions
end
