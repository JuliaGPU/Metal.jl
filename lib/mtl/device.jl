#
# device enums
#

@enum MTLArgumentBuffersTier::NSUInteger begin
    MTLArgumentBuffersTier1 = 0
    MTLArgumentBuffersTier2 = 1
end


#
# device
#

export MTLDevice, MTLCreateSystemDefaultDevice, devices

@objcwrapper MTLDevice <: NSObject

@objcproperties MTLDevice begin
    ## device inspection
    # compute support
    @autoproperty maxThreadgroupMemoryLength::NSUInteger
    @autoproperty maxThreadsPerThreadgroup::MTLSize
    # render support
    @autoproperty supportsRaytracing::Bool
    @autoproperty supportsPrimitiveMotionBlur::Bool
    @autoproperty supportsRaytracingFromRender::Bool
    @autoproperty supports32BitMSAA::Bool
    @autoproperty supportsPullModelInterpolation::Bool
    @autoproperty supportsShaderBarycentricCoordinates::Bool
    @autoproperty programmableSamplePositionsSupported::Bool
    @autoproperty rasterOrderGroupsSupported::Bool
    # texture and sampler support
    @autoproperty supports32BitFloatFiltering::Bool
    @autoproperty supportsBCTextureCompression::Bool
    @autoproperty depth24Stencil8PixelFormatSupported::Bool
    @autoproperty supportsQueryTextureLOD::Bool
    #@autoproperty readWriteTextureSupport::MTLReadWriteTextureTier
    # function pointer support
    @autoproperty supportsFunctionPointers::Bool
    @autoproperty supportsFunctionPointersFromRender::Bool
    # memory
    @autoproperty currentAllocatedSize::UInt64
    @autoproperty recommendedMaxWorkingSetSize::NSUInteger
    @autoproperty hasUnifiedMemory::Bool
    @autoproperty maxTransferRate::NSUInteger
    # counters
    #@autoproperty counterSets::MTLCounterSet
    # identifying
    @autoproperty name::id{NSString}
    @autoproperty registryID::UInt64
    #@autoproperty location::MTLDeviceLocation
    @autoproperty locationNumber::UInt64
    @autoproperty isLowPower::Bool
    @autoproperty isRemovable::Bool
    @autoproperty isHeadless::Bool
    @autoproperty peerGroupID::UInt64
    @autoproperty peerCount::UInt64
    @autoproperty peerIndex::UInt64

    ## resource creation
    # creating buffers
    @autoproperty maxBufferLength::NSUInteger
    # creating argument buffer encoders
    @autoproperty argumentBuffersSupport::MTLArgumentBuffersTier
    @autoproperty maxArgumentBufferSamplerCount::NSUInteger
end

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

export supports_family, is_m3, is_m2, is_m1

@cenum MTLGPUFamily::NSUInteger begin
    MTLGPUFamilyMetal3 = 5001 # Metal 3 support

    MTLGPUFamilyApple9 = 1009 # M3 & A17
    MTLGPUFamilyApple8 = 1008 # M2 & A15, A16
    MTLGPUFamilyApple7 = 1007 # M1 & A14
    MTLGPUFamilyApple6 = 1006 #      A13
    MTLGPUFamilyApple5 = 1005 #      A12
    MTLGPUFamilyApple4 = 1004 #      A11
    MTLGPUFamilyApple3 = 1003 #      A9, A10
    MTLGPUFamilyApple2 = 1002 #      A8
    MTLGPUFamilyApple1 = 1001 #      A7

    MTLGPUFamilyCommon3 = 3003
    MTLGPUFamilyCommon2 = 3002
    MTLGPUFamilyCommon1 = 3001

    MTLGPUFamilyMac2 = 2002 # Mac family 2 GPU features
end

function supports_family(device::MTLDevice, gpufamily::MTLGPUFamily)
    @objc [device::MTLDevice supportsFamily:gpufamily::MTLGPUFamily]::Bool
end

is_m1(dev::MTLDevice) = supports_family(dev, MTLGPUFamilyApple7) &&
                        !supports_family(dev, MTLGPUFamilyApple8)
is_m2(dev::MTLDevice) = supports_family(dev, MTLGPUFamilyApple8) &&
                        !supports_family(dev, MTLGPUFamilyApple9)
is_m3(dev::MTLDevice) = supports_family(dev, MTLGPUFamilyApple9)
