#
# event
#

export MTLEvent

# @objcwrapper immutable=false MTLEvent <: NSObject

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

# @objcwrapper immutable=false MTLSharedEvent <: MTLEvent

function MTLSharedEvent(dev::MTLDevice)
    ptr = @objc [dev::id{MTLDevice} newSharedEvent]::id{MTLSharedEvent}
    obj = MTLSharedEvent(ptr)
    finalizer(release, obj)
    return obj
end


## shared event handle

# @objcwrapper MTLSharedEventHandle <: MTLEvent

function MTLSharedEventHandle(ev::MTLSharedEvent)
    ptr = @objc [ev::id{MTLSharedEvent} newSharedEventHandle]::id{MTLSharedEventHandle}
    obj = MTLSharedEventHandle(ptr)
    finalizer(release, obj)
    return obj
end
