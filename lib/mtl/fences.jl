export MTLFence

# @objcwrapper managed = true MTLFence <: NSObject

function MTLFence(dev::MTLDevice)
    ptr = @objc [dev::id{MTLDevice} newFence]::id{MTLFence}
    obj = MTLFence(ptr)
    finalizer(release, obj)
    return obj
end
