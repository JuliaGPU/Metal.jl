@testset "execution" begin

function tester(A)
    idx = thread_position_in_grid_1d()
    A[idx] = Int(5)
    return nothing
end

bufferSize = 8
bufferA = MtlArray{Int,1}(undef, tuple(bufferSize), storage=Shared)
vecA = unsafe_wrap(Vector{Int}, bufferA.buffer, tuple(bufferSize))

@metal threads=(bufferSize) tester(bufferA.buffer)
synchronize()
@test all(vecA .== Int(5))

@testset "launch params" begin
    vecA .= 0
    @metal threads=(2) tester(bufferA.buffer)
    synchronize()
    @test all(vecA == Int.([5, 5, 0, 0, 0, 0, 0, 0]))
    vecA .= 0

    @metal grid=(3) threads=(2) tester(bufferA.buffer)
    synchronize()
    @test all(vecA == Int.([5, 5, 5, 5, 5, 5, 0, 0]))
    vecA .= 0

    @test_throws InexactError @metal threads=(-2) tester(bufferA.buffer)
    @test_throws InexactError @metal grid=(-2) tester(bufferA.buffer)
    @test_throws ArgumentError @metal threads=(1025) tester(bufferA.buffer)
    @test_throws ArgumentError @metal threads=(1000,2) tester(bufferA.buffer)
end

@testset "argument passing" begin
    @testset "buffer argument" begin
        function kernel(ptr)
            unsafe_store!(ptr, 42)
            return
        end

        a = MtlArray([1])
        @metal kernel(pointer(a))
        @test Array(a)[] == 42
    end

    @testset "scalar argument" begin
        function kernel(ptr, val)
            unsafe_store!(ptr, val)
            return
        end

        a = MtlArray([1])
        @metal kernel(pointer(a), 42)
        @test Array(a)[] == 42
    end

    @testset "array argument" begin
        function kernel(ptr, vals)
            unsafe_store!(ptr, vals[1])
            return
        end

        a = MtlArray([1])
        @metal kernel(pointer(a), (42,))
        @test Array(a)[] == 42
    end

    @testset "struct argument" begin
        function kernel(ptr, vals)
            unsafe_store!(ptr, vals[1] + vals[2])
            return
        end

        a = MtlArray([1])
        @metal kernel(pointer(a), (20, Int32(22)))
        @test Array(a)[] == 42
    end

    @testset "indirect struct argument" begin
        function kernel(obj)
            unsafe_store!(obj[1], obj[2])
            return
        end

        a = MtlArray([1])
        @metal kernel((pointer(a), 42))
        @test Array(a)[] == 42
    end

    @testset "nested indirect struct argument" begin
        function kernel(obj)
            unsafe_store!(obj[1][1], obj[2])
            return
        end

        a = MtlArray([1])
        @metal kernel(((pointer(a), 0), 42))
        @test Array(a)[] == 42
    end

    @testset "array in struct argument" begin
        function kernel(obj)
            unsafe_store!(obj[1], obj[2][1]+obj[2][2])
            return
        end

        a = MtlArray([1])
        @metal kernel((pointer(a), (20,22)))
        @test Array(a)[] == 42
    end
end

end
