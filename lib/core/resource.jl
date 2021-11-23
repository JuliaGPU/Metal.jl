export MtlResource, storage, options, cpuCacheMode, hazardTrackingMode

const MTLResource = Ptr{MtResource}

abstract type MtlResource end

Base.unsafe_convert(::Type{MTLResource}, res::MtlResource) = Base.bitcast(MTLResource, res.handle)

device(res::MtlResource) = convert(MtlDevice, mtResourceDevice(res))

function label(l::MtlResource)
    ptr = mtResourceLabel(l)
    return ptr == C_NULL ? "" : unsafe_string(ptr)
end

cpuCacheMode(res::MtlResource) = mtResourceCPUCacheMode(res)
storage(res::MtlResource) = mtResourceStorageMode(res)
hazardTrackingMode(res::MtlResource) = mtResourceHazardTrackingMode(res)
options(res::MtlResource) = mtResourceOptions(res)
