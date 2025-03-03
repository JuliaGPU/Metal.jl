@testset "MTL" begin

using .MTL

@autoreleasepool begin

@testset "devices" begin

devs = devices()
@test length(devs) > 0

dev = first(devs)
@test dev == devs[1]

if length(devs) > 1
    @test dev != devs[2]
end

compact_str = sprint(io->show(io, dev))
full_str = sprint(io->show(io, MIME"text/plain"(), dev))

@test dev.name isa NSString
@test dev.lowPower isa Bool
@test dev.removable isa Bool
@test dev.hasUnifiedMemory isa Bool
@test dev.registryID isa Integer
@test dev.maxTransferRate isa Integer

@test dev.recommendedMaxWorkingSetSize isa Integer
@test dev.maxThreadgroupMemoryLength isa Integer
@test dev.maxThreadsPerThreadgroup isa MTL.MTLSize
@test dev.argumentBuffersSupport isa MTL.MTLArgumentBuffersTier
@test dev.maxBufferLength isa Integer

@test dev.currentAllocatedSize isa Integer

end

@testset "compile options" begin

opts = MTLCompileOptions()

compact_str = sprint(io->show(io, opts))
full_str = sprint(io->show(io, MIME"text/plain"(), opts))

@test opts.fastMathEnabled isa Bool
val = !opts.fastMathEnabled
opts.fastMathEnabled = val
@test opts.fastMathEnabled == val

@test opts.languageVersion isa VersionNumber
opts.languageVersion = v"1.0"
@test opts.languageVersion == v"1.0"

end

@testset "libraries" begin

dev = first(devices())
opts = MTLCompileOptions()

let lib = MTLLibrary(dev, "", opts)
    @test lib.device == dev
    @test lib.label === nothing
    lib.label = "MyLibrary"
    @test lib.label == "MyLibrary"
    @test isempty(lib.functionNames)
end

metal_code = read(joinpath(@__DIR__, "..", "dummy.metal"), String)
let lib = MTLLibrary(dev, metal_code, opts)
    @test lib.device == dev
    @test lib.label === nothing
    fns = lib.functionNames
    @test length(fns) == 2
    @test "kernel_1" in fns
    @test "kernel_2" in fns
end

binary_path = joinpath(@__DIR__, "..", "dummy.metallib")
let lib = MTLLibraryFromFile(dev, binary_path)
    @test lib.device == dev
    @test lib.label === nothing
    fns = lib.functionNames
    @test length(fns) == 2
    @test "kernel_1" in fns
    @test "kernel_2" in fns
end

binary_code = read(binary_path)
let lib = MTLLibraryFromData(dev, binary_code)
    @test lib.device == dev
    @test lib.label === nothing
    fns = lib.functionNames
    @test length(fns) == 2
    @test "kernel_1" in fns
    @test "kernel_2" in fns

    compact_str = sprint(io->show(io, lib))
    full_str = sprint(io->show(io, MIME"text/plain"(), lib))
end

end

@testset "functions" begin

desc = MTLFunctionDescriptor()

compact_str = sprint(io->show(io, desc))
full_str = sprint(io->show(io, MIME"text/plain"(), desc))

@test desc.name === nothing
desc.name = "MyKernel"
@test desc.name == "MyKernel"

@test desc.specializedName === nothing
desc.specializedName = "MySpecializedKernel"
@test desc.specializedName == "MySpecializedKernel"


dev = first(devices())
lib = MTLLibraryFromFile(dev, joinpath(@__DIR__, "..", "dummy.metallib"))
fun = MTLFunction(lib, "kernel_1")

compact_str = sprint(io->show(io, fun))
full_str = sprint(io->show(io, MIME"text/plain"(), fun))

@test fun.device == dev
@test fun.label === nothing
fun.label = "MyKernel"
@test fun.label == "MyKernel"
@test fun.name == "kernel_1"
@test fun.functionType == MTL.MTLFunctionTypeKernel

end

@testset "events" begin

dev = first(devices())

let ev = MTLEvent(dev)
    @test ev.device == dev
    @test ev.label === nothing
    ev.label = "MyEvent"
    @test ev.label == "MyEvent"
end

let ev = MTLSharedEvent(dev)
    # This returns nothing, which aligns with the description from the Metal SDK headers.
    #     Interestingly, under validation, a device is returned.
    @test ev.device === nothing broken=shader_validation
    @test ev.label === nothing
    ev.label = "MyEvent"
    @test ev.label == "MyEvent"
    @test ev.signaledValue == 0
end

end

@testset "fences" begin

dev = first(devices())

let fen = MTLFence(dev)
    @test fen.device == dev
end

end

@testset "heap" begin

dev = first(devices())

let desc = MTLHeapDescriptor()
    @test desc.type == MTL.MTLHeapTypeAutomatic
    desc.type = MTL.MTLHeapTypePlacement
    @test desc.type == MTL.MTLHeapTypePlacement

    @test desc.size == 0
    desc.size = 1024
    @test desc.size == 1024

    @test desc.storageMode == MTL.MTLStorageModePrivate
    desc.storageMode = MTL.MTLStorageModeShared
    @test desc.storageMode == MTL.MTLStorageModeShared

    @test desc.cpuCacheMode == MTL.MTLCPUCacheModeDefaultCache
    desc.cpuCacheMode = MTL.MTLCPUCacheModeWriteCombined
    @test desc.cpuCacheMode == MTL.MTLCPUCacheModeWriteCombined

    @test desc.hazardTrackingMode == MTL.MTLHazardTrackingModeDefault
    desc.hazardTrackingMode = MTL.MTLHazardTrackingModeUntracked
    @test desc.hazardTrackingMode == MTL.MTLHazardTrackingModeUntracked

    @test desc.resourceOptions == MTL.MTLResourceStorageModeShared |
                                  MTL.MTLResourceCPUCacheModeWriteCombined |
                                  MTL.MTLResourceHazardTrackingModeUntracked
    desc.resourceOptions = MTL.MTLResourceStorageModePrivate |
                           MTL.MTLResourceCPUCacheModeDefaultCache |
                           MTL.MTLResourceHazardTrackingModeDefault
    @test desc.resourceOptions == MTL.MTLResourceStorageModePrivate |
                                  MTL.MTLResourceCPUCacheModeDefaultCache |
                                  MTL.MTLResourceHazardTrackingModeDefault

    # setting resource options should be reflected in individual fields
    @test desc.storageMode == MTL.MTLStorageModePrivate
    @test desc.cpuCacheMode == MTL.MTLCPUCacheModeDefaultCache
    @test desc.hazardTrackingMode == MTL.MTLHazardTrackingModeDefault
end

desc = MTLHeapDescriptor()
desc.size = 0x4000 # TODO: use heapBufferSizeAndAlign
let heap = MTLHeap(dev, desc)
    @test heap.label === nothing
    heap.label = "MyHeap"
    @test heap.label == "MyHeap"

    @test heap.type == desc.type

    @test heap.size == desc.size

    # NOTE: these checks are fragile, as the heap options seems to depend on the requested size

    #=@test=# heap.storageMode == desc.storageMode

    #=@test=# heap.cpuCacheMode == desc.cpuCacheMode

    #=@test=# heap.hazardTrackingMode == desc.hazardTrackingMode

    #=@test=# heap.resourceOptions == desc.resourceOptions
end

end

@testset "buffers" begin

dev = first(devices())

buf = MTLBuffer(dev, 8; storage=SharedStorage)

@test buf.length == 8
@test sizeof(buf) == 8

# MTLResource properties
@test buf.device == dev
@test buf.label === nothing
buf.label = "MyBuffer"
@test buf.label == "MyBuffer"
@test buf.gpuAddress isa Ptr{Cvoid}

@test contents(buf) isa Ptr{Cvoid}
@test convert(Ptr{UInt8}, buf) isa Ptr{UInt8}

free(buf)

end

@testset "command queue" begin

dev = first(devices())

cmdq = MTLCommandQueue(dev)

@test cmdq.device == dev
@test cmdq.label === nothing
cmdq.label = "MyCommandQueue"
@test cmdq.label == "MyCommandQueue"

end

@testset "command buffer" begin

dev = first(devices())
cmdq = MTLCommandQueue(dev)


cmdbuf = MTLCommandBuffer(cmdq)

@test cmdbuf.device == dev
@test cmdbuf.commandQueue == cmdq
@test cmdbuf.label === nothing
cmdbuf.label = "MyCommandBuffer"
@test cmdbuf.label == "MyCommandBuffer"
@test cmdbuf.error === nothing
@test cmdbuf.status == MTL.MTLCommandBufferStatusNotEnqueued
@test cmdbuf.kernelStartTime == 0
@test cmdbuf.kernelEndTime == 0
@test cmdbuf.GPUStartTime == 0
@test cmdbuf.GPUEndTime == 0

let ev = MTLSharedEvent(dev)
    @test ev.signaledValue == 0
    encode_signal!(cmdbuf, ev, 42)
    encode_wait!(cmdbuf, ev, 21)
    commit!(cmdbuf)
    wait_completed(cmdbuf)
    @test ev.signaledValue == 42
end

cmdbuf = MTLCommandBuffer(cmdq)
scheduled = Ref(false)
completed = Ref(false)
on_scheduled(cmdbuf) do buf
    scheduled[] = true
end
on_completed(cmdbuf) do buf
    completed[] = true
end
@test scheduled[] == false
@test completed[] == false
@test cmdbuf.status == MTL.MTLCommandBufferStatusNotEnqueued
enqueue!(cmdbuf)
@test cmdbuf.status == MTL.MTLCommandBufferStatusEnqueued
commit!(cmdbuf)
# XXX: happens too quickly to test for committed status
#@test cmdbuf.status == MTL.MTLCommandBufferStatusCommitted
wait_completed(cmdbuf) == MTL.MTLCommandBufferStatusCompleted
@test cmdbuf.status == MTL.MTLCommandBufferStatusCompleted
retry(; delays=[0, 0.1, 1]) do
    scheduled[] || error("scheduled callback not called")
    completed[] || error("completed callback not called")
end()
@test scheduled[] == true
@test completed[] == true


desc = MTLCommandBufferDescriptor()

@test desc.retainedReferences == true
desc.retainedReferences = false
@test desc.retainedReferences == false

@test desc.errorOptions == MTL.MTLCommandBufferErrorOptionNone
desc.errorOptions = MTL.MTLCommandBufferErrorOptionEncoderExecutionStatus
@test desc.errorOptions == MTL.MTLCommandBufferErrorOptionEncoderExecutionStatus

cmq = MTLCommandQueue(device())
cmdbuf = MTLCommandBuffer(cmq, desc)
if !runtime_validation
    # when the debug layer is activated, Metal seems to retain all resources?
    @test cmdbuf.retainedReferences == false
end
@test cmdbuf.errorOptions == MTL.MTLCommandBufferErrorOptionEncoderExecutionStatus

end

@testset "compute pipeline" begin

dev = first(devices())
lib = MTLLibraryFromFile(dev, joinpath(@__DIR__, "..", "dummy.metallib"))
fun = MTLFunction(lib, "kernel_1")

pipeline = MTLComputePipelineState(dev, fun)

@test pipeline.device == dev
@test pipeline.label === nothing

@test pipeline.maxTotalThreadsPerThreadgroup isa Integer
@test pipeline.threadExecutionWidth isa Integer
@test pipeline.staticThreadgroupMemoryLength == 0


desc = MTLComputePipelineDescriptor()

compact_str = sprint(io->show(io, desc))
full_str = sprint(io->show(io, MIME"text/plain"(), desc))

@test desc.label === nothing
desc.label = "foo"
@test desc.label == "foo"

@test desc.computeFunction === nothing
desc.computeFunction = fun
@test desc.computeFunction == fun

@test desc.threadGroupSizeIsMultipleOfThreadExecutionWidth == false
desc.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
@test desc.threadGroupSizeIsMultipleOfThreadExecutionWidth == true

@test desc.maxTotalThreadsPerThreadgroup isa Integer
# setting this may fail, so use the same value
desc.maxTotalThreadsPerThreadgroup = pipeline.maxTotalThreadsPerThreadgroup

@test desc.maxCallStackDepth == 1
desc.maxCallStackDepth = 2
@test desc.maxCallStackDepth == 2

end

@testset "binary archive" begin

dev = first(devices())
lib = MTLLibraryFromFile(dev, joinpath(@__DIR__, "..", "dummy.metallib"))
fun = MTLFunction(lib, "kernel_1")

desc = MTLBinaryArchiveDescriptor()
bin = MTLBinaryArchive(dev, desc)

compact_str = sprint(io->show(io, desc))
full_str = sprint(io->show(io, MIME"text/plain"(), desc))

@test desc.url === nothing
desc.url = NSFileURL("/tmp/foo")
@test desc.url == NSFileURL("/tmp/foo")

pipeline_desc = MTLComputePipelineDescriptor()
pipeline_desc.computeFunction = fun

add_functions!(bin, pipeline_desc)
mktempdir() do dir
    path = joinpath(dir, "kernel.bin")
    write(path, bin)
    @test isfile(path)
    @test filesize(path) > 0
end

end

@testset "async_copy" begin
    N = 1024
    signal_value = 2

    dev = first(devices())
    A = MtlArray(rand(Float32, N))
    B = MtlArray(rand(Float32, N))
    a = Array{Float32}(undef, N)

    queue1 = Metal.MTLCommandQueue(dev)
    queue2 = Metal.MTLCommandQueue(dev)
    buf1 = Metal.MTLCommandBuffer(queue1)
    buf2 = Metal.MTLCommandBuffer(queue2)
    event = Metal.MTLEvent(dev)


    Metal.encode_wait!(buf2, event, signal_value)
    Metal.commit!(buf2)

    unsafe_copyto!(dev, pointer(a), pointer(B), N, queue=queue1, async=true) # GPU -> CPU
    unsafe_copyto!(dev, pointer(A), pointer(a), N, queue=queue1, async=true) # CPU -> GPU

    Metal.encode_signal!(buf1, event, signal_value)
    Metal.commit!(buf1)


    Metal.wait_completed(buf2)

    @test isapprox(a, Array(A))
    @test isapprox(a, Array(B))
end

# Issue #192
@testset "append_fillbuffer!" begin
    for (T, val) in ((UInt8, 2), (Int8, 2), (Int8, -2))
        arr = Metal.zeros(T, 4)

        buf = Base.unsafe_convert(MTL.MTLBuffer, arr)
        Metal.unsafe_fill!(device(), Metal.MtlPtr{T}(buf, 0), T(val), 4)

        @test all(Array(arr) .== val)
    end
end

# TODO: continue adding tests

end

end
