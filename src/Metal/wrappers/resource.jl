abstract type MtlResource end

device(res::MtlResource) = convert(MtlDevice, mtResourceDevice(res))

function label(l::MtlResource)
    ptr = mtResourceLabel(l)
    return ptr == C_NULL ? "" : unsafe_string(ptr) 
end

cpuCacheMode(res::MtlResource) = mtResourceCPUCacheMode(res)
storageMode(res::MtlResource) = mtResourceStorageMode(res)
hazardTrackingMode(res::MtlResource) = mtResourceHazardTrackingMode(res)
options(res::MtlResource) = mtResourceOptions(res)

