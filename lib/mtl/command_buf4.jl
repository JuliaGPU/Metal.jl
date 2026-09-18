#
# command buffer options
#

export MTL4CommandBufferOptions

# @objcwrapper managed = true MTL4CommandBufferOptions <: NSObject

function MTL4CommandBufferOptions()
    return @objc [MTL4CommandBufferOptions new]::MTL4CommandBufferOptions
end


#
# command buffer
#

export MTL4CommandBuffer, beginCommandBuffer!, endCommandBuffer!

# @objcwrapper managed = true MTL4CommandBuffer <: NSObject

"""
    MTL4CommandBuffer(dev::MTLDevice)

Create a Metal 4 command buffer. Unlike a Metal 3 `MTLCommandBuffer`, this object is not
tied to a queue and carries no storage of its own: it is a reusable encoding cursor that
writes into the [`MTL4CommandAllocator`](@ref) passed to [`beginCommandBuffer!`](@ref), and
it can be re-used for another encoding pass as soon as it has been committed.
"""
function MTL4CommandBuffer(dev::MTLDevice)
    return @objc [dev::id{MTLDevice} newCommandBuffer]::MTL4CommandBuffer
end

function MTL4CommandBuffer(dev::MTLDevice, label::Union{String,NSString})
    cmdbuf = MTL4CommandBuffer(dev)
    cmdbuf.label = label
    return cmdbuf
end

"""
    beginCommandBuffer!(cmdbuf::MTL4CommandBuffer, allocator::MTL4CommandAllocator, [options])

Open `cmdbuf` for encoding, storing its commands in `allocator`.
"""
function beginCommandBuffer!(cmdbuf::MTL4CommandBuffer, allocator::MTL4CommandAllocator)
    @objc [cmdbuf::id{MTL4CommandBuffer} beginCommandBufferWithAllocator:allocator::id{MTL4CommandAllocator}]::Nothing
end

function beginCommandBuffer!(cmdbuf::MTL4CommandBuffer, allocator::MTL4CommandAllocator,
                             options::MTL4CommandBufferOptions)
    @objc [cmdbuf::id{MTL4CommandBuffer} beginCommandBufferWithAllocator:allocator::id{MTL4CommandAllocator}
                                                                options:options::id{MTL4CommandBufferOptions}]::Nothing
end

"""
    endCommandBuffer!(cmdbuf::MTL4CommandBuffer)

Close `cmdbuf` for encoding, making it eligible for `commit!`.
"""
function endCommandBuffer!(cmdbuf::MTL4CommandBuffer)
    @objc [cmdbuf::id{MTL4CommandBuffer} endCommandBuffer]::Nothing
end

"""
    MTL4CommandBuffer(f, dev, allocator; queue, options)

Open a command buffer, apply `f` to it, then end and commit it on `queue`, returning `f`'s
value.
"""
function MTL4CommandBuffer(f::Base.Callable, dev::MTLDevice,
                           allocator::MTL4CommandAllocator=MTL4CommandAllocator(dev);
                           queue::MTL4CommandQueue=MTL4CommandQueue(dev),
                           options::Union{Nothing,MTL4CommitOptions}=nothing)
    cmdbuf = MTL4CommandBuffer(dev)
    beginCommandBuffer!(cmdbuf, allocator)
    ret = try
        f(cmdbuf)
    finally
        endCommandBuffer!(cmdbuf)
    end
    if options === nothing
        commit!(queue, cmdbuf)
    else
        commit!(queue, cmdbuf, options)
    end
    return ret
end

function use_residency_set!(cmdbuf::MTL4CommandBuffer, resset::MTLResidencySet)
    @objc [cmdbuf::id{MTL4CommandBuffer} useResidencySet:resset::id{MTLResidencySet}]::Nothing
end

function use_residency_sets!(cmdbuf::MTL4CommandBuffer, ressets, count)
    @objc [cmdbuf::id{MTL4CommandBuffer} useResidencySets:ressets::Ptr{id{MTLResidencySet}}
                                                  count:count::NSUInteger]::Nothing
end

function push_debug_group!(cmdbuf::MTL4CommandBuffer, name::Union{String,NSString})
    @objc [cmdbuf::id{MTL4CommandBuffer} pushDebugGroup:name::id{NSString}]::Nothing
end

function pop_debug_group!(cmdbuf::MTL4CommandBuffer)
    @objc [cmdbuf::id{MTL4CommandBuffer} popDebugGroup]::Nothing
end
