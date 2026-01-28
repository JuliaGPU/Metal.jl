const RAND_TYPES = [Float16, Float32, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64,
                    UInt64]
const RANDN_TYPES = [Float16, Float32]
const INPLACE_TUPLES = [[(rand!, T) for T in RAND_TYPES];
                        [(randn!, T) for T in RANDN_TYPES]]
const OOPLACE_TUPLES = [[(Metal.rand, rand, T) for T in RAND_TYPES];
                        [(Metal.randn, rand, T) for T in RANDN_TYPES]]

# in-place
@testset "in-place" begin
    rng = Metal.MPS.RNG()

    @testset "$f with $T" for (f, T) in INPLACE_TUPLES
        # d == 2 and d == 3 are to hit the test cases where sizeof(A) <= 4
        @testset "$d" for d in (2, 3, (3, 3), (3, 3, 3), 16, (16, 16), (16, 16, 16), (1000,), (1000,1000))
            A = MtlArray{T}(undef, d)

            # default_rng
            fill!(A, T(0))
            f(A)
            @test !iszero(collect(A))

            # specified MPS rng
            if T != Float16
                fill!(A, T(0))

                f(rng, A)
                @test !iszero(collect(A))
            end
        end

        @testset "0" begin
            A = MtlArray{T}(undef, 0)

            # default_rng
            f(A)
            @test A isa MtlArray{T,1}
            @test Array(A) == fill(1, 0)

            # specified MPS rng
            if T != Float16
                fill!(A, T(0))

                f(rng, A)
                @test Array(A) == fill(1, 0)
            end
        end
    end
end

# in-place contiguous views
@testset "in-place for views" begin
    @testset "$f with $T" for (f, T) in INPLACE_TUPLES
        alen = 100
        A = MtlArray{T}(undef, alen)
        function test_view!(X::MtlArray{T}, idx) where {T}
            fill!(X, T(0))
            view_X = @view X[idx]
            f(view_X)
            cpuX = collect(X)
            not_zero_in_view = !iszero(cpuX[idx])
            rest_of_array_untouched = iszero(cpuX[1:alen .∉ Ref(idx)])
            return not_zero_in_view, rest_of_array_untouched
        end

        # Test when view offset is 0 and buffer size not multiple of 4
        @testset "Off == 0, buf % 4 != 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 1:51)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end

        # Test when view offset is 0 and buffer size is multiple of 16
        @testset "Off == 0, buf % 16 == 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 1:32)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end

        # Test when view offset is 0 and buffer size is multiple of 4
        @testset "Off == 0, buf % 4 == 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 1:36)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end

        # Test when view offset is not 0 nor multiple of 4 and buffer size not multiple of 16
        @testset "Off != 0, buf % 4 != 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 3:51)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end

        # Test when view offset is multiple of 4 and buffer size not multiple of 4
        @testset "Off % 4 == 0, buf % 4 != 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 17:51)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end

        # Test when view offset is multiple of 4 and buffer size multiple of 16
        @testset "Off % 4 == 0, buf % 16 == 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 9:40)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end

        # Test when view offset is multiple of 4 and buffer size multiple of 4
        @testset "Off % 16 == 0, buf % 4 == 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 9:32)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end
    end

    # Test when views try to use rand!(rng, args..)
    @testset "MPS.RNG with views" begin
        rng = Metal.MPS.RNG()
        @testset "$f with $T" for (f, T) in ((randn!, Float32),(rand!, Int64),(rand!, Float32), (rand!, UInt16), (rand!,Int8))
            A = MtlArray{T}(undef, 100)

            ## Offset > 0
            fill!(A, T(0))
            idx = 4:50
            view_A = @view A[idx]

            f(rng, view_A)

            cpuA = collect(A)
            @test !iszero(cpuA[idx])
            @test iszero(cpuA[1:100 .∉ Ref(idx)])

            ## Offset == 0
            fill!(A, T(0))
            idx = 1:51
            view_A = @view A[idx]

            f(rng, view_A)

            cpuA = collect(A)
            @test !iszero(cpuA[idx])
            @test iszero(cpuA[1:100 .∉ Ref(idx)])
        end
    end
end
# out-of-place
@testset "out-of-place" begin
    @testset "$fr with implicit type" for (fm, fr, T) in
                                            ((Metal.rand, rand, Float32), (Metal.randn, randn, Float32))
        rng = Metal.MPS.RNG()
        @testset "args" for args in ((0,), (1,), (3,), (3, 3), (16,), (16, 16), (1000,), (1000,1000))
            # default_rng
            A = fm(args...)
            @test eltype(A) == T

            # specified MPS rng
            B = fr(rng, args...)
            @test eltype(B) == T
        end

        @testset "scalar" begin
            a = fm()
            @test typeof(a) == T
            b = fr(rng)
            @test typeof(b) == T
        end
    end

    # out-of-place, with type specified
    @testset "$fr with $T" for (fm, fr, T) in OOPLACE_TUPLES
        rng = Metal.MPS.RNG()
        @testset "$args" for args in ((T, 0),
                                        (T, 1),
                                        (T, 3),
                                        (T, 3, 3),
                                        (T, (3, 3)),
                                        (T, 16),
                                        (T, 16, 16),
                                        (T, (16, 16)),
                                        (T, 1000),
                                        (T, 1000, 1000),)
            # default_rng
            A = fm(args...)
            @test eltype(A) == T

            # specified MPS rng
            if T != Float16
                B = fr(rng, args...)
                @test eltype(B) == T
            end
        end

        @testset "scalar" begin
            a = fm(T)
            @test typeof(a) == T
            b = fr(rng, T)
            @test typeof(b) == T
        end
    end
end

## CPU Arrays with MPS rng
@testset "CPU Arrays" begin
    mps_tuples = filter(INPLACE_TUPLES) do tup
        tup[2] != Float16
    end
    rng = Metal.MPS.RNG()
    @testset "$f with $T" for (f, T) in mps_tuples
        # d == 2 and d == 3 are to hit the test cases where sizeof(A) <= 4
        @testset "$d" for d in (2, 3, (3, 3), (3, 3, 3), 16, (16, 16), (16, 16, 16), (1000,), (1000,1000), 16384, 16385)
            A = zeros(T, d)

            f(rng, A)
            @test !iszero(A)
        end
    end
end

## seeding
@testset "Seeding $L" for (f,T,L) in [(Metal.rand,UInt32,"Uniform Integers MPS"),
                                        (Metal.rand,Float32,"Uniform Float32 MPS"),
                                        (Metal.randn,Float32,"Normal Float32 MPS"),
                                        (Metal.randn,Float16,"Float16 Native")]
    @testset "$d" for d in (1, 3, (3, 3, 3), 16, (16, 16), (16, 16, 16), (1000,), (1000,1000))
        Metal.seed!(1)
        a = f(T, d)
        Metal.seed!(1)
        b = f(T, d)
        @test Array(a) == Array(b)
    end
end


@testset "native generator" begin
    rng = Metal.RNG()
    Random.seed!(rng)

    ## in-place

    # uniform
    for T in (Float16, Float32,
              ComplexF16, ComplexF32,
              Int8, Int16, Int32, Int64,
              UInt8, UInt16, UInt32, UInt64),
        dims = (0, 2, (2,2), (2,2,2))
        A = MtlArray{T}(undef, dims)
        rand!(rng, A)

        B = Array{T}(undef, dims)
        Metal.@allowscalar rand!(rng, B)
    end

    # normal
    for T in (Float16, Float32,
              ComplexF16, ComplexF32),
        dims = (0, 2, (2,2), (2,2,2))
        A = MtlArray{T}(undef, dims)
        randn!(rng, A)

        B = Array{T}(undef, dims)
        Metal.@allowscalar randn!(rng, B)
    end

    ## out-of-place

    # uniform
    Metal.@allowscalar begin
        @test rand(rng) isa Number
        @test rand(rng, Float32) isa Float32
    end
    for dims in (0, 2, (2,2), (2,2,2))
        @test rand(rng, dims) isa MtlArray
        for T in (Float16, Float32,
                  ComplexF16, ComplexF32,
                  Int8, Int16, Int32, Int64,
                  UInt8, UInt16, UInt32, UInt64)
            @test rand(rng, T, dims) isa MtlArray{T}
        end
    end

    # normal
    Metal.@allowscalar begin
        @test randn(rng) isa Number
        @test randn(rng, Float32) isa Float32
    end
    for dims in (0, 2, (2,2), (2,2,2))
        @test randn(rng, dims) isa MtlArray
        for T in (Float16, Float32,
                  ComplexF16, ComplexF32)
            @test randn(rng, T, dims) isa MtlArray{T}
        end
    end

    # JuliaGPU/CUDA.jl#1464: Check that the Box-Muller transform doesn't produce infinities (stemming from
    # zeros in the radial sample). Virtually deterministic for the typical 23-24 bits of
    # entropy; a larger sample would be needed for a higher-entropy algorithm like the one
    # used by CURAND.
    @test isfinite(maximum(randn(rng, Float32, 2^26)))

    # JuliaGPU/CUDA.jl#1515: A quick way to check if the Box-Muller transform is correctly implemented for
    # complex numbers is to check that the real part never gets too large. The largest
    # possible value for ComplexF32 is sqrt(-log(u)) where u is the smallest nonzero Float32
    # that can be produced by rand. Typically u = 2f0^(-23) or u = 2f0^(-24) giving an upper
    # bound of around 4 or 4.1, while CURAND.rand gets down to u = 2f0^(-33) giving an upper
    # bound of around 4.8. In contrast, incorrectly reusing the real Box-Muller transform
    # gives typical real parts in the hundreds.
    @test maximum(real(randn(rng, ComplexF32, 32))) <= sqrt(-log(2f0^(-33)))
end

@testset "seeding idempotency" begin
    t = @async begin
        Random.seed!(1)
        Metal.seed!(1)
        x = rand()

        Random.seed!(1)
        Metal.seed!(1)
        y = rand()

        x == y
    end
    @test fetch(t)
end

@testset "copy RNGs" begin
    let r1 = Metal.default_rng(), r2 = copy(Metal.default_rng())
        @test r2 isa Metal.RNG
        @test r1 !== r2
        @test r1 == r2

        rand(r1, 1)
        @test r1 != r2
    end

    # JuliaGPU/CUDA.jl#1575
    let r1 = Metal.default_rng(), r2 = copy(Metal.default_rng())
        @test rand(r1, 3) == rand(r2, 3)
        @test rand(r1, 30_000) == rand(r2, 30_000)
    end

    let r1 = copy(Metal.default_rng()), r2 = copy(Metal.default_rng())
        x1 = rand(r1, 30, 10, 100)
        sum(rand(r1, 30) .+ x1 .+ Metal.randn(30))  # do some other work
        x2 = rand(r2, 30, 10, 100)
        @test x1 == x2
    end

    let r1 = copy(Metal.default_rng()), r2 = copy(Metal.default_rng())
        t2 = @async rand(r1, 1)
        t2 = @async rand(r2, 1)
        @test fetch(t2) == fetch(t2)
    end
end

@testset "counter overflow" begin
    rng = Metal.RNG()
    # we may not be able to allocate over 4GB on the GPU, so use unified memory
    c = MtlArray{Float16, 5, Metal.SharedStorage}(undef, 64, 32, 512, 32, 64)
    rand!(rng, c)
    randn!(rng, c)
end

@testset "randn NaN (Issue #474)" begin
    SEED = 1234
    N=100000000

    # randn!
    let X = Metal.zeros(Float32, N)
        Metal.seed!(SEED)
        randn!(X)
        nans = findall(isnan, Array(X))
        @test isempty(nans)
    end

    # randn(T, dims::Dims)
    let
        Metal.seed!(SEED)
        X = Metal.randn(Float32, Dims(N))
        nans = findall(isnan, Array(X))
        @test isempty(nans)
    end

    # randn(T, dim1::Integer, dims...)
    let
        Metal.seed!(SEED)
        X = Metal.randn(Float32, N)
        nans = findall(isnan, Array(X))
        @test isempty(nans)
    end

    # randn(dim1)
    let
        Metal.seed!(SEED)
        X = Metal.randn(N)
        nans = findall(isnan, Array(X))
        @test isempty(nans)
    end
end
