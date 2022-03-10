export MtlDevice, devices


## construction

const MTLDevice = Ptr{MtDevice}

struct MtlDevice
    handle::MTLDevice
end

Base.convert(::Type{MTLDevice}, dev::MtlDevice) = dev.handle
Base.unsafe_convert(::Type{MTLDevice}, d::MtlDevice) = convert(MTLDevice, d.handle)

Base.:(==)(a::MtlDevice, b::MtlDevice) = a.handle == b.handle
Base.hash(dev::MtlDevice, h::UInt) = hash(dev.handle, h)

"""
    devices()

Get an iterator for the compute devices.
"""
function devices()
    count = Ref{Csize_t}(0)
    mtCopyAllDevices(count, C_NULL)
    handles = Vector{Cstring}(undef, count[])
    mtCopyAllDevices(count, handles)
    MtlDevice.(handles)
end

"""
    MtlDevice(i::Integer)

Get a handle to a compute device.
"""
MtlDevice(i::Integer) = devices()[i]

function Base.show(io::IO, d::MtlDevice)
    print(io, "MtlDevice($(name(d)))")
end

function Base.show(io::IO, ::MIME"text/plain", d::MtlDevice)
    println(io, "MtlDevice:")
    println(io, " name :             ", name(d))
    println(io, " lowpower :         ", is_lowpower(d))
    println(io, " headless :         ", is_headless(d))
    println(io, " removable :        ", is_removable(d))
    println(io, " unified memory :   ", has_unified_memory(d))
    println(io, " id :               ", registry_id(d))
    print(io,   " transfer rate :    ", max_transfer_rate(d))
end


## properties

name(d::MtlDevice) = unsafe_string(mtDeviceName(d))

is_lowpower(d::MtlDevice) = mtDeviceLowPower(d)
is_headless(d::MtlDevice) = mtDeviceHeadless(d)
is_removable(d::MtlDevice) = mtDeviceRemovable(d)
has_unified_memory(d::MtlDevice) = mtDeviceHasUnifiedMemory(d)
registry_id(d::MtlDevice) = mtDeviceRegistryID(d)
max_transfer_rate(d::MtlDevice) = mtDeviceMaxTransferRate(d)

max_workingsetsize(d::MtlDevice) = mtDeviceRecommendedMaxWorkingSetSize(d)
max_threadgroupmemorylength(d::MtlDevice) = mtDeviceMaxThreadgroupMemoryLength(d)
max_threadspergroup(d::MtlDevice) = mtMaxThreadsPerThreadgroup(d)
max_bufferlength(d::MtlDevice) = mtDeviceMaxBufferLength(d)

allocatedsize(d::MtlDevice) = mtDeviceCurrentAllocatedSize(d)
