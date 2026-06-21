#
# heap descriptor
#

export MTLHeapDescriptor

# @objcwrapper managed = true MTLHeapDescriptor <: NSObject

function MTLHeapDescriptor()
    return @objc [MTLHeapDescriptor new]::MTLHeapDescriptor
end


#
# heap
#

export MTLHeap

# @objcwrapper managed = true MTLHeap <: MTLAllocation

function MTLHeap(dev::MTLDevice, desc::MTLHeapDescriptor)
    return @objc [dev::id{MTLDevice} newHeapWithDescriptor:desc::id{MTLHeapDescriptor}]::MTLHeap
end
