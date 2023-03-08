export MTLCommandQueue

@objcwrapper immutable=false MTLCommandQueue <: NSObject

function MTLCommandQueue(dev::MTLDevice)
    handle = @objc [dev::id{MTLDevice} newCommandQueue]::id{MTLCommandQueue}
    obj = MTLCommandQueue(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(queue::MTLCommandQueue)
    release(queue)
end


## properties

@objcproperties MTLCommandQueue begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
end
