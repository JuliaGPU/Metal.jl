import KernelInterface
const KI = KernelInterface
using Metal.MetalInterface

include(joinpath(dirname(pathof(KernelInterface)), "..", "test", "testsuite.jl"))

Testsuite.testsuite(MetalInterface.MetalBackend(), MtlArray)

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
    KI.@launch MetalInterface.MetalBackend() workgroupsize=workgroupsize ki_subgroup_kernel(num, sizes, id, lane)
    @test all(==(3), Array(num))
    @test Array(sizes) == [i < 64 ? 32 : 2 for i in 0:n-1]
    @test Array(id) == [div(i, 32) + 1 for i in 0:n-1]
    @test Array(lane) == [rem(i, 32) + 1 for i in 0:n-1]
end
