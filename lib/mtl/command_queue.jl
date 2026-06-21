
export MTLCommandQueueDescriptor

# @objcwrapper managed = true MTLCommandQueueDescriptor <: NSObject

function MTLCommandQueueDescriptor()
    return @objc [[MTLCommandQueueDescriptor alloc]::id{MTLCommandQueueDescriptor} init]::MTLCommandQueueDescriptor
end

function MTLCommandQueue(dev::MTLDevice, descriptor::MTLCommandQueueDescriptor)
    return @objc [dev::id{MTLDevice} newCommandQueueWithDescriptor:descriptor::id{MTLCommandQueueDescriptor}]::MTLCommandQueue
end


export MTLCommandQueue

# @objcwrapper managed = true MTLCommandQueue <: NSObject

function MTLCommandQueue(dev::MTLDevice)
    return @objc [dev::id{MTLDevice} newCommandQueue]::MTLCommandQueue
end

function add_residency_set!(queue::MTLCommandQueue, resset::MTLResidencySet)
    @objc [queue::id{MTLCommandQueue} addResidencySet:resset::id{MTLResidencySet}]::Nothing
end
