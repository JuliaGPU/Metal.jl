@testset "output" begin

# GPU logging requires macOS 15 / Metal 3.2. Targeting an older Metal version (here forced via
# the `metal`/`macos` kwargs, so this runs on any host) must raise an informative *host* error
# at compile time -- the dynamic replacement for the old static macOS-version check.
@testset "unsupported target" begin
    function logger()
        @mtlprintln("Hello, World")
        return
    end
    @test_throws "requires macOS 15 / Metal 3.2" @metal launch=false metal=v"3.1" logger()
    @test_throws "requires macOS 15 / Metal 3.2" @metal launch=false macos=v"14" logger()

    # version-gated logging must still compile cleanly for older targets: the dead `os_log`
    # call is eliminated before the check runs.
    function gated_logger()
        if metal_version() >= sv"3.2"
            @mtlprintln("Hello, World")
        end
        return
    end
    kernel = @metal launch=false metal=v"3.1" gated_logger()
    @test kernel isa Metal.HostKernel
end

if Metal.macos_version() < v"15"

@warn "Skipping GPU logging tests on macOS 14 and below"

elseif Metal.is_virtual(Metal.device())

# GPU logging requires an `MTLLogState`, which the paravirtualized GPU driver cannot
# create. Rather than the formatted-output tests below, verify the launch path bails out
# with a clear host error.
@testset "unsupported on virtualized GPUs" begin
    function logger()
        @mtlprintln("Hello, World")
        return
    end
    @test_throws "not supported on virtualized GPUs" @metal logger()
end

else

@testset "formatted output" begin
    _, out = @grab_output @on_device @mtlprintf("")
    @test out == ""

    _, out = @grab_output @on_device @mtlprintf("Testing...\n")
    @test out == "Testing...\n"

    # narrow integer
    _, out = @grab_output @on_device @mtlprintf("Testing %d %d...\n", Int32(1), Int32(2))
    @test out == "Testing 1 2...\n"

    # wide integer
    _, out = @grab_output @on_device @mtlprintf("Testing %ld %ld...\n", Int64(1), Int64(2))
    @test out == "Testing 1 2...\n"

    _, out = @grab_output @on_device begin
        @mtlprintf("foo")
        @mtlprintf("bar\n")
    end
    @test out == "foobar\n"

    # c argument promotions
    function kernel(A)
        @mtlprintf("%f %f\n", A[1], A[1])
        return
    end
    x = mtl(ones(2, 2))
    _, out = @grab_output begin
        Metal.@sync @metal kernel(x)
    end
    @test out == "1.000000 1.000000\n"
end

@testset "@mtlprint" begin
    # basic @mtlprint/@mtlprintln

    _, out = @grab_output @on_device @mtlprint("Hello, World\n")
    @test out == "Hello, World\n"

    _, out = @grab_output @on_device @mtlprintln("Hello, World")
    @test out == "Hello, World\n"


    # argument interpolation (by the macro, so can use literals)

    _, out = @grab_output @on_device @mtlprint("foobar")
    @test out == "foobar"

    _, out = @grab_output @on_device @mtlprint(:foobar)
    @test out == "foobar"

    _, out = @grab_output @on_device @mtlprint("foo", "bar")
    @test out == "foobar"

    _, out = @grab_output @on_device @mtlprint("foobar ", 42)
    @test out == "foobar 42"

    _, out = @grab_output @on_device @mtlprint("foobar $(42)")
    @test out == "foobar 42"

    _, out = @grab_output @on_device @mtlprint("foobar $(4)", 2)
    @test out == "foobar 42"

    _, out = @grab_output @on_device @mtlprint("foobar ", 4, "$(2)")
    @test out == "foobar 42"

    _, out = @grab_output @on_device @mtlprint(42)
    @test out == "42"

    _, out = @grab_output @on_device @mtlprint(4, 2)
    @test out == "42"

    _, out = @grab_output @on_device @mtlprint(Any)
    @test out == "Any"

    _, out = @grab_output @on_device @mtlprintln("foobar $(42)")
    @test out == "foobar 42\n"


    # argument types

    # we're testing the generated functions now, so can't use literals
    function test_output(val, str)
        canary = rand(Int32) # if we mess up the main arg, this one will print wrong
        _, out = @grab_output @on_device @mtlprint(val, " (", canary, ")")
        @test out == "$(str) ($(Int(canary)))"
    end

    for typ in (Int16, Int32, Int64, UInt16, UInt32, UInt64)
        test_output(typ(42), "42")
    end

    for typ in (Float32,)
        test_output(typ(42), "42.000000")
    end

    test_output(Cchar('c'), "c")

    for typ in (Ptr{Cvoid}, Ptr{Int})
        ptr = convert(typ, Int(0x12345))
        test_output(ptr, "0x12345")
    end

    test_output(true, "1")
    test_output(false, "0")

    test_output((1,), "(1,)")
    test_output((1,2), "(1, 2)")
    test_output((1,2,3.0f0), "(1, 2, 3.000000)")

    # escaping

    kernel1(val) = (@mtlprint(val); nothing)
    _, out = @grab_output @on_device kernel1(42)
    @test out == "42"

    kernel2(val) = (@mtlprintln(val); nothing)
    _, out = @grab_output @on_device kernel2(42)
    @test out == "42\n"
end

@testset "@mtlshow" begin
    function kernel()
        seven_i32 = Int32(7)
        three_f32 = Float32(3)
        @mtlshow seven_i32
        @mtlshow three_f32
        @mtlshow 1f0 + 4f0
        return
    end

    _, out = @grab_output @on_device kernel()
    @test out == "seven_i32 = 7\nthree_f32 = 3.000000\n1.0f0 + 4.0f0 = 5.000000\n"
end

end # macos_version() < v"15" else branch

end # @testset "output"
