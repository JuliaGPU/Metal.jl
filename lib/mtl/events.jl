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

@objcproperties MTLEvent begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
end

@objcproperties MTLSharedEvent begin
    @autoproperty signaledValue::UInt64
end


## shared event handle

@objcwrapper MTLSharedEventHandle <: NSObject

function MTLSharedEventHandle(ev::MTLSharedEvent)
    MTLSharedEventHandle(@objc [ev::id{MTLSharedEvent} newSharedEventHandle]::id{MTLSharedEventHandle})
end
