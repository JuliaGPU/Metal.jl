using Distributed, Test, Metal, Adapt, ObjectiveC, ObjectiveC.Foundation

# Quit without erroring if Metal loaded without issues on unsupported platforms
if Sys.isapple() && !startswith(read(`xcrun metal-arch`, String), "applegpu") || !Sys.isapple()
    @info "Metal.jl succesfully loaded on unsupported system."
    Sys.exit()
end

Metal.functional() || error("Metal.jl is not functional on this system")

# GPUArrays has a testsuite that isn't part of the main package.
# Include it directly.
import GPUArrays
gpuarrays = pathof(GPUArrays)
gpuarrays_root = dirname(dirname(gpuarrays))
include(joinpath(gpuarrays_root, "test", "testsuite.jl"))
testf(f, xs...; kwargs...) = TestSuite.compare(f, MtlArray, xs...; kwargs...)

const eltypes = [Int16, Int32, Int64,
                 Complex{Int16}, Complex{Int32}, Complex{Int64},
                 Float16, Float32,
                 ComplexF16, ComplexF32]
TestSuite.supported_eltypes(::Type{<:MtlArray}) = eltypes

const runtime_validation = get(ENV, "MTL_DEBUG_LAYER", "0") != "0"
const shader_validation  = get(ENV, "MTL_SHADER_VALIDATION", "0") != "0"

using Random


## entry point

function runtests(f, name)
    old_print_setting = Test.TESTSET_PRINT_ENABLE[]
    Test.TESTSET_PRINT_ENABLE[] = false

    try
        # generate a temporary module to execute the tests in
        mod_name = Symbol("Test", rand(1:100), "Main_", replace(name, '/' => '_'))
        mod = @eval(Main, module $mod_name end)
        @eval(mod, using Test, Random, Metal)

        let id = myid()
            wait(@spawnat 1 print_testworker_started(name, id))
        end

        ex = quote
            GC.gc(true)
            Random.seed!(1)
            Metal.allowscalar(false)

            @timed @testset $"$name" begin
                $f()
            end
        end
        data = Core.eval(mod, ex)
        #data[1] is the testset

        # process results
        cpu_rss = Sys.maxrss()
        if VERSION >= v"1.11.0-DEV.1529"
            tc = Test.get_test_counts(data[1])
            passes,fails,error,broken,c_passes,c_fails,c_errors,c_broken =
                tc.passes, tc.fails, tc.errors, tc.broken, tc.cumulative_passes,
                tc.cumulative_fails, tc.cumulative_errors, tc.cumulative_broken
        else
            passes,fails,errors,broken,c_passes,c_fails,c_errors,c_broken =
                Test.get_test_counts(data[1])
        end
        if data[1].anynonpass == false
            data = ((passes+c_passes,broken+c_broken),
                    data[2],
                    data[3],
                    data[4],
                    data[5])
        end
        res = vcat(collect(data), cpu_rss)

        GC.gc(true)
        res
    finally
        Test.TESTSET_PRINT_ENABLE[] = old_print_setting
    end
end


## auxiliary stuff

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

nothing # File is loaded via a remotecall to "include". Ensure it returns "nothing".
