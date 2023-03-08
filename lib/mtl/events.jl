#
# event
#

export MTLEvent

@objcwrapper MTLEvent <: NSObject

@objcproperties MTLEvent begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
end

function MTLEvent(dev::MTLDevice)
    MTLEvent(@objc [dev::id{MTLDevice} newEvent]::id{MTLEvent})
end


#
# shared event
#

export MTLSharedEvent, MTLSharedEventHandle

@objcwrapper MTLSharedEvent <: MTLEvent

@objcproperties MTLSharedEvent begin
    @autoproperty signaledValue::UInt64
end

function MTLSharedEvent(dev::MTLDevice)
    MTLSharedEvent(@objc [dev::id{MTLDevice} newSharedEvent]::id{MTLSharedEvent})
end


## shared event handle

@objcwrapper MTLSharedEventHandle <: NSObject

function MTLSharedEventHandle(ev::MTLSharedEvent)
    MTLSharedEventHandle(@objc [ev::id{MTLSharedEvent} newSharedEventHandle]::id{MTLSharedEventHandle})
end
