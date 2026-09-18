#
# command allocator descriptor
#

export MTL4CommandAllocatorDescriptor

# @objcwrapper managed = true MTL4CommandAllocatorDescriptor <: NSObject

function MTL4CommandAllocatorDescriptor()
    return @objc [MTL4CommandAllocatorDescriptor new]::MTL4CommandAllocatorDescriptor
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

# @objcwrapper managed = true MTL4CommandAllocator <: NSObject

function MTL4CommandAllocator(dev::MTLDevice)
    return @objc [dev::id{MTLDevice} newCommandAllocator]::MTL4CommandAllocator
end

function MTL4CommandAllocator(dev::MTLDevice, desc::MTL4CommandAllocatorDescriptor)
    err = Ref{id{NSError}}(nil)
    alloc = @objc [dev::id{MTLDevice} newCommandAllocatorWithDescriptor:desc::id{MTL4CommandAllocatorDescriptor}
                                                                 error:err::Ptr{id{NSError}}]::Union{Nothing,MTL4CommandAllocator}
    alloc === nothing && throw_error(err[])
    return alloc
end

function MTL4CommandAllocator(dev::MTLDevice, label::Union{String,NSString})
    desc = MTL4CommandAllocatorDescriptor(label)
    return MTL4CommandAllocator(dev, desc)
end

"""
    allocatedSize(alloc::MTL4CommandAllocator)::UInt64

The amount of memory, in bytes, that `alloc` currently holds for command storage.
"""
function allocatedSize(alloc::MTL4CommandAllocator)
    @objc [alloc::id{MTL4CommandAllocator} allocatedSize]::UInt64
end

"""
    reset!(alloc::MTL4CommandAllocator)

Return `alloc`'s memory to it for reuse. This invalidates the commands of every command
buffer that was encoded with `alloc`, so it is only legal once the GPU has finished
executing all of them.
"""
function reset!(alloc::MTL4CommandAllocator)
    @objc [alloc::id{MTL4CommandAllocator} reset]::Nothing
end
