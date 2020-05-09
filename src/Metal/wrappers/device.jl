export MtlDevice, name, devices, DefaultDevice

const MTLDevice = Ptr{MtDevice} 

"""
    MtlDevice(i::Integer)

Get a handle to a compute device.
"""
struct MtlDevice
    handle::MTLDevice

    # CuDevice is just an integer, but we need (?) to call cuDeviceGet to make sure this
    # integer is valid. to avoid ambiguity, add a bogus argument (cfr. `checkbounds`)
    MtlDevice(::Type{Bool}, handle::MTLDevice) = new(handle)
end

Base.convert(::Type{MTLDevice}, dev::MtlDevice) = dev.handle
Base.unsafe_convert(::Type{MTLDevice}, d::MtlDevice) = convert(MTLDevice, d.handle) 

Base.:(==)(a::MtlDevice, b::MtlDevice) = a.handle == b.handle
Base.hash(dev::MtlDevice, h::UInt) = hash(dev.handle, h)

DefaultDevice() = MtlDevice(mtCreateSystemDefaultDevice())
MtlDevice() = DefaultDevice()
MtlDevice(i::Integer) = devices()[i]
MtlDevice(ptr::MTLDevice) = MtlDevice(Bool, ptr)

## Properties
name(d::MtlDevice) = unsafe_string(mtDeviceName(d))

islowpower(d::MtlDevice) = mtDeviceLowPower(d)
isheadless(d::MtlDevice) = mtDeviceHeadless(d)
isremovable(d::MtlDevice) = mtDeviceRemovable(d)
hasunifiedMemory(d::MtlDevice) = mtDeviceHasUnifiedMemory(d)
registryId(d::MtlDevice) = mtDeviceRegistryID(d)
transfer_rate(d::MtlDevice) = mtDeviceMaxTransferRate(d)

# working set size
max_workingsetsize(d::MtlDevice) = mtDeviceRecommendedMaxWorkingSetSize(d)
max_threadgroupmemorylength(d::MtlDevice) = mtDeviceMaxThreadgroupMemoryLength(d)
max_threadspergroup(d::MtlDevice) = mtMaxThreadsPerThreadgroup(d)
max_bufferlength(d::MtlDevice) = mtDeviceMaxBufferLength(d)

allocatedsize(d::MtlDevice) = mtDeviceCurrentAllocatedSize(d)

function Base.show(io::IO, d::MtlDevice)
    print(io, "MtlDevice($(name(d)))")
end

function Base.show(io::IO, ::MIME"text/plain", d::MtlDevice)
    println(io, "MtlDevice:")
    println(io, " name :             ", name(d))
    println(io, " lowpower :         ", mtDeviceLowPower(d))
    println(io, " headless :         ", mtDeviceHeadless(d))
    println(io, " removable :        ", mtDeviceRemovable(d))
    println(io, " unified memory :   ", mtDeviceHasUnifiedMemory(d))
    println(io, " id :               ", mtDeviceRegistryID(d))
    print(io, " transfer rate :    ", mtDeviceMaxTransferRate(d))
end

## Iteration
"""
    devices()

Get an iterator for the compute devices.
"""
function devices()
    _devices = mtCopyAllDevices()
    devices = Vector{MtlDevice}()
    for i = 0:100
        _dev = Base.unsafe_load(_devices + i * sizeof(Ptr{MtDevice}))
        _dev == C_NULL && break
        push!(devices, MtlDevice(_dev))
    end
    Base.Libc.free(_devices)

    return devices
end