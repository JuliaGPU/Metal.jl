## gpucompiler interface implementation

"""
    Metal.AbstractMetalCompilerParams

The supertype of the parameters of compiler jobs that Metal.jl's implementation of
GPUCompiler's interface applies to. A package that compiles functions of its own kind with
Metal.jl's device library, e.g. the stages of a render pipeline, subtypes it and creates
jobs with `GPUCompiler.CompilerConfig(Metal.compiler_config(dev; ...); params)`. It then
only has to implement the methods of the interface for which its functions differ from
Metal.jl's kernels, invoking Metal.jl's for the rest. Compile the jobs with
[`compile_to_metallib`](@ref).

Jobs compile to kernels that take a [`KernelState`](@ref), unless
`GPUCompiler.kernel_state_type` returns `Nothing` for them. A thread of code without one
that throws an exception stops without reporting it, and the code can't use the device-side
random number generator, and keeps host addresses specific to the session.
"""
abstract type AbstractMetalCompilerParams <: AbstractCompilerParams end

struct MetalCompilerParams <: AbstractMetalCompilerParams end
const MetalCompilerConfig = CompilerConfig{MetalCompilerTarget, MetalCompilerParams}
const MetalCompilerJob = CompilerJob{MetalCompilerTarget, MetalCompilerParams}
const AnyMetalJob = CompilerJob{MetalCompilerTarget, <:AbstractMetalCompilerParams}

"""
    MetalResults

Cached compilation results for a Metal kernel job, managed by
`GPUCompiler.cached_results`. The fields partition by *pipeline stage*:

- `air`: AIR bitcode produced by the LLVM-downgrader from the post-irgen LLVM IR.
  The input to the Metal library wrapper. Session-portable; retained for diagnostics
  when the host-side Metal pipeline creation fails.
- `metallib` + `entry` + `loggingEnabled` + `device_rng`: library-wrapped AIR bytes and
  launch metadata — the final session-portable artifacts. `metallib === nothing` identifies
  a job that has not been compiled yet (see `compile_or_lookup` in `execution.jl`).
- `exception_sites`: the kernel's throw sites, which the exceptions it reports refer to (see
  `GPUCompiler.uses_exception_sites`). Session-portable.
- `relocations`: the kernel's relocation manifest, or `nothing` when it carries none
  (the common case). Session-portable — its `JuliaValueRef`/`CGlobalRef` targets are
  serializable and resolved per-session by the loader — so a relocation-carrying kernel
  now persists into package images too. The resolved words travel to the device in a
  buffer whose address the `KernelState` carries; see `reloc_table_buffer`.
- `pipelines`: session-local cache of `(MTLDevice, MTLComputePipelineState)` pairs
  resulting from the host-side link of `metallib` onto a device. Never populated
  during precompilation, so package images only carry the portable fields.
- `indirect_pipelines`: the same for pipelines that indirect command buffers can use,
  which are linked from the same `metallib` (see `mtlfunction`'s `indirect` keyword).
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
    device_rng::Union{Nothing, Bool}
    relocations::Union{Nothing, GPUCompiler.Relocations}
    exception_sites::Vector{GPUCompiler.ExceptionSite}
    # host-side objects (session-local)
    pipelines::Vector{Tuple{MTLDevice, MTLComputePipelineState}}
    indirect_pipelines::Vector{Tuple{MTLDevice, MTLComputePipelineState}}
    reloc_tables::Vector{Tuple{MTLDevice, MTLBuffer}}
    MetalResults() = new(nothing, nothing, nothing, nothing, nothing, nothing,
                         GPUCompiler.ExceptionSite[],
                         Tuple{MTLDevice, MTLComputePipelineState}[],
                         Tuple{MTLDevice, MTLComputePipelineState}[],
                         Tuple{MTLDevice, MTLBuffer}[])
end

GPUCompiler.runtime_module(::AnyMetalJob) = Metal

GPUCompiler.kernel_state_type(::AnyMetalJob) = KernelState
has_kernel_state(job::AnyMetalJob) = GPUCompiler.kernel_state_type(job) === KernelState

# exceptions are reported through the kernel state (see `exception_site`)
GPUCompiler.uses_exception_sites(job::AnyMetalJob) = has_kernel_state(job)

GPUCompiler.method_table(::AnyMetalJob) = method_table

# Metal supports neither double precision nor 128-bit integers, so also use GPUToolbox's
# overrides that keep single-precision math out of Float64, and 64-bit integer math (e.g.
# `Rational` comparisons) out of Int128. Base's exceptions with messages formatted at run
# time don't compile, so also use the overrides that throw them with a constant message.
GPUCompiler.method_tables(::AnyMetalJob) =
    (method_table, GPUToolbox.Overlays.float64_overrides, GPUToolbox.Overlays.int128_overrides,
     GPUToolbox.Overlays.throw_overrides)

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
# fall back to session-local `:bake` resolution and forgo persistence. So do jobs without a
# kernel state to reach a table through (see `AbstractMetalCompilerParams`), and non-kernel
# jobs: those exist only to be read (`Metal.code_air` and friends), never launched or cached,
# so a session-local resolution is all they need.
GPUCompiler.relocation_lowering(@nospecialize(job::AnyMetalJob)) =
    (job.config.kernel && has_kernel_state(job) && LLVM.version() >= v"17") ?
        (:table) : (:bake)

# Metal 4 tensor ops (`mpp::tensor_ops`, see `device/intrinsics/tensor.jl`) lower to calls to
# externally-defined `__tensorops_impl_*` symbols, resolved by the Metal runtime's tensor-ops
# library at link time. They aren't `air.*` intrinsics, so whitelist them alongside the base
# Metal prefix to keep IR validation from rejecting them as unknown functions.
GPUCompiler.isintrinsic(@nospecialize(job::AnyMetalJob), fn::String) =
    invoke(GPUCompiler.isintrinsic,
           Tuple{CompilerJob{MetalCompilerTarget}, String}, job, fn) ||
    startswith(fn, "__tensorops_")



function GPUCompiler.finish_module!(@nospecialize(job::AnyMetalJob),
                                    mod::LLVM.Module, entry::LLVM.Function)
    # Materialize apple_family() before GPUCompiler optimizes the linked module.
    gv = get(mod.globals, "apple_family", nothing)
    if gv !== nothing
        family = something(job.config.target.apple_family, 0)
        gv.initializer = ConstantInt(LLVM.Int32Type(), family)
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
        # (its state is primed with the seed that the kernel state carries)
        has_kernel_state(job) ||
            error("""The device-side random number generator needs the kernel state, which
                     jobs with $(nameof(typeof(job.config.params))) don't have.""")
        f = initialize_rng_state
        ft = typeof(f)
        tt = Tuple{}

        # create a deferred compilation job for `initialize_rng_state()`. it is an overlay,
        # so look it up in the job's method tables.
        src = GPUCompiler.generic_methodinstance(
            ft, tt, job.world; method_table_view=GPUCompiler.method_table_view(job))
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

            # call the `initialize_rng_state` function, which returns nothing. inferring its
            # return type natively would leave host code for it in sysimages.
            llvm_ft = LLVM.FunctionType(LLVM.VoidType())
            fptr = inttoptr!(builder, fptr, LLVM.PointerType(llvm_ft))
            call!(builder, llvm_ft, fptr)
            br!(builder, top_bb)
        end

        # note the use of the device-side RNG, so that launches only seed it when needed.
        # the optimizer can remove the RNG state, so this cannot be detected afterwards.
        push!(entry.function_attributes, StringAttribute("julia.metal.rng", ""))

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
    @nospecialize(job::AnyMetalJob),
    @nospecialize(gv::LLVM.GlobalVariable))

    if is_tensor_op_descriptor_constant(gv)
        return 0
    end

    return invoke(GPUCompiler.metal_global_constant_addrspace,
                  Tuple{CompilerJob{MetalCompilerTarget}, LLVM.GlobalVariable},
                  job, gv)
end

function GPUCompiler.finish_ir!(@nospecialize(job::AnyMetalJob),
                                    mod::LLVM.Module, entry::LLVM.Function)
    entry = invoke(GPUCompiler.finish_ir!,
                   Tuple{CompilerJob{MetalCompilerTarget}, LLVM.Module, LLVM.Function},
                   job, mod, entry)

    # device code emits intrinsics in their newest form; rewrite them for older AIR versions.
    # this lives here, next to the emitters, so that the two change together. GPUCompiler
    # only legalizes the intrinsics it emits itself (atomics and fences).
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
    ## tensor
    # allocate the storage of the tensor descriptors (see `TensorDescriptor`) like Apple's
    # front end: with a size computed by an argument-less function that has the
    # "deferred-static-alloca-size" attribute, which the back end evaluates. each
    # descriptor is created by an `init` or `slice` call, which also gives its rank.
    let storage = Dict{LLVM.AllocaInst,Int}(), allocas = LLVM.AllocaInst[]
        for (fn, rank_operand) in ("air.init_strided_private_tensor.i32.global" => 2,
                                   "air.init_strided_private_tensor.i32.local" => 2,
                                   "air.slice_private_tensor_private_tensor.s.i32" => 3)
            f = get(mod.functions, fn, nothing)
            f === nothing && continue
            for call in f.users
                call::LLVM.CallInst
                args = collect(call.arguments)
                dst = strip_pointer_casts(args[1])
                # (Julia allocates the storage of an `MtlInlineTensor` on the heap when it
                # cannot prove it doesn't escape)
                dst isa LLVM.AllocaInst ||
                    error("""An MtlInlineTensor escaped the kernel's stack. Keep tensors \
                             within code that is inlined into the kernel, don't choose \
                             between them at run time, and don't carry them across loop \
                             iterations.""")
                # (finish_ir! runs once for every entry point in the module)
                dst.operands[1] isa ConstantInt || continue
                rank = convert(Int, args[rank_operand]::ConstantInt)
                haskey(storage, dst) || push!(allocas, dst)
                @assert get!(storage, dst, rank) == rank
            end
        end

        T_i16 = LLVM.Int16Type()
        T_i64 = LLVM.Int64Type()
        size_ft = LLVM.FunctionType(T_i16, [T_i16, T_i16])
        helper_ft = LLVM.FunctionType(T_i64)
        function helper(rank)
            name = "metal.tensor_descriptor_size.r$rank"
            haskey(mod.functions, name) && return mod.functions[name]
            size_f = get(mod.functions, "air.get_descriptor_size_tensor", nothing)
            if size_f === nothing
                size_f = LLVM.Function(mod, "air.get_descriptor_size_tensor", size_ft)
            end
            # the rank has to be a constant here: the back end fails to evaluate a helper
            # that takes it as an argument
            f = LLVM.Function(mod, name, helper_ft)
            f.linkage = LLVM.Linkage.LinkOnceODR
            f.visibility = LLVM.Visibility.Hidden
            push!(f.function_attributes, StringAttribute("deferred-static-alloca-size", ""))
            @dispose builder=IRBuilder() begin
                position!(builder, LLVM.at_end(BasicBlock(f, "entry")))
                # (4 is the size of the `i32` indices)
                sz = call!(builder, size_ft, size_f,
                           [ConstantInt(T_i16, rank), ConstantInt(T_i16, 4)])
                ret!(builder, zext!(builder, sz, T_i64))
            end
            return f
        end

        sizes = Dict{Tuple{LLVM.Function,Int},LLVM.Value}()
        for old in allocas
            fun, rank = old.parent.parent, storage[old]
            @dispose builder=IRBuilder() begin
                sz = get!(sizes, (fun, rank)) do
                    position!(builder, LLVM.at_begin(first(fun.blocks)))
                    call!(builder, helper_ft, helper(rank))
                end
                position!(builder, LLVM.before(old))
                new = array_alloca!(builder, LLVM.Int8Type(), sz)
                new.alignment = 8
                # (with typed pointers, Julia's storage may have another type)
                if new.value_type != old.value_type
                    new = bitcast!(builder, new, old.value_type)
                end
                replace_uses!(old, new)
                erase!(old)
            end
        end
    end
    if job.config.target.air < v"2.9"
        # AIR 2.9 appended operands to these, which the front-end always emits; drop them
        for (fn, nparams) in ("air.init_strided_private_tensor.i32.global" => 6,
                              "air.init_strided_private_tensor.i32.local" => 6,
                              "air.get_extent_private_tensor.i32" => 3)
            f = get(mod.functions, fn, nothing)
            f === nothing && continue
            new_ft = f.function_type
            old_ft = LLVM.FunctionType(new_ft.return_type, new_ft.parameters[1:nparams])

            f.name = fn * ".air29"
            old_f = LLVM.Function(mod, fn, old_ft)
            append!(old_f.function_attributes, f.function_attributes)
            for call in collect(f.users)
                call::LLVM.CallInst
                @dispose builder=IRBuilder() begin
                    position!(builder, LLVM.before(call))
                    new_call = call!(builder, old_ft, old_f,
                                     collect(call.arguments)[1:nparams])
                    replace_uses!(call, new_call)
                    erase!(call)
                end
            end
            erase!(f)
        end
    end
    if job.config.target.macos < v"27"
        # macOS 27 added matmul2d entry points that take the data type and block sizes of
        # quantization scales and the static extents of each operand. the original ones
        # pass on the defaults: no scales and dynamic extents.
        for f in collect(mod.functions)
            m = match(MATMUL2D_RUN_V2, f.name)
            m === nothing && continue
            new_ft = f.function_type
            v1_operands = [1, 2, 3, 9, 10, 16, 17, 20]
            v2_defaults = (4 => 0, 5 => 0, 6 => 0, 7 => -1, 8 => -1,
                           11 => 0, 12 => 0, 13 => 0, 14 => -1, 15 => -1,
                           18 => -1, 19 => -1)
            old_ft = LLVM.FunctionType(new_ft.return_type, new_ft.parameters[v1_operands])
            old_f = LLVM.Function(mod, m.captures[1], old_ft)
            old_f.section = f.section
            append!(old_f.function_attributes, f.function_attributes)
            for call in collect(f.users)
                call::LLVM.CallInst
                args = collect(call.arguments)
                for (i, default) in v2_defaults
                    arg = args[i]
                    arg isa ConstantInt && convert(Int, arg) == default ||
                        error("matmul2d with quantization scales or static extents requires macOS 27")
                end
                @dispose builder=IRBuilder() begin
                    position!(builder, LLVM.before(call))
                    call!(builder, old_ft, old_f, args[v1_operands])
                    erase!(call)
                end
            end
            erase!(f)
        end
    end
    ## barriers
    # AIR 2.9 added a memory order operand between the memory flags and the scope, which
    # before MSL 4.1 has to be sequentially consistent
    for fn in ("air.wg.barrier", "air.simdgroup.barrier")
        f = get(mod.functions, fn, nothing)
        f === nothing && continue
        T_i32 = LLVM.Int32Type()
        if job.config.target.air >= v"2.9"
            job.config.target.metal >= v"4.1" && continue
            for call in collect(f.users)
                call::LLVM.CallInst
                call.operands[2] = ConstantInt(T_i32, 5)
            end
            continue
        end

        old_ft = LLVM.FunctionType(LLVM.VoidType(), [T_i32, T_i32])
        f.name = fn * ".air29"
        old_f = LLVM.Function(mod, fn, old_ft)
        append!(old_f.function_attributes, f.function_attributes)
        for call in collect(f.users)
            call::LLVM.CallInst
            @dispose builder=IRBuilder() begin
                position!(builder, LLVM.before(call))
                flags, _, scope = collect(call.arguments)
                call!(builder, old_ft, old_f, [flags, scope])
                erase!(call)
            end
        end
        erase!(f)
    end

    # pointer type information for typed intrinsics
    # (this is consumed by the LLVM IR downgrader)
    # map of intrinsics to pointer operand indices and eltypes
    intrinsics = Dict{String,Vector{Pair{Int,DataType}}}()
    ## simd
    for (jltyp, llvmtyp) in (Int32 => :i32, Int64 => :i64,
                             Float16 => :f16, Float32 => :f32,
                             BFloat16 => :bf16),
        (as, asname) in (AS.Device => "global", AS.ThreadGroup => "local")
        intrinsics["simdgroup_matrix_8x8_load.v64$llvmtyp.p$as$llvmtyp"] = [1 => jltyp]
        intrinsics["simdgroup_matrix_8x8_store.v64$llvmtyp.p$as$llvmtyp"] = [2 => jltyp]
    end
    ## logging: the subsystem, category, format string and argument buffer
    intrinsics["os_log"] = [1 => Int8, 2 => Int8, 4 => Int8, 5 => Int8]
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

    # same for the tensor functions, whose pointers are to Apple's types
    let T_i8 = LLVM.Int8Type(), T_i32 = LLVM.Int32Type()
        function named(name)
            T = get(LLVM.types(context()), name, nothing)
            return T === nothing ? LLVM.StructType(name) : T
        end
        pointee(kind) = if kind === :i8
            T_i8
        elseif kind === :tensor
            named("struct._tensor_t")   # opaque
        elseif kind === :matmul2d_descriptor
            T = named("struct.mpp::tensor_ops::matmul2d_descriptor")
            LLVM.isopaque(T) &&
                LLVM.elements!(T, LLVMType[T_i32, T_i32, T_i32, T_i8, T_i8, T_i8, T_i32])
            T
        end

        for f in mod.functions
            params = f.function_type.parameters
            kinds = tensor_pointees(f.name, length(params))
            kinds === nothing && continue
            ptrs = findall(T -> T isa LLVM.PointerType, params)
            @assert length(ptrs) == length(kinds)
            mds = Metadata[]
            for (i, kind) in zip(ptrs, kinds)
                push!(mds, ConstantInt(Int32(i-1)))
                push!(mds, UndefValue(pointee(kind)))
            end
            f.metadata["arg_eltypes"] = MDNode(mds)

            # Julia sign-extends narrow integer arguments, which Apple's front end declares
            # without extension attribute
            for i in eachindex(params)
                delete!(f.parameter_attributes[i], :signext)
                for call in f.users
                    delete!(call.argument_attributes[i], :signext)
                end
            end
        end
    end

    # name the kernel readably (see `kernel_symbol`). this has to happen after GPUCompiler
    # has looked up the entry point by its original name, i.e., not before optimization.
    if job.config.kernel && job.config.name === nothing
        LLVM.name!(entry, kernel_symbol(job.source))
    end

    return entry
end


## compiler implementation (configure, compile, and link)

# cache of compiler configurations, per device (but additionally configurable via kwargs)
const _compiler_configs = Dict{UInt, MetalCompilerConfig}()
const compiler_configs_lock = ReentrantLock()
function compiler_config(dev; kwargs...)
    # (as a `NamedTuple`: hashing the `Pairs` boxes each value, on every launch)
    h = hash(dev, hash(values(kwargs)))
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
                                         gpufamily=nothing, minthreads=nothing,
                                         maxthreads=nothing, kwargs...)
    # determine the versions of things to target
    if macos === nothing
        macos = macos_version()
    else
        macos = check_macos(macos)
    end
    if metal === nothing
        metal = metal_target(macos)
    end
    # like the offline compiler, derive everything from a single deployment target,
    # raised to what the language version requires
    macos = max(macos, macos_floor(metal))
    if air === nothing
        air = air_support(macos)
    elseif air < v"2.7"
        error("""Metal.jl requires AIR 2.7 (macOS 15) or newer; cannot target AIR $(air).""")
    elseif air < air_floor(metal)
            error("""Metal $(metal) requires AIR $(air_floor(metal)) or newer; cannot target AIR $(air).""")
    end
    # Only Apple family values form the capability sequence used by device code.
    apple_family = if gpufamily === nothing
        MTL.highest_apple_family(dev)
    else
        gpufamily = convert(MTL.MTLGPUFamily, gpufamily)
        family = Int(gpufamily) - 1000
        if !(1 <= family <= 11)
            throw(ArgumentError("gpufamily must be an MTLGPUFamilyApple<n>, got $(gpufamily)"))
        end
        family
    end

    # threadgroup size properties. These are checked here because a pipeline descriptor
    # requiring an unsupported size aborts the process. Apple GPUs limit the total number of
    # threads per threadgroup to the same value as each dimension.
    limits = dev.maxThreadsPerThreadgroup
    maxtotal = Int(limits.width)
    if minthreads !== nothing
        if !(1 <= length(minthreads) <= 3)
            throw(ArgumentError("minthreads should be an integer or a tuple of up to three integers, got $(minthreads)"))
        end
        # normalize, so that equivalent sizes share a compiled kernel
        minthreads = Int.((minthreads..., 1, 1)[1:3])
        if any(<(1), minthreads) || any(minthreads .> (limits.width, limits.height, limits.depth)) ||
           prod(minthreads) > maxtotal
            throw(ArgumentError("minthreads $(minthreads) is not a valid threadgroup size for this device (at most $(Int(limits.width))×$(Int(limits.height))×$(Int(limits.depth)) and $(maxtotal) threads in total)"))
        end
        # enforced through the pipeline descriptor's `requiredThreadsPerThreadgroup`, which the
        # runtime only provides on macOS 26, regardless of the targeted Metal version
        if macos_version() < v"26"
            throw(ArgumentError("minthreads requires macOS 26 or newer; running macOS $(macos_version())"))
        end
    end
    if maxthreads !== nothing
        if !(1 <= maxthreads <= maxtotal)
            throw(ArgumentError("maxthreads should be between 1 and $(maxtotal), got $(maxthreads)"))
        end
        if minthreads !== nothing && maxthreads < prod(minthreads)
            throw(ArgumentError("maxthreads ($(maxthreads)) should not be lower than the total of minthreads $(minthreads)"))
        end
    end

    # create GPUCompiler objects
    target = MetalCompilerTarget(; macos, air, metal, apple_family, minthreads, maxthreads,
                                   kwargs...)
    params = MetalCompilerParams()
    CompilerConfig(target, params; kernel, name, always_inline, debug_level, opt_level)
end

# find one of Apple's Metal tools, in METAL_TOOLCHAIN or with `xcrun`
function apple_tool(name)
    dir = get(ENV, "METAL_TOOLCHAIN", nothing)
    if dir !== nothing
        path = abspath(joinpath(dir, name))
        return isfile(path) ? path : nothing
    end
    Sys.isapple() || return nothing
    path = strip(read(pipeline(ignorestatus(`xcrun --find $name`); stderr=devnull), String))
    return isfile(path) ? String(path) : nothing
end

# run `cmd`, returning its process and its output and errors. (on Julia 1.10, waiting for a
# process doesn't wait for its output to be copied into an `IOBuffer`, so read a pipe)
function run_tool(cmd::Cmd)
    out = Pipe()
    proc = run(pipeline(ignorestatus(cmd); stdout=out, stderr=out); wait=false)
    close(out.in)
    output = read(out, String)
    wait(proc)
    return proc, output
end

# the version of the Apple tool at `tool`, e.g. "Apple LLVM version 32023.921.6"
function apple_tool_version(tool::String)
    try
        out = read(pipeline(`$tool --version`; stderr=devnull), String)
        line = readline(IOBuffer(out))
        isempty(line) || return strip(line)
    catch
    end
    return "unknown version"
end

# With `JULIA_METAL_VERIFY_AIR`, every compiled kernel's AIR is checked with Apple's
# verifier, which catches IR that Apple's front-end never emits (unknown or mistyped `air.*`
# functions, malformed metadata) before the back-end miscompiles or crashes on it. Being
# asked to verify without a verifier is an error, so that CI cannot silently stop checking.
verify_air() = parse(Bool, get(ENV, "JULIA_METAL_VERIFY_AIR", "false"))

# Apple's AIR verifier, or `nothing` if it can't be found
function air_verifier()
    haskey(ENV, "METAL_TOOLCHAIN") && return apple_tool("metal-opt")
    # (`xcrun` takes tens of milliseconds)
    @memoize begin
        apple_tool("metal-opt")
    end::Union{Nothing,String}
end

# the verifier's complaints about the AIR bitcode `air`, or `nothing` if it accepts it
function air_verifier_errors(air::Vector{UInt8})
    tool = air_verifier()
    tool === nothing &&
        error("""JULIA_METAL_VERIFY_AIR is set, but Apple's metal-opt was not found.
                 Install the Metal toolchain (`xcodebuild -downloadComponent MetalToolchain`),
                 or set METAL_TOOLCHAIN to the directory that contains metal-opt.""")
    msg = mktemp() do path, io
        write(io, air)
        close(io)
        cmd = `$tool -air-verify --air-verification-level=full -o /dev/null $path`
        try
            proc, out = run_tool(cmd)
            success(proc) && return nothing
            msg = replace(strip(out), path => "the kernel's AIR")
            isempty(msg) ? "metal-opt failed with exit code $(proc.exitcode)" : msg
        catch err
            "Failed to run metal-opt: $(sprint(showerror, err))"
        end
    end
    msg === nothing && return nothing
    return "$msg\n(verifier: $tool, $(apple_tool_version(tool)))"
end

# With `JULIA_METAL_BACKEND_CHECK`, every compiled kernel is also compiled with Apple's
# offline GPU back end (`applegpu-nt`) for a list of GPUs and macOS versions, which catches
# back-end crashes on hardware or systems we can't test on. Each target is `arch[@macos]`,
# e.g. `g17g@26` for an M5 running macOS 26, or `g17g` for an M5 running the host's macOS.
# Each kernel is compiled again for each target, the way it would be on that machine,
# because the IR depends on the GPU family (GPUCompiler works around a macOS 26 back-end bug
# on Apple10 GPUs only) and on the deployment target, which is lowered to the target's macOS
# when that is older. Host code still picks kernels by the host device's capabilities, so
# kernels another GPU would get instead aren't checked. Like with `JULIA_METAL_VERIFY_AIR`,
# a missing toolchain is an error. Only fresh compilations are checked, not kernels loaded
# from a cache.

struct BackendTarget
    arch::String            # e.g. "applegpu_g17g"
    macos::VersionNumber    # the macOS whose back end to use
end

Base.show(io::IO, t::BackendTarget) = print(io, t.arch, "@", t.macos.major, ".", t.macos.minor)

function backend_targets()
    targets = BackendTarget[]
    list = strip(get(ENV, "JULIA_METAL_BACKEND_CHECK", ""))
    isempty(list) && return targets
    for spec in split(list, ',')
        spec = strip(spec)
        m = match(r"^(?:applegpu_)?(g\d+[a-z])(?:@(\d+(?:\.\d+)?))?$", spec)
        m === nothing &&
            error("Invalid JULIA_METAL_BACKEND_CHECK target '$spec'; expected a GPU like g17g, optionally with a macOS version like g17g@26.")
        macos = normalize_macos(m[2] === nothing ? macos_version() : VersionNumber(m[2]))
        push!(targets, BackendTarget("applegpu_" * m[1], VersionNumber(macos.major, macos.minor)))
    end
    return unique!(targets)
end

# Apple's offline back end, and the tool that knows the GPU families of its architectures
function backend_tools()
    haskey(ENV, "METAL_TOOLCHAIN") && return find_backend_tools()
    # (`xcrun` takes tens of milliseconds)
    @memoize begin
        find_backend_tools()
    end::Tuple{String,String}
end
function find_backend_tools()
    tools = map(("applegpu-nt", "metal-config")) do name
        tool = apple_tool(name)
        tool === nothing &&
            error("""JULIA_METAL_BACKEND_CHECK is set, but Apple's $name was not found.
                     Install the Metal toolchain (`xcodebuild -downloadComponent MetalToolchain`),
                     or set METAL_TOOLCHAIN to the directory that contains $name.""")
        tool
    end
    return (tools[1], tools[2])
end

# the architectures the back end supports on `macos`, with the highest Apple GPU family
# each one belongs to (the toolchain's equivalent of `MTL.highest_apple_family`)
function backend_families(tools::Tuple{String,String}, macos::VersionNumber)
    @memoize key=(tools, macos)::Tuple{Tuple{String,String},VersionNumber} begin
        compiler, config = tools
        version = "$(macos.major).$(macos.minor)"
        available = split(readchomp(`$compiler -available-archs macos $version`))
        members = asyncmap(1:11) do n
            proc, out = run_tool(`$config --native-archs-supported macos $version --gpu-family=apple$n`)
            success(proc) && return split(out)
            # older toolchains don't know the newest families
            occursin("Cannot find option named 'apple$n'", out) && return SubString{String}[]
            error("Failed to query the architectures of Apple GPU family $n on macOS $version:\n$(strip(out))")
        end
        families = Dict{String,Int}()
        for (family, archs) in enumerate(members), arch in archs
            arch in available && (families[arch] = family)
        end
        (Set{String}(available), families)
    end::Tuple{Set{String},Dict{String,Int}}
end

# the Apple GPU family of target `t`, if the back end supports it
function backend_family(tools::Tuple{String,String}, t::BackendTarget)
    available, families = backend_families(tools, t.macos)
    t.arch in available ||
        error("""Apple's back end ($(first(tools))) does not support $(t.arch) on macOS $(t.macos.major).$(t.macos.minor).
                 Supported are: $(join(sort!(collect(available)), ", ")).""")
    haskey(families, t.arch) ||
        error("Apple's toolchain does not know the GPU family of $(t.arch).")
    return families[t.arch]
end

# the configuration `config` compiles with on a GPU of Apple family `family` running `macos`
function backend_config(config::CompilerConfig, family::Int, macos::VersionNumber)
    target = config.target
    versions = (; target.macos, target.air, target.metal)
    if macos < target.macos
        # a system can't load kernels for newer systems, so lower the deployment target and
        # the versions it supports, keeping any that were lower already
        macos = check_macos(macos)
        versions = (; macos, air=min(target.air, air_support(macos)),
                    metal=min(target.metal, metal_target(macos)))
    end
    fields = NamedTuple{fieldnames(MetalCompilerTarget)}(
        map(f -> getfield(target, f), fieldnames(MetalCompilerTarget)))
    target = MetalCompilerTarget(; merge(fields, versions, (; apple_family=family))...)
    return CompilerConfig(config; target)
end

# the descriptor that makes `applegpu-nt` compile the pipeline of function `entry`
pipeline_script(entry::String) =
    """{"pipelines":{"compute_pipelines":[{"compute_function":"$(escape_string(entry))"}]}}"""

# compile `job`, of which `art` are the artifacts, for each of the back-end targets, and
# check those with Apple's back end
function check_backend(@nospecialize(job::CompilerJob), art, targets::Vector{BackendTarget})
    tools = backend_tools()
    compiler = first(tools)

    # determine the configuration of each target, and which ones share it
    configs = Dict{MetalCompilerTarget,Tuple{CompilerConfig,Vector{BackendTarget}}}()
    for t in targets
        config = backend_config(job.config, backend_family(tools, t), t.macos)
        push!(last(get!(() -> (config, BackendTarget[]), configs, config.target)), t)
    end

    # compile each configuration that differs from the job's
    compiled = map(collect(values(configs))) do (config, ts)
        target = config.target
        target === job.config.target && return (; config, ts, art)
        derived = try
            emit_metallib(CompilerJob(job.source, config, job.world))
        catch err
            error("""Compiling the kernel for the back-end check of $(join(ts, ", ")) (Apple$(target.apple_family), macOS $(target.macos), AIR $(target.air), Metal $(target.metal)) failed:
                     $(sprint(showerror, err))""")
        end
        (; config, ts, art=derived)
    end

    failures = String[]
    mktempdir() do dir
        # run the back end for every target at once. the output goes to files: on Julia
        # 1.10, waiting for a process doesn't wait for its output to be copied to a buffer.
        checks = []
        try
            for (i, (; ts, art)) in enumerate(compiled)
                lib, json = joinpath(dir, "kernel$i.metallib"), joinpath(dir, "kernel$i.mtlp-json")
                write(lib, art.metallib)
                write(json, pipeline_script(art.entry))
                for t in ts
                    version = "$(t.macos.major).$(t.macos.minor)"
                    n = length(checks) + 1
                    bin, log = joinpath(dir, "check$n.bin"), joinpath(dir, "check$n.log")
                    cmd = `$compiler -arch $(t.arch) -platform_version macos $version $version -N $json -o $bin $lib`
                    proc = open(log, "w") do io
                        run(pipeline(ignorestatus(cmd); stdout=io, stderr=io); wait=false)
                    end
                    push!(checks, (; i, t, proc, log))
                end
            end
            foreach(c -> wait(c.proc), checks)
        finally
            # don't leave processes behind, or have them write to a removed directory
            for (; proc) in checks
                process_running(proc) && kill(proc, Base.SIGKILL)
            end
            foreach(c -> wait(c.proc), checks)
        end

        dumps = Dict{Int,Vector{String}}()
        for (; i, t, proc, log) in checks
            success(proc) && continue
            (; config, art) = compiled[i]
            msg = strip(read(log, String))
            aborted = proc.termsignal == 6  # SIGABRT, from LLVM's fatal error handler
            # the offline back end can't encode floating-point `os_log` arguments, which
            # the one in the OS can
            if aborted && art.loggingEnabled &&
               any(==("LLVM ERROR: Failed to encode."), eachline(IOBuffer(msg)))
                @debug "Skipping the back-end check of $(art.entry) for $t, which can't encode its logging calls"
                continue
            end

            ll_file, air_file, metallib_file, json_file = get!(dumps, i) do
                dump_artifacts(".ll" => art.ir, ".air" => art.air, ".metallib" => art.metallib,
                               ".mtlp-json" => pipeline_script(art.entry))
            end
            target = config.target
            version = "$(t.macos.major).$(t.macos.minor)"
            status = if aborted
                "it crashed"
            elseif proc.termsignal != 0
                "it was killed by signal $(proc.termsignal)"
            else
                "exit code $(proc.exitcode)"
            end
            command = join(Base.shell_escape_posixly.([compiler, "-arch", t.arch, "-platform_version",
                                               "macos", version, version, "-N", json_file,
                                               "-o", splitext(metallib_file)[1] * ".bin",
                                               metallib_file]), " ")
            push!(failures, """
                Apple's back end failed to compile the kernel for $(t.arch) (Apple$(target.apple_family)) on macOS $version, with the kernel compiled for macOS $(target.macos), AIR $(target.air) and Metal $(target.metal):
                $msg
                ($status; back end: $compiler, $(apple_tool_version(compiler)))
                To reproduce, run:
                  $command
                If you think this is a bug, please file an issue and attach the following files:
                - $ll_file
                - $air_file
                - $metallib_file
                - $json_file""")
        end
    end
    isempty(failures) || error(join(failures, "\n\n"))
    return
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

"""
    compile_to_metallib(job::GPUCompiler.CompilerJob)

Compile the kernel of `job`, whose parameters subtype [`AbstractMetalCompilerParams`](@ref),
and return an object whose `metallib` field holds the bytes of the resulting Metal library.
Its other fields are internal.

Metal.jl compiles its own jobs in the world it was initialized in, so that methods defined
later don't invalidate its compiler. Other jobs are compiled in the current world, so that
the methods of GPUCompiler's interface a package defines for them apply.
"""
function compile_to_metallib(@nospecialize(job::AnyMetalJob))
    job.config.kernel ||
        throw(ArgumentError("only kernels can be compiled to a Metal library"))
    Threads.atomic_add!(compilations, 1)
    art = emit_metallib(job)

    # when `JULIA_METAL_DUMP_DIR` is set, dump every compiled kernel's artifacts
    if haskey(ENV, "JULIA_METAL_DUMP_DIR")
        dump_artifacts(".ll" => art.ir, ".air" => art.air, ".metallib" => art.metallib)
    end

    # (only for Metal.jl's own jobs, as the check compiles a compute pipeline)
    if job isa MetalCompilerJob
        targets = backend_targets()
        if !isempty(targets)
            @signpost_interval log=log_compiler() start="" stop="" "Check back end" begin
                check_backend(job, art, targets)
            end
        end
    end

    # `nothing` marks a relocation-free kernel (the common case), keeping its `MetalResults`
    # and package-image footprint identical to before.
    return (; art.air, art.metallib, art.entry, art.loggingEnabled, art.device_rng,
              art.exception_sites, relocations = isempty(art.relocations) ? nothing : art.relocations)
end

# the world to run the compiler in (see `compile_to_metallib`)
compiler_world(::MetalCompilerJob) = initialization_world[]
compiler_world(@nospecialize(job::AnyMetalJob)) = Base.get_world_counter()

# lower the IR that GPUCompiler generated for `job` to AIR, and describe its kernel.
# the IR is only valid while GPUCompiler's `compile` callback runs, so this returns plain data.
function lower_to_air(@nospecialize(job::AnyMetalJob), world::UInt, mod::LLVM.Module,
                      @nospecialize(meta::NamedTuple))
    kernel_fn = meta.entry::LLVM.Function
    relocs = meta.relocations::GPUCompiler.Relocations
    sites = if Base.invoke_in_world(world, GPUCompiler.uses_exception_sites, job)::Bool
        meta.exception_sites::Vector{GPUCompiler.ExceptionSite}
    else
        GPUCompiler.ExceptionSite[]
    end

    # Detect logging after optimization so dead logging calls do not enable log state.
    loggingEnabled = haskey(mod.functions, "air.os_log")

    # (dropping the marker, which isn't AIR, so it doesn't end up in the metallib)
    rng_attr = StringAttribute("julia.metal.rng", "")
    device_rng = rng_attr in collect(kernel_fn.function_attributes)
    device_rng && delete!(kernel_fn.function_attributes, rng_attr)

    @signpost_interval log=log_compiler() start="" stop="" "Downgrade to AIR" begin
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
            Base.invoke_in_world(world, GPUCompiler.emit_asm, job, mod, relocs,
                                 LLVM.CodeGenFileType.Object)::Tuple{Vector{UInt8},Any}
        catch err
            # `emit_asm` has already lowered the module in-place, so stringifying it
            # here shows exactly what the downgrader was fed
            ir_file, = dump_artifacts(".ll" => string(mod))
            error("""Compilation to AIR failed: $(sprint(showerror, err))
                     If you think this is a bug, please file an issue and attach $(ir_file)""")
        end
    end

    # describe the function while we still have its module
    fun = try
        MetalLibFunction(mod, kernel_fn.name; air_module=air)
    catch err
        ir_file, air_file = dump_artifacts(".ll" => string(mod), ".air" => air)
        error("""Compilation to Metal library failed: $(sprint(showerror, err))
                 If you think this is a bug, please file an issue and attach the following files:
                 - $(ir_file)
                 - $(air_file)""")
    end

    return string(mod), air, fun, kernel_fn.name, loggingEnabled, device_rng, relocs, sites
end

# the artifacts of compiling `job`, including its LLVM IR
function emit_metallib(@nospecialize(job::AnyMetalJob))
    # (once, so that methods defined concurrently don't apply to only part of the compilation)
    world = compiler_world(job)
    lower(mod, meta) = lower_to_air(job, world, mod, meta)
    # (the AIR downgrade happens within the callback, so its interval nests in this one)
    ir, air, fun, entry, loggingEnabled, device_rng, relocations, exception_sites =
        @signpost_interval log=log_compiler() start="" stop="" "Generate LLVM IR" begin
            # (asserting the result types, which `invoke_in_world` hides, keeps the uses of
            #  the results statically dispatched, so that they're precompiled)
            Base.invoke_in_world(world, GPUCompiler.compile, lower, :llvm, job)::Tuple{
                String, Vector{UInt8}, MetalLibFunction, String, Bool, Bool,
                GPUCompiler.Relocations, Vector{GPUCompiler.ExceptionSite}}
        end

    @signpost_interval log=log_compiler() start="" stop="" "Create Metal library" begin
        metallib = try
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

    if verify_air()
        msg = @signpost_interval log=log_compiler() start="" stop="" "Verify AIR" begin
            air_verifier_errors(air)
        end
        if msg !== nothing
            target = job.config.target
            # an older toolchain doesn't know newer AIR versions, and says so in its terms
            occursin("unrecognized architecture", msg) &&
                (msg *= "\nThe Metal toolchain is too old for AIR $(target.air); " *
                        "verify with a release toolchain for macOS $(target.macos) or newer.")
            ir_file, air_file, metallib_file =
                dump_artifacts(".ll" => ir, ".air" => air, ".metallib" => metallib)
            error("""Apple's AIR verifier rejected the kernel:
                     $msg
                     If you think this is a bug, please file an issue and attach the following files:
                     - $(ir_file)
                     - $(air_file)
                     - $(metallib_file)""")
        end
    end

    return (; ir, air, metallib, entry, loggingEnabled, device_rng, exception_sites, relocations)
end

# Materialize this session's relocation words for `relocations` in a device buffer, whose GPU
# address every launch passes in the `KernelState`. `resolved_relocation_table` hands back the
# words in the order the compiler indexed them by, and permanently roots the referenced Julia
# values, so they cannot dangle for as long as the code is loaded.
#
# Shared storage, written once, read-only on device. The buffer is not bound to the encoder as
# an argument (only its address travels, inside the state), so each launch declares it
# resident — same as the malloc and exception scratch buffers.
function reloc_table_buffer(dev::MTLDevice,
                                             relocations::GPUCompiler.Relocations,
                                             label::String="kernel")
    words = GPUCompiler.resolved_relocation_table(relocations)
    buf = MTLBuffer(dev, sizeof(words); storage=SharedStorage)
    buf.label = "Metal.jl relocations of $label"
    GC.@preserve words unsafe_copyto!(convert(Ptr{UInt}, MTL.contents(buf)),
                                      pointer(words), length(words))
    return buf
end

# The runtime rejects libraries with a container, AIR or MSL version it doesn't know, with a
# generic error. Kernels can be compiled for newer systems (e.g. to inspect their code), so
# this is only checked when loading. Only major and minor versions matter: the function list
# doesn't encode patch versions, and newer container patch versions load fine. The
# deployment target itself isn't checked: the newest macOS emits the same versions as its
# successors, and the runtime ignores the header's OS.
function check_loadable(target)
    host = macos_version()
    newer(a, b) = (a.major, a.minor) > (b.major, b.minor)
    if newer(metallib_target(target.macos), metallib_support(host)) ||
       newer(target.air, air_support(host)) || newer(target.metal, metal_support(host))
        error("""Kernel was compiled for metallib $(metallib_target(target.macos)), AIR $(target.air) and MSL $(target.metal) (macOS $(target.macos)), which this system (macOS $host) cannot load.""")
    end
end

# The name a function was defined with, or `nothing` for an anonymous function. Closures,
# including those of `@kernel` and broadcast, have type names like
# `#broadcast_linear#_copyto!##1`, and anonymous functions ones like `#3#4`.
function function_name(@nospecialize(ft::Type{<:Function}))
    m = match(r"^#*([^#]+)", String(nameof(ft)))
    (m === nothing || all(isdigit, m[1])) ? nothing : String(m[1])
end

# The symbol name of the kernel `mi` is compiled from, e.g., `saxpy`. GPUCompiler names
# kernels after their mangled signature (`_Z5saxpy14MtlDeviceArrayI7Float32...`), which
# profilers that demangle C++ names group by function, but Apple's tools show symbol names
# as they are. Xcode's shader profiler even names every inlined frame of a call stack after
# the kernel, as it can only resolve the names of inlined functions in MSL sources. Each
# kernel is compiled into its own library, so specializations can share a name.
function kernel_symbol(mi::Core.MethodInstance)
    ft = mi.specTypes.parameters[1]
    name = if !(ft <: Function)
        String(nameof(ft))
    else
        something(function_name(ft), "anonymous")
    end
    return GPUCompiler.safe_name(name)
end

# A readable name for the kernel `mi` is compiled from, e.g.,
# `saxpy(::MtlDeviceVector{Float32, 1}, ::MtlDeviceVector{Float32, 1}, ::UInt32)`.
# Tools like Xcode's GPU frame capture otherwise only show the name of the entry point,
# which is the same for every specialization of a kernel (see `kernel_symbol`).
# Long argument types (broadcasts, KernelAbstractions contexts) get their type parameters
# abbreviated the way stack traces do, and the label is truncated if that doesn't suffice.
const MAX_KERNEL_LABEL = 256
const MAX_KERNEL_LABEL_ARG = 96
function kernel_label(mi::Core.MethodInstance)
    params = (mi.specTypes::DataType).parameters
    ft = params[1]
    name = if !(ft <: Function)
        "(::$ft)"
    elseif (fn = function_name(ft)) !== nothing
        fn
    else
        # anonymous functions are told apart by where they were defined
        meth = mi.def
        meth isa Method ? "anonymous@$(basename(String(meth.file))):$(meth.line)" :
                          "anonymous"
    end
    # `args` has to stay concretely typed (iterating the parameters directly, or rebinding
    # `args`, makes it abstract): `sum` over an abstract array has edges to GPUArrays'
    # methods, whose invalidation discards the precompiled compiler
    args = String["::" * sprint(show, params[i]) for i in 2:length(params)]
    # `type_depth_limit` is internal (it limits the types in stack traces), so don't
    # rely on it being there
    if sum(length, args; init=0) > MAX_KERNEL_LABEL && isdefined(Base, :type_depth_limit)
        map!(args, args) do arg
            length(arg) > MAX_KERNEL_LABEL_ARG ?
                Base.type_depth_limit(arg, MAX_KERNEL_LABEL_ARG) : arg
        end
    end
    label = name * "(" * join(args, ", ") * ")"
    if length(label) > MAX_KERNEL_LABEL
        label = first(label, MAX_KERNEL_LABEL - 1) * "…"
    end
    return label
end

## embedded sources

# Xcode's GPU frame capture shows a kernel's source, and the profiler's per-line costs, only
# for library functions it can pair with an embedded source archive: the function's
# dependency list (DEPF) has to name the file the archive's `original-input-filename.txt`
# names, and the archive has to come with the command that compiled that file. Apple's
# toolchain archives the MSL sources (with `-frecord-sources`); we archive the AIR module
# with the command that would compile it, plus the Julia files its debug info refers to,
# which is what Xcode displays. Xcode also rebuilds the library from the archived AIR file
# with that command, to attribute profiling costs within inlined code: if the rebuild
# fails, inlined functions are missing from the call stack, and their costs are attributed
# to their call sites.
#
# This happens when linking a pipeline, not when compiling a kernel, so that it doesn't
# affect cached compilation results, and so that the archive holds the source files as
# they are when the kernel is loaded.

const EMBED_SOURCES = @load_preference("embed_sources", nothing)

# without a preference, only embed sources when frame capture is enabled
embed_sources() = @something(EMBED_SOURCES, get(ENV, "METAL_CAPTURE_ENABLED", "0") == "1")

# files larger than this are left out of source archives
const MAX_EMBEDDED_SOURCE = 1 << 20

# Xcode finds a file in a source archive by its standardized path (see NSString's
# `stringByStandardizingPath`), without the `/private` of e.g. `/private/tmp`. Julia records
# such paths as given, or resolved by the working directory: `include("kernel.jl")` in
# `/tmp` results in `/private/tmp/kernel.jl`. Archive those under the standardized path.
function standardized_path(path::String)
    if startswith(path, "/private/")
        short = path[sizeof("/private")+1:end]
        ispath(short) && samefile(short, path) && return short
    end
    return path
end

# a library like `metallib`, but with the sources of its function embedded
function embed_sources(metallib::Vector{UInt8}, air::Vector{UInt8})
    lib = read(IOBuffer(metallib), MetalLib)
    fun = only(lib.functions)
    sources = @dispose ctx=LLVM.Context() mod=parse(LLVM.Module, air) begin
        debug_source_files(mod)
    end

    # the AIR file the function claims to be linked from. it doesn't exist, but its name
    # has to be stable, and short enough for the archive format. kernels are named after
    # their function, so tell specializations apart by the module's contents.
    name = first(replace(fun.name, r"[^A-Za-z0-9_]" => "_"), 32) * "-" *
           bytes2hex(sha256(air))[1:16]
    air_path = joinpath(tempdir(), "metal.jl", name * ".air")

    # the deployment target, without which the rebuild targets the toolchain's newest macOS
    platform = let v = lib.platform_version
        "$(v.major).$(v.minor).$(v.patch)"
    end

    working_directory = try pwd() catch; "/" end
    options = join(["metal", "--driver-mode=metal", "-x", "ir", "-gline-tables-only",
                    "-mmacosx-version-min=$platform", "-frecord-sources=yes",
                    Base.shell_escape(air_path), "-o", Base.shell_escape(name * ".metallib")],
                   " ")
    files = Pair{String,Vector{UInt8}}[
        "metal-options.txt" => codeunits(options),
        "metal-working-dir.txt" => codeunits(working_directory * "\n"),
        "original-input-filename.txt" => codeunits(air_path * "\n")]
    # when Xcode can't tell which file holds the kernel, it opens the AIR file, or without
    # one, the first file. put the kernel's file first and the AIR file last.
    if fun.debug_info !== nothing
        sort!(sources; by = !=(fun.debug_info.path))
    end
    for path in sources
        if isfile(path) && filesize(path) <= MAX_EMBEDDED_SOURCE
            push!(files, standardized_path(path) => read(path))
        end
    end
    push!(files, air_path => air)
    archive = source_archive(files)

    # the command that would link the AIR file into this library
    arch = "air64_v$(fun.air_version.major)$(fun.air_version.minor)"
    link_options = join(["air-lld", "-arch", arch, "-platform_version", "macos", platform,
                         platform, "-o", Base.shell_escape(name * ".metallib"),
                         Base.shell_escape(air_path), "-embed_sources"], " ")

    fun = MetalLibFunction(fun; source_id="0", dependencies=[air_path], layout=nothing)
    lib = MetalLib(lib; functions=[fun], layout=nothing,
                   embedded_source=EmbeddedSource(link_options, working_directory,
                                                  ["0" => archive]),
                   uuid=content_uuid(metallib, archive))
    io = IOBuffer()
    write(io, lib)
    return take!(io)
end

# link the metallib into a session-local pipeline state on the given device. `label`
# names the library, function and pipeline in Metal's developer tools. `indirect` makes a
# pipeline that the commands of an indirect command buffer can use: they refuse others.
function link_pipeline(dev::MTLDevice, air::Vector{UInt8},
                                        metallib::Vector{UInt8}, entry::String,
                                        minthreads::Union{Nothing,NTuple{3,Int}},
                                        label::String=entry; indirect::Bool=false)
    if embed_sources()
        metallib = try
            embed_sources(metallib, air)
        catch err
            @error "Failed to embed the sources of kernel $label; continuing without" exception=(err, catch_backtrace())
            metallib
        end
    end

    @signpost_interval log=log_compiler() start=label stop="" "Instantiate compute pipeline" begin
        lib = MTLLibraryFromData(dev, metallib)
        lib.label = label
        fun = MTLFunction(lib, entry)
        fun.label = label
        desc = MTLComputePipelineDescriptor()
        desc.computeFunction = fun
        # the kernel's IR only carries the required size as a hint; this enforces it
        if minthreads !== nothing
            desc.requiredThreadsPerThreadgroup = MTLSize(minthreads)
        end
        desc.supportIndirectCommandBuffers = indirect
        desc.label = label
        started = time()
        try
            MTLComputePipelineState(dev, desc)
        catch err
            isa(err, NSError) || rethrow()

            air_file, metallib_file = dump_artifacts(".air" => air, ".metallib" => metallib)
            msg = if occursin("XPC_ERROR_CONNECTION_INTERRUPTED", String(err.localizedDescription))
                # the error only says that the compiler service went away. when the back-end
                # aborted, the reason is in the crash report it left behind.
                crash = compiler_crash_report(started)
                details = if crash === nothing
                    "Look for an MTLCompilerService crash report in $(crash_report_dir()); " *
                    "macOS stops writing them once 25 have accumulated."
                else
                    path, reasons = crash
                    "It reported:\n" * join(map(r -> "  " * r, reasons), "\n") *
                    "\n(crash report: $path)"
                end
                """Compilation to native code failed: Metal's compiler service crashed.
                   $details
                   If you think this is a bug, please file an issue and attach:
                   - $(air_file)
                   - $(metallib_file)"""
            else
                """Compilation to native code failed; see below for details.
                   If you think this is a bug, please file an issue and attach:
                   - $(air_file)
                   - $(metallib_file)"""
            end
            if !gpu_addresses_available(dev)
                msg *= """\n\nMetal also returned a null GPU address for a new buffer. The driver may
                          have stopped servicing this process, failing all further compilations.
                          Restart Julia."""
            end
            error(msg)
        end
    end
end

crash_report_dir() = joinpath(homedir(), "Library", "Logs", "DiagnosticReports")

# Find the MTLCompilerService crash report this process caused since `started`, and return
# its path with the abort reason (e.g. LLVM's "cannot select" plus context lines), or
# `nothing`. ReportCrash writes the report about half a second after Metal returns the
# error, so wait for it a little. Best effort: never throws.
function compiler_crash_report(started::Float64; dir::String=crash_report_dir(),
                               pid::Integer=getpid(), timeout::Real=2)
    deadline = time() + timeout
    while true
        try
            for name in readdir(dir)
                startswith(name, "MTLCompilerService") && endswith(name, ".ips") || continue
                path = joinpath(dir, name)
                mtime(path) >= started || continue
                reasons = crash_reasons(read(path, String), pid)
                reasons === nothing || return path, reasons
            end
        catch
            return nothing
        end
        time() < deadline || return nothing
        sleep(0.1)
    end
end

# An .ips file is a JSON header line followed by a JSON body. Avoid a JSON dependency by
# only extracting the responsible pid and the `"reasons"` string array.
function crash_reasons(report::String, pid::Integer)
    m = match(r"\"responsiblePid\"\s*:\s*(\d+)", report)
    m === nothing && return nothing
    parse(Int, m[1]) == pid || return nothing
    m = match(r"\"reasons\"\s*:\s*\[((?:\s*\"(?:[^\"\\]|\\.)*\"\s*,?)*)\s*\]", report)
    m === nothing && return nothing
    reasons = [unescape_string(s[1]) for s in eachmatch(r"\"((?:[^\"\\]|\\.)*)\"", m[1])]
    isempty(reasons) ? nothing : reasons
end

# After repeated GPU errors, the driver may stop servicing the process, failing every
# compilation, also of valid kernels. New buffers then lack a GPU address.
function gpu_addresses_available(dev::MTLDevice)
    try
        buf = MTLBuffer(dev, 4; storage=SharedStorage)
        try
            !iszero(UInt(buf.gpuAddress))
        finally
            release(buf)
        end
    catch
        true    # inconclusive
    end
end
