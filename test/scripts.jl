using LLVM

@testset "scripts" begin

mktempdir() do dir
    dummy = joinpath(@__DIR__, "dummy.metallib")
    metallib_as = joinpath(dirname(@__DIR__), "bin", "metallib-as")
    metallib_dis = joinpath(dirname(@__DIR__), "bin", "metallib-dis")

    # disassemble to bitcode
    run(`$metallib_dis -o $(dir)/dummy.bc $(dummy)`)
    @test isfile(joinpath(dir, "dummy.bc"))
    @dispose ctx=Context() mod=parse(LLVM.Module, read(joinpath(dir, "dummy.bc"))) begin
        @test mod isa LLVM.Module
    end

    # disassemble to IR
    run(`$metallib_dis -o $(dir)/dummy.ll $(dummy)`)
    @test isfile(joinpath(dir, "dummy.ll"))
    @test contains(read(joinpath(dir, "dummy.ll"), String), "define void @kernel_1()")

    # assemble and load bitcode (without downgrading)
    run(`$metallib_as -f -o $(dir)/dummy.metallib $(dir)/dummy.bc`)
    let
        dev = current_device()
        lib = MTLLibraryFromData(dev, read(joinpath(dir, "dummy.metallib")))
        fun = MTLFunction(lib, "kernel_1")
        pipeline = MTLComputePipelineState(dev, fun)
    end

    # assemble and load IR
    run(`$metallib_as -f -o $(dir)/dummy.metallib $(dir)/dummy.ll`)
    let
        dev = current_device()
        lib = MTLLibraryFromData(dev, read(joinpath(dir, "dummy.metallib")))
        fun = MTLFunction(lib, "kernel_1")
        pipeline = MTLComputePipelineState(dev, fun)
    end
end

end
