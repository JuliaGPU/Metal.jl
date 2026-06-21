#
# event
#

export MTLEvent

# @objcwrapper managed = true MTLEvent <: NSObject

function MTLEvent(dev::MTLDevice)
    return @objc [dev::id{MTLDevice} newEvent]::MTLEvent
end


#
# shared event
#

export MTLSharedEvent, MTLSharedEventHandle

# @objcwrapper managed = true MTLSharedEvent <: MTLEvent

function MTLSharedEvent(dev::MTLDevice)
    return @objc [dev::id{MTLDevice} newSharedEvent]::MTLSharedEvent
end

function waitUntilSignaledValue(ev::MTLSharedEvent, value, timeoutMS=typemax(UInt64))
    @objc [ev::id{MTLSharedEvent} waitUntilSignaledValue:value::UInt64
                        timeoutMS:timeoutMS::UInt64]::Bool
end

## shared event handle

# @objcwrapper managed = true MTLSharedEventHandle <: MTLEvent

function MTLSharedEventHandle(ev::MTLSharedEvent)
    return @objc [ev::id{MTLSharedEvent} newSharedEventHandle]::MTLSharedEventHandle
end
