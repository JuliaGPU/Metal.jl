## gpucompiler interface implementation

struct MetalCompilerParams <: AbstractCompilerParams
    gpufamily::Union{Nothing, MTL.MTLGPUFamily}
end
const MetalCompilerConfig = CompilerConfig{MetalCompilerTarget, MetalCompilerParams}
const MetalCompilerJob = CompilerJob{MetalCompilerTarget, MetalCompilerParams}

GPUCompiler.runtime_module(::MetalCompilerJob) = Metal

GPUCompiler.method_table(::MetalCompilerJob) = method_table

GPUCompiler.kernel_state_type(job::MetalCompilerJob) = KernelState

# Metal 4 tensor ops (`mpp::tensor_ops`, see `device/intrinsics/tensor.jl`) lower to calls to
# externally-defined `__tensorops_impl_*` symbols, resolved by the Metal runtime's tensor-ops
# library at link time. They aren't `air.*` intrinsics, so whitelist them alongside the base
# Metal prefix to keep IR validation from rejecting them as unknown functions.
GPUCompiler.isintrinsic(@nospecialize(job::MetalCompilerJob), fn::String) =
    invoke(GPUCompiler.isintrinsic,
           Tuple{CompilerJob{MetalCompilerTarget}, String}, job, fn) ||
    startswith(fn, "__tensorops_")

function GPUCompiler.finish_module!(@nospecialize(job::MetalCompilerJob),
                                    mod::LLVM.Module, entry::LLVM.Function)
    entry = invoke(GPUCompiler.finish_module!,
                   Tuple{CompilerJob{MetalCompilerTarget}, LLVM.Module, LLVM.Function},
                   job, mod, entry)

    # annotate Metal 4 tensor-ops runtime functions as externally defined, for the validator
    for f in functions(mod)
        if isdeclaration(f) && startswith(LLVM.name(f), "__tensorops_impl_")
            section!(f, "air.externally_defined")
            push!(function_attributes(f), EnumAttribute("convergent"))
        end
    end

    # if this kernel uses our RNG, we should prime the shared state.
    # XXX: these transformations should really happen at the Julia IR level...
    if job.config.kernel && haskey(globals(mod), "global_random_keys")
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
        top_bb = first(blocks(entry))
        bb = BasicBlock(top_bb, "initialize_rng")
        @dispose builder=IRBuilder() begin
            position!(builder, bb)
            subprogram = LLVM.subprogram(entry)
            if subprogram !== nothing
                loc = DILocation(0, 0, subprogram)
                debuglocation!(builder, loc)
            end
            debuglocation!(builder, first(instructions(top_bb)))

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
            deferred_codegen = if haskey(functions(mod), "deferred_codegen")
                functions(mod)["deferred_codegen"]
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

# the statically-known integer in lane `i` of a vector value, or `nothing` if that lane
# isn't a compile-time constant. looks through the `insertelement` chains and constant
# vectors that the simdgroup intrinsics build their dims/strides operands from.
function static_vector_lane(v::LLVM.Value, i::Integer)
    if v isa LLVM.InsertElementInst
        base, elt, idx = operands(v)
        idx isa LLVM.ConstantInt || return nothing  # unknown insert position
        if convert(Int, idx) == i
            return elt isa LLVM.ConstantInt ? convert(Int, elt) : nothing
        end
        return static_vector_lane(base, i)  # this lane is untouched by the insert
    end
    elref = LLVM.API.LLVMGetAggregateElement(v, UInt32(i))
    elref == C_NULL && return nothing
    el = LLVM.Value(elref)
    return el isa LLVM.ConstantInt ? convert(Int, el) : nothing
end

# Follow bitcasts / zero-offset GEPs / address-space casts back to the object a pointer
# ultimately refers to.
function trace_to_alloca(v::LLVM.Value)
    while true
        if v isa LLVM.AllocaInst
            return v
        elseif v isa LLVM.BitCastInst || v isa LLVM.AddrSpaceCastInst
            v = first(operands(v))
        elseif v isa LLVM.GetElementPtrInst &&
               all(idx -> idx isa LLVM.ConstantInt && iszero(convert(Int, idx)),
                   operands(v)[2:end])
            v = first(operands(v))
        else
            return nothing
        end
    end
end

function trace_to_global(v::LLVM.Value)
    while true
        if v isa LLVM.GlobalVariable
            return v
        elseif v isa LLVM.BitCastInst || v isa LLVM.AddrSpaceCastInst
            v = first(operands(v))
        elseif v isa LLVM.GetElementPtrInst &&
               all(idx -> idx isa LLVM.ConstantInt && iszero(convert(Int, idx)),
                   operands(v)[2:end])
            v = first(operands(v))
        else
            return nothing
        end
    end
end

function is_tensor_op_descriptor_constant(gv::LLVM.GlobalVariable)
    # Shader Validation faults if tensor-op descriptors are copied out of AIR's
    # constant address space, so leave just those descriptor globals in AS0.
    mod = LLVM.parent(gv)
    descriptor_allocas = Set{LLVM.API.LLVMValueRef}()
    for f in functions(mod)
        startswith(LLVM.name(f), "__tensorops_impl_matmul2d_op_run_") || continue
        for u in uses(f)
            call = user(u)
            call isa LLVM.CallInst || continue
            args = collect(arguments(call))
            isempty(args) && continue
            storage = trace_to_alloca(args[1])
            storage === nothing && continue
            push!(descriptor_allocas, Base.unsafe_convert(LLVM.API.LLVMValueRef, storage))
        end
    end
    isempty(descriptor_allocas) && return false

    gv_key = Base.unsafe_convert(LLVM.API.LLVMValueRef, gv)
    for f in functions(mod), bb in blocks(f), inst in instructions(bb)
        inst isa LLVM.CallInst || continue
        callee = called_operand(inst)
        callee isa LLVM.Function || continue
        startswith(LLVM.name(callee), "llvm.memcpy.") || continue

        args = collect(arguments(inst))
        length(args) == 4 || continue
        dst = trace_to_alloca(args[1])
        dst === nothing && continue
        key = Base.unsafe_convert(LLVM.API.LLVMValueRef, dst)
        key in descriptor_allocas || continue

        src = trace_to_global(args[2])
        src === nothing && continue
        Base.unsafe_convert(LLVM.API.LLVMValueRef, src) == gv_key || continue
        return true
    end

    return false
end

function GPUCompiler.metal_global_constant_addrspace(
    @nospecialize(job::MetalCompilerJob),
    @nospecialize(gv::LLVM.GlobalVariable))

    if is_tensor_op_descriptor_constant(gv)
        return 0
    end

    return invoke(GPUCompiler.metal_global_constant_addrspace,
                  Tuple{CompilerJob{MetalCompilerTarget}, LLVM.GlobalVariable},
                  job, gv)
end

function GPUCompiler.finish_ir!(@nospecialize(job::MetalCompilerJob),
                                    mod::LLVM.Module, entry::LLVM.Function)
    entry = invoke(GPUCompiler.finish_ir!,
                   Tuple{CompilerJob{MetalCompilerTarget}, LLVM.Module, LLVM.Function},
                   job, mod, entry)

    # downgrade intrinsics when targeting older AIR versions
    if job.config.target.air < v"2.8"
        # AIR 2.8 generalized the simdgroup matrix load/store intrinsics, replacing
        # the elements-per-row scalar, matrix origin, and transposition flag with
        # vectors describing the dimensions, strides and origin of the memory operand,
        # with transposition expressed by swapping those vectors' elements (see
        # `simdgroup_load/store` in src/device/intrinsics/simd.jl). recover the legacy
        # operands from the 2.8 layout: the elements-per-row is the non-unit stride, the
        # transpose flag is statically recovered from which stride is unit (the legacy
        # intrinsic needs it as an immediate), and the transposed layout's swapped origin
        # is unswapped back.
        for f in collect(functions(mod))
            fn = LLVM.name(f)
            m = match(r"^air\.simdgroup_matrix_8x8_(load|store)\.", fn)
            m === nothing && continue
            is_load = m.captures[1] == "load"

            calls = [user(u) for u in uses(f)]
            @assert all(call -> call isa LLVM.CallInst, calls)

            # construct the legacy function type
            T_i64 = LLVM.Int64Type()
            T_vec2 = LLVM.VectorType(T_i64, 2)
            T_bool = LLVM.Int1Type()
            new_ft = function_type(f)
            old_params = if is_load
                # value pointer; elements per row; origin; transpose
                [parameters(new_ft)[1], T_i64, T_vec2, T_bool]
            else
                # value; value pointer; elements per row; origin; transpose
                [parameters(new_ft)[1:2]..., T_i64, T_vec2, T_bool]
            end
            old_ft = LLVM.FunctionType(LLVM.return_type(new_ft), old_params)

            # redeclare the function and rewrite its calls
            LLVM.name!(f, fn * ".air28")
            old_f = LLVM.Function(mod, fn, old_ft)
            # carry over the attributes (convergent etc.); they were attached before
            # optimization, so GPUCompiler won't re-derive them for this declaration
            for attr in collect(function_attributes(f))
                push!(function_attributes(old_f), attr)
            end
            for call in calls
                @dispose builder=IRBuilder() begin
                    position!(builder, call)
                    debuglocation!(builder, call)

                    args = collect(arguments(call))
                    prefix = is_load ? args[1:1] : args[1:2]
                    _, strides, origin = args[end-2:end]

                    # the transposed layout has a unit stride in the second dimension;
                    # the non-transposed one in the first. one of the two is always the
                    # literal 1, so this is statically decidable.
                    transposed = static_vector_lane(strides, 1) == 1
                    @assert transposed || static_vector_lane(strides, 0) == 1 """
                        unexpected simdgroup matrix strides $(strides); the AIR downgrade \
                        only handles the transposed and non-transposed column-major layouts \
                        emitted by `simdgroup_load`/`simdgroup_store`"""

                    # elements per row is the non-unit (leading-dimension) stride
                    epr = extract_element!(builder, strides,
                                           ConstantInt(Int32(transposed ? 0 : 1)))

                    # the transposed layout emits a row/column-swapped origin; unswap it
                    # for the legacy form, which leaves the non-transposed origin as-is
                    legacy_origin = origin
                    if transposed
                        o1 = extract_element!(builder, origin, ConstantInt(Int32(0)))
                        o2 = extract_element!(builder, origin, ConstantInt(Int32(1)))
                        legacy_origin = insert_element!(builder, UndefValue(T_vec2), o2,
                                                        ConstantInt(Int32(0)))
                        legacy_origin = insert_element!(builder, legacy_origin, o1,
                                                        ConstantInt(Int32(1)))
                    end

                    new_call = call!(builder, old_ft, old_f,
                                     [prefix..., epr, legacy_origin,
                                      ConstantInt(T_bool, transposed)])
                    replace_uses!(call, new_call)
                    erase!(call)
                end
            end

            @assert isempty(uses(f))
            erase!(f)
        end
    end

    # pointer type information for typed intrinsics
    # (this is consumed by the LLVM IR downgrader)
    for (jltyp, llvmtyp) in (Int32 => :i32, Int64 => :i64,
                             Float16 => :f16, Float32 => :f32,
                             BFloat16 => :bf16),
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
            haskey(functions(mod), fn) || continue
            f = functions(mod)[fn]
            mds = []
            for (idx, typ) in args
                push!(mds, ConstantInt(Int32(idx-1)))
                push!(mds, null(convert(LLVMType, typ)))
            end
            metadata(f)["arg_eltypes"] = MDNode(mds)
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
                                         debug_level=Base.JLOptions().debug_level,
                                         opt_level=2,
                                         macos=nothing, air=nothing, metal=nothing,
                                         gpufamily=nothing, kwargs...)
    # determine the versions of things to target
    if macos === nothing
        macos = macos_version()
    else
        macos = normalize_macos(macos)
    end
    if metal === nothing
        metal = metal_target(macos)
    end
    if air === nothing
        air = air_target(macos)
        if air < v"2.6"
            error("""Metal.jl requires AIR 2.6 (macOS 14) or newer, but macOS $(macos) only supports AIR $(air_support(macos)).""")
        end
    elseif air < v"2.6"
        error("""Metal.jl requires AIR 2.6 (macOS 14) or newer; cannot target AIR $(air).""")
    end
    if gpufamily === nothing
        highest_family = MTL.highest_apple_family(device())
        gpufamily = isnothing(highest_family) ? nothing : MTL.MTLGPUFamily(1000 | highest_family)
    end

    # create GPUCompiler objects
    target = MetalCompilerTarget(; macos, air, metal, kwargs...)
    params = MetalCompilerParams(gpufamily)
    CompilerConfig(target, params; kernel, name, always_inline, debug_level, opt_level)
end

# Persist compilation artifacts so they can be retrieved off-machine (e.g. from CI).
# Writes the files (their paths go in the error message) and, on a CI runner, makes
# them retrievable:
#  - Buildkite: uploaded in-process via `buildkite-agent artifact upload`.
#  - GitHub Actions: there is no in-process upload equivalent, so the files are
#    dropped in a predictable directory for an `actions/upload-artifact` step (run
#    it with `if: always()`) to collect, and that directory is surfaced as a
#    workflow notice.
# Set `JULIA_METAL_DUMP_DIR` to force a deterministic destination (handy for CI or
# local debugging); otherwise GitHub Actions uses $RUNNER_TEMP/metal-compilation-dumps
# and everything else uses a temp directory.
# Used both on a compilation error (the catch blocks below) and, when
# `JULIA_METAL_DUMP_DIR` is set, unconditionally for every kernel.
# `artifacts` are `extension => data` pairs sharing one base name, e.g.
# `dump_artifacts(".ll" => ir, ".air" => air)`.
function dump_artifacts(artifacts::Pair{String}...)
    on_github = get(ENV, "GITHUB_ACTIONS", "false") == "true"
    dir = if haskey(ENV, "JULIA_METAL_DUMP_DIR")
        mkpath(ENV["JULIA_METAL_DUMP_DIR"])
    elseif on_github
        mkpath(joinpath(get(ENV, "RUNNER_TEMP", tempdir()), "metal-compilation-dumps"))
    else
        tempdir()
    end
    stem = tempname(dir; cleanup=false)

    paths = String[]
    for (ext, data) in artifacts
        path = stem * ext
        write(path, data)
        push!(paths, path)
    end

    if parse(Bool, get(ENV, "BUILDKITE", "false"))
        for path in paths
            run(`buildkite-agent artifact upload $path`)
        end
    elseif on_github
        println("::notice title=Metal compilation dump::wrote $(join(basename.(paths), ", ")) to $dir")
    end

    return paths
end

# compile to executable machine code
function compile(@nospecialize(job::CompilerJob))
    @signpost_event log=log_compiler() "Compile" "Job=$job"

    # TODO: on 1.9, this actually creates a context. cache those.
    ir, air, entry, loggingEnabled = JuliaContext() do ctx
        @signpost_interval log=log_compiler() "Generate LLVM IR" begin
            mod, meta = invoke_frozen(GPUCompiler.compile, :llvm, job)
        end

        # GPU logging is emitted as the `air.os_log` intrinsic, which requires Metal 3.2
        # (macOS 15). check for it *here*, after optimization, rather than during macro
        # expansion: that way version-gated logging (e.g. `metal_version() >= sv"3.2" &&
        # @mtlprintln(...)`) compiles fine for older targets, because the dead `os_log`
        # call has already been eliminated and won't trip this check.
        loggingEnabled = haskey(functions(mod), "air.os_log")
        if loggingEnabled && job.config.target.metal < v"3.2"
            error("""GPU logging (`@mtlprintf`, `@mtlprint`, `@mtlprintln`, `@mtlshow`) requires \
                     macOS 15 / Metal 3.2 or newer, but this kernel targets Metal $(job.config.target.metal) \
                     (macOS $(job.config.target.macos)). To keep targeting older versions, guard logging \
                     calls behind `metal_version() >= sv"3.2"`.""")
        end

        # 64-bit atomic modify intrinsics (`atomic_{min,max}_explicit` on `atomic_ulong`)
        # require the newer Apple GPU families that implement this optional feature.
        has_i64_atomic_modify =
            haskey(functions(mod), "air.atomic.global.min.u.i64") ||
            haskey(functions(mod), "air.atomic.global.max.u.i64")
        if has_i64_atomic_modify && (is_nothing(job.config.params.gpufamily) ||
           job.config.params.gpufamily < MTL.MTLGPUFamilyApple8)
            error("""64-bit atomic modify intrinsics (`atomic_min_explicit`/`atomic_max_explicit` on `UInt64`) \
                     require `MTLGPUFamilyApple8` (M2 or newer). Guard usage with \
                     `MTL.supports_family(device(), MTL.MTLGPUFamilyApple8)`.""")
        end

        @signpost_interval log=log_compiler() "Downgrade to AIR" begin
            # generate AIR, having GPUCompiler lower the IR to AIR-compatible form and
            # invoke the LLVM downgrader (both as part of Metal's `mcgen`)
            air = try
                air, _ = invoke_frozen(GPUCompiler.emit_asm, job, mod,
                                       LLVM.API.LLVMObjectFile)
                air
            catch err
                # `emit_asm` has already lowered the module in-place, so stringifying it
                # here shows exactly what the downgrader was fed
                ir_file, = dump_artifacts(".ll" => string(mod))
                error("""Compilation to AIR failed: $(sprint(showerror, err))
                         If you think this is a bug, please file an issue and attach $(ir_file)""")
            end
        end

        string(mod), air, LLVM.name(meta.entry), loggingEnabled
    end

    @signpost_interval log=log_compiler() "Create Metal library" begin
        metallib = try
            fun = MetalLibFunction(; name=entry, air_module=air,
                                     air_version=job.config.target.air,
                                     metal_version=job.config.target.metal)
            lib = MetalLib(; functions = [fun],
                             file_version = metallib_target(job.config.target.macos),
                             platform_version = job.config.target.macos,
                             uuid = content_uuid(air))

            io = IOBuffer()
            write(io, lib)
            take!(io)
        catch err
            ir_file, air_file = dump_artifacts(".ll" => ir, ".air" => air)
            error("""Compilation to Metal library failed; see below for details.
                     If you think this is a bug, please file an issue and attach the following files:
                     - $(ir_file)
                     - $(air_file)""")
        end
    end

    # when `JULIA_METAL_DUMP_DIR` is set, dump every compiled kernel's artifacts
    if haskey(ENV, "JULIA_METAL_DUMP_DIR")
        dump_artifacts(".ll" => ir, ".air" => air, ".metallib" => metallib)
    end

    return (; ir, air, metallib, entry, loggingEnabled)
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

            # the back-end compiler likely failed
            # XXX: check more accurately? the error domain doesn't help much here
            ir_file, air_file, metallib_file =
                dump_artifacts(".ll" => compiled.ir, ".air" => compiled.air,
                               ".metallib" => compiled.metallib)
            error("""Compilation to native code failed; see below for details.
                     If you think this is a bug, please file an issue and attach the following files:
                     - $(ir_file)
                     - $(air_file)
                     - $(metallib_file)""")
        end
    end

    pipeline_state, compiled.loggingEnabled
end
