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
