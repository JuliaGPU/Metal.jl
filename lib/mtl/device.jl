export MtlDevice, devices

const MTLDevice = Ptr{MtDevice}

struct MtlDevice
    handle::MTLDevice
end

Base.unsafe_convert(::Type{MTLDevice}, dev::MtlDevice) = dev.handle

Base.:(==)(a::MtlDevice, b::MtlDevice) = a.handle == b.handle
Base.hash(dev::MtlDevice, h::UInt) = hash(dev.handle, h)

"""
    devices()

Get an iterator for the compute devices.
"""
function devices()
    count = Ref{Csize_t}(0)
    mtCopyAllDevices(count, C_NULL)
    handles = Vector{Ptr{MtDevice}}(undef, count[])
    mtCopyAllDevices(count, handles)
    MtlDevice.(handles)
end

"""
    MtlDevice(i::Integer)

Get a handle to a compute device.
"""
MtlDevice(i::Integer) = devices()[i]


## properties

Base.propertynames(::MtlDevice) = (
    # GPU properties
    :recommendedMaxWorkingSetSize,
    :hasUnifiedMemory,
    :maxTransferRate,
    :name,
    :isHeadless,
    :isLowPower,
    :isRemovable,
    :registryID,
    # threadgroup limits
    :maxThreadgroupMemoryLength,
    :maxThreadsPerThreadgroup,
    # argument buffers
    :argumentBuffersSupport,
    # buffers
    :maxBufferLength,
    # gpu memory
    :currentAllocatedSize,
)

function Base.getproperty(dev::MtlDevice, f::Symbol)
    if f === :recommendedMaxWorkingSetSize
        mtDeviceRecommendedMaxWorkingSetSize(dev)
    elseif f === :hasUnifiedMemory
        mtDeviceHasUnifiedMemory(dev)
    elseif f === :maxTransferRate
        mtDeviceMaxTransferRate(dev)
    elseif f === :name
        unsafe_string(mtDeviceName(dev))
    elseif f === :isHeadless
        mtDeviceLowPower(dev)
    elseif f === :isLowPower
        mtDeviceHeadless(dev)
    elseif f === :isRemovable
        mtDeviceRemovable(dev)
    elseif f === :registryID
        mtDeviceRegistryID(dev)
    elseif f === :maxThreadgroupMemoryLength
        mtDeviceMaxThreadgroupMemoryLength(dev)
    elseif f === :maxThreadsPerThreadgroup
        mtMaxThreadsPerThreadgroup(dev)
    elseif f === :argumentBuffersSupport
        mtDeviceArgumentBuffersSupport(dev)
    elseif f === :maxBufferLength
        mtDeviceMaxBufferLength(dev)
    elseif f === :currentAllocatedSize
        mtDeviceCurrentAllocatedSize(dev)
    else
        getfield(dev, f)
    end
end


## display

function Base.show(io::IO, dev::MtlDevice)
    print(io, "MtlDevice($(dev.name))")
end

function Base.show(io::IO, ::MIME"text/plain", dev::MtlDevice)
    println(io, "MtlDevice:")
    println(io, " name:             ", dev.name)
    println(io, " lowpower:         ", dev.isLowPower)
    println(io, " headless:         ", dev.isHeadless)
    println(io, " removable:        ", dev.isRemovable)
    println(io, " unified memory:   ", dev.hasUnifiedMemory)
    println(io, " registry id:      ", dev.registryID)
    print(io,   " transfer rate:    ", dev.maxTransferRate)
end
