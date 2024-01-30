STORAGEMODES = [Private, Shared]#, Managed]

@testset "array" begin

let arr = MtlVector{Int}(undef, 1)
    @test sizeof(arr) == 8
    @test length(arr) == 1
    @test eltype(arr) == Int
end

let arr = MtlVector{Int}(undef, 0)
    @test sizeof(arr) == 0
end

@testset "constructors" begin
    xs = MtlArray{Int}(undef, 2, 3)
    @test device(xs) == current_device()
    @test collect(MtlArray([1 2; 3 4])) == [1 2; 3 4]
    @test collect(mtl[1, 2, 3]) == [1, 2, 3]
    @test collect(mtl([1, 2, 3])) == [1, 2, 3]
    @test testf(vec, rand(Float32, 5,3))
    @test mtl(1:3) === 1:3
    @test Base.elsize(xs) == sizeof(Int)
    @test pointer(MtlArray{Int, 2}(xs)) != pointer(xs)

    # test aggressive conversion to Float32, but only for floats, and only with `mtl`
    @test mtl([1]) isa MtlArray{Int}
    @test mtl(Float64[1]) isa MtlArray{Float32}
    @test mtl(ComplexF64[1+1im]) isa MtlArray{ComplexF32}
    @test Adapt.adapt(MtlArray{Float16}, Float64[1]) isa MtlArray{Float16}


    @test collect(Metal.zeros(2, 2)) == zeros(Float32, 2, 2)
    @test collect(Metal.ones(2, 2)) == ones(Float32, 2, 2)

    @test collect(Metal.fill(0, 2, 2)) == zeros(Float32, 2, 2)
    @test collect(Metal.fill(1, 2, 2)) == ones(Float32, 2, 2)
end

check_storagemode(arr, smode) = Metal.storagemode(arr) == smode

# There is some repetition to the GPUArrays tests to test for different storagemodes
@testset "$SM storageMode $dim" for SM in STORAGEMODES, dim in [(10,10,10), (1000,17,10)] # The second one purposefully made to always be bigger than 16KiB

    N = length(dim)

    # mtl
    let arr = mtl(rand(2,2), storage= SM)
        @test check_storagemode(arr,  SM)
    end

    # type and dimensionality specified, accepting dims as series of Ints
    let arr = MtlArray{Int,3,SM}(undef, dim[1],dim[2],dim[3])
        @test check_storagemode(arr, SM)
    end
    let arr = MtlArray{Int,2,SM}(undef, dim[1],dim[2])
        @test check_storagemode(arr, SM)
    end

    # empty vector constructor
    let arr = MtlArray{Int,1,SM}(undef, 0)
        @test check_storagemode(arr, SM)
    end
    let arr = MtlVector{Int,SM}()
        @test check_storagemode(arr, SM)
    end

    ## interop with other arrays
    let arr = MtlArray{Float32,N,SM}(rand(Float32,dim))
        @test check_storagemode(arr, SM)
    end
    let arr = MtlArray{Float32,N,SM}(rand(Int,dim))
        @test check_storagemode(arr, SM)
    end

    # constructing new MtlArray from MtlArray
    let arr = MtlArray{Int,N,SM}(rand(Int,dim))
        arr2 = MtlArray{Int,N,SM}(arr)
        @test check_storagemode(arr2, SM)
    end

    # fill, zeros, ones
    let arr = Metal.fill(rand(Float32), dim; storage=SM)
        @test check_storagemode(arr, SM)
    end

    let arr = Metal.zeros(Float32, dim; storage=SM)
        @test check_storagemode(arr, SM)
    end

    let arr = Metal.ones(Float32, dim; storage=SM)
        @test check_storagemode(arr, SM)
    end

    for SM2 in STORAGEMODES
        let arr = MtlArray{Int,N,SM}(rand(Int,dim))
            arr2 = MtlArray{Int,N,SM2}(arr)
            @test check_storagemode(arr2, SM2)
        end
    end

    # private storage errors.
    if SM == Metal.Private
        let arr_mtl = Metal.zeros(Float32, dim...; storage=Private)
            @test_throws "Cannot access the contents of a private buffer" arr_cpu = unsafe_wrap(Array{Float32}, arr_mtl, dim)
        end
    end
end

# Also tests changing storagemode
@testset "similar" begin
    check_similar(::MtlArray{T,N,S}, typ, dim, sm) where {T,N,S} =
        T == typ && N == dim && S == sm
    # similar
    typ1 = Int
    typ2 = Float32
    dim1 = (10,10,10)
    n1   = length(dim1)
    dim2 = dim1[1:2]
    n2   = length(dim2)
    sm1  = Shared
    sm2  = Private

    arr = MtlArray{typ1, n1, sm1}(undef, dim1)

    s1 = similar(arr)
    @test check_similar(s1,typ1,n1,sm1)

    s2 = similar(arr, dim2)
    @test check_similar(s2,typ1,n2,sm1)

    s3 = similar(arr, typ2, dim2)
    @test check_similar(s3,typ2,n2,sm1)

    # s4-s6 test for changing storagemode
    s4 = similar(arr; storage=sm2)
    @test check_similar(s4,typ1,n1,sm2)

    s5 = similar(arr, dim2; storage=sm2)
    @test check_similar(s5,typ1,n2,sm2)

    s6 = similar(arr, typ2, dim2; storage=sm2)
    @test check_similar(s6,typ2,n2,sm2)

end

@testset "fill($T)" for T in [Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64,
                              Float16, Float32]

    b = rand(T)

    # Dims in tuple
    let A = Metal.fill(b, (10, 10, 10, 1000))
        @test all(Array(A) .== b)
    end

    let M = Metal.fill(b, (10, 10))
        @test all(Array(M) .== b)
    end

    let V = Metal.fill(b, (10,))
        @test all(Array(V) .== b)
    end

    #Dims already unpacked
    let A = Metal.fill(b, 10, 10, 10, 1000)
        @test all(Array(A) .== b)
    end

    let M = Metal.fill(b, 10, 10)
        @test all(Array(M) .== b)
    end

    let V = Metal.fill(b, 10)
        @test all(Array(V) .== b)
    end
end

@testset "fill!($T)" for T in [Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64,
                               Float16, Float32]

    b = rand(T)

    # Dims in tuple
    let A = MtlArray{T,3}(undef, (10, 10, 10))
        fill!(A, b)
        @test all(Array(A) .== b)
    end

    let M = MtlMatrix{T}(undef, (10, 10))
        fill!(M, b)
        @test all(Array(M) .== b)
    end

    let V = MtlVector{T}(undef, (10,))
        fill!(V, b)
        @test all(Array(V) .== b)
    end

    # Dims already unpacked
    let A = MtlArray{T,3}(undef, 10, 10, 10)
        fill!(A, b)
        @test all(Array(A) .== b)
    end

    let M = MtlMatrix{T}(undef, 10, 10)
        fill!(M, b)
        @test all(Array(M) .== b)
    end

    let V = MtlVector{T}(undef, 10)
        fill!(V, b)
        @test all(Array(V) .== b)
    end
end

# https://github.com/JuliaGPU/CUDA.jl/issues/2191
@testset "preserving storage mode" begin
  a = mtl([1]; storage=Shared)
  @test Metal.storagemode(a) == Shared

  # storage mode should be preserved
  b = a .+ 1
  @test Metal.storagemode(b) == Shared

  # when there's a conflict, we should defer to shared memory
  c = mtl([1]; storage=Private)
  d = mtl([1]; storage=Shared)
  e = c .+ d
  @test Metal.storagemode(e) == Shared
end

@testset "resizing" begin
  a = MtlArray([1,2,3])

  resize!(a, 3)
  @test length(a) == 3
  @test Array(a) == [1,2,3]

  resize!(a, 5)
  @test length(a) == 5
  @test Array(a)[1:3] == [1,2,3]

  resize!(a, 2)
  @test length(a) == 2
  @test Array(a)[1:2] == [1,2]

  b = MtlArray{Int}(undef, 0)
  @test length(b) == 0
  resize!(b, 1)
  @test length(b) == 1
end

end
