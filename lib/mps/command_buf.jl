#
# command buffer
#

# XXX: Not actually inheritance but MPSCommandBuffer conforms to MTLCommandBuffer protocol
@objcwrapper immutable=false MPSCommandBuffer <: MTLCommandBuffer

@objcproperties MPSCommandBuffer begin
    # Identifying the Command Buffer
    @autoproperty commandBuffer::id{MTLCommandBuffer}
    # @autoproperty heapProvider::id{MPSHeapProvider}
    # @autoproperty predicate::id{MPSPredicate}
    @autoproperty rootCommandBuffer::id{MTLCommandBuffer}
end

function MPSCommandBuffer(commandBuffer::MTLCommandBuffer)
    cmdbuf = @objc [MPSCommandBuffer commandBufferWithCommandBuffer:commandBuffer::id{MTLCommandBuffer}]::id{MPSCommandBuffer}
    obj = MPSCommandBuffer(cmdbuf)
    finalizer(release, obj)
    return obj
end

function MPSCommandBuffer(commandQueue::MTLCommandQueue)
    cmdbuf = @objc [MPSCommandBuffer commandBufferFromCommandQueue:commandQueue::id{MTLCommandQueue}]::id{MPSCommandBuffer}
    obj = MPSCommandBuffer(cmdbuf)
    finalizer(release, obj)
    return obj
end

function MPSCommandBuffer(f::Base.Callable, queueOrBuf::Q) where Q <: Union{MTLCommandBuffer, MTLCommandQueue}
    cmdbuf = MPSCommandBuffer(queueOrBuf)
    cmdbuf = commitAndContinue!(f, cmdbuf)
    return cmdbuf
end

MTL.enqueue!(cmdbuf::MPSCommandBuffer) = @inline MTL.enqueue!(cmdbuf.commandBuffer)
MTL.commit!(cmdbuf::MPSCommandBuffer) = @inline MTL.commit!(cmdbuf.commandBuffer)

function commitAndContinue!(cmdbuf::MPSCommandBuffer)
    @objc [cmdbuf::id{MPSCommandBuffer} commitAndContinue]::Nothing
end

function commitAndContinue!(f::Base.Callable, cmdbuf::MPSCommandBuffer)
    enqueue!(cmdbuf)
    ret = f(cmdbuf)
    commitAndContinue!(cmdbuf)
    return cmdbuf
end
