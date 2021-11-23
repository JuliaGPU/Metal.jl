using Metal

@show devices()
dev = MtlDevice(1)


#lib = MTL.LibraryWithFile(d, "default.metallib")
src = read(dirname(pathof(Metal))*"/Metal/kernels/add.metal", String)

bufferSize = 128
bufferA = MtlArray{Float32,1}(undef, tuple(bufferSize), storage=Shared)
bufferB = MtlArray{Float32,1}(undef, tuple(bufferSize), storage=Shared)
bufferC = MtlArray{Float32,1}(undef, tuple(bufferSize), storage=Shared)

vecA = unsafe_wrap(Vector{Float32}, bufferA.buffer, tuple(bufferSize))
vecB = unsafe_wrap(Vector{Float32}, bufferB.buffer, tuple(bufferSize))
vecC = unsafe_wrap(Vector{Float32}, bufferC.buffer, tuple(bufferSize))

using Random
rand!.([vecA, vecB])

## Setup
opts = MtlCompileOptions()
lib = MtlLibrary(dev, src, opts)

fun = MtlFunction(lib, "add_arrays")
pip_addfun = MtlComputePipelineState(dev, fun)
queue = global_queue(dev) #MtlCommandQueue(dev)

##
vecA .= 0.0; vecB .= 0.0; vecC .= 0.0;
cmd = MTL.commit!(queue) do cmdbuf
    MtlComputeCommandEncoder(cmdbuf) do enc
        MTL.set_function!(enc, pip_addfun)
        MTL.set_buffer!(enc, bufferA.buffer, 0, 1)
        MTL.set_buffer!(enc, bufferB.buffer, 0, 2)
        MTL.set_buffer!(enc, bufferC.buffer, 0, 3)
        #MTL.set_buffers!(enc,
        #                        [bufferA.buffer, bufferB.buffer, bufferC.buffer],
        #                        [0,0,0], 1:3)
        gridSize = MtSize(length(vecA), 1, 1)
        threadGroupSize = min(length(vecA), pip_addfun.maxTotalThreadsPerThreadgroup)
        threadGroupSize = MTL.MtSize(threadGroupSize, 1, 1)
        @info threadGroupSize
        MTL.append_current_function!(enc, gridSize, threadGroupSize)
    end
end

# Execute
wait(cmd)

@show vecC
