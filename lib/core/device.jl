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
    handles = mtCopyAllDevices()
    devices = Vector{MtlDevice}()
    while true
        handle = unsafe_load(handles, length(devices)+1)
        handle == C_NULL && break
        push!(devices, MtlDevice(handle))
    end
    Libc.free(handles)

    return devices
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

# Kernel Intrinsics
nodim_intr = [
    "dispatch_quadgroups_per_threadgroup", "dispatch_simdgroups_per_threadgroup",
    "quadgroup_index_in_threadgroup", "quadgroups_per_threadgroup",
    "simdgroup_index_in_threadgroup", "simdgroups_per_threadgroup",
    "thread_index_in_quadgroup", "thread_index_in_simdgroup", "thread_index_in_threadgroup",
    "thread_execution_width", "threads_per_simdgroup"]

for intr in nodim_intr
    # XXX: these are also available as UInt16 (ushort)
    @eval $(Symbol(intr))() = ccall($"extern julia.air.$intr.i32", llvmcall, UInt32, ())
    @eval export $(Symbol(intr))
end

# ushort vec or uint vec
dim_intr = [
    "dispatch_threads_per_threadgroup",
    "grid_origin", "grid_size",
    "thread_position_in_grid", "thread_position_in_threadgroup",
    "threadgroup_position_in_grid", "threadgroups_per_grid",
    "threads_per_grid", "threads_per_threadgroup"]

for intr in dim_intr
    # XXX: these are also available as UInt16 (ushort)
    @eval $(Symbol(intr * "_1d"))() = ccall($"extern julia.air.$intr.i32", llvmcall, UInt32, ())
    @eval $(Symbol(intr * "_2d"))() = ccall($"extern julia.air.$intr.v2i32", llvmcall, NTuple{2, VecElement{UInt32}}, ())
    @eval $(Symbol(intr * "_3d"))() = ccall($"extern julia.air.$intr.v3i32", llvmcall, NTuple{3, VecElement{UInt32}}, ())
    @eval export $(Symbol(intr * "_1d"))
    @eval export $(Symbol(intr * "_2d"))
    @eval export $(Symbol(intr * "_3d"))
end