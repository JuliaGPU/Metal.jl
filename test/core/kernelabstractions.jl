import KernelAbstractions
import KernelAbstractions as KA
import KernelInterface as KI
using Metal.MetalKernels

include(joinpath(dirname(pathof(KernelAbstractions)), "..", "test", "testsuite.jl"))

skip_tests = Set([
    "SpecialFunctions",  # gamma and erfc not currently supported on Metal.jl
    "sparse",            # not supported yet
    "many arguments",    # Metal kernels take at most 31 buffers, one per argument
])
if Metal.is_virtual(Metal.device())
    # device-side printing needs GPU logging, which is unsupported on virtualized GPUs
    push!(skip_tests, "Printing")
end

Testsuite.testsuite(MetalBackend, "Metal", Metal, MtlArray, Metal.MtlDeviceArray; skip_tests)

KA.@kernel function store_global_linear!(A)
    I = KA.@index(Global, Linear)
    @inbounds A[I] = I
end

KA.@kernel function store_last_index!(A)
    I = KA.@index(Global, Linear)
    if I == prod(KA.@ndrange())
        @inbounds A[1] = I
        @inbounds A[2] = KA.@index(Global, Cartesian)[2]
    end
end

@testset "launch configuration" begin
    backend = MetalBackend()
    # a dynamic N-d range is indexed without divisions
    kernel = store_global_linear!(backend)
    A = Metal.zeros(Int, 64, 32, 16)
    llvm = sprint(io -> Metal.@device_code_llvm io=io kernel(A; ndrange=size(A)))
    @test !occursin(r"\b[us](div|rem) ", llvm)
    @test Array(A) == LinearIndices(A)

    # iteration spaces that don't fit 32-bit indices
    kernel = store_last_index!(backend)
    A = Metal.zeros(Int, 2)
    for dims in ((2^16 + 1, 2^15), (2^11 + 1, 2^10, 2^9, 2), (1, 1, 1, 2^31 + 1))
        kernel(A; ndrange=dims)
        @test Array(A) == [prod(dims), dims[2]]
    end
end

function ki_store_index!(A)
    i = KI.get_global_id().x
    if i <= length(A)
        @inbounds A[i] = i
    end
    return
end

@testset "workgroup size tuning" begin
    # the pipeline's maximum threadgroup size, as Metal launched KA kernels before
    A = Metal.zeros(Int, 4096)
    kernel = KI.@launch MetalBackend() launch=false ki_store_index!(A)
    maxthreads = kernel.kern.maxthreads
    @test KI.launch_configuration(kernel; nitems=length(A)).workgroupsize == maxthreads
    @test KI.launch_configuration(kernel; max_work_group_size=32).workgroupsize == 32

    kernel = store_global_linear!(MetalBackend())
    kernel(A; ndrange=length(A))
    @test Array(A) == 1:length(A)
end

KA.@kernel function const_copy!(A, @Const(B))
    I = KA.@index(Global)
    @inbounds A[I] = B[I]
end

KA.@kernel function const_copy_2d!(A, @Const(B))
    i, j = KA.@index(Global, NTuple)
    @inbounds A[i, j] = B[i, j]
end

@testset "@Const" begin
    backend = MetalBackend()

    A = Metal.zeros(Float32, 1024)
    B = MtlArray(rand(Float32, 1024))
    ir = sprint() do io
        Metal.@device_code_llvm io=io raw=true begin
            const_copy!(backend)(A, B; ndrange=length(A))
            KA.synchronize(backend)
        end
    end
    @test Array(A) == Array(B)
    # loads from a constified argument are marked as invariant
    @test occursin("!invariant.load", ir)

    A = Metal.zeros(Float32, 32, 32)
    B = MtlArray(rand(Float32, 32, 32))
    const_copy_2d!(backend)(A, B; ndrange=size(A))
    KA.synchronize(backend)
    @test Array(A) == Array(B)
end
