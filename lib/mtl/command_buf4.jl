#
# command buffer
#

export MTL4CommandBuffer, commit!, beginCommandBufferWithAllocator!, endCommandBuffer!

# @objcwrapper immutable=false MTL4CommandBuffer <: NSObject

function MTL4CommandBuffer(device::MTLDevice, label=nothing)
    handle = @objc [device::id{MTLDevice} newCommandBuffer]::id{MTL4CommandBuffer}
    buf = MTL4CommandBuffer(handle)
    if !isnothing(label)
        buf.label = label
    end
    return buf
end

function MTL4CommandBuffer(f::Base.Callable, device::MTLDevice, label=nothing; queue::MTL4CommandQueue=MTL4CommandQueue(device), allocator::MTL4CommandAllocator=MTL4CommandAllocator(device))
    cmdbuf = MTL4CommandBuffer(device, label)

    commit!(f, cmdbuf, queue, allocator)
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
    cmdbufRef = Ref{MTL4CommandBuffer}(cmdbuf)
    @objc [cmdqueue::id{MTL4CommandQueue} commit:cmdbufRef::Ref{MTL4CommandBuffer}
                                    count:1::NSUInteger]::Nothing
end
function commit!(cmdqueue::MTL4CommandQueue, cmdbuf::MTL4CommandBuffer, options::MTL4CommitOptions)
    cmdbufRef = Ref{MTL4CommandBuffer}(cmdbuf)
    @objc [cmdqueue::id{MTL4CommandQueue} commit:cmdbufRef::Ref{MTL4CommandBuffer}
                                    count:1::NSUInteger
                                    options:options::id{MTL4CommitOptions}]::Nothing
end

function commit!(f::Base.Callable, cmdbuf::MTL4CommandBuffer, queue::MTL4CommandQueue, allocator::MTL4CommandAllocator)
    beginCommandBufferWithAllocator!(cmdbuf, allocator)

    try
        ret = f(cmdbuf)
        return ret
    finally
        endCommandBuffer!(cmdbuf)
        commit!(queue, cmdbuf)
    end
end
