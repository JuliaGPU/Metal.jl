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

# TODO: Remove when `macos_version() == v"15"` is the mininimum version supported
Base.sizeof(heap::MTLHeap) = Int(heap.size)

# @objcwrapper immutable=false MTLHeap <: MTLAllocation

function MTLHeap(dev::MTLDevice, desc::MTLHeapDescriptor)
    handle = @objc [dev::id{MTLDevice} newHeapWithDescriptor:desc::id{MTLHeapDescriptor}]::id{MTLHeap}
    obj = MTLHeap(handle)
    return obj
end

function setPurgeableState!(heap::MTLHeap, state)
    @objc [heap::id{MTLHeap} setPurgeableState:state::MTLPurgeableState]::MTLPurgeableState
end

function getPurgeableState(heap::MTLHeap)
    setPurgeableState!(heap::MTLHeap, MTLPurgeableStateKeepCurrent)
end

function heapBufferSizeAndAlign(dev::MTLDevice, length, options)
        @objc [dev::id{MTLDevice} heapBufferSizeAndAlignWithLength:length::NSUInteger
                                     options:options::MTLResourceOptions]::MTLSizeAndAlign
end

function maxAvailableSizeWithAlignment(heap::MTLHeap, alignment)
        @objc [heap::id{MTLHeap} maxAvailableSizeWithAlignment:alignment::NSUInteger]::NSUInteger
end
