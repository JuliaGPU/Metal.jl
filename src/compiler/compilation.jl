## gpucompiler interface implementation

struct MetalCompilerParams <: AbstractCompilerParams
    # Highest targeted MTLGPUFamilyApple<n>, or 0 if the device reports none.
    apple_family::Int
end
const MetalCompilerConfig = CompilerConfig{MetalCompilerTarget, MetalCompilerParams}
const MetalCompilerJob = CompilerJob{MetalCompilerTarget, MetalCompilerParams}

"""
    MetalResults

Cached compilation results for a Metal kernel job, managed by
`GPUCompiler.cached_results`. The fields partition by *pipeline stage*:

- `air`: AIR bitcode produced by the LLVM-downgrader from the post-irgen LLVM IR.
  The input to the Metal library wrapper. Session-portable; retained for diagnostics
  when the host-side Metal pipeline creation fails.
- `metallib` + `entry` + `loggingEnabled`: library-wrapped AIR bytes and launch
  metadata — the final session-portable artifacts. `metallib === nothing` identifies
  a job that has not been compiled yet (see `compile_or_lookup` in `execution.jl`).
- `relocations`: the kernel's relocation manifest, or `nothing` when it carries none
  (the common case). Session-portable — its `JuliaValueRef`/`CGlobalRef` targets are
  serializable and resolved per-session by the loader — so a relocation-carrying kernel
  now persists into package images too. The resolved words travel to the device in a
  buffer whose address the `KernelState` carries; see `reloc_table_buffer`.
- `pipelines`: session-local cache of `(MTLDevice, MTLComputePipelineState)` pairs
  resulting from the host-side link of `metallib` onto a device. Never populated
  during precompilation, so package images only carry the portable fields.
- `reloc_tables`: session-local cache of the per-device relocation-word buffers, keyed
  the same way and populated under the same rule.

The cache partition (via `GPUCompiler.cache_owner`) already covers the macOS / AIR /
Metal versions that affect codegen, and results are further keyed by the full
`CompilerConfig` (including e.g. the debug level). The only runtime-visible dimension
left in `pipelines` is the `MTLDevice` itself. A linear scan with `===` is fastest
in the common case (n=1, single device per process) and remains cheap when multiple
GPUs are addressed (e.g. integrated + discrete on a Mac).
"""
mutable struct MetalResults
    # session-portable artifacts
    air::Union{Nothing, Vector{UInt8}}
    metallib::Union{Nothing, Vector{UInt8}}
    entry::Union{Nothing, String}
    loggingEnabled::Union{Nothing, Bool}
    relocations::Union{Nothing, GPUCompiler.Relocations}
    # host-side objects (session-local)
    pipelines::Vector{Tuple{MTLDevice, MTLComputePipelineState}}
    reloc_tables::Vector{Tuple{MTLDevice, MTLBuffer}}
    MetalResults() = new(nothing, nothing, nothing, nothing, nothing,
                         Tuple{MTLDevice, MTLComputePipelineState}[],
                         Tuple{MTLDevice, MTLBuffer}[])
end

GPUCompiler.runtime_module(::MetalCompilerJob) = Metal

GPUCompiler.method_table(::MetalCompilerJob) = method_table

# Metal does not support double precision, so also use GPUToolbox's overrides that keep
# single-precision math out of Float64.
GPUCompiler.method_tables(::MetalCompilerJob) =
    (method_table, GPUToolbox.Overlays.float64_overrides)

GPUCompiler.kernel_state_type(job::MetalCompilerJob) = KernelState

# Keep relocations symbolic. Most kernels are relocation-free, so their metallib is
# byte-stable across sessions, which restores pkgimage persistence (`can_persist_results`)
# and lets Metal's shader cache, keyed on the library contents, hit across sessions. Kernels
# that reference a type tag or `isa`-test a boxed value do carry records; Metal has no
# post-load symbol patching, so under `:table` GPUCompiler rewrites each of them into an
# indexed load from a table of words the loader delivers as ordinary run-time data — a small
# buffer whose device address the `KernelState` carries (see `reloc_table_buffer` and
# `GPUCompiler.relocation_table_pointer` for the Metal target). Nothing session-local
# reaches the metallib, so these kernels are byte-stable and persist across sessions too.
#
# The lowering (and the box demotion it relies on) needs LLVM.jl's
# `convert_users_to_instructions!`, available on LLVM 17+ (Julia 1.12+) only; older versions
# fall back to session-local `:bake` resolution and forgo persistence. So do non-kernel jobs,
# which have no kernel state to reach a table through: those exist only to be read
# (`Metal.code_air` and friends), never launched or cached, so a session-local resolution is
# all they need.
GPUCompiler.relocation_lowering(@nospecialize(job::MetalCompilerJob)) =
    (job.config.kernel && LLVM.version() >= v"17") ? (:table) : (:bake)

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
    # Materialize apple_family() before GPUCompiler optimizes the linked module.
    gv = get(mod.globals, "apple_family", nothing)
    if gv !== nothing
        gv.initializer = ConstantInt(LLVM.Int32Type(), job.config.params.apple_family)
        gv.linkage = LLVM.Linkage.Private
    end

    entry = invoke(GPUCompiler.finish_module!,
                   Tuple{CompilerJob{MetalCompilerTarget}, LLVM.Module, LLVM.Function},
                   job, mod, entry)

    # annotate Metal 4 tensor-ops runtime functions as externally defined, for the validator
    for f in mod.functions
        if isdeclaration(f) && startswith(f.name, "__tensorops_impl_")
            f.section = "air.externally_defined"
            push!(f.function_attributes, EnumAttribute(:convergent))
        end
    end

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
            # (declared like GPUCompiler's `ccall("extern deferred_codegen", llvmcall, Ptr{Cvoid}, ...)`)
            T_ptr = convert(LLVMType, Ptr{Cvoid})
            T_id = convert(LLVMType, Int)
            deferred_codegen_ft = LLVM.FunctionType(T_ptr, [T_id])
            deferred_codegen = get!(mod.functions, "deferred_codegen") do
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
        base, elt, idx = v.operands
        idx isa LLVM.ConstantInt || return nothing  # unknown insert position
        if convert(Int, idx) == i
            return elt isa LLVM.ConstantInt ? convert(Int, elt) : nothing
        end
        return static_vector_lane(base, i)  # this lane is untouched by the insert
    end
    # (lanes of other values, including undef and poison vectors, aren't known integers)
    v isa Union{LLVM.ConstantVector, LLVM.ConstantDataVector,
                LLVM.ConstantAggregateZero} || return nothing
    el = get(v.elements, i+1, nothing)
    return el isa LLVM.ConstantInt ? convert(Int, el) : nothing
end

function is_tensor_op_descriptor_constant(gv::LLVM.GlobalVariable)
    # Shader Validation faults if tensor-op descriptors are copied out of AIR's
    # constant address space, so leave just those descriptor globals in AS0.
    mod = gv.parent
    descriptor_allocas = Set{LLVM.Value}()
    for f in mod.functions
        startswith(f.name, "__tensorops_impl_matmul2d_op_run_") || continue
        for call in f.users
            call isa LLVM.CallInst || continue
            args = call.arguments
            isempty(args) && continue
            storage = strip_pointer_casts(args[1])
            storage isa LLVM.AllocaInst || continue
            push!(descriptor_allocas, storage)
        end
    end
    isempty(descriptor_allocas) && return false

    memcpys = (Intrinsic("llvm.memcpy"), Intrinsic("llvm.memcpy.inline"))
    for f in mod.functions, bb in f.blocks, inst in bb.instructions
        inst isa LLVM.CallInst || continue
        any(intr -> isintrinsic(inst.called_operand, intr), memcpys) || continue

        args = inst.arguments
        length(args) == 4 || continue
        strip_pointer_casts(args[1]) in descriptor_allocas || continue
        strip_pointer_casts(args[2]) == gv || continue
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
    # (GPUCompiler legalizes atomics, see `lower_atomics!`)
    ## simdgroup
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
        for f in collect(mod.functions)
            fn = f.name
            m = match(r"^air\.simdgroup_matrix_8x8_(load|store)\.", fn)
            m === nothing && continue
            is_load = m.captures[1] == "load"

            calls = collect(f.users)
            @assert all(call -> call isa LLVM.CallInst, calls)

            # construct the legacy function type
            T_i64 = LLVM.Int64Type()
            T_vec2 = LLVM.VectorType(T_i64, 2)
            T_bool = LLVM.Int1Type()
            new_ft = f.function_type
            old_params = if is_load
                # value pointer; elements per row; origin; transpose
                [new_ft.parameters[1], T_i64, T_vec2, T_bool]
            else
                # value; value pointer; elements per row; origin; transpose
                [new_ft.parameters[1:2]..., T_i64, T_vec2, T_bool]
            end
            old_ft = LLVM.FunctionType(new_ft.return_type, old_params)

            # redeclare the function and rewrite its calls
            f.name = fn * ".air28"
            old_f = LLVM.Function(mod, fn, old_ft)
            # carry over the attributes (convergent etc.); they were attached before
            # optimization, so GPUCompiler won't re-derive them for this declaration
            append!(old_f.function_attributes, f.function_attributes)
            for call in calls
                @dispose builder=IRBuilder() begin
                    # (positioning the builder gives it the call's debug location)
                    position!(builder, LLVM.before(call))

                    args = collect(call.arguments)
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

            @assert isempty(f.uses)
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

        # apply metadata to the function declarations
        for (intr, args) in intrinsics
            fn = "air.$intr"
            f = get(mod.functions, fn, nothing)
            f === nothing && continue
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


## compiler implementation (configure, compile, and link)

# cache of compiler configurations, per device (but additionally configurable via kwargs)
const _compiler_configs = Dict{UInt, MetalCompilerConfig}()
const compiler_configs_lock = ReentrantLock()
function compiler_config(dev; kwargs...)
    h = hash(dev, hash(kwargs))
    return Base.@lock compiler_configs_lock begin
        get!(_compiler_configs, h) do
            _compiler_config(dev; kwargs...)
        end
    end
end
@noinline function _compiler_config(dev; kernel=true, name=nothing, always_inline=false,
                                         debug_level=Base.JLOptions().debug_level,
                                         opt_level=2,
                                         macos=nothing, air=nothing, metal=nothing,
                                         gpufamily=nothing, minthreads=nothing, kwargs...)
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
        air = max(air_support(macos), air_floor(metal))
        if air < v"2.7"
            error("""Metal.jl requires AIR 2.7 (macOS 15) or newer, but macOS $(macos) only supports AIR $(air_support(macos)).""")
        end
    elseif air < v"2.7"
        error("""Metal.jl requires AIR 2.7 (macOS 15) or newer; cannot target AIR $(air).""")
    elseif air < air_floor(metal)
            error("""Metal $(metal) requires AIR $(air_floor(metal)) or newer; cannot target AIR $(air).""")
    end
    # Only Apple family values form the capability sequence used by device code.
    if gpufamily === nothing
        highest_family = MTL.highest_apple_family(dev)
        apple_family = something(highest_family, 0)
    else
        gpufamily = convert(MTL.MTLGPUFamily, gpufamily)
        apple_family = Int(gpufamily) - 1000
        if !(1 <= apple_family <= 10)
            throw(ArgumentError("gpufamily must be an MTLGPUFamilyApple<n>, got $(gpufamily)"))
        end
    end

    # minthreads is applied through MTLComputePipelineDescriptor.requiredThreadsPerThreadgroup,
    # which the runtime only provides on macOS 26, regardless of the targeted MSL version.
    # All-zero dimensions disable the requirement, and are normalized to `nothing`.
    if minthreads !== nothing
        if all(iszero, minthreads)
            minthreads = nothing
        elseif !all(>(0), minthreads)
            throw(ArgumentError("minthreads dimensions should be either all zero or all non-zero, got $(minthreads)"))
        elseif macos_version() < v"26"
            throw(ArgumentError("minthreads requires macOS 26 or newer; running macOS $(macos_version())"))
        end
    end

    # create GPUCompiler objects
    target = MetalCompilerTarget(; macos, air, metal, minthreads, kwargs...)
    params = MetalCompilerParams(apple_family)
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

# Run inference + LLVM codegen, downgrade to AIR, wrap in a Metal library.
# Returns the per-phase artifacts as a NamedTuple so the caller can hand them
# onto the cached `MetalResults`. All byte/string fields are session-portable.
const compilations = Threads.Atomic{Int}(0)
function compile_to_metallib(@nospecialize(job::CompilerJob))
    Threads.atomic_add!(compilations, 1)
    @signpost_event log=log_compiler() "Compile" "Job=$job"

    # TODO: on 1.9, this actually creates a context. cache those.
    ir, air, entry, loggingEnabled, relocations = JuliaContext() do _
        @signpost_interval log=log_compiler() "Generate LLVM IR" begin
            mod, meta = invoke_frozen(GPUCompiler.compile, :llvm, job)
        end

        # the IR belongs to us: lower and inspect it, then dispose of it
        @dispose mod=mod begin
            # Detect logging after optimization so dead logging calls do not enable log state.
            local loggingEnabled = haskey(mod.functions, "air.os_log")

            @signpost_interval log=log_compiler() "Downgrade to AIR" begin
                # generate AIR, having GPUCompiler lower the IR to AIR-compatible form and
                # invoke the LLVM downgrader (both as part of Metal's `mcgen`).
                #
                # Passing `meta.relocations` (the 4-arg `emit_asm`) is load-bearing: surviving
                # relocations (interned symbols, type tags, boxed non-smalltag constants) are then
                # rewritten into indexed loads from the kernel state's relocation table, and
                # `meta.relocations` is finalized into the manifest the loader resolves against.
                # The 3-arg form would hand the lowering an empty table and strand the slots.
                local air
                air, _ = try
                    invoke_frozen(GPUCompiler.emit_asm, job, mod, meta.relocations,
                                  LLVM.CodeGenFileType.Object)
                catch err
                    # `emit_asm` has already lowered the module in-place, so stringifying it
                    # here shows exactly what the downgrader was fed
                    ir_file, = dump_artifacts(".ll" => string(mod))
                    error("""Compilation to AIR failed: $(sprint(showerror, err))
                             If you think this is a bug, please file an issue and attach $(ir_file)""")
                end
            end

            string(mod), air, meta.entry.name, loggingEnabled, meta.relocations
        end
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

    # `nothing` marks a relocation-free kernel (the common case), keeping its `MetalResults`
    # and package-image footprint identical to before.
    return (; air, metallib, entry, loggingEnabled,
              relocations = isempty(relocations) ? nothing : relocations)
end

# Materialize this session's relocation words for `relocations` in a device buffer, whose GPU
# address every launch passes in the `KernelState`. `resolved_relocation_table` hands back the
# words in the order the compiler indexed them by, and permanently roots the referenced Julia
# values, so they cannot dangle for as long as the code is loaded.
#
# Shared storage, written once, read-only on device. The buffer is not bound to the encoder as
# an argument (only its address travels, inside the state), so each launch declares it
# resident — same as the malloc and exception scratch buffers.
@autoreleasepool function reloc_table_buffer(dev::MTLDevice,
                                             relocations::GPUCompiler.Relocations)
    words = GPUCompiler.resolved_relocation_table(relocations)
    buf = MTLBuffer(dev, sizeof(words); storage=SharedStorage)
    GC.@preserve words unsafe_copyto!(convert(Ptr{UInt}, MTL.contents(buf)),
                                      pointer(words), length(words))
    return buf
end

# link the metallib into a session-local pipeline state on the given device.
@autoreleasepool function link_pipeline(dev::MTLDevice, air::Vector{UInt8},
                                        metallib::Vector{UInt8}, entry::String)
    @signpost_event log=log_compiler() "Link" entry

    @signpost_interval log=log_compiler() "Instantiate compute pipeline" begin
        lib = MTLLibraryFromData(dev, metallib)
        fun = MTLFunction(lib, entry)
        try
            return MTLComputePipelineState(dev, fun)
        catch err
            isa(err, NSError) || rethrow()

            # the back-end compiler likely failed
            # XXX: check more accurately? the error domain doesn't help much here
            air_file, metallib_file = dump_artifacts(".air" => air, ".metallib" => metallib)
            error("""Compilation to native code failed; see below for details.
                     If you think this is a bug, please file an issue and attach:
                     - $(air_file)
                     - $(metallib_file)""")
        end
    end
end
