using .MTL

# a trivial kernel to exercise the Metal 4 dispatch path without going through the
# Julia compiler
const add1_source = """
#include <metal_stdlib>
using namespace metal;
kernel void add1(device uint* out [[buffer(0)]],
                 device const uint* inp [[buffer(1)]],
                 uint gid [[thread_position_in_grid]]) {
    out[gid] = inp[gid] + 1;
}
"""

@autoreleasepool begin

dev = MTLDevice(1)

@testset "command queue" begin

queue = MTL4CommandQueue(dev)
@test queue isa MTL4CommandQueue
@test queue.device == dev

desc = MTL4CommandQueueDescriptor()
desc.label = "test queue"
@test String(desc.label) == "test queue"
queue2 = MTL4CommandQueue(dev, desc)
@test String(queue2.label) == "test queue"

@test MTL4CommandQueueDescriptor("labelled").label isa NSString

ev = MTLSharedEvent(dev)
MTL.signal_event!(queue, ev, 1)
@test MTL.waitUntilSignaledValue(ev, 1, 5000)
@test ev.signaledValue >= 1
# a queue-level wait on an already-signalled value must not block later work
MTL.wait_event!(queue, ev, 1)

end

@testset "command allocator" begin

alloc = MTL4CommandAllocator(dev)
@test alloc isa MTL4CommandAllocator
@test alloc.device == dev
@test MTL.allocatedSize(alloc) isa Integer
MTL.reset!(alloc)

desc = MTL4CommandAllocatorDescriptor("test allocator")
@test String(desc.label) == "test allocator"
alloc2 = MTL4CommandAllocator(dev, desc)
@test String(alloc2.label) == "test allocator"
@test String(MTL4CommandAllocator(dev, "inline label").label) == "inline label"

end

@testset "command buffer" begin

alloc = MTL4CommandAllocator(dev)
cmdbuf = MTL4CommandBuffer(dev)
@test cmdbuf isa MTL4CommandBuffer
@test cmdbuf.device == dev

cmdbuf.label = "test buffer"
@test String(cmdbuf.label) == "test buffer"

# a Metal 4 command buffer is a reusable encoding cursor: it can be begun, ended and
# begun again without being recreated
MTL.beginCommandBuffer!(cmdbuf, alloc)
MTL.endCommandBuffer!(cmdbuf)
MTL.beginCommandBuffer!(cmdbuf, alloc)
MTL.endCommandBuffer!(cmdbuf)

@test String(MTL4CommandBuffer(dev, "labelled").label) == "labelled"

end

@testset "argument table" begin

desc = MTL4ArgumentTableDescriptor()
desc.maxBufferBindCount = 4
desc.label = "test table"
@test desc.maxBufferBindCount == 4

argtab = MTL4ArgumentTable(dev, desc)
@test argtab isa MTL4ArgumentTable
@test argtab.device == dev

argtab2 = MTL4ArgumentTable(dev; buffers=8, label="kwargs table")
@test String(argtab2.label) == "kwargs table"

buf = MTLBuffer(dev, 64; storage=Metal.SharedStorage)
MTL.set_buffer!(argtab2, buf, 0, 1)
MTL.set_buffer!(argtab2, buf, 16, 2)
MTL.set_address!(argtab2, UInt64(buf.gpuAddress), 3)

end

@testset "compute encoder" begin

pipeline = MTLComputePipelineState(dev, MTLFunction(MTLLibrary(dev, add1_source), "add1"))

N = 16
bufs = [MTLBuffer(dev, N*sizeof(UInt32); storage=Metal.SharedStorage) for _ in 1:3]
A, B, C = bufs
pA = convert(Ptr{UInt32}, MTL.contents(A))
pC = convert(Ptr{UInt32}, MTL.contents(C))
for i in 1:N
    unsafe_store!(pA, UInt32(i), i)
    unsafe_store!(pC, UInt32(0), i)
end

rdesc = MTLResidencySetDescriptor()
rdesc.initialCapacity = 3
resset = MTLResidencySet(dev, rdesc)
foreach(b -> MTL.add_allocation!(resset, b), bufs)
MTL.commit!(resset)

queue = MTL4CommandQueue(dev)
alloc = MTL4CommandAllocator(dev)
cmdbuf = MTL4CommandBuffer(dev)
argtab = MTL4ArgumentTable(dev; buffers=4)

MTL.beginCommandBuffer!(cmdbuf, alloc)
MTL.use_residency_set!(cmdbuf, resset)
enc = MTL4ComputeCommandEncoder(cmdbuf)
@test enc isa MTL4ComputeCommandEncoder
@test MTL.stages(enc) isa MTL.MTLStages

MTL.set_function!(enc, pipeline)
MTL.set_argument_table!(enc, argtab)

# B = A + 1
MTL.set_buffer!(argtab, B, 0, 1)
MTL.set_buffer!(argtab, A, 0, 2)
MTL.dispatchThreads!(enc, MTLSize(N,1,1), MTLSize(N,1,1))

# commands in a Metal 4 encoder run concurrently unless a barrier separates them
MTL.barrierAfterEncoderStages!(enc)

# C = B + 1, rebinding the *same* argument table: bindings are captured per dispatch
MTL.set_buffer!(argtab, C, 0, 1)
MTL.set_buffer!(argtab, B, 0, 2)
MTL.dispatchThreads!(enc, MTLSize(N,1,1), MTLSize(N,1,1))

close(enc)
MTL.endCommandBuffer!(cmdbuf)

feedback = Ref{Any}(nothing)
done = Threads.Atomic{Bool}(false)
options = MTL4CommitOptions() do fb
    feedback[] = (fb.GPUStartTime, fb.GPUEndTime, fb.error)
    done[] = true
    return
end
MTL.commit!(queue, cmdbuf, options)

ev = MTLSharedEvent(dev)
MTL.signal_event!(queue, ev, 1)
@test MTL.waitUntilSignaledValue(ev, 1, 10_000)

@test [unsafe_load(pC, i) for i in 1:N] == UInt32[i+2 for i in 1:N]

t0 = time()
while !done[] && time() - t0 < 5
    sleep(0.01)
end
@test done[]
start, stop, err = feedback[]
@test err === nothing
@test stop >= start

# the allocator can only be reset once the GPU is done with the commands it holds
MTL.reset!(alloc)

end

@testset "copy and fill" begin

N = 64
src = MTLBuffer(dev, N; storage=Metal.SharedStorage)
dst = MTLBuffer(dev, N; storage=Metal.SharedStorage)
psrc = convert(Ptr{UInt8}, MTL.contents(src))
pdst = convert(Ptr{UInt8}, MTL.contents(dst))
for i in 1:N
    unsafe_store!(psrc, UInt8(i), i)
    unsafe_store!(pdst, UInt8(0), i)
end

rdesc = MTLResidencySetDescriptor()
resset = MTLResidencySet(dev, rdesc)
MTL.add_allocation!(resset, src)
MTL.add_allocation!(resset, dst)
MTL.commit!(resset)

queue = MTL4CommandQueue(dev)
alloc = MTL4CommandAllocator(dev)
cmdbuf = MTL4CommandBuffer(dev)

MTL.beginCommandBuffer!(cmdbuf, alloc)
MTL.use_residency_set!(cmdbuf, resset)
MTL4ComputeCommandEncoder(cmdbuf) do enc
    MTL.append_copy!(enc, dst, 0, src, 0, 32)
    MTL.barrierAfterEncoderStages!(enc)
    MTL.append_fillbuffer!(enc, dst, UInt8(0xff), 32, 32)
end
MTL.endCommandBuffer!(cmdbuf)
MTL.commit!(queue, cmdbuf)

ev = MTLSharedEvent(dev)
MTL.signal_event!(queue, ev, 1)
@test MTL.waitUntilSignaledValue(ev, 1, 10_000)

@test [unsafe_load(pdst, i) for i in 1:32] == UInt8[i for i in 1:32]
@test all([unsafe_load(pdst, i) for i in 33:64] .== 0xff)

end

@testset "capture scope" begin

queue = MTL4CommandQueue(dev)
scope = MTLCaptureScope(queue)
@test scope isa MTLCaptureScope
@test scope.mtl4CommandQueue == queue

end

end
