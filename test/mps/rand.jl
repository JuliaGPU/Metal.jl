using Random

# MPS.RNG supports uniform integers + Float32, and normal Float32.
const MPS_RAND_TYPES  = (Float32, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64)
const MPS_RANDN_TYPES = (Float32,)
const MPS_INPLACE_TUPLES = [[(rand!, T) for T in MPS_RAND_TYPES];
                            [(randn!, T) for T in MPS_RANDN_TYPES]]
const MPS_OOPLACE_TUPLES = [[(rand, T) for T in MPS_RAND_TYPES];
                            [(randn, T) for T in MPS_RANDN_TYPES]]

# in-place
@testset "in-place" begin
    rng = Metal.MPS.RNG()

    @testset "$f with $T" for (f, T) in MPS_INPLACE_TUPLES
        # d == 2 and d == 3 are to hit the test cases where sizeof(A) <= 4
        @testset "$d" for d in (2, 3, (3, 3), (3, 3, 3), 16, (16, 16), (16, 16, 16),
                                (1000,), (1000,1000))
            A = MtlArray{T}(undef, d)
            fill!(A, T(0))
            f(rng, A)
            @test !iszero(collect(A))
        end

        @testset "0" begin
            A = MtlArray{T}(undef, 0)
            fill!(A, T(0))
            f(rng, A)
            @test Array(A) == fill(1, 0)
        end
    end
end

# in-place contiguous views — MPS has a 4-byte alignment requirement on the
# destination buffer's offset and size. Sweep enough view geometries to cover
# every relevant offset/length residue mod 4 / mod 16.
@testset "in-place for views" begin
    rng = Metal.MPS.RNG()
    @testset "$f with $T" for (f, T) in MPS_INPLACE_TUPLES
        alen = 100
        A = MtlArray{T}(undef, alen)
        function test_view!(X::MtlArray{T}, idx) where {T}
            fill!(X, T(0))
            view_X = @view X[idx]
            f(rng, view_X)
            cpuX = collect(X)
            not_zero_in_view = !iszero(cpuX[idx])
            rest_of_array_untouched = iszero(cpuX[1:alen .∉ Ref(idx)])
            return not_zero_in_view, rest_of_array_untouched
        end

        # offset == 0, len % 4 != 0
        @testset "Off == 0, buf % 4 != 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 1:51)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end

        # offset == 0, len % 16 == 0
        @testset "Off == 0, buf % 16 == 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 1:32)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end

        # offset == 0, len % 4 == 0
        @testset "Off == 0, buf % 4 == 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 1:36)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end

        # offset != 0 and not a multiple of 4, len % 4 != 0
        @testset "Off != 0, buf % 4 != 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 3:51)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end

        # offset multiple of 4, len % 4 != 0
        @testset "Off % 4 == 0, buf % 4 != 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 17:51)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end

        # offset multiple of 4, len multiple of 16
        @testset "Off % 4 == 0, buf % 16 == 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 9:40)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end

        # offset multiple of 16, len multiple of 4
        @testset "Off % 16 == 0, buf % 4 == 0" begin
            not_zero_in_view, rest_of_array_untouched = test_view!(A, 9:32)
            @test not_zero_in_view
            @test rest_of_array_untouched
        end
    end
end

# out-of-place
@testset "out-of-place" begin
    @testset "$f with implicit type" for (f, T) in ((rand, Float32), (randn, Float32))
        rng = Metal.MPS.RNG()
        @testset "args" for args in ((0,), (1,), (3,), (3, 3), (16,), (16, 16),
                                      (1000,), (1000,1000))
            A = f(rng, args...)
            @test eltype(A) == T
        end

        @testset "scalar" begin
            a = f(rng)
            @test typeof(a) == T
        end
    end

    @testset "$f with $T" for (f, T) in MPS_OOPLACE_TUPLES
        rng = Metal.MPS.RNG()
        @testset "$args" for args in ((T, 0), (T, 1), (T, 3), (T, 3, 3), (T, (3, 3)),
                                       (T, 16), (T, 16, 16), (T, (16, 16)),
                                       (T, 1000), (T, 1000, 1000))
            A = f(rng, args...)
            @test eltype(A) == T
        end

        @testset "scalar" begin
            a = f(rng, T)
            @test typeof(a) == T
        end
    end
end

# CPU arrays via MPS.RNG (uses unsafe_wrap + can_alloc_nocopy or shared-storage round-trip)
@testset "CPU Arrays" begin
    rng = Metal.MPS.RNG()
    @testset "$f with $T" for (f, T) in MPS_INPLACE_TUPLES
        @testset "$d" for d in (2, 3, (3, 3), (3, 3, 3), 16, (16, 16), (16, 16, 16),
                                (1000,), (1000,1000), 16384, 16385)
            A = zeros(T, d)
            f(rng, A)
            @test !iszero(A)
        end
    end
end

# Metal.seed! seeds both the default RNG and the MPS RNG, so calls that route
# through MPS must reproduce after a re-seed.
@testset "seeding via Metal.seed!" begin
    @testset "$f $T $d" for (f, T) in ((Metal.rand, UInt32), (Metal.rand, Float32),
                                         (Metal.randn, Float32)),
                              d in (1, 3, (3, 3, 3), 16, (16, 16), (16, 16, 16),
                                    (1000,), (1000, 1000))
        Metal.seed!(1)
        a = Random.rand!(Metal.mps_rng(), MtlArray{T}(undef, d))
        Metal.seed!(1)
        b = Random.rand!(Metal.mps_rng(), MtlArray{T}(undef, d))
        @test Array(a) == Array(b)
    end
end

# Metal.seed! is callable from a Task without bleeding state across tasks.
@testset "seeding idempotency" begin
    t = @async begin
        Random.seed!(1)
        Metal.seed!(1)
        x = Random.rand(Metal.mps_rng(), Float32)

        Random.seed!(1)
        Metal.seed!(1)
        y = Random.rand(Metal.mps_rng(), Float32)

        x == y
    end
    @test fetch(t)
end
