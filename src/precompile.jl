using PrecompileTools: @setup_workload, @compile_workload

Sys.isapple() && Sys.ARCH === :aarch64 && @setup_workload begin
    metallib_file = joinpath(dirname(@__DIR__), "test", "dummy.metallib")

    @compile_workload begin
        # parsing and writing metal libraries
        metallib = parse(MetalLib, metallib_file)
        sprint(write, metallib)

        # exercise the kernel compilation pipeline. on Julia 1.11+ this also stores
        # the compiled kernel (inference results and metallib bytes, attached to its
        # CodeInstance) in the package image, so that loading Metal.jl can launch it
        # without invoking the compiler. session-local state (pipeline handles,
        # kernel instances) is kept out of the image below and by `mtlfunction`.
        # NOTE: only compile and link; actually launching a kernel (committing a
        #       command buffer and waiting for it) hangs during precompilation.
        mtlfunction(identity, Tuple{Nothing})

        # exercise the integrated profiler and its display path:
        sprint(show, @profile @metal identity(nothing))

        # exercise MtlArray creation and host↔device copy paths in both 1D and 2D
        for h in (Float32[0], Float32[0;;])
            a = MtlArray(h)
            Array(a)
        end

        # exercise real computational kernels, not just the empty identity kernel.
        #
        # only do so on 1.11+: unlike the identity kernel, broadcast and reduction kernels
        # reuse the same generic `Base` methods that host code does. before Julia 1.11
        # GPUCompiler cannot tag its inferred `CodeInstance`s with a cache owner
        # (`CodeInstance.owner` does not exist yet), so the device-context results for
        # those shared methods leak into the package image and shadow the host versions,
        # crashing the host with unresolved `julia.air.*` intrinsics when it later
        # compiles the corresponding `Base` method.
        @static if VERSION >= v"1.11"
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
    end

    # Caches populated by the workload hold ObjectiveC handles whose underlying
    # objects only exist in the precompilation process; serializing those into
    # the package image yields dangling pointers when the image is loaded. Drop
    # the entries before precompilation finalizes.
    empty!(_compiler_configs)
    empty!(kernel_instances)
    empty!(global_queues)
    Base.@lock batched_queues_lock empty!(batched_queues)
    empty!(queue_residency_sets)
    Base.@lock memory_pressure_stats_lock empty!(_memory_pressure_stats)
    empty!(device_malloc_bufs)
    empty!(MTL.last_committed_per_queue)
    empty!(MTL.submission_state_per_queue)
    empty!(device_exception_info)
end
