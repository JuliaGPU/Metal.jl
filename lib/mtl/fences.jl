export MTLFence

@objcwrapper MTLFence <: NSObject

function MTLFence(dev::MTLDevice)
    MTLFence(@objc [dev::id{MTLDevice} newFence]::id{MTLFence})
end

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtFence}}, obj::MTLFence) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLFence(ptr::Ptr{MtFence}) = MTLFence(reinterpret(id, ptr))


## properties

@objcproperties MTLFence begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString}
end
