using .MPS: MPSShape
using .MPSGraphs: MPSGraph, MPSGraphDevice, MPSGraphShapedType

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
    f() = MPSGraphs.accumulate!(+, similar(A), A; dims=2)
    # with the Metal 4 command API, collected buffers are only released on the next
    # allocation or device synchronization
    allocated() = (GC.gc(true); device_synchronize(); Int(dev.currentAllocatedSize))
    # MPSGraph grows internal pools for the first few hundred runs
    foreach(_ -> f(), 1:200)
    before = allocated()
    foreach(_ -> f(), 1:100)
    @test allocated() - before < 25 * sizeof(A)
end
