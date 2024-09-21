export MTLCommandQueueDescriptor

@objcwrapper immutable=false MTLCommandQueueDescriptor <: NSObject

@objcproperties MTLCommandQueueDescriptor begin
    @autoproperty maxCommandBufferCount::NSUInteger
    @autoproperty logState::id{MTLLogState} setter=setLogState
end

function MTLCommandQueueDescriptor()
    handle = @objc [MTLCommandQueueDescriptor alloc]::id{MTLCommandQueueDescriptor}
    obj = MTLCommandQueueDescriptor(handle)
    finalizer(release, obj)
    @objc [obj::id{MTLCommandQueueDescriptor} init]::id{MTLCommandQueueDescriptor}
    return obj
end


export MTLCommandQueue

@objcwrapper immutable=false MTLCommandQueue <: NSObject

@objcproperties MTLCommandQueue begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
end

function MTLCommandQueue(dev::MTLDevice)
    handle = @objc [dev::id{MTLDevice} newCommandQueue]::id{MTLCommandQueue}
    obj = MTLCommandQueue(handle)
    finalizer(release, obj)
    return obj
end

function MTLCommandQueue(dev::MTLDevice, descriptor::MTLCommandQueueDescriptor)
    handle = @objc [dev::id{MTLDevice} newCommandQueueWithDescriptor:descriptor::id{MTLCommandQueueDescriptor}]::id{MTLCommandQueue}
    obj = MTLCommandQueue(handle)
    finalizer(release, obj)
    return obj
end
