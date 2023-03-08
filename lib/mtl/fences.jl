export MTLFence

@objcwrapper MTLFence <: NSObject

function MTLFence(dev::MTLDevice)
    MTLFence(@objc [dev::id{MTLDevice} newFence]::id{MTLFence})
end


## properties

@objcproperties MTLFence begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString}
end
