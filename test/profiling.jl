@testset "profiling" begin
mktempdir() do tmpdir

# Verify Metal capture is enabled via environment variable
@test haskey(ENV, "MTL_CAPTURE_ENABLED")
@test ENV["MTL_CAPTURE_ENABLED"]=="1"

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
@test desc.captureObject == nothing
cmdq = global_queue(current_device())
desc.captureObject = cmdq
@test desc.captureObject == cmdq
dev = current_device()
desc.captureObject = dev
@test desc.captureObject == dev

# Capture Destination
@test desc.destination == MTL.MTLCaptureDestinationDeveloperTools
desc.destination = MTL.MTLCaptureDestinationGPUTraceDocument
@test desc.destination == MTL.MTLCaptureDestinationGPUTraceDocument

# Output URL
@test desc.outputURL == nothing
path = joinpath(tmpdir, "test.gputrace")
desc.outputURL = NSFileURL(path)
@test desc.outputURL == NSFileURL(path)

# Capture Scope
queue = MTLCommandQueue(current_device())
default_scope = manager.defaultCaptureScope
@test default_scope == nothing
new_scope = MTLCaptureScope(@objc [manager::id{MTLCaptureManager} newCaptureScopeWithCommandQueue:queue::id{MTLCommandQueue}]::id{MTLCaptureScope})
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
bufferA = MtlArray{Float32,1,Shared}(undef, tuple(4))

@test !isdir(path)
@test manager.isCapturing == false
startCapture(manager, desc)
@test manager.isCapturing
@test_throws ErrorException startCapture(manager, desc)
@metal threads=4 tester(bufferA)
stopCapture(manager)
@test manager.isCapturing == false
@test isdir(path)
release(new_scope)

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
