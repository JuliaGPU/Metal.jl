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
    compilation_cmd =
        `$base_cmd -e "using Metal
                       kernel() = return
                       Metal.code_native(devnull, kernel, Tuple{}; kernel=true)"`
    results["compilation"] = @benchmark run($compilation_cmd) evals=1 seconds=60

    # time to launch a first kernel, which the package image should contain compiled
    launch_cmd =
        `$base_cmd -e "using Metal
                       MtlArray([1]) .+ 1
                       synchronize()"`
    results["launch"] = @benchmark run($launch_cmd) evals=1 seconds=30

    results
end

end

Latency.main()
