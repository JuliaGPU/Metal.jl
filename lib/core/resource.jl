export MtlResource

const MTLResource = Ptr{MtResource}

abstract type MtlResource end

Base.unsafe_convert(::Type{MTLResource}, res::MtlResource) = Base.bitcast(MTLResource, res.handle)


## properties

Base.propertynames(::MtlResource) =
    (:device, :label, :cpuCacheMode, :storageMode, :hazardTrackingMode, :resourceOptions)

function Base.getproperty(res::MtlResource, f::Symbol)
    if f === :device
        MtlDevice(mtResourceDevice(res))
    elseif f === :label
        ptr = mtResourceLabel(res)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    elseif f === :cpuCacheMode
        mtResourceCPUCacheMode(res)
    elseif f === :storageMode
        mtResourceStorageMode(res)
    elseif f === :hazardTrackingMode
        mtResourceHazardTrackingMode(res)
    elseif f === :resourceOptions
        mtResourceOptions(res)
    else
        getfield(res, f)
    end
end

function Base.setproperty!(res::MtlResource, f::Symbol, val)
    if f === :label
		mtResourceLabelSet(res, val)
    else
        setfield!(res, f, val)
    end
end
