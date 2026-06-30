using Test

# Runs only when Enzyme is installed (opt-in via runtests.jl); mirrors AMDGPU's enzyme_tests.jl.
const enzyme_uuid = Base.UUID("7da242da-08ed-463a-9acd-ee780be4f1d9")
const enzyme_available = Base.locate_package(Base.PkgId(enzyme_uuid, "Enzyme")) !== nothing

if enzyme_available
    using EnzymeCore, Enzyme
    import GPUCompiler

    function sq_kernel!(y, x)
        i = Metal.thread_position_in_grid_1d()
        @inbounds y[i] = x[i] * x[i]
        return nothing
    end
    run_sq!(y, x) = (Metal.@metal threads = length(x) sq_kernel!(y, x); nothing)

    @testset "EnzymeCoreExt" begin
        @test Base.get_extension(Metal, :EnzymeCoreExt) !== nothing

        @testset "compiler_job_from_backend" begin
            @test EnzymeCore.compiler_job_from_backend(
                Metal.MetalBackend(), typeof(() -> nothing), Tuple{}) isa GPUCompiler.CompilerJob
        end

        @testset "sum gradient (vector)" begin
            x = mtl(Float32[1, 2, 3, 4])
            dx = only(gradient(Reverse, sum, x))
            @test Array(dx) ≈ ones(Float32, 4)
        end

        @testset "sum gradient (matrix)" begin
            A = mtl(Float32[1 2 3; 4 5 6])
            dA = only(gradient(Reverse, sum, A))
            @test Array(dA) ≈ ones(Float32, 2, 3)
        end

        @testset "kernel-launch gradient" begin
            xv = Float32[1, 2, 3, 4]
            x = mtl(xv)
            y = mtl(zeros(Float32, 4))
            dx = mtl(zeros(Float32, 4))
            dy = mtl(ones(Float32, 4))
            Enzyme.autodiff(Reverse, run_sq!, Const, Duplicated(y, dy), Duplicated(x, dx))
            @test Array(dx) ≈ 2 .* xv   # d/dx x^2 = 2x
        end
    end
else
    @info "Skipping Enzyme tests (Enzyme not installed)"
end
