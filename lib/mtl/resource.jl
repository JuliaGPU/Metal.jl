#
# resource enums
#

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
    MTLResourceStorageModeShared = 0
    MTLResourceStorageModeManaged = 16
    MTLResourceStorageModePrivate = 32
    MTLResourceStorageModeMemoryless = 48
    MTLResourceCPUCacheModeDefaultCache = 0
    MTLResourceCPUCacheModeWriteCombined = 1
    MTLResourceHazardTrackingModeDefault = 0
    MTLResourceHazardTrackingModeUntracked = 256
    MTLResourceHazardTrackingModeTracked = 512
end
## bitwise operations lose type information, so allow conversions
Base.convert(::Type{MTLResourceOptions}, x::Integer) = MTLResourceOptions(x)

@cenum MTLResourceUsage::NSUInteger begin
    MTLResourceUsageRead = 1
    MTLResourceUsageWrite = 2
    MTLResourceUsageSample = 4
end


#
# resourcs
#

export MTLResource

@objcwrapper MTLResource <: NSObject

@objcproperties MTLResource begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
    @autoproperty cpuCacheMode::MTLCPUCacheMode
    @autoproperty storageMode::MTLStorageMode
    @autoproperty hazardTrackingMode::MTLHazardTrackingMode
    @autoproperty resourceOptions::MTLResourceOptions
end
