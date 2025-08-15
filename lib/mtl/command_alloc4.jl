
export MTL4CommandAllocatorDescriptor

function MTL4CommandAllocatorDescriptor()
    handle = @objc [MTL4CommandAllocatorDescriptor new]::id{MTL4CommandAllocatorDescriptor}
    obj = MTL4CommandAllocatorDescriptor(handle)
    finalizer(release, obj)
    return obj
end
function MTL4CommandAllocatorDescriptor(label)
    desc = MTL4CommandAllocatorDescriptor()
    desc.label = label
    return desc
end



#
# command allocator
#

export MTL4CommandAllocator

# @objcwrapper immutable=false MTL4CommandAllocator <: NSObject

function MTL4CommandAllocator(device::MTLDevice)
    handle = @objc [device::id{MTLDevice} newCommandAllocator]::id{MTL4CommandAllocator}
    obj = MTL4CommandAllocator(handle)
    finalizer(release, obj)
    return obj
end

function MTL4CommandAllocator(dev::MTLDevice, descriptor::MTL4CommandAllocatorDescriptor)
    err = Ref{id{NSError}}(nil)
    handle = @objc [dev::id{MTLDevice} newCommandAllocatorWithDescriptor:descriptor::id{MTL4CommandAllocatorDescriptor}
                                        error:err::Ptr{id{NSError}}]::id{MTL4CommandAllocator}
    obj = MTL4CommandAllocator(handle)
    finalizer(release, obj)
    return obj
end

function MTL4CommandAllocator(dev::MTLDevice, label)
    desc = MTL4CommandAllocatorDescriptor(label)
    return MTL4CommandAllocator(dev, desc)
end

function allocatedSize(alloc::MTL4CommandAllocator)::UInt64
    @objc [alloc::id{MTL4CommandAllocator} allocatedSize]::UInt64
end

function reset!(alloc::MTL4CommandAllocator)
    @objc [alloc::id{MTL4CommandAllocator} reset]::Nothing
end
