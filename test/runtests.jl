using Metal
using ParallelTestRunner

# Force 3 workers if running on the 8GB buildkite mac minis
#  until ParallelTestRunner.jl interface to determine # workers
if parse(Bool, get(ENV, "BUILDKITE", "false"))
    jobs_pos = findfirst(arg -> startswith(arg, "--jobs"), ARGS)
    if isnothing(jobs_pos) && (Sys.total_memory() == 8*2^30)
        push!(ARGS, "--jobs=3")
    end
end

# Quit without erroring if Metal loaded without issues on unsupported platforms
if !Sys.isapple()
    @warn """Metal.jl succesfully loaded on non-macOS system.
             This system is unsupported but should still load.
             Skipping tests."""
    Sys.exit()
else # if Sys.isapple()
    # Skip tests on older unsupported versions
    if !Metal.is_macos(v"13")
        @warn """Metal.jl succesfully loaded on unsupported macOS version (v$(Metal.macos_version())).
                This system is unsupported but should still load.
                Skipping tests."""
        Sys.exit()
    end

    archname = if Metal.is_macos(v"14")
        arch = device().architecture
        if !isnothing(arch)
            string(arch.name)
        else
            ""
        end
    end

    # device.architecture returns null on Intel graphics devices so use Xcode
    if isempty(archname)
        cmd = pipeline(Cmd(`xcrun -f metal-arch`, ignorestatus = true), stdout = devnull, stderr = devnull)

        if run(cmd).exitcode == 0 # Check that Xcode is installed
            archname = read(`xcrun metal-arch --name`, String)
        end
    end

    if !isempty(archname)
        archchecker = occursin(archname)
        if archchecker("Paravirtual") # Virtualized graphics (probably Github Actions runners)
            @warn """Metal.jl succesfully loaded on macOS system with unsupported Paravirtual graphics.
                    This system is unsupported but should still load.
                    Skipping tests."""
            Sys.exit()
        elseif !archchecker("applegpu") # Every other unsupported system (Intel or AMD graphics)
            @warn """Metal.jl succesfully loaded on macOS system with unsupported graphics.
                    This system is unsupported but should still load.
                    Skipping tests."""
            Sys.exit()
        end
    else
        @info "GPU architecture could not be detected, assuming supported device."
    end
end

# If we ever error here, fix above
Metal.functional() || error("Metal.jl is not functional on this system. This is unexpected; please file an issue.")

@info "System information:\n" * sprint(io->Metal.versioninfo(io))

# register custom tests that do not correspond to files in the test directory
testsuite = find_tests(@__DIR__)
## GPUArrays test suite
import GPUArrays
gpuarrays = pathof(GPUArrays)
gpuarrays_root = dirname(dirname(gpuarrays))
gpuarrays_testsuite = joinpath(gpuarrays_root, "test", "testsuite.jl")
include(gpuarrays_testsuite)
for name in keys(TestSuite.tests)
    testsuite["gpuarrays/$name"] = :(TestSuite.tests[$name](MtlArray))
end

args = parse_args(ARGS)

# filter out certain tests depending on the exact testing conditions
if filter_tests!(testsuite, args)
    if Metal.DefaultStorageMode != Metal.PrivateStorage
        # GPUArrays' scalar indexing tests assume that indexing is not supported
        delete!(testsuite, "gpuarrays/indexing scalar")
    end

    # for some reason, the environment shenanigans done by the scripts only work when
    # invoked from the Metal.jl CI, and not from GPUArrays.jl' reverse CI
    if get(ENV, "BUILDKITE_PIPELINE_NAME", "") != "Metal.jl"
        delete!(testsuite, "scripts")
    end

    # only run large copy test on machines with >12GiB memory
    if Sys.total_memory() < 12 * 2^30
        delete!(testsuite, "largecopy")
    end
end

# workers to run tests on
function test_worker(name)
    if name == "capturing"
        return addworker(env=["METAL_CAPTURE_ENABLED"=>"1"])
    end

    return nothing
end

# code to run in each test's sandbox module before running the test
init_code = quote
    using Metal, Adapt, ObjectiveC, ObjectiveC.Foundation, BFloat16s

    # XXX: expose this as --validate
    const runtime_validation = get(ENV, "MTL_DEBUG_LAYER", "0") != "0"
    const shader_validation  = get(ENV, "MTL_SHADER_VALIDATION", "0") != "0"

    const capturing = parse(Int, get(ENV, "METAL_CAPTURE_ENABLED", "0")) > 0

    import GPUArrays
    include($gpuarrays_testsuite)
    testf(f, xs...; kwargs...) = TestSuite.compare(f, MtlArray, xs...; kwargs...)

    const eltypes = [Int16, Int32, Int64,
                     Complex{Int16}, Complex{Int32}, Complex{Int64},
                     Float16, Float32,
                     ComplexF16, ComplexF32]
    TestSuite.supported_eltypes(::Type{<:MtlArray}) = eltypes

    # NOTE: based on test/pkg.jl::capture_stdout, but doesn't discard exceptions
    macro grab_output(ex)
        quote
            mktemp() do fname, fout
                ret = nothing
                open(fname, "w") do fout
                    redirect_stdout(fout) do
                        ret = $(esc(ex))
                    end
                end
                ret, read(fname, String)
            end
        end
    end

    # Run some code on-device
    macro on_device(ex...)
        code = ex[end]
        kwargs = ex[1:end-1]

        @gensym kernel
        esc(quote
            let
                function $kernel()
                    $code
                    return
                end

                Metal.@sync @metal $(kwargs...) $kernel()
            end
        end)
    end
end

runtests(Metal, args; testsuite, init_code, test_worker)
