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

function allocatedSize(alloc::MTL4CommandAllocator)::UInt64
    @objc [alloc::id{MTL4CommandAllocator} allocatedSize]::UInt64
end

function reset!(alloc::MTL4CommandAllocator)
    @objc [alloc::id{MTL4CommandAllocator} reset]::Nothing
end
