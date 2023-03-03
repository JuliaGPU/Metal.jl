@testset "profiling" begin
mktempdir() do tmpdir

# Verify Metal capture is enabled via environment variable
@test haskey(ENV, "METAL_CAPTURE_ENABLED")
@test ENV["METAL_CAPTURE_ENABLED"]=="1"

function tester(A)
    idx = thread_position_in_grid_1d()
    A[idx] = Int(5)
    return nothing
end

# Capture Manager
manager = MtlCaptureManager()
@test manager.supportsTraceXcode isa Bool
@test manager.supportsTraceFile  isa Bool
@test manager.isCapturing isa Bool

# Capture Descriptor
desc = MtlCaptureDescriptor()
# Capture Object
@test desc.captureObject == nothing
cmdq = global_queue(current_device())
desc.captureObject = cmdq
@test desc.captureObject == cmdq.handle
dev = current_device()
desc.captureObject = dev
@test desc.captureObject == dev.handle

# Capture Destination
@test desc.destination == MTL.MtCaptureDestinationDeveloperTools
desc.destination = MTL.MtCaptureDestinationGPUTraceDocument
@test desc.destination == MTL.MtCaptureDestinationGPUTraceDocument

# Output URL
@test desc.outputFolder == nothing
path = joinpath(tmpdir, "test.gputrace")
desc.outputFolder = path
@test desc.outputFolder == path

# Capture Scope
queue = MtlCommandQueue(current_device())
default_scope = manager.defaultCaptureScope
@test default_scope == nothing
new_scope = MtlCaptureScope(Metal.MTL.mtNewCaptureScopeWithCommandQueue(manager, queue))
@test new_scope.commandQueue == queue
@test new_scope.device == current_device()
@test new_scope.label == nothing
new_label = "Metal.jl profiling test"
new_scope.label = new_label
@test new_scope.label == new_label

# Assign new scope
manager.defaultCaptureScope = new_scope
@test manager.defaultCaptureScope == new_scope

# Capturing
bufferA = MtlArray{Float32,1}(undef, tuple(4), storage=Shared)

@test !isdir(path)
@test manager.isCapturing == false
startCapture(manager, desc)
@test manager.isCapturing
@test_throws ErrorException startCapture(manager, desc)
@metal threads=4 tester(bufferA)
stopCapture(manager)
@test manager.isCapturing == false
@test isdir(path)

# Profile Macro
cd(path) do
    Metal.@profile @metal threads=4 tester(bufferA)
    @test isdir("julia_capture_1.gputrace")
    Metal.@profile capture=current_device() @metal threads=4 tester(bufferA)
    @test isdir("julia_capture_2.gputrace")
    @test_throws ArgumentError Metal.@profile @metal threads=4 tester(bufferA)
end

end
end
