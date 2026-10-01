## gpucompiler interface implementation

struct MetalCompilerParams <: AbstractCompilerParams end
const MetalCompilerConfig = CompilerConfig{MetalCompilerTarget, MetalCompilerParams}
const MetalCompilerJob = CompilerJob{MetalCompilerTarget, MetalCompilerParams}

GPUCompiler.runtime_module(::MetalCompilerJob) = Metal

GPUCompiler.method_table(::MetalCompilerJob) = method_table

GPUCompiler.kernel_state_type(job::MetalCompilerJob) = KernelState

function GPUCompiler.finish_module!(@nospecialize(job::MetalCompilerJob),
                                    mod::LLVM.Module, entry::LLVM.Function)
    entry = invoke(GPUCompiler.finish_module!,
                   Tuple{CompilerJob{MetalCompilerTarget}, LLVM.Module, LLVM.Function},
                   job, mod, entry)

    # if this kernel uses our RNG, we should prime the shared state.
    # XXX: these transformations should really happen at the Julia IR level...
    if job.config.kernel && haskey(mod.globals, "global_random_keys")
        f = initialize_rng_state
        ft = typeof(f)
        tt = Tuple{}

        # create a deferred compilation job for `initialize_rng_state()`
        src = methodinstance(ft, tt, GPUCompiler.tls_world_age())
        cfg = CompilerConfig(job.config; kernel=false, name=nothing)
        job = CompilerJob(src, cfg, job.world)
        id = length(GPUCompiler.deferred_codegen_jobs) + 1
        GPUCompiler.deferred_codegen_jobs[id] = job

        # generate IR for calls to `deferred_codegen` and the resulting function pointer
        top_bb = entry.entry
        bb = BasicBlock(LLVM.before(top_bb), "initialize_rng")
        @dispose builder=IRBuilder() begin
            position!(builder, LLVM.at_end(bb))
            subprogram = entry.subprogram
            if subprogram !== nothing
                builder.debug_location = DILocation(0, 0, subprogram)
            end

            # call the `deferred_codegen` marker function
            T_ptr = if LLVM.version() >= v"17"
                LLVM.PointerType()
            elseif VERSION >= v"1.12.0-DEV.225"
                LLVM.PointerType(LLVM.Int8Type())
            else
                LLVM.Int64Type()
            end
            T_id = convert(LLVMType, Int)
            deferred_codegen_ft = LLVM.FunctionType(T_ptr, [T_id])
            deferred_codegen = if haskey(mod.functions, "deferred_codegen")
                mod.functions["deferred_codegen"]
            else
                LLVM.Function(mod, "deferred_codegen", deferred_codegen_ft)
            end
            fptr = call!(builder, deferred_codegen_ft, deferred_codegen, [ConstantInt(id)])

            # call the `initialize_rng_state` function
            rt = Core.Compiler.return_type(f, tt)
            llvm_rt = convert(LLVMType, rt)
            llvm_ft = LLVM.FunctionType(llvm_rt)
            fptr = inttoptr!(builder, fptr, LLVM.PointerType(llvm_ft))
            call!(builder, llvm_ft, fptr)
            br!(builder, top_bb)
        end

        # XXX: put some of the above behind GPUCompiler abstractions
        #      (e.g., a compile-time version of `deferred_codegen`)
    end
    return entry
end

function GPUCompiler.finish_ir!(@nospecialize(job::MetalCompilerJob),
                                    mod::LLVM.Module, entry::LLVM.Function)
    entry = invoke(GPUCompiler.finish_ir!,
                   Tuple{CompilerJob{MetalCompilerTarget}, LLVM.Module, LLVM.Function},
                   job, mod, entry)

    # pointer type information for typed intrinsics
    # (this is consumed by the LLVM IR downgrader)
    for (jltyp, llvmtyp) in (Int32 => :i32, Int64 => :i64,
                             Float16 => :f16, Float32 => :f32),
        (as, asname) in (AS.Device => "global", AS.ThreadGroup => "local")

        # map of intrinsics to pointer operand indices and eltypes
        intrinsics = Dict()
        ## simd
        intrinsics["simdgroup_matrix_8x8_load.v64$llvmtyp.p$as$llvmtyp"] = (1 => jltyp,)
        intrinsics["simdgroup_matrix_8x8_store.v64$llvmtyp.p$as$llvmtyp"] = (2 => jltyp,)
        ## atomics
        for op in [:store, :load, :xchg, :add, :sub, :min, :max, :and, :or, :xor]
            intrinsics["atomic.$asname.$op.$llvmtyp"] = (1 => jltyp,)
        end
        intrinsics["atomic.$asname.cmpxchg.weak.$llvmtyp"] = (1 => jltyp, 2 => jltyp)

        # apply metadata to the function declarations
        for (intr, args) in intrinsics
            fn = "air.$intr"
            haskey(mod.functions, fn) || continue
            f = mod.functions[fn]
            mds = []
            for (idx, typ) in args
                push!(mds, ConstantInt(Int32(idx-1)))
                push!(mds, null(convert(LLVMType, typ)))
            end
            f.metadata["arg_eltypes"] = MDNode(mds)
        end
    end

    return entry
end


## compiler implementation (cache, configure, compile, and link)

# cache of compilation caches, per device
const _compiler_caches = Dict{MTLDevice, Dict{Any, Any}}()
function compiler_cache(ctx::MTLDevice)
    cache = get(_compiler_caches, ctx, nothing)
    if cache === nothing
        cache = Dict{Any, Any}()
        _compiler_caches[ctx] = cache
    end
    return cache
end

# cache of compiler configurations, per device (but additionally configurable via kwargs)
const _toolchain = Ref{Any}()
const _compiler_configs = Dict{UInt, MetalCompilerConfig}()
function compiler_config(dev; kwargs...)
    h = hash(dev, hash(kwargs))
    config = get(_compiler_configs, h, nothing)
    if config === nothing
        config = _compiler_config(dev; kwargs...)
        _compiler_configs[h] = config
    end
    return config
end
@noinline function _compiler_config(dev; kernel=true, name=nothing, always_inline=false,
                                         macos=nothing, air=nothing, metal=nothing,
                                         kwargs...)
    # determine the versions of things to target
    if macos === nothing
        macos = macos_version()
    end
    if metal === nothing
        metal = metal_support()
    end
    if air === nothing
        # we support down to macOS 13, which supports AIR 2.5
        # so always target that version for now
        air = v"2.5"
        @assert air <= air_support()
    end

    # create GPUCompiler objects
    target = MetalCompilerTarget(; macos, air, metal, kwargs...)
    params = MetalCompilerParams()
    CompilerConfig(target, params; kernel, name, always_inline)
end

# compile to executable machine code
function compile(@nospecialize(job::CompilerJob))
    @signpost_event log=log_compiler() "Compile" "Job=$job"

    # TODO: on 1.9, this actually creates a context. cache those.
    ir, air, entry = JuliaContext() do ctx
        @signpost_interval log=log_compiler() "Generate LLVM IR" begin
            mod, meta = GPUCompiler.compile(:llvm, job)
        end

        @signpost_interval log=log_compiler() "Downgrade to AIR" begin
            # generate AIR, having GPUCompiler lower the IR to AIR-compatible form and
            # invoke the LLVM downgrader (both as part of Metal's `mcgen`)
            air = try
                air, _ = GPUCompiler.emit_asm(job, mod, LLVM.API.LLVMObjectFile)
                air
            catch err
                # `emit_asm` has already lowered the module in-place, so stringifying it
                # here shows exactly what the downgrader was fed
                ir_file = tempname(cleanup=false) * ".ll"
                write(ir_file, string(mod))
                if parse(Bool, get(ENV, "BUILDKITE", "false"))
                    run(`buildkite-agent artifact upload $(ir_file)`)
                end
                error("""Compilation to AIR failed: $(sprint(showerror, err))
                         If you think this is a bug, please file an issue and attach $(ir_file)""")
            end
        end

        string(mod), air, meta.entry.name
    end

    @signpost_interval log=log_compiler() "Create Metal library" begin
        metallib = try
            fun = MetalLibFunction(; name=entry, air_module=air,
                                     air_version=job.config.target.air,
                                     metal_version=job.config.target.metal)
            lib = MetalLib(; functions = [fun])

            io = IOBuffer()
            write(io, lib)
            take!(io)
        catch err
            ir_file = tempname(cleanup=false) * ".ll"
            write(ir_file, ir)
            air_file = tempname(cleanup=false) * ".air"
            write(air_file, air)
            if parse(Bool, get(ENV, "BUILDKITE", "false"))
                run(`buildkite-agent artifact upload $(ir_file)`)
                run(`buildkite-agent artifact upload $(air_file)`)
            end
            error("""Compilation to Metal library failed; see below for details.
                     If you think this is a bug, please file an issue and attach the following files:
                     - $(ir_file)
                     - $(air_file)""")
        end
    end

    return (; ir, air, metallib, entry)
end

# link into an executable kernel
@autoreleasepool function link(@nospecialize(job::CompilerJob), compiled)
    @signpost_event log=log_compiler() "Link" "Job=$job"

    @signpost_interval log=log_compiler() "Instantiate compute pipeline" begin
        dev = device()
        lib = MTLLibraryFromData(dev, compiled.metallib)
        fun = MTLFunction(lib, compiled.entry)
        pipeline_state = try
            MTLComputePipelineState(dev, fun)
        catch err
            isa(err, NSError) || rethrow()
            retain(err)

            # the back-end compiler likely failed
            # XXX: check more accurately? the error domain doesn't help much here
            ir_file = tempname(cleanup=false) * ".ll"
            write(ir_file, compiled.ir)
            air_file = tempname(cleanup=false) * ".air"
            write(air_file, compiled.air)
            metallib_file = tempname(cleanup=false) * ".metallib"
            write(metallib_file, compiled.metallib)
            if parse(Bool, get(ENV, "BUILDKITE", "false"))
                run(`buildkite-agent artifact upload $(ir_file)`)
                run(`buildkite-agent artifact upload $(air_file)`)
                run(`buildkite-agent artifact upload $(metallib_file)`)
            end
            error("""Compilation to native code failed; see below for details.
                     If you think this is a bug, please file an issue and attach the following files:
                     - $(ir_file)
                     - $(air_file)
                     - $(metallib_file)""")
        end
    end

    pipeline_state
end
