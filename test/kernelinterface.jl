import KernelInterface
import KernelInterface as KI
using Metal.MetalKernels
import Adapt

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

# KernelInterface leaves the formation of sub-groups unspecified; Metal forms SIMD-groups
# from consecutive linear thread indices, which `get_sub_group_size` relies on
@testset "partial sub-groups" begin
    # a 33x2 threadgroup is made up of 3 SIMD-groups, the last one only partially filled
    workgroupsize = (33, 2)
    n = prod(workgroupsize)
    num = MtlArray{UInt32}(undef, n)
    sizes = MtlArray{UInt32}(undef, n)
    id = MtlArray{UInt32}(undef, n)
    lane = MtlArray{UInt32}(undef, n)
    KI.@launch MetalBackend() workgroupsize=workgroupsize ki_subgroup_kernel(num, sizes, id, lane)
    @test all(==(3), Array(num))
    @test Array(sizes) == [i < 64 ? 32 : 2 for i in 0:n-1]
    @test Array(id) == [div(i, 32) + 1 for i in 0:n-1]
    @test Array(lane) == [rem(i, 32) + 1 for i in 0:n-1]
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

@testset "limits" begin
    backend = MetalBackend()
    dims = KI.max_work_group_dims(backend)
    @test prod(dims) >= KI.max_work_group_size(backend)
    @test all(KI.max_num_groups(backend) .* dims .<= typemax(UInt32))
end
