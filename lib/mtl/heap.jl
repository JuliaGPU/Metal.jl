#
# heap descriptor
#

export MTLHeapDescriptor

# @objcwrapper managed = true MTLHeapDescriptor <: NSObject

function MTLHeapDescriptor()
    handle = @objc [MTLHeapDescriptor new]::id{MTLHeapDescriptor}
    return adopt(MTLHeapDescriptor, handle)
end


#
# heap
#

export MTLHeap

# @objcwrapper managed = true MTLHeap <: MTLAllocation

function MTLHeap(dev::MTLDevice, desc::MTLHeapDescriptor)
    handle = @objc [dev::id{MTLDevice} newHeapWithDescriptor:desc::id{MTLHeapDescriptor}]::id{MTLHeap}
    return adopt(MTLHeap, handle)
end
