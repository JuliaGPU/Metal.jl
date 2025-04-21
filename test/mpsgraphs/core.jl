if MPS.is_supported(device())

using .MPS: MPSShape
using .MPSGraphs: MPSGraph, MPSGraphDevice
@testset "Core" begin

graph = MPSGraph()
@test graph isa MPSGraph

dev = device()
graphdev = MPSGraphDevice(dev)
@test graphdev isa MPSGraphDevice
@test graphdev.type == MPSGraphs.MPSGraphDeviceTypeMetal
@test graphdev.metalDevice == dev

end # @testset "Core"

end # MPS.is_supported(device())
