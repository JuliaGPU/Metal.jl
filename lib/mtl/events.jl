export MTLEvent, MTLSharedEvent, MTLSharedEventHandle

@objcwrapper MTLEvent <: NSObject

function MTLEvent(dev::MTLDevice)
    MTLEvent(@objc [dev::id{MTLDevice} newEvent]::id{MTLEvent})
end

@objcwrapper MTLSharedEvent <: MTLEvent

function MTLSharedEvent(dev::MTLDevice)
    MTLSharedEvent(@objc [dev::id{MTLDevice} newSharedEvent]::id{MTLSharedEvent})
end

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtEvent}}, obj::Union{MTLEvent,MTLSharedEvent}) =
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
    $(emit_getproperties(:ev, MTLEvent, :f, event_properties))

@eval Base.setproperty!(ev::MTLEvent, f::Symbol, val) =
    $(emit_setproperties(:ev, MTLEvent, :f, :val, event_properties))

const shared_event_properties = [
    (:signaledValue,        UInt64)
]

# TODO: these don't include MTLEvent's properties.
#       use an emit_propertynames
Base.propertynames(::MTLSharedEvent) = map(first, shared_event_properties)

@eval Base.getproperty(ev::MTLSharedEvent, f::Symbol) =
    $(emit_getproperties(:ev, MTLSharedEvent, :f, shared_event_properties))

@eval Base.setproperty!(ev::MTLSharedEvent, f::Symbol, val) =
    $(emit_setproperties(:ev, MTLSharedEvent, :f, :val, shared_event_properties))


## shared event handle

@objcwrapper MTLSharedEventHandle <: NSObject

function MTLSharedEventHandle(ev::MTLSharedEvent)
    MTLSharedEventHandle(@objc [ev::id{MTLSharedEvent} newSharedEventHandle]::id{MTLSharedEventHandle})
end
