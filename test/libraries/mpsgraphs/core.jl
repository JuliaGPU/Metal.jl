using .MPS: MPSShape
using .MPSGraphs: MPSGraph, MPSGraphDevice, MPSGraphShapedType, MPSGraphExecutable,
                  MPSGraphExecutableSerializationDescriptor, placeholderTensor,
                  matrixMultiplicationWithPrimaryTensor, MPSGraphTensor, MPSGraphTensorData

graph = MPSGraph()
@test graph isa MPSGraph

dev = device()
graphdev = MPSGraphDevice(dev)
@test graphdev isa MPSGraphDevice
@test graphdev.type == MPSGraphs.MPSGraphDeviceTypeMetal
@test graphdev.metalDevice == dev

mpsh = convert(MPS.MPSShape, (2,3,4))
shtyp = MPSGraphShapedType(mpsh, Float32)
@test shtyp.shape == convert(MPS.MPSShape,(2,3,4))
@test shtyp.dataType == MPS.MPSDataTypeFloat32

@testset "cached graphs release their arrays" begin
    # MPSGraphExecutable keeps every output buffer it is encoded with alive
    A = MtlArray(rand(Float32, 1024, 1024))
    # the device's allocated size does not reliably drop when buffers are freed, but can
    # stay at the peak of what was alive at once. outputs are only released when the GC
    # finalizes them (and the objects MPS wraps them in), so collect after every few runs
    # to bound that peak; otherwise a late GC during the measured runs looks like a leak.
    # with the Metal 4 command API, collected buffers are only released on the next
    # allocation or device synchronization.
    allocated() = (GC.gc(true); device_synchronize(); Int(dev.currentAllocatedSize))
    batches(n) = foreach(1:n) do _
        foreach(_ -> MPSGraphs.accumulate!(+, similar(A), A; dims=2), 1:10)
        allocated()
    end
    # also lets MPSGraph grow its internal pools
    batches(10)
    before = allocated()
    batches(10)
    @test allocated() - before < 25 * sizeof(A)
end

@testset "command buffers committed while encoding" begin
    # MPSGraph commits the command buffer it encodes into and continues with a new one by
    # itself when encoding large graphs (on an M1 with macOS 27, for the products we tried
    # with 2^25 output elements or more). that command buffer needs to be recorded for its
    # errors to be reported.
    A = MtlArray(rand(Float32, 4096, 1))
    B = MtlArray(rand(Float32, 1, 8192))
    C = MtlArray{Float32}(undef, 4096, 8192)
    graph = MPSGraph()
    a = placeholderTensor(graph, size(A), Float32)
    b = placeholderTensor(graph, size(B), Float32)
    c = matrixMultiplicationWithPrimaryTensor(graph, b, a)
    feeds = Dict{MPSGraphTensor,MPSGraphTensorData}(a => MPSGraphTensorData(A),
                                                    b => MPSGraphTensorData(B))
    results = Dict{MPSGraphTensor,MPSGraphTensorData}(c => MPSGraphTensorData(C))

    queue = MTL.MTLCommandQueue(dev)
    cmdbuf = MPS.MPSCommandBuffer(queue)
    submitted = cmdbuf.commandBuffer
    MPS.encode!(cmdbuf, graph, NSDictionary(feeds), NSDictionary(results), nil,
                MPSGraphs.default_exec_desc())
    if cmdbuf.commandBuffer != submitted
        @test MTL.last_committed(queue) == submitted
        @test MTL.pending_submission_count(queue) == 1
    else
        @test_skip MTL.last_committed(queue) == submitted
    end
    MTL.commit!(cmdbuf)
    synchronize(queue)
    @test Array(C[1:4, 1:4]) ≈ Array(A)[1:4, :] * Array(B)[:, 1:4]
end

@testset "executable serialization descriptor" begin
    desc = MPSGraphExecutableSerializationDescriptor()
    @test desc isa MPSGraphExecutableSerializationDescriptor
    @test !desc.append
    @test desc.deploymentPlatform == MPSGraphs.MPSGraphDeploymentPlatformMacOS
    # not set on a descriptor that was allocated, but never initialized
    @test desc.minimumDeploymentTarget isa NSString

    desc.append = true
    @test desc.append
    desc.deploymentPlatform = MPSGraphs.MPSGraphDeploymentPlatformIOS
    @test desc.deploymentPlatform == MPSGraphs.MPSGraphDeploymentPlatformIOS
    desc.minimumDeploymentTarget = NSString("17.0")
    @test string(desc.minimumDeploymentTarget) == "17.0"
end

@testset "executable serialization" begin
    graph = MPSGraph()
    a = placeholderTensor(graph, (4, 4), Float32)
    c = matrixMultiplicationWithPrimaryTensor(graph, a, a)
    feeds = NSDictionary(Dict(a => MPSGraphShapedType((4, 4), Float32)))
    exe = MPSGraphs.compile(graph, dev, feeds, NSArray([c]))
    @test exe isa MPSGraphExecutable

    mktempdir() do dir
        @testset "$name" for (name, target) in (("path", identity), ("URL", NSFileURL))
            path = joinpath(dir, "default-$name.mpsgraphpackage")
            MPSGraphs.serialize(exe, target(path))
            @test isdir(path) && !isempty(readdir(path))

            path = joinpath(dir, "descriptor-$name.mpsgraphpackage")
            MPSGraphs.serialize(exe, target(path), MPSGraphExecutableSerializationDescriptor())
            @test isdir(path) && !isempty(readdir(path))
        end
    end
end
