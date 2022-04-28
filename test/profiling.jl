using Metal
using Test

function tester(A)
    idx = thread_position_in_grid_1d()
    A[idx] = Int(5)
    return nothing
end

# Manager objects
manager = MtlCaptureManager()
@test manager.supportsTraceXcode == false
@test manager.supportsTraceFile  == true

# Descriptors
desc = MtlCaptureDescriptor()

# Capture Object
@test desc.captureObject == nothing
cmdq = global_queue(device())
desc.captureObject = cmdq
@test desc.captureObject == cmdq.handle

dev = device()
desc.captureObject = dev
@test desc.captureObject == dev.handle

# Destination
@test desc.destination == MTL.MtCaptureDestinationDeveloperTools
desc.destination = MTL.MtCaptureDestinationGPUTraceDocument
@test desc.destination == MTL.MtCaptureDestinationGPUTraceDocument

# Output URL
@test desc.outputFolder == nothing
path = tempname()*"/jl_metal.gputrace"
println(path)
desc.outputFolder = path
desc.outputFolder == path

bufferA = MtlArray{Float32,1}(undef, tuple(4), storage=Shared)

@test manager.isCapturing == false
startCapture(manager, desc)
@test manager.isCapturing
@test_throws ErrorException startCapture(manager, desc)

@metal threads=4 tester(bufferA.buffer)

stopCapture(manager)
@test manager.isCapturing == false

# macro
Metal.@profile @metal threads=4 tester(bufferA.buffer)
Metal.@profile capture=device() @metal threads=4 tester(bufferA.buffer)

@test_throws MtlError Metal.@profile dest=MTL.MtCaptureDestinationDeveloperTools @metal threads=4 tester(bufferA.buffer)
@test_throws ArgumentError Metal.@profile dir=path @metal threads=4 tester(bufferA.buffer)
