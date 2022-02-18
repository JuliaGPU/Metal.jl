using Metal

dev = MtlDevice(1)

src = read(dirname(pathof(Metal))*"/../lib/core/kernels/vadd.metal", String)

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

fun = MtlFunction(lib, "add_vectors")

pip_addfun = MtlComputePipelineState(dev, fun)
queue = global_queue(dev) #MtlCommandQueue(dev)

args = Metal.mtlconvert.((bufferA, bufferB, bufferC))

cmd = MTL.commit!(queue) do cmdbuf
    MtlComputeCommandEncoder(cmdbuf) do enc
        MTL.set_function!(enc, pip_addfun)

        Metal.encode_arguments!(enc, fun, args...)

        gridSize = MtSize(length(vecA), 1, 1)
        threadGroupSize = min(length(vecA), pip_addfun.maxTotalThreadsPerThreadgroup)
        threadGroupSize = MTL.MtSize(threadGroupSize, 1, 1)
        MTL.append_current_function!(enc, gridSize, threadGroupSize)
    end
end

####

# Execute
wait(cmd)

@show vecC
