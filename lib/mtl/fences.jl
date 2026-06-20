export MTLFence

# @objcwrapper managed = true MTLFence <: NSObject

function MTLFence(dev::MTLDevice)
    ptr = @objc [dev::id{MTLDevice} newFence]::id{MTLFence}
    return adopt(MTLFence, ptr)
end
