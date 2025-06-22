
export MTL4CommandQueue

# @objcwrapper immutable=false MTL4CommandQueue <: NSObject

function MTL4CommandQueue(dev::MTLDevice)
    handle = @objc [dev::id{MTLDevice} newMTL4CommandQueue]::id{MTL4CommandQueue}
    obj = MTL4CommandQueue(handle)
    finalizer(release, obj)
    return obj
end
