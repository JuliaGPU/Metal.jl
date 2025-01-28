#
# device
#

export MTLDevice, MTLCreateSystemDefaultDevice, devices

# @objcwrapper MTLDevice <: NSObject

MTLCreateSystemDefaultDevice() =
    MTLDevice(ccall(:MTLCreateSystemDefaultDevice, id{MTLDevice}, ()))

"""
    devices()

Get an iterator for the compute devices.
"""
function devices()
    list = NSArray(ccall(:MTLCopyAllDevices, id{NSArray}, ()))
    [reinterpret(MTLDevice, dev) for dev in list]
end

"""
    MTLDevice(i::Integer)

Get a handle to a compute device.
"""
MTLDevice(i::Integer) = devices()[i]


#
# family
#

export supports_family, is_m4, is_m3, is_m2, is_m1

function supports_family(dev::MTLDevice, gpufamily::MTLGPUFamily)
    @objc [dev::MTLDevice supportsFamily:gpufamily::MTLGPUFamily]::Bool
end

is_m1(dev::MTLDevice) = supports_family(dev, MTLGPUFamilyApple7) &&
                        !supports_family(dev, MTLGPUFamilyApple8)
is_m2(dev::MTLDevice) = supports_family(dev, MTLGPUFamilyApple8) &&
                        !supports_family(dev, MTLGPUFamilyApple9)
is_m3(dev::MTLDevice) = supports_family(dev, MTLGPUFamilyApple9) &&
                        occursin("M3", String(dev.name))
is_m4(dev::MTLDevice) = supports_family(dev, MTLGPUFamilyApple9) &&
                        occursin("M4", String(dev.name))
