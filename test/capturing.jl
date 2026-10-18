using .MTL

if shader_validation
    @warn "Skipping capturing tests; capturing is not supported with Metal Shader Validation enabled"
else

# Verify Metal capture is enabled via environment variable
@test capturing

mktempdir() do tmpdir
cd(tmpdir) do

function tester(A)
    idx = thread_position_in_grid().x
    A[idx] = Int(5)
    return nothing
end

# Capture Manager
manager = MTLCaptureManager()
@test manager.isCapturing isa Bool

# Capture Descriptor
desc = MTLCaptureDescriptor()
# Capture Object
@test desc.captureObject === nothing
cmdq = global_queue(device())
desc.captureObject = cmdq
@test desc.captureObject == cmdq
dev = device()
desc.captureObject = dev
@test desc.captureObject == dev

# Capture Destination
@test desc.destination == MTL.MTLCaptureDestinationDeveloperTools
desc.destination = MTL.MTLCaptureDestinationGPUTraceDocument
@test desc.destination == MTL.MTLCaptureDestinationGPUTraceDocument

# Capture Manager supports destination
@test !supports_destination(manager, MTL.MTLCaptureDestinationDeveloperTools)
@test supports_destination(manager, MTL.MTLCaptureDestinationGPUTraceDocument)

# Output URL
@test desc.outputURL === nothing
path = joinpath(tmpdir, "test.gputrace")
desc.outputURL = NSFileURL(path)
@test desc.outputURL == NSFileURL(path)

# Capture Scope
queue = MTLCommandQueue(device())
default_scope = manager.defaultCaptureScope
@test default_scope === nothing
new_scope = MTLCaptureScope(queue, manager)
@test new_scope.commandQueue == queue
@test new_scope.device == device()
@test new_scope.label === nothing
new_label = "Metal.jl capturing test"
new_scope.label = new_label
@test new_scope.label == new_label

# Assign new scope
manager.defaultCaptureScope = new_scope
@test manager.defaultCaptureScope == new_scope

# Capturing
bufferA = MtlArray{Float32,1,SharedStorage}(undef, tuple(4))

@test !isdir(path)
@test manager.isCapturing == false
startCapture(manager, desc)
@test manager.isCapturing
@test_throws "Capture manager is already capturing." startCapture(manager, desc)
Metal.@sync @metal threads=4 tester(bufferA)
stopCapture(manager)
@test manager.isCapturing == false
@test isdir(path)

# frame capture being enabled turns on resource labels and debug groups
@testset "labels" begin
    @test Metal.label_resources()
    @test String(bufferA.data[].buffer.label) == "MtlArray{Float32,1,Metal.SharedStorage}(dims=(4,))"
end

# ... and embeds the sources of kernels in their libraries
@test Metal.embed_sources()
# (a kernel whose sources can't be embedded still loads)
let art = Metal.compile_to_metallib(Metal.GPUCompiler.CompilerJob(
        Metal.methodinstance(typeof(tester), Tuple{MtlDeviceVector{Float32,1}}),
        Metal.compiler_config(device())))
    pipeline = @test_logs (:error, r"Failed to embed") Metal.link_pipeline(
        device(), UInt8[], art.metallib, art.entry)
    @test pipeline isa MTLComputePipelineState
end

# Profile Macro
@testset "macro" begin
    # traces are named after the captured kernel
    path = Metal.@capture @metal threads=4 tester(bufferA)
    @test path == joinpath(pwd(), "tester_1.gputrace")
    @test isdir(path)
    Metal.@capture object=device() @metal threads=4 tester(bufferA)
    @test isdir("tester_2.gputrace")
    custom = "custom"
    path = Metal.@capture name=custom Metal.@sync @metal threads=4 tester(bufferA)
    @test path == joinpath(pwd(), "custom_1.gputrace")
    @test isdir(path)
end

end # cd(tmpdir) do
end # mktempdir() do tmpdir

end # if shader_validation (else branch)
