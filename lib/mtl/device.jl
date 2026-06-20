#
# device
#

export MTLDevice, MTLCreateSystemDefaultDevice, devices

# @objcwrapper MTLDevice <: NSObject

# MTLDevice is deliberately unmanaged: system devices are borrowed process-level
# handles, and `devices()` benefits from returning dense isbits wrapper values.
MTLCreateSystemDefaultDevice() =
    MTLDevice(@ccall libmtl.MTLCreateSystemDefaultDevice()::id{MTLDevice})

"""
    devices()

Get an iterator for the compute devices.
"""
function devices()
    list = NSArray(@ccall libmtl.MTLCopyAllDevices()::id{NSArray})
    [reinterpret(MTLDevice, dev) for dev in list]
end

"""
    MTLDevice(i::Integer)

Get a handle to a compute device.
"""
MTLDevice(i::Integer) = devices()[i]

function threadgroup_limits(dev::MTLDevice)
    key = UInt(pointer(dev))
    @memoize key::UInt begin
        (Int(dev.maxThreadsPerThreadgroup.width), Int(dev.maxThreadgroupMemoryLength))
    end::Tuple{Int,Int}
end

max_threadgroup_threads(dev::MTLDevice) = first(threadgroup_limits(dev))
max_threadgroup_memory(dev::MTLDevice) = last(threadgroup_limits(dev))


#
# family
#

export supports_family, is_virtual, is_m4, is_m3, is_m2, is_m1

function supports_family(dev::MTLDevice, gpufamily::MTLGPUFamily)
    @objc [dev::MTLDevice supportsFamily:gpufamily::MTLGPUFamily]::Bool
end

"""
    is_virtual(dev::MTLDevice)

Returns `true` if `dev` is a paravirtualized GPU, i.e. Metal.jl is running inside a virtual
machine. On Apple Silicon, such devices partially support Metal 3, and they support
some of the capabilities of their underlying hardware family despite `supportsFamily`
claiming lower capabilities (e.g. Not claiming support for `MTLGPUFamilyApple7` and `MTLGPUFamilyMetal3` feature sets due to a few missing features).
"""
is_virtual(dev::MTLDevice) = occursin("Paravirtual", String(dev.name))

is_m1(dev::MTLDevice) = supports_family(dev, MTLGPUFamilyApple7) &&
                        !supports_family(dev, MTLGPUFamilyApple8)
is_m2(dev::MTLDevice) = supports_family(dev, MTLGPUFamilyApple8) &&
                        !supports_family(dev, MTLGPUFamilyApple9)
is_m3(dev::MTLDevice) = supports_family(dev, MTLGPUFamilyApple9) &&
                        occursin("M3", String(dev.name))
is_m4(dev::MTLDevice) = supports_family(dev, MTLGPUFamilyApple9) &&
                        occursin("M4", String(dev.name))

"""
    highest_apple_family(dev::MTLDevice)

Returns the number `n` of the highest `MTLGPUFamilyApple`n` feature set that `dev` reports
support for (e.g. `7` for `MTLGPUFamilyApple7`), or `nothing` if it supports none of them.
"""
function highest_apple_family(dev::MTLDevice)
    for n in 10:-1:1
        supports_family(dev, MTLGPUFamily(1000 + n)) && return n
    end
    return nothing
end

"""
    highest_metal_family(dev::MTLDevice)

Returns the number `n` of the highest `MTLGPUFamilyMetal`n` feature set that `dev` reports
support for (e.g. `3` for Metal 3, `4` for Metal 4), or `nothing` if it supports neither.
"""
function highest_metal_family(dev::MTLDevice)
    supports_family(dev, MTLGPUFamilyMetal4) && return 4
    supports_family(dev, MTLGPUFamilyMetal3) && return 3
    return nothing
end
