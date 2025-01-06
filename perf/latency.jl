module Latency

using Metal
using BenchmarkTools

function main()
    results = BenchmarkGroup()

    base_cmd = Base.julia_cmd()
    if Base.JLOptions().project != C_NULL
        base_cmd = `$base_cmd --project=$(unsafe_string(Base.JLOptions().project))`
    end
    # NOTE: we don't ust Base.active_project() here because of how CI launches this script,
    #       starting with --project in the main Metal.jl project.

    # time to precompile the package and its dependencies
    precompile_cmd =
        `$base_cmd -e "pkg = Base.identify_package(\"Metal\")
                       Base.compilecache(pkg)"`
    results["precompile"] = @benchmark run($precompile_cmd) evals=1 seconds=60

    # time to actually import the package
    import_cmd =
        `$base_cmd -e "using Metal"`
    results["import"] = @benchmark run($import_cmd) evals=1 seconds=30

    # time to actually compile a kernel
    ttfp_cmd =
        `$base_cmd -e "using Metal
                       kernel() = return
                       Metal.code_native(devnull, kernel, Tuple{}; kernel=true)"`
    results["ttfp"] = @benchmark run($ttfp_cmd) evals=1 seconds=60

    results
end

end

Latency.main()
