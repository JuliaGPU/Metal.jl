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

Base.propertynames(::MTLFence) = (:device, :label)

function Base.getproperty(ev::MTLFence, f::Symbol)
    if f === :device
        ptr = @objc [ev::id{MTLFence} device]::id{MTLDevice}
        ptr === nil ? nothing : MTLDevice(ptr)
    elseif f === :label
        str = @objc [ev::id{MTLFence} label]::id{NSString}
        str === nil ? nothing : String(NSString(str))
    else
        getfield(ev, f)
    end
end

function Base.setproperty!(ev::MTLFence, f::Symbol, val)
    if f === :label
        @objc [ev::id{MTLFence} setLabel:val::id{NSString}]::Cvoid
    else
        setfield!(ev, f, val)
    end
end
