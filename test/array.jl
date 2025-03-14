STORAGEMODES = [Metal.PrivateStorage, Metal.SharedStorage, Metal.ManagedStorage]

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
    xs = MtlArray{Int8}(undef, 2, 3)
    @test device(xs) == device()
    @test Base.elsize(xs) == sizeof(Int8)
    @test xs.data[].length == 6
    xs2 = MtlArray{Int8, 2}(xs)
    @test xs2.data[].length == 6
    @test pointer(xs2) != pointer(xs)

    @test collect(MtlArray([1 2; 3 4])) == [1 2; 3 4]
    @test collect(mtl([1, 2, 3])) == [1, 2, 3]
    @test testf(vec, rand(Float32, 5,3))
    @test mtl(1:3) === 1:3


    # Page 22 of https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf
    # Only bfloat missing
    supported_number_types = [Float16  => Float16,
                              Float32  => Float32,
                              Float64  => Float32,
                              Bool     => Bool,
                              Int16    => Int16,
                              Int32    => Int32,
                              Int64    => Int64,
                              Int8     => Int8,
                              UInt16   => UInt16,
                              UInt32   => UInt32,
                              UInt64   => UInt64,
                              UInt8    => UInt8]
    # Test supported types and ensure only Float64 get converted to Float32
    for (SrcType, TargType) in supported_number_types
        @test mtl(SrcType[1]) isa MtlArray{TargType}
        @test mtl(Complex{SrcType}[1+1im]) isa MtlArray{Complex{TargType}}
    end

    # test the regular adaptor
    @test Adapt.adapt(MtlArray, [1 2;3 4]) isa MtlArray{Int, 2, Metal.DefaultStorageMode}
    @test Adapt.adapt(MtlArray{Float32}, [1 2;3 4]) isa MtlArray{Float32, 2, Metal.DefaultStorageMode}
    @test Adapt.adapt(MtlArray{Float32, 2}, [1 2;3 4]) isa MtlArray{Float32, 2, Metal.DefaultStorageMode}
    @test Adapt.adapt(MtlArray{Float32, 2, Metal.SharedStorage}, [1 2;3 4]) isa MtlArray{Float32, 2, Metal.SharedStorage}
    @test Adapt.adapt(MtlMatrix{ComplexF32, Metal.SharedStorage}, [1 2;3 4]) isa MtlArray{ComplexF32, 2, Metal.SharedStorage}
    @test Adapt.adapt(MtlArray{Float16}, Float64[1]) isa MtlArray{Float16}

    # Test a few explicitly unsupported types
    @test_throws "MtlArray only supports element types that are stored inline" MtlArray(BigInt[1])
    @test_throws "MtlArray only supports element types that are stored inline" MtlArray(BigFloat[1])
    @test_throws "Metal does not support Float64 values" MtlArray(Float64[1])
    @test_throws "Metal does not support Int128 values" MtlArray(Int128[1])
    @test_throws "Metal does not support UInt128 values" MtlArray(UInt128[1])

    @test collect(Metal.zeros(2, 2)) == zeros(Float32, 2, 2)
    @test collect(Metal.ones(2, 2)) == ones(Float32, 2, 2)

    @test collect(Metal.fill(0, 2, 2)) == zeros(Float32, 2, 2)
    @test collect(Metal.fill(1, 2, 2)) == ones(Float32, 2, 2)
end

@testset "copyto!" begin
    @testset "$T, $S" for S in [Metal.PrivateStorage, Metal.SharedStorage],
                          T in [Float16, Float32, Bool, Int16, Int32, Int64, Int8, UInt16, UInt32, UInt64, UInt8]
        dim = (1000,17,10)
        A = rand(T,dim)
        mtlA = mtl(A;storage=S)

        #cpu -> gpu
        res = Metal.zeros(T,dim;storage=S)
        copyto!(res,A)
        @test Array(res) == Array(A)

        #gpu -> cpu
        res = zeros(T,dim)
        copyto!(res,mtlA)
        @test Array(res) == Array(mtlA)

        #gpu -> gpu
        res = Metal.zeros(T,dim;storage=S)
        copyto!(res,mtlA)
        @test Array(res) == Array(mtlA)
    end
end

check_storagemode(arr, smode) = Metal.storagemode(arr) == smode

# There is some repetition to the GPUArrays tests to test for different storagemodes
@testset "$SM storageMode $dim" for SM in STORAGEMODES, dim in [(10,10,10), (1000,17,10)] # The second one purposefully made to always be bigger than 16KiB

    N = length(dim)

    # mtl
    let arr = mtl(rand(2,2); storage= SM)
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
    if SM == Metal.PrivateStorage
        let arr_mtl = Metal.zeros(Float32, dim...; storage=Metal.PrivateStorage)
            @test is_private(arr_mtl) && !is_shared(arr_mtl) && !is_managed(arr_mtl)
            @test_throws "Cannot access the contents of a private buffer" arr_cpu = unsafe_wrap(Array{Float32}, arr_mtl, dim)
        end

        let b = rand(Float32, 10)
            arr_mtl = mtl(b; storage=Metal.PrivateStorage)
            @test_throws ErrorException arr_mtl[1]
            @test Metal.@allowscalar arr_mtl[1] == b[1]
        end
    elseif SM == Metal.SharedStorage
        let arr_mtl = Metal.zeros(Float32, dim...; storage=Metal.SharedStorage)
            @test !is_private(arr_mtl) && is_shared(arr_mtl) && !is_managed(arr_mtl)
            @test unsafe_wrap(Array{Float32}, arr_mtl) isa Array{Float32}
        end

        let b = rand(Float32, 10)
            arr_mtl = mtl(b; storage=Metal.SharedStorage)
            @test arr_mtl[1] == b[1]
        end
    elseif SM == Metal.ManagedStorage
        let arr_mtl = Metal.zeros(Float32, dim...; storage=Metal.ManagedStorage)
            @test !is_private(arr_mtl) && !is_shared(arr_mtl) && is_managed(arr_mtl)
            @test unsafe_wrap(Array{Float32}, arr_mtl) isa Array{Float32}
        end

        let b = rand(Float32, 10)
            arr_mtl = mtl(b; storage=Metal.ManagedStorage)
            @test arr_mtl[1] == b[1]
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
    sm1  = Metal.SharedStorage
    sm2  = Metal.PrivateStorage

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
        B = fill(b, (10, 10, 10, 1000))
        @test Array(A) == B
    end

    let M = Metal.fill(b, (10, 10))
        B = fill(b, (10, 10))
        @test Array(M) == B
    end

    let V = Metal.fill(b, (10,))
        B = fill(b, (10,))
        @test Array(V) == B
    end

    #Dims already unpacked
    let A = Metal.fill(b, 10, 1000, 1000)
        B = fill(b, 10, 1000, 1000)
        @test Array(A) == B
    end

    let M = Metal.fill(b, 10, 10)
        B = fill(b, 10, 10)
        @test Array(M) == B
    end

    let V = Metal.fill(b, 10)
        B = fill(b, 10)
        @test Array(V) == B
    end
end

@testset "fill!($T)" for T in [Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64,
                               Float16, Float32]
    b = rand(T)

    # Dims in tuple
    let A = MtlArray{T,3}(undef, (10, 1000, 1000))
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
    let A = MtlArray{T,4}(undef, 10, 10, 10, 1000)
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

    # 0-length array
    let A = MtlArray{T}(undef, 0)
        b = rand(T)
        fill!(A, b)
        @test A isa MtlArray{T,1}
        @test Array(A) == fill(b, 0)
    end
end

# https://github.com/JuliaGPU/CUDA.jl/issues/2191
@testset "preserving storage mode" begin
    a = mtl([1]; storage=Metal.SharedStorage)
    @test Metal.storagemode(a) == Metal.SharedStorage

    # storage mode should be preserved
    b = a .+ 1
    @test Metal.storagemode(b) == Metal.SharedStorage

    # when there's a conflict, we should defer to shared memory
    c = mtl([1]; storage=Metal.PrivateStorage)
    d = mtl([1]; storage=Metal.SharedStorage)
    e = c .+ d
    @test Metal.storagemode(e) == Metal.SharedStorage
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

function _alignedvec(::Type{T}, n::Integer, alignment::Integer = 16384) where {T}
    ispow2(alignment) || throw(ArgumentError("$alignment is not a power of 2"))
    alignment ≥ sizeof(Int) || throw(ArgumentError("$alignment is not a multiple of $(sizeof(Int))"))
    isbitstype(T) || throw(ArgumentError("$T is not a bitstype"))
    p = Ref{Ptr{T}}()
    err = ccall(:posix_memalign, Cint, (Ref{Ptr{T}}, Csize_t, Csize_t), p, alignment, n * sizeof(T))
    iszero(err) || throw(OutOfMemoryError())
    return unsafe_wrap(Array, p[], n, own = true)
end

@testset "unsafe_wrap" begin
    @testset "cpu array incremented" begin
        @testset "wrap cpu" begin
            @testset "check cpu" begin # cpu array checked first
                arr = _alignedvec(Float32, 16384 * 2)
                fill!(arr, one(eltype(arr)))
                marr = Metal.@sync unsafe_wrap(MtlVector{Float32}, arr)

                @test all(arr .== 1)
                @test all(marr .== 1)

                arr .+= 1
                @test all(arr .== 2)
                @test all(marr .== 2)
            end

            @testset "check gpu" begin # gpu array checked first
                arr = _alignedvec(Float32, 16384 * 2)
                fill!(arr, one(eltype(arr)))
                marr = Metal.@sync unsafe_wrap(MtlVector{Float32}, arr)

                @test all(marr .== 1)
                @test all(arr .== 1)

                arr .+= 1
                @test all(marr .== 2)
                @test all(arr .== 2)
            end
        end

        @testset "wrap gpu" begin
            @testset "check cpu" begin # cpu array checked first
                marr = Metal.@sync Metal.ones(Float32, 18000; storage = Metal.SharedStorage)
                arr = unsafe_wrap(Vector{Float32}, marr)

                @test all(arr .== 1)
                @test all(marr .== 1)

                arr .+= 1
                @test all(arr .== 2)
                @test all(marr .== 2)
            end

            @testset "check gpu" begin # gpu array checked first
                marr = Metal.@sync Metal.ones(Float32, 18000; storage = Metal.SharedStorage)
                arr = unsafe_wrap(Vector{Float32}, marr)

                @test all(marr .== 1)
                @test all(arr .== 1)

                arr .+= 1
                @test all(marr .== 2)
                @test all(arr .== 2)
            end
        end
    end

    @testset "gpu array incremented" begin
        @testset "wrap cpu" begin
            @testset "check cpu" begin # cpu array checked first
                arr = _alignedvec(Float32, 16384 * 2)
                fill!(arr, one(eltype(arr)))
                marr = Metal.@sync unsafe_wrap(MtlVector{Float32}, arr)

                @test all(arr .== 1)
                @test all(marr .== 1)

                Metal.@sync marr .+= 1
                @test all(arr .== 2)
                @test all(marr .== 2)
            end

            @testset "check gpu" begin # gpu array checked first
                arr = _alignedvec(Float32, 16384 * 2)
                fill!(arr, one(eltype(arr)))
                marr = Metal.@sync unsafe_wrap(MtlVector{Float32}, arr)

                @test all(marr .== 1)
                @test all(arr .== 1)

                marr .+= 1
                @test all(marr .== 2)
                @test all(arr .== 2)
            end
        end

        @testset "wrap gpu" begin
            @testset "check cpu" begin # cpu array checked first
                marr = Metal.@sync Metal.ones(Float32, 18000; storage = Metal.SharedStorage)
                arr = unsafe_wrap(Vector{Float32}, marr)

                @test all(arr .== 1)
                @test all(marr .== 1)

                Metal.@sync marr .+= 1
                @test all(arr .== 2)
                @test all(marr .== 2)
            end

            @testset "check gpu" begin # gpu array checked first
                marr = Metal.@sync Metal.ones(Float32, 18000; storage = Metal.SharedStorage)
                arr = unsafe_wrap(Vector{Float32}, marr)

                @test all(marr .== 1)
                @test all(arr .== 1)

                marr .+= 1
                @test all(marr .== 2)
                @test all(arr .== 2)
            end
        end
    end

    @testset "Issue #451" begin
        a = mtl(reshape(Float32.(1:60), 5,4,3);storage=Metal.SharedStorage)
        view_a = @view a[:,1:4,2]
        b = copy(unsafe_wrap(Array, view_a))
        c = Array(view_a)

        @test b == c
    end

    # test that you cannot create an array with a different eltype
    marr3 = mtl(zeros(Float32, 10); storage = Metal.SharedStorage)
    @test_throws MethodError unsafe_wrap(Array{Float16}, marr3)
end

@testset "ReshapedArray" begin
    @test Array(sum(reshape(Metal.ones(3, 10)', (5, 3, 2)); dims=1)) == fill(5, (1,3,2))
    @test Array(sum(reshape(PermutedDimsArray(reshape(mtl(collect(Float32, 1:30)), 5, 3, 2), (3, 1, 2)), (10, 3)); dims=1)) ==
        sum(reshape(PermutedDimsArray(reshape(Float32.(1:30), 5, 3, 2), (3, 1, 2)), (10, 3)); dims=1)
end

@testset "accumulate" begin
    testf(f, x) = Array(f(MtlArray(x))) ≈ f(x)
    for n in (0, 1, 2, 3, 10, 10_000, 16384, 16384+1) # small, large, odd & even, pow2 and not
        @test testf(x->accumulate(+, x), rand(Float32, n))
        @test testf(x->accumulate(+, x), rand(Float32, n, 2))
        @test testf(Base.Fix2((x,y)->accumulate(+, x; init=y), rand(Float32)), rand(Float32, n))
    end

    # multidimensional
    for (sizes, dims) in ((2,) => 2,
                          (3,4,5) => 2,
                          (1, 70, 50, 20) => 3)
        @test testf(x->accumulate(+, x; dims=dims), rand(Int, sizes))
        @test testf(x->accumulate(+, x), rand(Int, sizes))
    end

    # using initializer
    for (sizes, dims) in ((2,) => 2,
                          (3,4,5) => 2,
                          (1, 70, 50, 20) => 3)
        @test testf(Base.Fix2((x,y)->accumulate(+, x; dims=dims, init=y), rand(Int)), rand(Int, sizes))
        @test testf(Base.Fix2((x,y)->accumulate(+, x; init=y), rand(Int)), rand(Int, sizes))
    end

    # in place
    @test testf(x->(accumulate!(+, x, copy(x)); x), rand(Float32, 2))

    # specialized
    @test testf(cumsum, rand(Float32, 2))
    @test testf(cumprod, rand(Float32, 2))
end

@testset "findall" begin
    # 1D
    @test testf(x->findall(x), rand(Bool, 1000))
    @test testf(x->findall(y->y>Float32(0.5), x), rand(Float32,1000))

    # ND
    let x = rand(Bool, 1000, 1000)
        @test findall(x) == Array(findall(MtlArray(x)))
    end
    let x = rand(Float32, 1000, 1000)
        @test findall(y->y>Float32(0.5), x) == Array(findall(y->y>Float32(0.5), MtlArray(x)))
    end
end

@testset "broadcast" begin
    testf(f, x) = Array(f(MtlArray(x))) ≈ f(x)

    @test testf(x->max.(x, zero(Float32)), randn(Float32, 1000))
    @test testf(x->min.(x, one(Float32)), randn(Float32, 1000))
    @test testf(x->min.(max.(x, zero(Float32)), one(Float32)), randn(Float32, 1000))
    @test testf(x->max.(min.(x, one(Float32)), zero(Float32)), randn(Float32, 1000))
end

end
