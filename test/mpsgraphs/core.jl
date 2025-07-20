if MPS.is_supported(device())

using .MPS: MPSShape
using .MPSGraphs: MPSGraph, MPSGraphDevice, MPSGraphShapedType
@testset "Core" begin

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

end # @testset "Core"

end # MPS.is_supported(device())
