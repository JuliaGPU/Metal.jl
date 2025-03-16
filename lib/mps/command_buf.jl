#
# MPSCommandBuffer allows:
#   - to predicate execution of MPS kernels
#   - intermediate commits during encoding of MPS work using `commitAndContinue`
#

# @objcwrapper MPSCommandBuffer <: MTLCommandBuffer

export MPSCommandBuffer

function MPSCommandBuffer(commandBuffer::MTLCommandBuffer)
    handle = @objc [MPSCommandBuffer commandBufferWithCommandBuffer:commandBuffer::id{MTLCommandBuffer}]::id{MPSCommandBuffer}
    MPSCommandBuffer(handle)
end

function MPSCommandBuffer(commandQueue::MTLCommandQueue)
    handle = @objc [MPSCommandBuffer commandBufferFromCommandQueue:commandQueue::id{MTLCommandQueue}]::id{MPSCommandBuffer}
    MPSCommandBuffer(handle)
end

function MPSCommandBuffer(f::Base.Callable, queueOrBuf)
    cmdbuf = MPSCommandBuffer(queueOrBuf)
    commitAndContinue!(f, cmdbuf)
    return cmdbuf
end

MTL.enqueue!(cmdbuf::MPSCommandBuffer) = @inline MTL.enqueue!(cmdbuf.commandBuffer)
MTL.commit!(cmdbuf::MPSCommandBuffer) = @inline MTL.commit!(cmdbuf.commandBuffer)

function MTL.commit!(f::Base.Callable, cmdbuf::MPSCommandBuffer)
    enqueue!(cmdbuf)
    ret = f(cmdbuf)
    commit!(cmdbuf)
    return ret
end

export commitAndContinue!

commitAndContinue!(cmdbuf::MPSCommandBuffer) =
    @objc [cmdbuf::id{MPSCommandBuffer} commitAndContinue]::Nothing

function commitAndContinue!(f::Base.Callable, cmdbuf::MPSCommandBuffer)
    enqueue!(cmdbuf)
    ret = f(cmdbuf)
    commitAndContinue!(cmdbuf)
    return ret
end
