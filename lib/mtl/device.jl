export MTLDevice, devices

@objcwrapper MTLDevice <: NSObject

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtDevice}}, obj::MTLDevice) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLDevice(ptr::Ptr{MtDevice}) = MTLDevice(reinterpret(id, ptr))

MTLCreateSystemDefaultDevice() = MTLDevice(ccall(:MTLCreateSystemDefaultDevice, id, ()))

"""
    devices()

Get an iterator for the compute devices.
"""
function devices()
    list = NSArray(ccall(:MTLCopyAllDevices, id, ()))
    MTLDevice.(collect(list))
end

"""
    MTLDevice(i::Integer)

Get a handle to a compute device.
"""
MTLDevice(i::Integer) = devices()[i]


## properties

@enum MTLArgumentBuffersTier::NSUInteger begin
    MTLArgumentBuffersTier1 = 0
    MTLArgumentBuffersTier2 = 1
end

const properties = [
    ## device inspection
    # compute support
    (:maxThreadgroupMemoryLength, :NSUInteger),
    (:maxThreadsPerThreadgroup, :MTLSize => :MtSize),
    # render support
    (:supportsRaytracing, :Bool),
    (:supportsPrimitiveMotionBlur, :Bool),
    (:supportsRaytracingFromRender, :Bool),
    (:supports32BitMSAA, :Bool),
    (:supportsPullModelInterpolation, :Bool),
    (:supportsShaderBarycentricCoordinates, :Bool),
    (:programmableSamplePositionsSupported, :Bool),
    (:rasterOrderGroupsSupported, :Bool),
    # texture and sampler support
    (:supports32BitFloatFiltering, :Bool),
    (:supportsBCTextureCompression, :Bool),
    (:depth24Stencil8PixelFormatSupported, :Bool),
    (:supportsQueryTextureLOD, :Bool),
    #(:readWriteTextureSupport, :MTLReadWriteTextureTier),
    # function pointer support
    (:supportsFunctionPointers, :Bool),
    (:supportsFunctionPointersFromRender, :Bool),
    # memory
    (:currentAllocatedSize, :UInt64),
    (:recommendedMaxWorkingSetSize, :NSUInteger),
    (:hasUnifiedMemory, :Bool),
    (:maxTransferRate, :NSUInteger),
    # counters
    #(:counterSets, :MTLCounterSet),
    # identifying
    (:name, :(id{NSString}) => :NSString),
    (:registryID, :UInt64),
    #(:location, :MTLDeviceLocation),
    (:locationNumber, :UInt64),
    (:isLowPower, :Bool),
    (:isRemovable, :Bool),
    (:isHeadless, :Bool),
    (:peerGroupID, :UInt64),
    (:peerCount, :UInt64),
    (:peerIndex, :UInt64),
    ## resource creation
    # creating buffers
    (:maxBufferLength, :NSUInteger),
    # creating argument buffer encoders
    (:argumentBuffersSupport, :MTLArgumentBuffersTier),
    (:maxArgumentBufferSamplerCount, :NSUInteger),
]

Base.propertynames(::MTLDevice) = map(first, properties)

@eval Base.getproperty(dev::MTLDevice, f::Symbol) =
    $(emit_getproperties(:MTLDevice, properties))
