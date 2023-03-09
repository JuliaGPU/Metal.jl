#
# event
#

export MTLEvent

@objcwrapper immutable=false MTLEvent <: NSObject

@objcproperties MTLEvent begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
end

function MTLEvent(dev::MTLDevice)
    ptr = @objc [dev::id{MTLDevice} newEvent]::id{MTLEvent}
    obj = MTLEvent(ptr)
    finalizer(release, obj)
    return obj
end


#
# shared event
#

export MTLSharedEvent, MTLSharedEventHandle

@objcwrapper immutable=false MTLSharedEvent <: MTLEvent

@objcproperties MTLSharedEvent begin
    @autoproperty signaledValue::UInt64
end

function MTLSharedEvent(dev::MTLDevice)
    ptr = @objc [dev::id{MTLDevice} newSharedEvent]::id{MTLSharedEvent}
    obj = MTLSharedEvent(ptr)
    finalizer(release, obj)
    return obj
end


## shared event handle

@objcwrapper MTLSharedEventHandle <: NSObject

function MTLSharedEventHandle(ev::MTLSharedEvent)
    ptr = @objc [ev::id{MTLSharedEvent} newSharedEventHandle]::id{MTLSharedEventHandle}
    obj = MTLSharedEventHandle(ptr)
    finalizer(release, obj)
    return obj
end
