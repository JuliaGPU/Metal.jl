export MTLFence

# @objcwrapper immutable=false MTLFence <: NSObject

# @objcproperties MTLFence begin
#     @autoproperty device::id{MTLDevice}
#     @autoproperty label::id{NSString}
# end

function MTLFence(dev::MTLDevice)
    ptr = @objc [dev::id{MTLDevice} newFence]::id{MTLFence}
    obj = MTLFence(ptr)
    finalizer(release, obj)
    return obj
end
