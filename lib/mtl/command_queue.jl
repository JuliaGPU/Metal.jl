
export MTLCommandQueueDescriptor

# @objcwrapper managed = true MTLCommandQueueDescriptor <: NSObject

function MTLCommandQueueDescriptor()
    handle = @objc [MTLCommandQueueDescriptor alloc]::id{MTLCommandQueueDescriptor}
    obj = MTLCommandQueueDescriptor(handle)
    finalizer(release, obj)
    @objc [obj::id{MTLCommandQueueDescriptor} init]::id{MTLCommandQueueDescriptor}
    return obj
end

function MTLCommandQueue(dev::MTLDevice, descriptor::MTLCommandQueueDescriptor)
    handle = @objc [dev::id{MTLDevice} newCommandQueueWithDescriptor:descriptor::id{MTLCommandQueueDescriptor}]::id{MTLCommandQueue}
    obj = MTLCommandQueue(handle)
    finalizer(release, obj)
    return obj
end


export MTLCommandQueue

# @objcwrapper managed = true MTLCommandQueue <: NSObject

function MTLCommandQueue(dev::MTLDevice)
    handle = @objc [dev::id{MTLDevice} newCommandQueue]::id{MTLCommandQueue}
    obj = MTLCommandQueue(handle)
    finalizer(release, obj)
    return obj
end

function add_residency_set!(queue::MTLCommandQueue, resset::MTLResidencySet)
    @objc [queue::id{MTLCommandQueue} addResidencySet:resset::id{MTLResidencySet}]::Nothing
end
