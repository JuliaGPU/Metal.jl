export MTLFence

@objcwrapper MTLFence <: NSObject

@objcproperties MTLFence begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString}
end

function MTLFence(dev::MTLDevice)
    MTLFence(@objc [dev::id{MTLDevice} newFence]::id{MTLFence})
end
