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

        # exercise real computational kernels, not just the empty identity kernel
        let a = MtlArray([1, 2, 3])
            a .+ 1
            synchronize()
        end
        let a = MtlArray(Float32[1, 2, 3])
            a .+ 1f0
            sum(a)
            synchronize()
        end
    end

    # Caches populated by the workload hold ObjectiveC handles whose underlying
    # objects only exist in the precompilation process; serializing those into
    # the package image yields dangling pointers when the image is loaded. Drop
    # the entries before precompilation finalizes.
    empty!(_compiler_caches)
    empty!(_compiler_configs)
    empty!(kernel_instances)
    empty!(global_queues)
    Base.@lock batched_queues_lock empty!(batched_queues)
    empty!(queue_residency_sets)
    Base.@lock memory_pressure_stats_lock empty!(_memory_pressure_stats)
    empty!(device_malloc_bufs)
    empty!(MTL.last_committed_per_queue)
    empty!(device_exception_info)
end
