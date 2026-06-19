using PrecompileTools: @setup_workload, @compile_workload

Sys.isapple() && @setup_workload begin
    metallib_file = joinpath(dirname(@__DIR__), "test", "dummy.metallib")

    @compile_workload begin
        # parsing and writing metal libraries
        metallib = parse(MetalLib, metallib_file)
        sprint(write, metallib)

        # exercise the full kernel-launch pipeline:
        @metal identity(nothing)

        # exercise the integrated profiler and its display path:
        sprint(show, @profile @metal identity(nothing))

        # exercise MtlArray creation and host↔device copy paths in both 1D and 2D
        for h in (Float32[0], Float32[0;;])
            a = MtlArray(h)
            Array(a)
        end
    end

    # Caches populated by the workload hold ObjectiveC handles whose underlying
    # objects only exist in the precompilation process; serializing those into
    # the package image yields dangling pointers when the image is loaded. Drop
    # the entries before precompilation finalizes.
    empty!(_compiler_caches)
    empty!(_compiler_configs)
    empty!(_kernel_instances)
    empty!(global_queues)
    empty!(MTL.last_committed_per_queue)
    empty!(device_exception_info)
end
