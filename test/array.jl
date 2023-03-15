STORAGEMODES = [Private, Shared]#, Managed]
@testset "arrays ($SM)" for SM in STORAGEMODES

let arr = MtlArray{Int}(undef, 1; storage=SM)
    @test sizeof(arr) == 8
    @test length(arr) == 1
    @test eltype(arr) == Int
end

let arr = MtlArray{Int}(undef, 0; storage=SM)
    @test sizeof(arr) == 0
end

@testset "mtl" begin
    @test mtl(rand(2,2)) isa MtlArray{Float32}
    @test adapt(MtlArray, rand(2,2)) isa MtlArray{Float64}
end

# There is some repetition to the GPUArrays tests to test for different storagemodes
@testset "storageMode $dim" for dim in [(10,10,10), (1000,17,10)] # The second one purposefully made to always be bigger than 16KiB
    check_storagemode(arr) = Metal.storagemode(arr) == SM
    check_storagemode(arr, smode) = Metal.storagemode(arr) == smode

    N = length(dim)

    # type and dimensionality specified, accepting dims as series of Ints
    let arr = MtlArray{Int,3}(undef, dim[1],dim[2],dim[3]; storage=SM)
        @test check_storagemode(arr)
    end
    let arr = MtlArray{Int,2}(undef, dim[1],dim[2]; storage=SM)
        @test check_storagemode(arr)
    end

    # type but not dimensionality specified
    let arr = MtlArray{Int}(undef, dim; storage=SM)
        @test check_storagemode(arr)
    end

    # empty vector constructor
    let arr = MtlArray{Int}(undef, 0; storage=SM)
        @test check_storagemode(arr)
    end

    # similar
    let arr = MtlArray{Int}(undef, dim; storage=SM)
        s1 = similar(arr)
        @test check_storagemode(s1)

        s2 = similar(arr, dim[1:2])
        @test check_storagemode(s2)

        s3 = similar(arr, Float32, dim[1:2])
        @test check_storagemode(s3)
    end

    ## interop with other arrays
    let arr = MtlArray{Float32,N}(rand(Float32,dim); storage=SM)
        @test check_storagemode(arr)
    end
    let arr = MtlArray{Float32,N}(rand(Int,dim); storage=SM)
        @test check_storagemode(arr)
    end

    # underspecified constructors
    let arr = MtlArray{Float32}(rand(Int,dim); storage=SM)
        @test check_storagemode(arr)
    end

    let arr = MtlArray(rand(Int,dim); storage=SM)
        @test check_storagemode(arr)
    end


    # constructing new MtlArray from MtlArray
    let arr = MtlArray(rand(Int,dim); storage=SM)
        arr2 = MtlArray(arr)
        @test check_storagemode(arr2)
    end

    for SM2 in STORAGEMODES
        let arr = MtlArray(rand(Int,dim); storage=SM)
            arr2 = MtlArray(arr, storage=SM2)
            @test check_storagemode(arr2,SM2)
        end
    end

    # private storage errors
    if SM == Metal.Private
        let arr_mtl = Metal.zeros(Float32, dim; storage=Private)
            @test_throws "Cannot access the contents of a private buffer" arr_cpu = unsafe_wrap(Array{Float32}, arr_mtl, dim)
        end
    end
end

@testset "fill($T)" for T in [Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64,
                              Float16, Float32]

    b = rand(T)
    A = Metal.fill(b, (10, 10, 10, 1000))

    @test all(Array(A) .== b)

    M = Metal.fill(b, (10, 10))
    @test all(Array(M) .== b)

    v = Metal.fill(b, 10)
    @test all(Array(v) .== b)
end

@testset "fill!($T)" for T in [Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64,
                               Float16, Float32]

    A = MtlArray{T}(undef, (10, 10, 10); storage=SM)
    b = rand(T)
    fill!(A, b)
    @test all(Array(A) .== b)

    M = MtlMatrix{T}(undef, (10, 10); storage=SM)
    fill!(M, b)
    @test all(Array(M) .== b)

    v = MtlVector{T}(undef, 10; storage=SM)
    fill!(v, b)
    @test all(Array(v) .== b)
end

end
