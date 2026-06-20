#
# event
#

export MTLEvent

# @objcwrapper managed = true MTLEvent <: NSObject

function MTLEvent(dev::MTLDevice)
    ptr = @objc [dev::id{MTLDevice} newEvent]::id{MTLEvent}
    return adopt(MTLEvent, ptr)
end


#
# shared event
#

export MTLSharedEvent, MTLSharedEventHandle

# @objcwrapper managed = true MTLSharedEvent <: MTLEvent

function MTLSharedEvent(dev::MTLDevice)
    ptr = @objc [dev::id{MTLDevice} newSharedEvent]::id{MTLSharedEvent}
    return adopt(MTLSharedEvent, ptr)
end

function waitUntilSignaledValue(ev::MTLSharedEvent, value, timeoutMS=typemax(UInt64))
    @objc [ev::id{MTLSharedEvent} waitUntilSignaledValue:value::UInt64
                        timeoutMS:timeoutMS::UInt64]::Bool
end

## shared event handle

# @objcwrapper managed = true MTLSharedEventHandle <: MTLEvent

function MTLSharedEventHandle(ev::MTLSharedEvent)
    ptr = @objc [ev::id{MTLSharedEvent} newSharedEventHandle]::id{MTLSharedEventHandle}
    return adopt(MTLSharedEventHandle, ptr)
end
