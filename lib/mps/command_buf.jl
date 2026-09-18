#
# MPSCommandBuffer allows:
#   - to predicate execution of MPS kernels
#   - intermediate commits during encoding of MPS work using `commitAndContinue`
#

# @objcwrapper MPSCommandBuffer <: MTLCommandBuffer

export MPSCommandBuffer

function MPSCommandBuffer(commandBuffer::MTLCommandBufferLike)
    @objc [MPSCommandBuffer commandBufferWithCommandBuffer:commandBuffer::id{MTLCommandBuffer}]::MPSCommandBuffer
end

function MPSCommandBuffer(commandQueue)
    @objc [MPSCommandBuffer commandBufferFromCommandQueue:commandQueue::id{MTLCommandQueue}]::MPSCommandBuffer
end

# Deriving from a batched queue orders the buffer after the Metal 4 work committed so far
# with a GPU-side wait, instead of the host-side wait that converting the queue implies.
# The commit hooks see the underlying `MTLCommandBuffer`, so that is what gets registered.
function MPSCommandBuffer(bq::Metal.BatchedCommandQueue)
    cmdbuf = MPSCommandBuffer(bq.queue)
    Metal.order_after_batch!(bq, cmdbuf, Metal.derived_key(cmdbuf.commandBuffer))
    return cmdbuf
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

function commitAndContinue!(cmdbuf::MPSCommandBuffer)
    # `commitAndContinue` replaces `commandBuffer` with a fresh underlying buffer,
    # so retain and record the submitted one before asking MPS to continue.
    submitted = cmdbuf.commandBuffer
    hook = MTL.submit_hook[]
    hook === nothing || hook(submitted)
    hook = MTL.commit_hook[]
    hook === nothing || hook(submitted)
    @objc [cmdbuf::id{MPSCommandBuffer} commitAndContinue]::Nothing
    MTL.record_committed!(submitted, pointer(submitted.commandQueue))
end

function commitAndContinue!(f::Base.Callable, cmdbuf::MPSCommandBuffer)
    enqueue!(cmdbuf)
    ret = f(cmdbuf)
    commitAndContinue!(cmdbuf)
    return ret
end
