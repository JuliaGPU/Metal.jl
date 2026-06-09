# BFloat16 execution tests.
#
# Only Julia/LLVM that emits the native `bfloat` IR type is supported: on Apple silicon that
# needs LLVM 19+, i.e. Julia 1.13+ (JuliaGPU/Metal.jl#817, #298). Older versions represent
# BFloat16 as an `i16` and emulate the arithmetic in software, which we don't target here.
# GPUCompiler's codegen tests cover the AIR lowering; these check it runs on the device.
if !BFloat16s.llvm_arithmetic
    @warn "BFloat16 is software-emulated as i16 on this Julia/LLVM; skipping native BFloat16 execution tests"
else

@testset "construction & conversion" begin
    a = rand(Float32, 16)
    @test Array(BFloat16.(MtlArray(a))) == BFloat16.(a)
    @test Array(Float32.(MtlArray(BFloat16.(a)))) == Float32.(BFloat16.(a))
end

@testset "arithmetic" begin
    @test testf((a, b) -> a .+ b, rand(BFloat16, 16), rand(BFloat16, 16))
    @test testf((a, b) -> a .- b, rand(BFloat16, 16), rand(BFloat16, 16))
    @test testf((a, b) -> a .* b, rand(BFloat16, 16), rand(BFloat16, 16))
    @test testf(a -> BFloat16(2) .* a .+ BFloat16(1), rand(BFloat16, 16))
end

@testset "math" begin
    # abs and min/max fold to native bfloat intrinsics (the folds are exact), exercising the
    # bfloat-to-float promotion in the AIR lowering; sqrt stays a float computation.
    @test testf(a -> abs.(a), rand(BFloat16, 16) .- BFloat16(0.5))
    @test testf(a -> sqrt.(a), rand(BFloat16, 16))
    @test testf((a, b) -> min.(a, b), rand(BFloat16, 16), rand(BFloat16, 16))
    @test testf((a, b) -> max.(a, b), rand(BFloat16, 16), rand(BFloat16, 16))
end

@testset "reductions" begin
    # min/max are exact and order-independent, so the GPU tree reduction matches the host
    @test testf(maximum, rand(BFloat16, 128))
    @test testf(minimum, rand(BFloat16, 128))
    # sum/prod round in bfloat, so reduction order matters; keep the arrays small enough that
    # the result stays within the comparison tolerance regardless of order
    @test testf(sum, rand(BFloat16, 8))
    @test testf(prod, rand(BFloat16, 8))
end

end
