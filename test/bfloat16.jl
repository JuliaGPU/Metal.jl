# BFloat16 tests.
#
# BFloat16 runs on Metal on every supported Julia: pre-1.13 it is stored as an `i16` with the
# arithmetic emulated in Float32 by BFloat16s (correct, just not native), and on 1.13+ (Apple
# silicon needs LLVM 19+) Julia emits the native `bfloat` IR type (JuliaGPU/Metal.jl#817, #298).
# The execution tests run on both paths; the codegen tests assert that the native path actually
# produces `bfloat` AIR rather than the i16 fallback.

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
    # abs and min/max fold to native bfloat intrinsics on 1.13+ (the folds are exact),
    # exercising the bfloat-to-float promotion in the AIR lowering; sqrt stays a float op.
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

# only the native path emits `bfloat`; on the i16 fallback there is nothing bfloat-specific to check
if BFloat16s.llvm_arithmetic
    bf16_add(c, a, b) = (i = thread_position_in_grid_1d(); @inbounds c[i] = a[i] + b[i]; return)
    bf16_abs(c, a)    = (i = thread_position_in_grid_1d(); @inbounds c[i] = abs(a[i]); return)

    @testset "codegen" begin
        T = MtlDeviceVector{BFloat16,1}
        # the kernel uses the native `bfloat` IR type, not an i16 emulation
        ir = sprint(io -> Metal.code_llvm(io, bf16_add, Tuple{T,T,T}; kernel=true))
        @test occursin(r"fadd[^\n]*bfloat", ir)
        # bfloat reaches AIR, and abs is promoted to the f32 builtin AIR lacks for bfloat
        air = sprint(io -> Metal.code_native(io, bf16_abs, Tuple{T,T}; kernel=true))
        @test occursin("bfloat", air)
        @test occursin("air.fabs.f32", air)
    end
end
