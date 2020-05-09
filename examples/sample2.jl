using MetalCore

@show devices()
dev = MtlDevice(1)

vecC=rand(Float32, 128)

bufferSize = 128
bufferA = MtlBuffer(dev, Float32, bufferSize, MetalCore.Metal.MtResourceStorageModeShared)
bufferB = MtlBuffer(dev, Float32, bufferSize, MetalCore.Metal.MtResourceStorageModeShared)
bufferC = MtlBuffer(dev, vecC, MetalCore.Metal.MtResourceStorageModeShared)

ptrA = convert(Ptr{Float32}, contents(bufferA))
ptrB = convert(Ptr{Float32}, contents(bufferB))

vecA = unsafe_wrap(Vector{Float32}, ptrA, bufferSize)
vecB = unsafe_wrap(Vector{Float32}, ptrB, bufferSize)

using Random
rand!(vecA)

queue = MetalCore.global_queue(dev)

vecB .= 0
MetalCore.Metal.commit!(queue) do buffer
    MetalCore.Metal.MtlBlitCommandEncoder(buffer) do enc
        MetalCore.Metal.append_copy!(enc, bufferA, bufferC, 0, 0, 128*4)
    end
end

MetalCore.Metal.waitUntilCompleted(cmdBuffer)


# buffer

## add compute


#mycfun(asd) = (tuple(1,4); return nothing);#return println("hello", asd)
#cf = @cfunction(mycfun, Cvoid, (MetalCore.MTLCommandBuffer, ))

#MetalCore.mtCommandBufferAddCompletedHandler(cmdBuffer, cf)
