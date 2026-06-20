export MTLFence

# @objcwrapper managed = true MTLFence <: NSObject

function MTLFence(dev::MTLDevice)
    return @objc [dev::id{MTLDevice} newFence]::MTLFence
end
