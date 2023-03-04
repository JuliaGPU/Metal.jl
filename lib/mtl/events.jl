export MTLEvent, MTLSharedEvent, MTLSharedEventHandle

# MTLSharedEvend extends MTLEvent, which we cannot express in Julia,
# so we use a common supertype that has all of the MTLEven properties.
abstract type MTLAbstractEvent <: NSObject end

@objcwrapper MTLEvent <: MTLAbstractEvent

@objcwrapper MTLSharedEvent <: MTLAbstractEvent

function MTLEvent(dev::MTLDevice)
    MTLEvent(@objc [dev::id{MTLDevice} newEvent]::id{MTLEvent})
end

function MTLSharedEvent(dev::MTLDevice)
    MTLSharedEvent(@objc [dev::id{MTLDevice} newSharedEvent]::id{MTLSharedEvent})
end

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtEvent}}, obj::MTLAbstractEvent) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLEvent(ptr::Ptr{MtEvent}) = MTLEvent(reinterpret(id, ptr))
Base.unsafe_convert(T::Type{Ptr{MtSharedEvent}}, obj::MTLSharedEvent) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLSharedEvent(ptr::Ptr{MtSharedEvent}) = MTLSharedEvent(reinterpret(id, ptr))


## properties

Base.propertynames(::MTLAbstractEvent) = (:device, :label, :signaledValue)

function Base.getproperty(ev::MTLAbstractEvent, f::Symbol)
    if f === :device
        ptr = @objc [ev::id{MTLEvent} device]::id{MTLDevice}
        ptr === nil ? nothing : MTLDevice(ptr)
    elseif f === :label
        str = @objc [ev::id{MTLEvent} label]::id{NSString}
        str === nil ? nothing : String(NSString(str))
    elseif ev isa MTLSharedEvent && f === :signaledValue
        @objc [ev::id{MTLSharedEvent} signaledValue]::UInt64
    else
        getfield(ev, f)
    end
end

function Base.setproperty!(ev::MTLAbstractEvent, f::Symbol, val)
    if f === :label
        @objc [ev::id{MTLEvent} setLabel:val::id{NSString}]::Cvoid
    else
        setfield!(ev, f, val)
    end
end


## shared event handle

@objcwrapper MTLSharedEventHandle <: NSObject

function MTLSharedEventHandle(ev::MTLSharedEvent)
    MTLSharedEventHandle(@objc [ev::id{MTLSharedEvent} newSharedEventHandle]::id{MTLSharedEventHandle})
end
