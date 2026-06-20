
export MTLCommandQueueDescriptor

# @objcwrapper managed = true MTLCommandQueueDescriptor <: NSObject

function MTLCommandQueueDescriptor()
    handle = @objc [MTLCommandQueueDescriptor alloc]::id{MTLCommandQueueDescriptor}
    obj = adopt(MTLCommandQueueDescriptor, handle)
    @objc [obj::id{MTLCommandQueueDescriptor} init]::id{MTLCommandQueueDescriptor}
    return obj
end

function MTLCommandQueue(dev::MTLDevice, descriptor::MTLCommandQueueDescriptor)
    handle = @objc [dev::id{MTLDevice} newCommandQueueWithDescriptor:descriptor::id{MTLCommandQueueDescriptor}]::id{MTLCommandQueue}
    return adopt(MTLCommandQueue, handle)
end


export MTLCommandQueue

# @objcwrapper managed = true MTLCommandQueue <: NSObject

function MTLCommandQueue(dev::MTLDevice)
    handle = @objc [dev::id{MTLDevice} newCommandQueue]::id{MTLCommandQueue}
    return adopt(MTLCommandQueue, handle)
end

function add_residency_set!(queue::MTLCommandQueue, resset::MTLResidencySet)
    @objc [queue::id{MTLCommandQueue} addResidencySet:resset::id{MTLResidencySet}]::Nothing
end
