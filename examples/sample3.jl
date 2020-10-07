using MetalCore

@show devices()
dev = MtlDevice(1)


bufferSize = 128
bufferA = MtlArray{Float32,1}(undef, tuple(bufferSize), storage=Shared)
bufferB = MtlArray{Float32,1}(undef, tuple(bufferSize), storage=Shared)
bufferC = MtlArray{Float32,1}(undef, tuple(bufferSize), storage=Shared)

vecA = unsafe_wrap(Vector{Float32}, bufferA.buffer, tuple(bufferSize))
vecB = unsafe_wrap(Vector{Float32}, bufferB.buffer, tuple(bufferSize))
vecC = unsafe_wrap(Vector{Float32}, bufferC.buffer, tuple(bufferSize))

using Random
rand!.([vecA, vecB])
vecC .= 0.0

## Setup
src = read(dirname(pathof(MetalCore))*"/Metal/kernels/vadd.metal", String)
opts = MtlCompileOptions()
lib = MtlLibrary(dev, src, opts)

fun = MtlFunction(lib, "add_vectors")
pip_addfun = MtlComputePipelineState(dev, fun)
queue = global_queue(dev) #MtlCommandQueue(dev)

##
argbufenc = MtlArgumentEncoder(fun, 1)
argbuf1 = alloc(Cchar, dev, sizeof(argbufenc), storage=Shared)
MetalCore.Metal.assign_argument_buffer!(argbufenc, argbuf1, 1)
MetalCore.Metal.set_field!(argbufenc, 128, 1)
set_buffer!(argbufenc, bufferA.buffer, 0, 2)
content1 = (128, Base.unsafe_load(Base.convert(Ptr{Int}, Metal.content(argbuf1)),2))

argbufenc = MtlArgumentEncoder(fun, 2)
argbuf2 = alloc(Cchar, dev, sizeof(argbufenc), storage=Shared)
MetalCore.Metal.assign_argument_buffer!(argbufenc, argbuf2, 1)
MetalCore.Metal.set_field!(argbufenc, 128, 1)
set_buffer!(argbufenc, bufferB.buffer, 0, 2)
content2 = (128, Base.unsafe_load(Base.convert(Ptr{Int}, Metal.content(argbuf2)),2))

argbufenc = MtlArgumentEncoder(fun, 3)
argbuf3 = alloc(Cchar, dev, sizeof(argbufenc), storage=Shared)
MetalCore.Metal.assign_argument_buffer!(argbufenc, argbuf3, 1)
MetalCore.Metal.set_field!(argbufenc, 128, 1)
set_buffer!(argbufenc, bufferC.buffer, 0, 2)
content3 = (128, Base.unsafe_load(Base.convert(Ptr{Int}, Metal.content(argbuf3)),2))

rc1 = Base.RefValue(content1)
rc2 = Base.RefValue(content2)
rc3 = Base.RefValue(content3)
pt1 = Base.unsafe_convert(Ptr{typeof(content1)}, rc1)
pt2 = Base.unsafe_convert(Ptr{typeof(content1)}, rc2)
pt3 = Base.unsafe_convert(Ptr{typeof(content1)}, rc3)

cmd = MetalCore.commit!(queue) do cmdbuf
    MtlComputeCommandEncoder(cmdbuf) do enc
        MetalCore.Metal.use!(enc, bufferA.buffer, MetalCore.ReadWriteUsage)
        MetalCore.Metal.use!(enc, bufferB.buffer, MetalCore.ReadWriteUsage)
        MetalCore.Metal.use!(enc, bufferC.buffer, MetalCore.ReadWriteUsage)
        #MetalCore.set_buffers!(enc,
        #                        [argbuf1, argbuf2, argbuf3],
        #                        [0,0,0], 1:3)
        MetalCore.Metal.set_bytes!(enc, pt1, 16, 1)
        MetalCore.Metal.set_bytes!(enc, pt2, 16, 2)
        MetalCore.Metal.set_bytes!(enc, pt3, 16, 3)
        gridSize = MtSize(length(vecA), 1, 1)
        MetalCore.Metal.set_function!(enc, pip_addfun)
        threadGroupSize = min(length(vecA), pip_addfun.maxTotalThreadsPerThreadgroup)
        threadGroupSize = MetalCore.MtSize(threadGroupSize, 1, 1)
        MetalCore.append_current_function!(enc, gridSize, threadGroupSize)
    end
end

####

# Execute
wait(cmd)

@show vecC
