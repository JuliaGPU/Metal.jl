using MetalCore

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
rand!(vecC)

queue = global_queue(dev)
cmdbuf = MtlCommandBuffer(queue)

async_send(data::Ptr{Cvoid}, info::Ptr{Cvoid}) = ccall(:uv_async_send, Cint, (Ptr{Cvoid},), data, )
begin
    cbfun = Base.AsyncCondition() do x
        println("hey")
        println(typeof(x))
        println(x)
        println(typeof(y))
        println(y)
    end
    callback = @cfunction(async_send, Cint, (Ptr{Cvoid}, Ptr{Cvoid}, ))
    #cuLaunchHostFunc(stream, callback, cond)
    Metal.mtCommandBufferOnComplete(cmdbuf, cbfun, callback)
end



MetalCore.Metal.MtlBlitCommandEncoder(cmdbuf) do enc
    MetalCore.Metal.append_copy!(enc, bufferA, 1, bufferC, 1, 128*4)
end

Metal.commit!(cmdbuf)

wait(cmdbuf)


###
arr2 = MetalCore.MtlArray{Float32,1}(undef, (bufferSize,), storage=MetalCore.Metal.MtResourceStorageModeShared)
arrptr = MetalCore.Metal.content(arr2.buffer)
arrvec = unsafe_wrap(Vector{Float32}, arrptr, bufferSize)

Base.unsafe_copyto!(dev, arr2.buffer, 1, bufferB, 1, 128)





# buffer

## add compute


mycfun(asd) = (println("info"); return nothing);#return println("hello", asd)
cf = @cfunction(mycfun, Cvoid, (MetalCore.Metal.MTLCommandBuffer, ))

# This fails for some reason... should investigate
#MetalCore.Metal.mtCommandBufferAddCompletedHandler(cmdBuffer, cf)
