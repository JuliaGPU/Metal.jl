import KernelInterface
import KernelInterface as KI
using Metal.MetalKernels
import Adapt
import GPUCompiler

include(joinpath(dirname(pathof(KernelInterface)), "..", "test", "testsuite.jl"))

Testsuite.testsuite(MetalBackend(), MtlArray)

function ki_subgroup_kernel(num, sizes, id, lane)
    l = KI.get_local_id()
    s = KI.get_local_size()
    i = l.x + (l.y - 1) * s.x
    @inbounds begin
        num[i] = KI.get_num_sub_groups()
        sizes[i] = KI.get_sub_group_size()
        id[i] = KI.get_sub_group_id()
        lane[i] = KI.get_sub_group_local_id()
    end
    return
end

# the SIMD-group width kernels are compiled for
const W = KI.sub_group_size(MetalBackend())

function ki_max_sub_group_size!(A)
    @inbounds A[KI.get_global_id().x] = KI.get_max_sub_group_size()
    return
end

@testset "SIMD-group width" begin
    # Apple GPUs are 32 wide
    Metal.is_supported(device()) && @test W == 32
    A = Metal.zeros(Int, 1)
    kernel = KI.@launch MetalBackend() launch=false ki_max_sub_group_size!(A)
    @test kernel.kern.exec_width == W
    kernel(A; ndrange=1)
    @test Array(A) == [W]
end

# KernelInterface leaves the formation of sub-groups unspecified; Metal forms SIMD-groups
# from consecutive linear thread indices, which `get_sub_group_size` relies on
@testset "partial sub-groups" begin
    # a (W+1)x2 threadgroup is made up of 3 SIMD-groups, the last one only partially filled
    workgroupsize = (W + 1, 2)
    n = prod(workgroupsize)
    num = MtlArray{UInt32}(undef, n)
    sizes = MtlArray{UInt32}(undef, n)
    id = MtlArray{UInt32}(undef, n)
    lane = MtlArray{UInt32}(undef, n)
    KI.@launch MetalBackend() workgroupsize=workgroupsize ki_subgroup_kernel(num, sizes, id, lane)
    @test all(==(3), Array(num))
    @test Array(sizes) == [i < 2W ? W : 2 for i in 0:n-1]
    @test Array(id) == [div(i, W) + 1 for i in 0:n-1]
    @test Array(lane) == [rem(i, W) + 1 for i in 0:n-1]
end

function ki_shfl_width!(A)
    i = KI.get_global_id().x
    @inbounds A[i] = KI.shfl(A[i], A[i]) + KI.get_max_sub_group_size(Int32)
    return
end

# code is specialized for the width it is compiled for, also when compiling the same kernel
# for several widths
@testset "code for a SIMD-group width of $width" for width in (8, 32, 16, W)
    config = Metal._compiler_config(device(), width)
    src = Metal.methodinstance(typeof(ki_shfl_width!), Tuple{MtlDeviceVector{Int32,1}})
    job = GPUCompiler.CompilerJob(src, config)
    ir = sprint(io -> GPUCompiler.code_llvm(io, job; dump_module=false))
    # the lane is wrapped to the width, and the width added
    @test occursin(Regex("and i16 %\\S+, $(width - 1)\\b"), ir)
    @test occursin(Regex("add i32 %\\S+, $(width)\\b"), ir)
end

@testset "copyto!" begin
    backend = MetalBackend()

    # contiguous views of host arrays (those of an `MtlArray` are `MtlArray`s)
    dev = Metal.zeros(Float32, 4)
    host = Float32[1, 2, 3, 4, 5, 6]
    @test KI.copyto!(backend, dev, view(host, 2:5)) === dev
    KI.synchronize(backend)
    @test Array(dev) == [2, 3, 4, 5]
    KI.copyto!(backend, view(host, 1:4), Metal.ones(Float32, 4))
    KI.synchronize(backend)
    @test host == [1, 1, 1, 1, 5, 6]

    # host to host
    a = zeros(Float32, 4)
    @test KI.copyto!(backend, a, view(host, 3:6)) === a
    @test a == [1, 1, 5, 6]
    union = Vector{Union{Missing, Int32}}(undef, 2)
    KI.copyto!(backend, union, view(Union{Missing, Int32}[1, missing, 3], 1:2))
    @test isequal(union, [1, missing])

    # only contiguous arrays
    @test_throws ArgumentError KI.copyto!(backend, Metal.zeros(Float32, 3), view(host, 1:2:6))
end

@testset "adapt" begin
    # all arrays, not only `Array`s, as `adapt(MtlArray, ...)` does
    @test Adapt.adapt(MetalBackend(), trues(4)) isa MtlArray{Bool}
    @test Adapt.adapt(MetalBackend(), 1:4) === 1:4
end

function ki_fill!(A)
    i = KI.get_global_id().x
    if i <= length(A)
        @inbounds A[i] = i
    end
    return
end

@testset "launch keywords" begin
    A = Metal.zeros(Int, 4)
    kernel = KI.@launch MetalBackend() launch=false ki_fill!(A)

    # Metal's launch options are passed on
    kernel(A; ndrange=4, queue=global_queue(device()), submit=true)
    @test Array(A) == 1:4

    # but not ones that would override the launch geometry
    @test_throws ArgumentError kernel(A; ndrange=4, threads=8)
    @test_throws ArgumentError kernel(A; ndrange=4, groups=2)
    @test_throws ArgumentError kernel(A; ndrange=4, stream=nothing)
end

function ki_fenced_barriers(::Core.LLVMPtr{Int32,Metal.AS.Device}, ::Val{flags}) where {flags}
    KI.barrier(flags)
    return
end

# KernelInterface's flags don't have the bits of Metal's: local memory is threadgroup
# memory, and global memory is device memory
@testset "memory fence flags" begin
    @testset "$(flags.bits)" for (flags, mtl) in (
            KI.LOCAL_MEM_FENCE => Metal.MemoryFlagThreadGroup,
            KI.GLOBAL_MEM_FENCE => Metal.MemoryFlagDevice,
            KI.LOCAL_MEM_FENCE | KI.GLOBAL_MEM_FENCE =>
                Metal.MemoryFlagThreadGroup | Metal.MemoryFlagDevice)
        tt = Tuple{Core.LLVMPtr{Int32,Metal.AS.Device}, Val{flags}}
        ir = sprint(io -> Metal.code_air(io, ki_fenced_barriers, tt))
        @test occursin("@air.wg.barrier(i32 $(UInt32(mtl)),", ir)
    end
end

@testset "limits" begin
    backend = MetalBackend()
    dims = KI.max_work_group_dims(backend)
    @test prod(dims) >= KI.max_work_group_size(backend)
    @test all(KI.max_num_groups(backend) .* dims .<= typemax(UInt32))
end

@testset "versioninfo" begin
    @test occursin("Metal.jl", sprint(KI.versioninfo, MetalBackend()))
end
