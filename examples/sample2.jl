using MetalCore

@show devices()
dev = MtlDevice(1)


bufferSize = 128
bufferA = MtlBuffer(dev, Float32, bufferSize, MetalCore.MtResourceStorageModeShared)
bufferB = MtlBuffer(dev, Float32, bufferSize, MetalCore.MtResourceStorageModeShared)
bufferH = MtlBuffer(dev, Float32, bufferSize, MetalCore.MtResourceStorageModePrivate)

ptrA = convert(Ptr{Float32}, contents(bufferA))
ptrB = convert(Ptr{Float32}, contents(bufferB))

vecA = unsafe_wrap(Vector{Float32}, ptrA, bufferSize)
vecB = unsafe_wrap(Vector{Float32}, ptrB, bufferSize)

using Random
rand!(vecA)

queue = MetalCore.global_queue(dev)

cmdBuffer = MtlCommandBuffer(queue)

blitEncoder = MtlBlitCommandEncoder(cmdBuffer) do enc
    MetalCore.encode_copy!(enc, bufferA, bufferB, 0, 0, 128*4)
end

MetalCore.commit!(cmdBuffer)

MetalCore.waitUntilCompleted(cmdBuffer)

vecB .= 0
MetalCore.commit!(queue) do buffer
    MtlBlitCommandEncoder(buffer) do enc
        MetalCore.encode_copy!(enc, bufferA, bufferB, 0, 0, 128*4)
    end
end


# buffer

## add compute


#mycfun(asd) = (tuple(1,4); return nothing);#return println("hello", asd)
#cf = @cfunction(mycfun, Cvoid, (MetalCore.MTLCommandBuffer, ))

#MetalCore.mtCommandBufferAddCompletedHandler(cmdBuffer, cf)
