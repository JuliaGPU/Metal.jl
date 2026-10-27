using PrecompileTools: @setup_workload, @compile_workload

function precompile_kernel(a)
    i = thread_position_in_grid().x
    # Cache host code for compiling `sqrt` domain checks and `exp` via `llvm_math`.
    a[i] = exp(sqrt(a[i]))
    return
end

@setup_workload begin
    # `__init__` installs this, but it doesn't run before the workload
    MTL.submit_hook[] = submit_command_buffer

    metallib_file = joinpath(dirname(@__DIR__), "test", "dummy.metallib")

    @compile_workload begin
        # parsing and writing metal libraries
        metallib = parse(MetalLib, metallib_file)
        sprint(write, metallib)

        # exercise the kernel compilation pipeline. on Julia 1.11+ this also stores
        # the compiled kernel (inference results and metallib bytes, attached to its
        # CodeInstance) in the package image, so that loading Metal.jl can launch it
        # without invoking the compiler. session-local state (pipeline handles,
        # relocation tables) is kept out of the image below and by `mtlfunction`.
        mtlfunction(identity, Tuple{Nothing})

        # the rest needs a command queue, which can't be created when the `command_api`
        # preference selects an API this system doesn't support (`__init__` reports that)
        command_api_supported =
            COMMAND_API === :metal3 || metal4_unsupported_reason(device()) === nothing

        # exercise the integrated profiler
        command_api_supported && @profile @metal identity(nothing)

        # displaying results takes seconds to compile. each table's columns depend on the
        # data (e.g. a distribution column for repeated operations), so cover the variants
        # that are common.
        let sz = MTL.MTLSize(1, 1, 1)
            kernel = (; kind=:kernel, name="kernel", threadgroups=sz, threads=sz,
                      tgmem=0, maxthreads=1024)
            copy = (; kind=:copy, name="copyto!", bytes=1024)
            names = ["[MTLDevice newBufferWithLength:options:]", "[MTLCommandBuffer commit]",
                     "[MTLDevice newBufferWithLength:options:]"]
            host = (name=names[1:2], calls=[2, 1], time=[2e-6, 1e-6])
            host_trace = (id=[1, 2, 3], start=[1e-6, 2e-6, 3e-6], time=[1e-6, 1e-6, 1e-6],
                          tid=[1, 1, 2], name=names)
            device = (name=["kernel", "copyto!"], start=[1e-6, 3e-6], stop=[2e-6, 4e-6],
                      ops=[Any[kernel], Any[copy]])
            single_threaded_host_trace = map(col -> col[1:2], host_trace)
            kernels_only = (name=["kernel", "kernel"], start=[1e-6, 3e-6], stop=[2e-6, 4e-6],
                            ops=[Any[kernel], Any[kernel]])
            for (host_trace, device) in ((host_trace, device),
                                         (single_threaded_host_trace, kernels_only)),
                trace in (false, true)
                r = Profiling.ProfileResults(; device, host, host_trace, trace_start=0.0,
                                             wall=1e-5, trace, raw=false)
                show(IOContext(IOBuffer(), :limit => true), MIME"text/plain"(), r)
            end
        end

        # exercise MtlArray creation and host↔device copy paths in both 1D and 2D
        for h in (Float32[0], Float32[0;;], [0])
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
        @static if VERSION >= v"1.11"; if command_api_supported
            let a = MtlArray([1, 2, 3])
                Array(a .+ 1)
            end
            # a kernel with bounds checks, which links the exception runtime
            let a = MtlArray(Float32[1, 2, 3])
                @metal threads=3 precompile_kernel(a)
                synchronize()
            end
            Array(rand(Float32, 3))
            Array(rand(Float32, 2, 2))
            let a = MtlArray(Float32[1, 2, 3])
                a .+ 1f0
                sum(a)
                sum(reshape(a, 3, 1); dims=1)   # a dimensioned reduction kernel
                synchronize()
            end
            # matrix multiplication, both with the GPUArrays generic-matmul kernels and
            # with MPSGraph (whose framework `__init__` loads at run time)
            let a = MtlArray(Int32[1 2; 3 4])
                LinearAlgebra.mul!(similar(a), a, a)
                synchronize()
            end
            load_framework("MetalPerformanceShadersGraph")
            let a = MtlArray(Float32[1 2; 3 4])
                Array(a * a)
            end
        end; end
    end

    # Caches populated by the workload hold ObjectiveC handles whose underlying
    # objects only exist in the precompilation process; serializing those into
    # the package image yields dangling pointers when the image is loaded. Drop
    # the entries before precompilation finalizes.
    Base.@lock compiler_configs_lock empty!(_compiler_configs)
    Base.@lock global_queues_lock empty!(global_queues)
    Base.@lock batched_queues_lock empty!(batched_queues)
    empty!(queue_residency_sets)
    Base.@lock device_residencies_lock empty!(device_residencies)
    Base.@lock memory_pressure_stats_lock empty!(_memory_pressure_stats)
    empty!(device_malloc_bufs)
    empty!(MTL.last_committed_per_queue)
    empty!(MTL.submission_state_per_queue)
    empty!(device_exception_info)
    Base.@lock MPSGraphs.graph_cache_lock empty!(MPSGraphs.graph_cache)
end
