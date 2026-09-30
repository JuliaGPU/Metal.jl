import KernelInterface
import KernelInterface as KI
using Metal.MetalKernels
import Adapt

include(joinpath(dirname(pathof(KernelInterface)), "..", "test", "testsuite.jl"))

Testsuite.testsuite(MetalBackend(), MtlArray)

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
