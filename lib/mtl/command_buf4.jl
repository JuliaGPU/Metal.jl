#
# command buffer
#

export MTL4CommandBuffer, commit!, beginCommandBufferWithAllocator!, endCommandBuffer!

# @objcwrapper immutable=false MTL4CommandBuffer <: NSObject

function MTL4CommandBuffer(device::MTLDevice)
    handle = @objc [device::id{MTLDevice} newCommandBuffer]::id{MTL4CommandBuffer}
    return MTL4CommandBuffer(handle)
end

function MTL4CommandBuffer(f::Base.Callable, device::MTLDevice; queue::MTL4CommandQueue=MTL4CommandQueue(device), allocator::MTL4CommandAllocator=MTL4CommandAllocator(device))
    cmdbuf = MTL4CommandBuffer(device)

    beginCommandBufferWithAllocator!(cmdbuf, allocator)

    try
        ret = f(cmdbuf)
        return ret
    finally
        endCommandBuffer!(cmdbuf)
        commit!(queue, cmdbuf)
    end
end

function beginCommandBufferWithAllocator!(cmdbuf::MTL4CommandBuffer, allocator::MTL4CommandAllocator, options::Union{Nothing, MTL4CommandBufferOptions} = nothing)
    if isnothing(options)
        @objc [cmdbuf::id{MTL4CommandBuffer} beginCommandBufferWithAllocator:allocator::id{MTL4CommandAllocator}]::Nothing
    else
        @objc [cmdbuf::id{MTL4CommandBuffer} beginCommandBufferWithAllocator:allocator::id{MTL4CommandAllocator}
                                    options:options::id{MTL4CommandBufferOptions}]::Nothing
    end
end

function endCommandBuffer!(cmdbuf::MTL4CommandBuffer)
    @objc [cmdbuf::id{MTL4CommandBuffer} endCommandBuffer]::Nothing
end

function commit!(cmdqueue::MTL4CommandQueue, cmdbuf::MTL4CommandBuffer)
    cmdbuff = Ref{MTL4CommandBuffer}(cmdbuf)
    @objc [cmdqueue::id{MTL4CommandQueue} commit:cmdbuff::Ref{MTL4CommandBuffer}
                                    count:1::NSUInteger]::Nothing
end
