#
# MPSCommandBuffer allows:
#   - to predicate execution of MPS kernels
#   - intermediate commits during encoding of MPS work using `commitAndContinue`
#

# XXX: Not actually inheritance but MPSCommandBuffer conforms to MTLCommandBuffer protocol
@objcwrapper MPSCommandBuffer <: MTLCommandBuffer

@objcproperties MPSCommandBuffer begin
    # Identifying the Command Buffer
    @autoproperty commandBuffer::id{MTLCommandBuffer}
    # @autoproperty heapProvider::id{MPSHeapProvider}
    # @autoproperty predicate::id{MPSPredicate}
    @autoproperty rootCommandBuffer::id{MTLCommandBuffer}
end

function MPSCommandBuffer(commandBuffer::MTLCommandBuffer)
    cmdbuf = @objc [MPSCommandBuffer commandBufferWithCommandBuffer:commandBuffer::id{MTLCommandBuffer}]::id{MPSCommandBuffer}
    MPSCommandBuffer(cmdbuf)
end

function MPSCommandBuffer(commandQueue::MTLCommandQueue)
    cmdbuf = @objc [MPSCommandBuffer commandBufferFromCommandQueue:commandQueue::id{MTLCommandQueue}]::id{MPSCommandBuffer}
    MPSCommandBuffer(cmdbuf)
end

function MPSCommandBuffer(f::Base.Callable, queueOrBuf)
    cmdbuf = MPSCommandBuffer(queueOrBuf)
    commitAndContinue!(f, cmdbuf)
    return cmdbuf
end

MTL.enqueue!(cmdbuf::MPSCommandBuffer) = @inline MTL.enqueue!(cmdbuf.commandBuffer)
MTL.commit!(cmdbuf::MPSCommandBuffer) = @inline MTL.commit!(cmdbuf.commandBuffer)

function MPS.commit!(f::Base.Callable, cmdbuf::MPSCommandBuffer)
    enqueue!(cmdbuf)
    ret = f(cmdbuf)
    commit!(cmdbuf)
    return cmdbuf
end

commitAndContinue!(cmdbuf::MPSCommandBuffer) =
    @objc [cmdbuf::id{MPSCommandBuffer} commitAndContinue]::Nothing

function commitAndContinue!(f::Base.Callable, cmdbuf::MPSCommandBuffer)
    enqueue!(cmdbuf)
    ret = f(cmdbuf)
    commitAndContinue!(cmdbuf)
    return cmdbuf
end
