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
