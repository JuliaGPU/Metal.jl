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

queue = MtlCommandQueue(dev)



# buffer
cmdBuffer = MtlCommandBuffer(queue)
blitEncoder = MtlBlitCommandEncoder(cmdBuffer)

## add compute
MetalCore.encode_copy!(blitEncoder, bufferA, bufferB, 0, 0, 128*4)
MetalCore.endEncoding!(blitEncoder)

MetalCore.commit!(cmdBuffer)
MetalCore.waitUntilCompleted(cmdBuffer)
