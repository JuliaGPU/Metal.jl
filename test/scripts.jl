using LLVM

@testset "scripts" begin

# for some reason, the environment shenanigans done by the scripts only work when
# invoked from the Metal.jl CI, and not from GPUArrays.jl' reverse CI
if get(ENV, "BUILDKITE_PIPELINE_NAME", "") != "Metal.jl"

@warn "Skipping script tests"

else

mktempdir() do dir
    metallib_as = joinpath(dirname(@__DIR__), "bin", "metallib-as")
    metallib_dis = joinpath(dirname(@__DIR__), "bin", "metallib-dis")
    metallib_load = joinpath(dirname(@__DIR__), "bin", "metallib-load")

    # make sure we can load the dummy metallib
    dummy = joinpath(@__DIR__, "dummy.metallib")
    @test success(`$metallib_load $dummy`)

    # disassemble to bitcode
    run(`$metallib_dis -o $dir/dummy.bc $dummy kernel_1`)
    @test isfile(joinpath(dir, "dummy.bc"))
    @dispose ctx=Context() mod=parse(LLVM.Module, read(joinpath(dir, "dummy.bc"))) begin
        @test mod isa LLVM.Module
    end

    # disassemble to IR
    run(`$metallib_dis -o $dir/dummy.ll $dummy kernel_1`)
    @test isfile(joinpath(dir, "dummy.ll"))
    @test contains(read(joinpath(dir, "dummy.ll"), String), "define void @kernel_1()")

    # assemble and load bitcode (without downgrading)
    run(`$metallib_as -f -o $dir/dummy.metallib $dir/dummy.bc`)
    @test success(`$metallib_load $dir/dummy.metallib`)

    # assemble and load IR
    run(`$metallib_as -f -o $dir/dummy.metallib $dir/dummy.ll`)
    @test success(`$metallib_load $dir/dummy.metallib`)

    # test pipelines
    @test success(pipeline(`$metallib_dis -o - $dummy kernel_1`,
                           `$metallib_as -o - -`,
                           `$metallib_load -`))
    @test success(pipeline(`$metallib_dis -S -o - $dummy kernel_1`,
                           `$metallib_as -o - -`,
                           `$metallib_load -`))
end

end

end
