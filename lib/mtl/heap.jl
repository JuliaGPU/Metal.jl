#
# heap descriptor
#

export MTLHeapDescriptor

# @objcwrapper immutable=false MTLHeapDescriptor <: NSObject

function MTLHeapDescriptor()
    handle = @objc [MTLHeapDescriptor new]::id{MTLHeapDescriptor}
    obj = MTLHeapDescriptor(handle)
    finalizer(release, obj)
    return obj
end


#
# heap
#

export MTLHeap

# @objcwrapper immutable=false MTLHeap <: MTLAllocation

function MTLHeap(dev::MTLDevice, desc::MTLHeapDescriptor)
    handle = @objc [dev::id{MTLDevice} newHeapWithDescriptor:desc::id{MTLHeapDescriptor}]::id{MTLHeap}
    obj = MTLHeap(handle)
    finalizer(release, obj)
    return obj
end
