const RAND_TYPES = [Float16, Float32, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64,
                    UInt64]
const RANDN_TYPES = [Float16, Float32]
const INPLACE_TUPLES = [[(rand!, T) for T in RAND_TYPES];
                        [(randn!, T) for T in RANDN_TYPES]]
const OOPLACE_TUPLES = [[(Metal.rand, rand, T) for T in RAND_TYPES];
                        [(Metal.randn, rand, T) for T in RANDN_TYPES]]

@testset "random" begin
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
                    if Metal.can_use_mpsrandom(A)
                        f(rng, A)
                        @test !iszero(collect(A))
                    else
                        @test_throws "Destination buffer" f(rng, A)
                    end
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
                    if Metal.can_use_mpsrandom(A)
                        f(rng, A)
                        @test Array(A) == fill(1, 0)
                    else
                        @test_throws "Destination buffer" f(rng, A)
                    end
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

                # Errors in Julia before crashing whole process
                if Metal.can_use_mpsrandom(view_A)
                    f(rng, view_A)

                    cpuA = collect(A)
                    @test !iszero(cpuA[idx])
                    @test iszero(cpuA[1:100 .∉ Ref(idx)]) broken=(sizeof(view_A) % 4 != 0)
                else
                    @test_throws "Destination buffer" f(rng, view_A)
                end

                ## Offset == 0
                fill!(A, T(0))
                idx = 1:51
                view_A = @view A[idx]
                if Metal.can_use_mpsrandom(view_A)
                    f(rng, view_A)

                    cpuA = collect(A)
                    @test !iszero(cpuA[idx])
                    @test iszero(cpuA[1:100 .∉ Ref(idx)])
                else
                    @test_throws "Destination buffer" f(rng, view_A)
                end
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
                    if length(zeros(args...)) * sizeof(T) % 4 == 0
                        B = fr(rng, args...)
                        @test eltype(B) == T
                    else
                        @test_throws "Destination buffer" fr(rng, args...)
                    end
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
                if (prod(d) * sizeof(T)) % 4 == 0
                    f(rng, A)
                    @test !iszero(A)
                else
                    @test_throws "Destination buffer" f(rng, A)
                end
            end
        end
    end

    ## seeding
    @testset "Seeding $L" for (f,T,L) in [(Metal.rand,UInt32,"Uniform Integers MPS"),
                                          (Metal.rand,Float32,"Uniform Float32 MPS"),
                                          (Metal.randn,Float32,"Normal Float32 MPS"),
                                          (Metal.randn,Float16,"Float16 GPUArrays")]
        @testset "$d" for d in (1, 3, (3, 3, 3), 16, (16, 16), (16, 16, 16), (1000,), (1000,1000))
            Metal.seed!(1)
            a = f(T, d)
            Metal.seed!(1)
            b = f(T, d)
            @test Array(a) == Array(b)
        end
    end
end # testset
