export MTLResource

@objcwrapper MTLResource <: NSObject

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtResource}}, obj::MTLResource) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLResource(ptr::Ptr{MtResource}) = MTLResource(reinterpret(id, ptr))


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

const resource_properties = [
    # identifying the resource
    (:device,               :(id{MTLDevice})),
    (:label,                :(id{NSString}),
     :setLabel),
    # reading memory and storage properties
    (:cpuCacheMode,         :(MTLCPUCacheMode)),
    (:storageMode,          :(MTLStorageMode)),
    (:hazardTrackingMode,   :(MTLHazardTrackingMode)),
    (:resourceOptions,      :(MTLResourceOptions)),
]

Base.propertynames(::MTLResource) = map(first, resource_properties)

@eval Base.getproperty(obj::MTLResource, f::Symbol) =
    $(emit_getproperties(:obj, MTLResource, :f, resource_properties))

@eval Base.setproperty!(obj::MTLResource, f::Symbol, val) =
    $(emit_setproperties(:obj, MTLResource, :f, :val, resource_properties))
