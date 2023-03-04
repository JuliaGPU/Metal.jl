export MTLEvent, MTLSharedEvent, MTLSharedEventHandle

# MTLSharedEvent extends MTLEvent, which we cannot express in Julia,
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

const event_properties = [
    (:device,               :(id{MTLDevice})),
    (:label,                :(id{NSString}),
     :setLabel),
]

Base.propertynames(::MTLEvent) = map(first, event_properties)

@eval Base.getproperty(ev::MTLEvent, f::Symbol) =
    $(emit_getproperties(:ev, :MTLEvent, :f, event_properties))

@eval Base.setproperty!(ev::MTLEvent, f::Symbol, val) =
    $(emit_setproperties(:ev, :MTLEvent, :f, :val, event_properties))

const shared_event_properties = [
    (:signaledValue,        UInt64),
    event_properties...
]

Base.propertynames(::MTLSharedEvent) = map(first, shared_event_properties)

@eval Base.getproperty(ev::MTLSharedEvent, f::Symbol) =
    $(emit_getproperties(:ev, :MTLSharedEvent, :f, shared_event_properties))

@eval Base.setproperty!(ev::MTLSharedEvent, f::Symbol, val) =
    $(emit_setproperties(:ev, :MTLSharedEvent, :f, :val, shared_event_properties))


## shared event handle

@objcwrapper MTLSharedEventHandle <: NSObject

function MTLSharedEventHandle(ev::MTLSharedEvent)
    MTLSharedEventHandle(@objc [ev::id{MTLSharedEvent} newSharedEventHandle]::id{MTLSharedEventHandle})
end
