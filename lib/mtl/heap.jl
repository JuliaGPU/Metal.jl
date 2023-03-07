#
# heap enums
#

@cenum MTLHeapType::NSUInteger begin
    MTLHeapTypeAutomatic = 0
    MTLHeapTypePlacement = 1
end


#
# heap descriptor
#

export MTLHeapDescriptor

@objcwrapper immutable=false MTLHeapDescriptor <: NSObject

function MTLHeapDescriptor()
    handle = @objc [MTLHeapDescriptor new]::id{MTLHeapDescriptor}
    obj = MTLHeapDescriptor(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(desc::MTLHeapDescriptor)
    release(desc)
end


## properties

@objcproperties MTLHeapDescriptor begin
    # Configuring a Heap
    @autoproperty type::MTLHeapType setter=setType
    @autoproperty storageMode::MTLStorageMode setter=setStorageMode
    @autoproperty cpuCacheMode::MTLCPUCacheMode setter=setCpuCacheMode
    @autoproperty hazardTrackingMode::MTLHazardTrackingMode setter=setHazardTrackingMode
    @autoproperty resourceOptions::MTLResourceOptions setter=setResourceOptions
    @autoproperty size::NSUInteger setter=setSize
end



#
# heap
#

export MTLHeap

@objcwrapper immutable=false MTLHeap <: NSObject

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtHeap}}, obj::MTLHeap) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLHeap(ptr::Ptr{MtHeap}) = MTLHeap(reinterpret(id{MTLHeap}, ptr))

function MTLHeap(dev::MTLDevice, desc::MTLHeapDescriptor)
    handle = @objc [dev::id{MTLDevice} newHeapWithDescriptor:desc::id{MTLHeapDescriptor}]::id{MTLHeap}
    obj = MTLHeap(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(desc::MTLHeap)
    release(desc)
end


## properties

@objcproperties MTLHeap begin
    # Identifying the Heap
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel

    # Querying Heap Properties
    @autoproperty type::MTLHeapType
    @autoproperty storageMode::MTLStorageMode
    @autoproperty cpuCacheMode::MTLCPUCacheMode
    @autoproperty hazardTrackingMode::MTLHazardTrackingMode
    @autoproperty resourceOptions::MTLResourceOptions
    @autoproperty size::NSUInteger
    @autoproperty usedSize::NSUInteger
    @autoproperty currentAllocatedSize::NSUInteger
end
