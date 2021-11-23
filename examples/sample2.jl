using Metal

@show devices()
dev = MtlDevice(1)

vecC=rand(Float32, 128)

bufferSize = 128
bufferA = MtlBuffer(Float32, dev, bufferSize, storage=Shared)
bufferB = MtlBuffer(Float32, dev, bufferSize, storage=Shared)
bufferC = MtlBuffer(Float32, dev, bufferSize, storage=Shared)

vecA = unsafe_wrap(Vector{Float32}, bufferA, (bufferSize,))
vecB = unsafe_wrap(Vector{Float32}, bufferB, (bufferSize,))
vecC = unsafe_wrap(Vector{Float32}, bufferC, (bufferSize,))

using Random
rand!(vecA)

queue = global_queue(dev)

vecB .= 0
cmdBuffer = commit!(queue) do buffer
    MTL.MtlBlitCommandEncoder(buffer) do enc
        MTL.append_copy!(enc, bufferA, 1, bufferC, 1, 128*4)
    end
end

Base.unsafe_copyto!(dev, bufferA, 1, bufferB, 1, 128)

vecD = rand(Float32, 128)
ptrD = pointer(vecD)
Base.unsafe_copyto!(dev, ptrD, bufferB, 0, 128)

###
arr2 = MTL.MtlArray{Float32,1}(undef, (bufferSize,), storage=MTL.MtResourceStorageModeShared)
arrptr = MTL.content(arr2.buffer)
arrvec = unsafe_wrap(Vector{Float32}, arrptr, bufferSize)

Base.unsafe_copyto!(dev, arr2.buffer, 1, bufferB, 1, 128)



MTL.waitUntilCompleted(cmdBuffer)
