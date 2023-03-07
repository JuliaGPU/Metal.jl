export MTLCommandQueue

@objcwrapper immutable=false MTLCommandQueue <: NSObject

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtCommandQueue}}, obj::MTLCommandQueue) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLCommandQueue(ptr::Ptr{MtCommandQueue}) =
    MTLCommandQueue(reinterpret(id{MTLCommandQueue}, ptr))

function MTLCommandQueue(dev::MTLDevice)
    handle = @objc [dev::id{MTLDevice} newCommandQueue]::id{MTLCommandQueue}
    obj = MTLCommandQueue(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(queue::MTLCommandQueue)
    release(queue)
end


## properties

@objcproperties MTLCommandQueue begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
end
