dummy() = return

@testset "@metal" begin

@test_throws UndefVarError @metal undefined()
@test_throws MethodError @metal dummy(1)


@testset "launch configuration" begin
    @metal dummy()

    threads = 1
    @metal threads dummy()
    @metal threads=1 dummy()
    @metal threads=(1,1) dummy()
    @metal threads=(Int32(1),Int64(1)) dummy()
    @metal threads=(1,1,1) dummy()
    @metal threads=(Int8(1),Int32(1),1) dummy()

    groups = 1
    @metal groups dummy()
    @metal groups=1 dummy()
    @metal groups=(1,1) dummy()
    @metal groups=(Int32(1),Int64(1)) dummy()
    @metal groups=(1,1,1) dummy()
    @metal groups=(Int8(1),Int32(1),1) dummy()

    @metal macos=Metal.macos_version() dummy()
    @metal metal=Metal.metal_support() dummy()
    @metal air=Metal.air_support() dummy()

    @test_throws InexactError @metal threads=(-2) dummy()
    @test_throws InexactError @metal groups=(-2) dummy()
    @test_throws ArgumentError @metal threads=(1025) dummy()
    @test_throws ArgumentError @metal threads=(1000,2) dummy()
end

@testset "launch=false" begin
    k = @metal launch=false dummy()
    k()
    k(; threads=1)

    # TODO: kernel introspection
end

@testset "inference" begin
    foo() = @metal dummy()
    @inferred foo()

    # with arguments, we call mtlconvert
    kernel(a) = return
    bar(a) = @metal kernel(a)
    @inferred bar(MtlArray([1]))
end


@testset "reflection" begin
    Metal.code_lowered(dummy, Tuple{})
    Metal.code_typed(dummy, Tuple{})
    Metal.code_warntype(devnull, dummy, Tuple{})
    Metal.code_llvm(devnull, dummy, Tuple{})

    @device_code_lowered @metal dummy()
    @device_code_typed @metal dummy()
    @device_code_warntype io=devnull @metal dummy()
    @device_code_llvm io=devnull @metal dummy()

    mktempdir() do dir
        @device_code dir=dir @metal dummy()
    end

    @test_throws ErrorException @device_code_lowered nothing

    # make sure kernel name aliases are preserved in the generated code
    @test occursin("dummy", sprint(io->(@device_code_llvm io=io optimize=false @metal dummy())))
    @test occursin("dummy", sprint(io->(@device_code_llvm io=io @metal dummy())))

    # make sure invalid kernels can be partially reflected upon
    let
        invalid_kernel() = throw()
        @test_throws Metal.InvalidIRError @metal invalid_kernel()
        @test_throws Metal.InvalidIRError @grab_output @device_code_warntype @metal invalid_kernel()
        out, err = @grab_output begin
            try
                @device_code_warntype @metal invalid_kernel()
            catch
            end
        end
        @test occursin("Body::Union{}", err)
    end

    # set name of kernel
    @test occursin("mykernel", sprint(io->(@device_code_llvm io=io begin
        @metal name="mykernel" dummy()
    end)))

    # set macOS, AIR, and Metal versions
    let
        @test occursin("""!{!"Metal", i32 3, i32 2, i32 1}""",
                       sprint(io->Metal.code_llvm(io, dummy, Tuple{}; metal=v"3.2.1",
                                                      dump_module=true, kernel=true)))

        @test occursin("!{i32 3, i32 2, i32 1}",
                       sprint(io->Metal.code_llvm(io, dummy, Tuple{}; air=v"3.2.1",
                                                      dump_module=true, kernel=true)))

        @test occursin("""!"SDK Version", [3 x i32] [i32 3, i32 2, i32 1]}""",
                       sprint(io->Metal.code_llvm(io, dummy, Tuple{}; macos=v"3.2.1",
                                                      dump_module=true, kernel=true)))
    end

    @test Metal.return_type(identity, Tuple{Int}) === Int
    @test Metal.return_type(sin, Tuple{Float32}) === Float32
    @test Metal.return_type(getindex, Tuple{MtlDeviceArray{Float32,1,1},Int32}) === Float32
    @test Metal.return_type(getindex, Tuple{Base.RefValue{Integer}}) === Integer
end



function tester(A)
    idx = thread_position_in_grid_1d()
    A[idx] = Int(5)
    return nothing
end

bufferSize = 8
bufferA = MtlArray{Int,1,Metal.SharedStorage}(undef, tuple(bufferSize))
vecA = unsafe_wrap(Vector{Int}, pointer(bufferA), tuple(bufferSize))

@testset "synchronization" begin
    @metal threads=(bufferSize) tester(bufferA)
    synchronize()
    @test all(vecA .== Int(5))
end

@testset "device synchronization" begin
    t = @async begin
        @metal threads=(bufferSize) tester(bufferA)
    end
    wait(t)
    device_synchronize()
    @test all(vecA .== Int(5))
end

@testset "launch params" begin
    vecA .= 0
    @metal threads=(2) tester(bufferA)
    synchronize()
    @test all(vecA == Int.([5, 5, 0, 0, 0, 0, 0, 0]))
    vecA .= 0

    @metal groups=(3) threads=(2) tester(bufferA)
    synchronize()
    @test all(vecA == Int.([5, 5, 5, 5, 5, 5, 0, 0]))
    vecA .= 0

    dev = device()
    queue = MTL.MTLCommandQueue(dev)
    @metal threads=(3) queue=queue tester(bufferA)
    synchronize(queue)
    @test all(vecA == Int.([5, 5, 5, 0, 0, 0, 0, 0]))
    vecA .= 0

    @test_throws InexactError @metal threads=(-2) tester(bufferA)
    @test_throws InexactError @metal groups=(-2) tester(bufferA)
    @test_throws ArgumentError @metal threads=(1025) tester(bufferA)
    @test_throws ArgumentError @metal threads=(1000,2) tester(bufferA)
end

end

############################################################################################

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

    @testset "unused mutable types" begin
        function kernel(T, ptr)
            unsafe_store!(ptr, one(T))
            return
        end

        a = MtlArray([0])
        @metal kernel(Int, pointer(a))
        @test Array(a)[] == 1
    end
end
