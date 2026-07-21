using Metal
using ParallelTestRunner
import Pkg

if !Metal.functional()
    @warn """Metal.jl is not functional on this system, so there is nothing to test; skipping.
             (If you believe this system should be supported, please file an issue.)"""
    Sys.exit()
end

@info "System information:\n" * sprint(io->Metal.versioninfo(io))

# parse command-line arguments (--all is Metal-specific)
args = parse_args(ARGS; custom = ["all"])

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
## examples
function find_examples(dir, examples=String[])
    if VERSION < v"1.12"
        # we rely on workspaces to add dependencies to examples
        return examples
    end
    for entry in readdir(dir; join=true)
        if isfile(entry) && endswith(entry, ".jl") && readline(entry) != "# EXCLUDE FROM TESTING"
            push!(examples, entry)
        elseif isdir(entry)
            find_examples(entry, examples)
        end
    end
    return examples
end
for example in find_examples(joinpath(@__DIR__, "..", "examples"))
    name = splitext(basename(example))[1]
    dir = dirname(example)
    testsuite["examples/$name"] = quote
        cd($dir) do
            project = Base.active_project()
            Base.set_active_project($dir)
            try
                withenv("TESTING" => "true") do
                redirect_stdout(devnull) do
                    include($example)
                end
                end
            finally
                Base.set_active_project(project)
            end
        end
    end
end

# filter out certain tests depending on the exact testing conditions
if filter_tests!(testsuite, args)
    # The GPUArrays test suite is large and slow, so it's opt-in
    if args.custom["all"] === nothing
        filter!(testsuite) do (name, _)
            !startswith(name, "gpuarrays/")
        end
    end

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
    if parse(Bool, get(ENV, "CI", "false")) || Sys.total_memory() < 12 * 2^30
        delete!(testsuite, "largecopy")
    end

    # only run large broadcast test on machines with >12GiB memory
    if parse(Bool, get(ENV, "CI", "false")) || Sys.total_memory() < 12 * 2^30
        delete!(testsuite, "largebroadcast")
    end

    # Enzyme tests are opt-in (Enzyme is a heavy, optional dependency); run via `runtests.jl enzyme`.
    delete!(testsuite, "enzyme")
end

# Add Enzyme / EnzymeCore on the fly when the tests are requested, rather than as test deps
# (matches AMDGPU.jl).
if any(name -> startswith(name, "enzyme"), keys(testsuite))
    @info "Running Enzyme tests"
    Pkg.add(["EnzymeCore", "Enzyme"])
end

# workers to run tests on
function test_worker(name, init_worker_code)
    if name == "capturing"
        return addworker(; env=["METAL_CAPTURE_ENABLED"=>"1"], init_worker_code)
    end

    if name == "examples/flopscomp"
        # Single-use worker since loading AppleAccelerate
        # overloads some base functionality with extra
        # limitations (e.g. FFTs must be powers of 2)
        return addworker(; init_worker_code)
    end

    return nothing
end

# code to run in each test's sandbox module before running the test
init_worker_code = quote
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

init_code = quote
    using Metal, Adapt, ObjectiveC, ObjectiveC.Foundation, BFloat16s

    # bring used symbols into the temporary module
    import ..TestSuite, ..testf
    import ..runtime_validation, ..shader_validation, ..capturing, ..@grab_output, ..@on_device
end

# 8GB mac minis can struggle in some julia versions
max_worker_rss = 2^20 * (Sys.total_memory() > 8*2^30 ? 3800 : 2200)

runtests(Metal, args; testsuite, init_code, init_worker_code, test_worker, max_worker_rss)
