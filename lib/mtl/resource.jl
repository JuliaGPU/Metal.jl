# Extra definition for MTLResourceOptions defined in libmtl.jl
## bitwise operations lose type information, so allow conversions
Base.convert(::Type{MTLResourceOptions}, x::Integer) = MTLResourceOptions(x)

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
