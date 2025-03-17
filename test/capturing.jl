using .MTL

if shader_validation
    @warn "Skipping capturing tests; capturing is not supported with Metal Shader Validation enabled"
else

@testset "capturing" begin

mktempdir() do tmpdir
cd(tmpdir) do

# Verify Metal capture is enabled via environment variable
@test haskey(ENV, "METAL_CAPTURE_ENABLED")
@test ENV["METAL_CAPTURE_ENABLED"]=="1"

function tester(A)
    idx = thread_position_in_grid_1d()
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

# Output URL
@test desc.outputURL === nothing
path = joinpath(tmpdir, "test.gputrace")
desc.outputURL = NSFileURL(path)
@test desc.outputURL == NSFileURL(path)

# Capture Scope
queue = MTLCommandQueue(device())
default_scope = manager.defaultCaptureScope
@test default_scope === nothing
new_scope = MTLCaptureScope(@objc [manager::id{MTLCaptureManager} newCaptureScopeWithCommandQueue:queue::id{MTLCommandQueue}]::id{MTLCaptureScope})
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
@test_throws ErrorException startCapture(manager, desc)
Metal.@sync @metal threads=4 tester(bufferA)
stopCapture(manager)
@test manager.isCapturing == false
@test isdir(path)
release(new_scope)

# Profile Macro
@testset "macro" begin
    Metal.@capture @metal threads=4 tester(bufferA)
    @test isdir("julia_1.gputrace")
    Metal.@capture object=device() @metal threads=4 tester(bufferA)
    @test isdir("julia_2.gputrace")
end

end # cd(tmpdir) do
end # mktempdir() do tmpdir

end # @testset "capturing" begin
end # if shader_validation (else branch)
