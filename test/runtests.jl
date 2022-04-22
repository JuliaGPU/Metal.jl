using Test
using Random
using Metal

@testset "MTL" begin

@testset "devices" begin

devs = devices()
@test length(devs) > 0

dev = first(devs)
@test dev == devs[1]

if length(devs) > 1
    @test dev != devs[2]
end

compact_str = sprint(io->show(io, dev))
full_str = sprint(io->show(io, MIME"text/plain"(), dev))

@test dev.name isa String
@test dev.isLowPower isa Bool
@test dev.isRemovable isa Bool
@test dev.hasUnifiedMemory isa Bool
@test dev.registryID isa Integer
@test dev.maxTransferRate isa Integer

@test dev.recommendedMaxWorkingSetSize isa Integer
@test dev.maxThreadgroupMemoryLength isa Integer
@test dev.maxThreadsPerThreadgroup isa MTL.MtSize
@test dev.maxBufferLength isa Integer

@test dev.currentAllocatedSize isa Integer

end

@testset "compile options" begin

opts = MtlCompileOptions()

compact_str = sprint(io->show(io, opts))
full_str = sprint(io->show(io, MIME"text/plain"(), opts))

@test opts.fastMathEnabled isa Bool
val = !opts.fastMathEnabled
opts.fastMathEnabled = val
@test opts.fastMathEnabled == val

@test opts.languageVersion isa VersionNumber
opts.languageVersion = v"1.0"
@test opts.languageVersion == v"1.0"

end

@testset "libraries" begin

dev = first(devices())
opts = MtlCompileOptions()

let lib = MtlLibrary(dev, "", opts)
    @test lib.device == dev
    @test lib.label == nothing
    @test isempty(lib.functionNames)
end

metal_code = read(joinpath(@__DIR__, "dummy.metal"), String)
let lib = MtlLibrary(dev, metal_code, opts)
    @test lib.device == dev
    @test lib.label == nothing
    fns = lib.functionNames
    @test length(fns) == 2
    @test "kernel_1" in fns
    @test "kernel_2" in fns
end

binary_path = joinpath(@__DIR__, "dummy.metallib")
let lib = MtlLibraryFromFile(dev, binary_path)
    @test lib.device == dev
    @test lib.label == nothing
    fns = lib.functionNames
    @test length(fns) == 2
    @test "kernel_1" in fns
    @test "kernel_2" in fns
end

binary_code = read(binary_path)
let lib = MtlLibraryFromData(dev, binary_code)
    @test lib.device == dev
    @test lib.label == nothing
    fns = lib.functionNames
    @test length(fns) == 2
    @test "kernel_1" in fns
    @test "kernel_2" in fns

    compact_str = sprint(io->show(io, lib))
    full_str = sprint(io->show(io, MIME"text/plain"(), lib))
end

end

@testset "functions" begin

dev = first(devices())
lib = MtlLibraryFromFile(dev, joinpath(@__DIR__, "dummy.metallib"))
fun = MtlFunction(lib, "kernel_1")

compact_str = sprint(io->show(io, fun))
full_str = sprint(io->show(io, MIME"text/plain"(), fun))

@test fun.device == dev
@test fun.label == nothing
@test fun.name == "kernel_1"
@test fun.functionType == MTL.MtFunctionTypeKernel

end

@testset "events" begin

dev = first(devices())

let ev = MtlEvent(dev)
    @test ev.device == dev
    @test ev.label == nothing
end

let ev = MtlSharedEvent(dev)
    @test ev.device == dev
    @test ev.label == nothing
    @test ev.signaledValue == 0
end

end

@testset "fences" begin

dev = first(devices())

let fen = MtlFence(dev)
    @test fen.device == dev
end

end

@testset "heap" begin

dev = first(devices())

let desc = MtlHeapDescriptor()
    @test desc.type == MTL.MtHeapTypeAutomatic
    desc.type = MTL.MtHeapTypePlacement
    @test desc.type == MTL.MtHeapTypePlacement

    @test desc.size == 0
    desc.size = 1024
    @test desc.size == 1024

    @test desc.storageMode == MTL.MtStorageModePrivate
    desc.storageMode = MTL.MtStorageModeShared
    @test desc.storageMode == MTL.MtStorageModeShared

    @test desc.cpuCacheMode == MTL.MtCPUCacheModeDefaultCache
    desc.cpuCacheMode = MTL.MtCPUCacheModeWriteCombined
    @test desc.cpuCacheMode == MTL.MtCPUCacheModeWriteCombined

    @test desc.hazardTrackingMode == MTL.MtHazardTrackingModeDefault
    desc.hazardTrackingMode = MTL.MtHazardTrackingModeUntracked
    @test desc.hazardTrackingMode == MTL.MtHazardTrackingModeUntracked

    @test desc.resourceOptions == MTL.MtResourceStorageModeShared |
                                  MTL.MtResourceCPUCacheModeWriteCombined |
                                  MTL.MtResourceHazardTrackingModeUntracked
    desc.resourceOptions = MTL.MtResourceStorageModePrivate |
                           MTL.MtResourceCPUCacheModeDefaultCache |
                           MTL.MtResourceHazardTrackingModeDefault
    @test desc.resourceOptions == MTL.MtResourceStorageModePrivate |
                                  MTL.MtResourceCPUCacheModeDefaultCache |
                                  MTL.MtResourceHazardTrackingModeDefault

    # setting resource options should be reflected in individual fields
    @test desc.storageMode == MTL.MtStorageModePrivate
    @test desc.cpuCacheMode == MTL.MtCPUCacheModeDefaultCache
    @test desc.hazardTrackingMode == MTL.MtHazardTrackingModeDefault
end

desc = MtlHeapDescriptor()
desc.size = 0x4000 # TODO: use heapBufferSizeAndAlign
let heap = MtlHeap(dev, desc)
    @test heap.label == nothing

    @test heap.type == desc.type

    @test heap.size == desc.size

    # NOTE: these checks are fragile, as the heap options seems to depend on the requested size

    #=@test=# heap.storageMode == desc.storageMode

    #=@test=# heap.cpuCacheMode == desc.cpuCacheMode

    #=@test=# heap.hazardTrackingMode == desc.hazardTrackingMode

    #=@test=# heap.resourceOptions == desc.resourceOptions
end

end

@testset "buffers" begin

dev = first(devices())

buf = MtlBuffer{Int}(dev, 1)

@test buf.length == 8

# MtlResource properties
@test buf.device == dev
@test buf.label == nothing

@test sizeof(buf) == 8

free(buf)

end

@testset "command queue" begin

dev = first(devices())

cmdq = MtlCommandQueue(dev)

@test cmdq.device == dev
@test cmdq.label == nothing

end

@testset "command buffer" begin

dev = first(devices())
cmdq = MtlCommandQueue(dev)

cmdbuf = MtlCommandBuffer(cmdq)

@test cmdbuf.device == dev
@test cmdbuf.commandQueue == cmdq
@test cmdbuf.label == nothing
@test cmdbuf.error === nothing
@test cmdbuf.status == MTL.MtCommandBufferStatusNotEnqueued
@test cmdbuf.kernelStartTime == 0
@test cmdbuf.kernelEndTime == 0
@test cmdbuf.gpuStartTime == 0
@test cmdbuf.gpuEndTime == 0

let ev = MtlSharedEvent(dev)
    @test ev.signaledValue == 0
    encode_signal!(cmdbuf, ev, 42)
    encode_wait!(cmdbuf, ev, 21)
    commit!(cmdbuf)
    wait_completed(cmdbuf)
    @test ev.signaledValue == 42
end

cmdbuf = MtlCommandBuffer(cmdq)
@test cmdbuf.status == MTL.MtCommandBufferStatusNotEnqueued
enqueue!(cmdbuf)
@test cmdbuf.status == MTL.MtCommandBufferStatusEnqueued
commit!(cmdbuf)
@test cmdbuf.status == MTL.MtCommandBufferStatusCommitted
# Completion happens too quickly to test for committed status to be checked
wait_completed(cmdbuf) == MTL.MtCommandBufferStatusCompleted
@test cmdbuf.status == MTL.MtCommandBufferStatusCompleted

# CommandBufferDescriptor tests
desc = MTL.mtNewCommandBufferDescriptor()
@test MTL.mtCommandBufferDescriptorRetainedReferences(desc) == true
MTL.mtCommandBufferDescriptorRetainedReferencesSet(desc,false)
@test MTL.mtCommandBufferDescriptorRetainedReferences(desc) == false

@test MTL.mtCommandBufferDescriptorErrorOptions(desc) == MTL.MtCommandBufferErrorOptionNone
MTL.mtCommandBufferDescriptorErrorOptionsSet(desc,MTL.MtCommandBufferErrorOptionEncoderExecutionStatus)
@test MTL.mtCommandBufferDescriptorErrorOptions(desc) == MTL.MtCommandBufferErrorOptionEncoderExecutionStatus

cmq = MtlCommandQueue(device())
cmdbuf = MtlCommandBuffer(cmq; retainReferences=false, errorOption=MTL.MtCommandBufferErrorOptionEncoderExecutionStatus)
@test cmdbuf.retainedReferences == false
@test cmdbuf.errorOptions == MTL.MtCommandBufferErrorOptionEncoderExecutionStatus

end

@testset "compute pipeline" begin

dev = first(devices())
lib = MtlLibraryFromFile(dev, joinpath(@__DIR__, "dummy.metallib"))
fun = MtlFunction(lib, "kernel_1")

pipeline = MtlComputePipelineState(dev, fun)

@test pipeline.device == dev
@test pipeline.label === nothing

@test pipeline.maxTotalThreadsPerThreadgroup isa Integer
@test pipeline.threadExecutionWidth isa Integer
@test pipeline.staticThreadgroupMemoryLength == 0

end

@testset "argument encoder" begin

dev = first(devices())
lib = MtlLibraryFromFile(dev, joinpath(@__DIR__, "vadd.metallib"))
fun = MtlFunction(lib, "vadd")

encoder = MtlArgumentEncoder(fun, 1)

@test encoder.encodedLength == 0
@test encoder.alignment == 1

# TODO: actually encode arguments

end

# TODO: continue adding tests

end


@testset "arrays" begin

mtl_arr = MtlArray{Int}(undef, 1)
arr = Array(mtl_arr)

@test sizeof(arr) == 8
@test length(arr) == 1
@test eltype(arr) == Int

end


@testset "kernels" begin

function tester(A)
    idx = thread_position_in_grid_1d()
    A[idx] = Int(5)
    return nothing
end

bufferSize = 8
bufferA = MtlArray{Int,1}(undef, tuple(bufferSize), storage=Shared)
vecA = unsafe_wrap(Vector{Int}, bufferA.buffer, tuple(bufferSize))

Metal.@sync @metal threads=(bufferSize) tester(bufferA.buffer)
@test all(vecA .== Int(5))

@testset "launch params" begin
    vecA .= 0
    Metal.@sync @metal threads=(2) tester(bufferA.buffer)
    @test all(vecA == Int.([5, 5, 0, 0, 0, 0, 0, 0]))
    vecA .= 0

    Metal.@sync @metal grid=(3) threads=(2) tester(bufferA.buffer)
    @test all(vecA == Int.([5, 5, 5, 5, 5, 5, 0, 0]))
    vecA .= 0

    @test_throws InexactError @metal threads=(-2) tester(bufferA.buffer)
    @test_throws InexactError @metal grid=(-2) tester(bufferA.buffer)
    @test_throws ArgumentError @metal threads=(1025) tester(bufferA.buffer)
    @test_throws ArgumentError @metal threads=(1000,2) tester(bufferA.buffer)
end

@testset "argument buffers" begin
    Metal.@sync @metal threads=(bufferSize) tester(bufferA)
    @test all(vecA .== Int(5))
    vecA .= 0

    function no_intrinsic(A)
        A[1] += Int(5)
        return nothing
    end
    Metal.@sync @metal no_intrinsic(bufferA)
    @test all(vecA == Int.([5, 0, 0, 0, 0, 0, 0, 0]))

    function types_tester(A::MtlDeviceVector{T}) where T
        idx = thread_position_in_grid_1d()
        A[idx] = T(5)
        return nothing
    end
    types = [Float32, Float16, Int64, Int32, Int16, Int8]
    for typ in types
        bufferA = MtlArray{typ,1}(undef, tuple(bufferSize), storage=Shared)
        vecA = unsafe_wrap(Vector{typ}, bufferA.buffer, tuple(bufferSize))
        Metal.@sync @metal threads=(bufferSize) types_tester(bufferA)
        @test all(vecA .== typ(5))
    end
end

@testset "math intrinsics" begin
    a = ones(Float32,1)
    a .* Float32(3.14)
    bufferA = MtlArray(a)
    vecA = unsafe_wrap(Vector{Float32}, bufferA.buffer, 1)

    function intr_test(buf)
        idx = thread_position_in_grid_1d()
        buf[idx] = cos(buf[idx])
        return nothing
    end
    @metal intr_test(bufferA.buffer)
    synchronize()
    @test vecA ≈ cos.(a)

    function intr_test2(buf)
        idx = thread_position_in_grid_1d()
        buf[idx] = Metal.rsqrt(buf[idx])
        return nothing
    end
    @metal intr_test2(bufferA.buffer)
end

@testset "sync barriers" begin
    function sync_test_kernel(buf)
        idx = thread_position_in_grid_1d()
        buf[idx] += UInt8(1)
        return nothing
    end
    buf = MtlArray{UInt8,1}(undef, tuple(1024); storage=Shared)
    vec = unsafe_wrap(Vector{UInt8}, buf.buffer, (1024))
    @metal threads=1024 sync_test_kernel(buf)
    synchronize()
    @test all(vec .== UInt8(1))

    function barrier_test_kernel(buf)
        idx = thread_position_in_grid_1d()
        if thread_position_in_threadgroup_1d() != UInt32(1)
            for i in range(1,threads_per_threadgroup_1d())
                buf[idx] += UInt32(i)
            end
            buf[idx] = 1
        end

        threadgroup_barrier()

        if thread_position_in_threadgroup_1d() == UInt32(1)
            for i in range(1,threads_per_threadgroup_1d())
                buf[idx] += buf[idx+i-1]
            end
        end
        return nothing
    end

    buf = MtlArray{Int,1}(undef, tuple(1024); storage=Shared)
    vec = unsafe_wrap(Vector{Int}, buf.buffer, (1024))
    Metal.@sync @metal threads=1024 barrier_test_kernel(buf)
    @test vec[1] == 992

    # TODO: simdgroup barrier test
end

@testset "threadgroup memory" begin
    for typ in [Float32, Float16, Int32, UInt32, Int16, UInt16, Int8, UInt8]
        dims=10

        @eval function kernel_alloc(a, b)
            idx = thread_position_in_grid_1d()
            tg = MtlStaticSharedArray($typ, $dims)

            tg[idx] = a[idx]
            simdgroup_barrier(Metal.MemoryFlagThreadGroup)

            if idx == 1
                b[idx] += tg[1] + tg[9]
            end
            return
        end

        dev_a = MtlArray{typ}(undef, dims)
        dev_b = MtlArray{typ}(undef, dims)
        a = unsafe_wrap(Array{typ}, dev_a, dims)
        b = unsafe_wrap(Array{typ}, dev_b, dims)

        rand!(a, (1:4))
        Metal.@sync @metal threads=dims kernel_alloc(dev_a, dev_b)
        @test b[1] == a[1] + a[9]
    end

    # Threadgroup overallocation
    function threadgroup_error_kernel(b, n::Val{_size}) where _size
        idx = thread_position_in_grid_1d()
        shared      = MtlStaticSharedArray(Int8, _size)
        shared[idx] = b[1]
        threadgroup_barrier(Metal.MemoryFlagThreadGroup)
        b[idx] = shared[1] + shared[2]
        return
    end

    MtlStaticSharedArray(Int8, 32768)
    @test_throws ArgumentError MtlStaticSharedArray(Int8, 32769)

    buf = MtlArray{Int8}(undef, 2)
    @metal threads=2 threadgroup_error_kernel(buf, Val{32768}())
    @test_throws MtlError @metal threads=2 threadgroup_error_kernel(buf, Val{32772}())
    @test_throws MtlError @metal threads=2 threadgroup_error_kernel(buf, Val{327720000}())

    # TODO: Test threadgroup memory as argument
end

@testset "simd intrinsics" begin

    for typ in [Float32, Float16, Int32, UInt32, Int16, UInt16, Int8, UInt8]
        dims=32
        threadgroup_size=32

        @eval function shuffle_down_kernel(a, b)
            idx = thread_position_in_grid_1d()
            idx_in_simd = thread_index_in_simdgroup()
            simd_idx = simdgroup_index_in_threadgroup()

            temp = MtlStaticSharedArray($typ, $dims)
            temp[idx] = a[idx]
            simdgroup_barrier(Metal.MemoryFlagThreadGroup)

            if simd_idx == 1
                value = temp[idx_in_simd];

                value = value + simd_shuffle_down(value, 16)
                value = value + simd_shuffle_down(value,  8)
                value = value + simd_shuffle_down(value,  4)
                value = value + simd_shuffle_down(value,  2)
                value = value + simd_shuffle_down(value,  1)

                b[idx] = value
            end
            return
        end

        dev_a = MtlArray{typ}(undef, dims)
        dev_b = MtlArray{typ}(undef, dims)
        a = unsafe_wrap(Array{typ}, dev_a, dims)
        b = unsafe_wrap(Array{typ}, dev_b, dims)

        rand!(a, (1:4))
        Metal.@sync @metal threads=threadgroup_size shuffle_down_kernel(dev_a, dev_b)
        @test sum(a) ≈ b[1]
    end
end

@testset "values as references" begin
    function kernel(a, val)
        @inbounds a[thread_index_in_threadgroup()] = val
        return
    end

    a = MtlArray{Float32}(undef, 1)
    @metal kernel(a, 42f0)
    @test Array(a) == [42f0]
end

@testset "mapreduce" begin
    function reduce_threadgroup_test(op, a, b, neutral, shuffle, shmem)
        threadIdx_reduce = thread_position_in_threadgroup_1d()
        threadgroupIdx_reduce = threadgroup_position_in_grid_1d()

        val = a[threadIdx_reduce]

        val = Metal.reduce_threadgroup(op, val, neutral, shuffle, shmem)

        # write back to memory
        if threadIdx_reduce == 1
            b[threadIdx_reduce] = val
        end
        return
    end

    dims=1024
    typ=Int32

    dev_a = MtlArray{typ}(undef, dims)
    dev_b = MtlArray{typ}(undef, 1)
    a = unsafe_wrap(Array{typ}, dev_a, dims)
    b = unsafe_wrap(Array{typ}, dev_b, 1)

    rand!(a, (1:4))

    Metal.@sync @metal threads=dims reduce_threadgroup_test(+, dev_a, dev_b, typ(0), Val(true), Val{dims}())
    @test b[] ≈ sum(a)

    b[] = 0
    Metal.@sync @metal threads=dims reduce_threadgroup_test(+, dev_a, dev_b, typ(0), Val(false), Val{dims}())
    @test b[] ≈ sum(a)
end

end # End kernels testset

# Examples
# TODO: Do this in a way more similar to the other backends
@testset "examples" begin
    include("../examples/unified_memory.jl")
    include("../examples/vadd.jl")
end
