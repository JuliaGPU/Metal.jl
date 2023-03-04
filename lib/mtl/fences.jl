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

const fence_properties = [
    (:device,               :(id{MTLDevice})),
    (:label,                :(id{NSString}),
     :setLabel),
]

Base.propertynames(::MTLFence) = map(first, fence_properties)

@eval Base.getproperty(obj::MTLFence, f::Symbol) =
    $(emit_getproperties(:obj, :MTLFence, :f, fence_properties))

@eval Base.setproperty!(obj::MTLFence, f::Symbol, val) =
    $(emit_setproperties(:obj, :MTLFence, :f, :val, fence_properties))
