export MtlHeapDescriptor, MtlHeap

const MTLHeapDescriptor = Ptr{MtHeapDescriptor}

mutable struct MtlHeapDescriptor
    handle::MTLHeapDescriptor
end

function MtlHeapDescriptor()
    handle = mtNewHeapDescriptor()
    obj = MtlHeapDescriptor(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(desc::MtlHeapDescriptor)
    mtRelease(desc.handle)
end

Base.unsafe_convert(::Type{MTLHeapDescriptor}, d::MtlHeapDescriptor) = d.handle

Base.:(==)(a::MtlHeapDescriptor, b::MtlHeapDescriptor) = a.handle == b.handle
Base.hash(dev::MtlHeapDescriptor, h::UInt) = hash(dev.handle, h)


## properties

Base.propertynames(::MtlHeapDescriptor) =
    (:type, :storageMode, :cpuCacheMode, :hazardTrackingMode, :resourceOptions, :size)

function Base.getproperty(o::MtlHeapDescriptor, f::Symbol)
    if f === :type
        mtHeapDescriptorType(o)
    elseif f === :storageMode
        mtHeapDescriptorStorageMode(o)
    elseif f === :cpuCacheMode
        mtHeapDescriptorCPUCacheMode(o)
    elseif f === :hazardTrackingMode
        mtHeapDescriptorHazardTrackingMode(o)
    elseif f === :resourceOptions
        mtHeapDescriptorResourceOptions(o)
    elseif f === :size
        mtHeapDescriptorSize(o)
    else
        getfield(o, f)
    end
end

function Base.setproperty!(o::MtlHeapDescriptor, f::Symbol, val)
    if f === :type
        mtHeapDescriptorTypeSet(o, val)
    elseif f === :storageMode
        mtHeapDescriptorStorageModeSet(o, val)
    elseif f === :cpuCacheMode
        mtHeapDescriptorCpuCacheModeSet(o, val)
    elseif f === :hazardTrackingMode
        mtHeapDescriptorHazardTrackingModeSet(o, val)
    elseif f === :resourceOptions
        mtHeapDescriptorResourceOptionsSet(o, val)
    elseif f === :size
        mtHeapDescriptorSizeSet(o, val)
    else
        setfield!(o, f, val)
    end
end


## display

function Base.show(io::IO, ::MIME"text/plain", o::MtlHeapDescriptor)
    print(io, "MtlHeapDescriptor: ")
    for f = propertynames(o)
        print(io, "\n $f : $(getproperty(o, f))")
    end
end



###############################################################################

const MTLHeap = Ptr{MtHeap}

mutable struct MtlHeap
    handle::MTLHeap
    device::MtlDevice
end

Base.unsafe_convert(::Type{MTLHeap}, d::MtlHeap) = d.handle

Base.:(==)(a::MtlHeap, b::MtlHeap) = a.handle == b.handle
Base.hash(dev::MtlHeap, h::UInt) = hash(dev.handle, h)

function MtlHeap(device::MtlDevice, desc::MtlHeapDescriptor)
    handle = mtDeviceNewHeapWithDescriptor(device, desc)
    obj = MtlHeap(handle, device)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(desc::MtlHeap)
    mtRelease(desc.handle)
end


## properties

Base.propertynames(::MtlHeap) =
    (:device, :label, :type, :storageMode, :cpuCacheMode, :hazardTrackingMode,
      :resourceOptions, :size, :usedSize, :currentAllocatedSize, :maxAvailableSizeWithAlignment)

function Base.getproperty(o::MtlHeap, f::Symbol)
    if f === :device
        mtHeapDevice(heap)
    elseif f === :label
        ptr = mtHeapLabel(o)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    elseif f === :type
        mtHeapType(o)
    elseif f === :storageMode
        mtHeapStorageMode(o)
    elseif f === :cpuCacheMode
        mtHeapCPUCacheMode(o)
    elseif f === :hazardTrackingMode
        mtHeapHazardTrackingMode(o)
    elseif f === :resourceOptions
        mtHeapResourceOptions(o)
    elseif f === :size
        mtHeapSize(o)
    elseif f === :usedSize
        mtHeapUsedSize(o)
    elseif f === :currentAllocatedSize
        mtHeapCurrentAllocatedSize(o)
    elseif f === :maxAvailableSizeWithAlignment
        maxAvailableSizeWithAlignment(o)
    else
        getfield(o, f)
    end
end

function Base.setproperty!(o::MtlHeap, f::Symbol, val)
    if f === :label
        mtHeapLabelSet(o, val)
    else
        setfield!(o, f, val)
    end
end


## display

function Base.show(io::IO, ::MIME"text/plain", o::MtlHeap)
    print(io, "MtlHeap: ")
    for f = propertynames(o)
        print(io, "\n $f : $(getproperty(o, f))")
    end
end
