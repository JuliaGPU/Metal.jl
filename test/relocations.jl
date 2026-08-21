using GPUCompiler
using LLVM: LLVM

# Metal selects the `:table` relocation-lowering strategy so kernels stay byte-stable across
# sessions (restoring pkgimage persistence and content-keyed binary archives) whether or not
# they carry relocations. See `GPUCompiler.relocation_lowering(::MetalCompilerJob)`; on
# LLVM < 17 (Julia < 1.12) it falls back to session-local `:bake` resolution.

# the compiler job a `@metal` launch of `f(tt...)` would use
function kernel_job(@nospecialize(f), @nospecialize(tt))
    dev = Metal.device()
    cfg = Metal.compiler_config(dev; kernel=true, name=nothing)
    src = Metal.methodinstance(typeof(f), tt, Base.get_world_counter())
    return GPUCompiler.CompilerJob(src, cfg, Base.get_world_counter())
end

let job = kernel_job(identity, Tuple{Nothing})
    if LLVM.version() >= v"17"
        @test GPUCompiler.relocation_lowering(job) === :table
        if GPUCompiler.supports_relocatable_ir()
            @test GPUCompiler.can_persist_results(job)
        end
    else
        @test GPUCompiler.relocation_lowering(job) === :bake
        @test !GPUCompiler.can_persist_results(job)
    end
end

# The state field the table travels in is always present, so the layout does not depend on
# what a kernel happens to reference.
@test :reloc_table in fieldnames(Metal.KernelState)

# inspect the relocation records a kernel would carry (before any lowering)
kernel_relocations(@nospecialize(f), @nospecialize(tt)) =
    GPUCompiler.JuliaContext() do ctx
        _, meta = GPUCompiler.compile_unhooked(:llvm, kernel_job(f, tt);
                                               resolve_relocations=false)
        meta.relocations
    end

# Most kernels are relocation-free: Metal doesn't use the Julia runtime and optimization
# folds host-object references away. Those carry an empty table and stay fully portable.
@testset "relocation-free kernels" begin
    a = MtlArray(Float32[1, 2, 3, 4])
    @test Array(a .+ 1f0) == Float32[2, 3, 4, 5]
    @test sum(a) == 10f0

    b = MtlArray(Int32[1, 2, 3])
    @test Array(b .* 2) == Int32[2, 4, 6]

    # a bounds-checked (throwing) kernel exercises the exception runtime
    function checked!(x)
        i = thread_position_in_grid_1d()
        x[i] = x[i] + 1f0   # no @inbounds
        return
    end
    c = Metal.zeros(Float32, 8)
    @metal threads=8 checked!(c)
    synchronize()
    @test all(Array(c) .== 1f0)

    # such a kernel carries no relocations, hence no table buffer at all
    tt = Tuple{MtlDeviceVector{Float32,1}}
    @test isempty(kernel_relocations(checked!, tt))
    @test Metal.mtlfunction(checked!, tt).reloc_table === nothing
end

# Some kernels DO carry relocations — the same Julia-level sources as on CUDA (type tags,
# boxed values and constants). Metal has no post-load symbol patching, so GPUCompiler rewrites
# each record into an indexed load from a table of words the loader hands over as run-time
# data: a small buffer whose device address rides in the `KernelState`
# (`Metal.reloc_table_buffer`). These tests cover each expressible source and the GPUCompiler
# relocation patterns behind them, launched on-device for correctness.

# a non-smalltag isbits struct, for the `isa`-on-boxed relocation source
struct RelocRGB
    r::Int32
    g::Int32
    b::Int32
end

const _reloc_type_tag = GPUCompiler.Runtime.type_tag
reloc_typetag_kernel(out) = (@inbounds out[1] = _reloc_type_tag(Val(:float32)); return)

@noinline _reloc_produce(cond::Bool, a::Int32) = cond ? RelocRGB(a, a, a) : RelocRGB(11, 22, 33)
function reloc_isa_kernel(out, cond::Bool, a::Int32)
    x = _reloc_produce(cond, a)
    @inbounds out[1] = x isa RelocRGB ? UInt(x.r) : UInt(999)
    return
end

# a type-unstable producer whose *constant* leaf is the non-smalltag struct, materializing
# a boxed replica with a relocatable (DataType) header word
@noinline _reloc_produce_const(cond::Bool, a::Int32) = cond ? a : RelocRGB(11, 22, 33)
function reloc_dt_kernel(out, cond::Bool, a::Int32)
    x = _reloc_produce_const(cond, a)
    @inbounds out[1] = x isa RelocRGB ? x.r : Int32(-2)
    return
end

# an interned Symbol passed as a kernel *argument*, compared against module-level Symbols
function reloc_sym_kernel(out, sym::Symbol)
    @inbounds out[1] = sym === :foo ? Int32(1) : (sym === :bar ? Int32(2) : Int32(-1))
    return
end

@testset "relocation-carrying kernels" begin
    # 1. CGlobalRef: a runtime type tag reads a libjulia global (`jl_float32_type`).
    # The cglobal collector only runs for non-`:bake` lowerings at the `:llvm` stage, so
    # under the LLVM < 17 `:bake` fallback these records are not observable here.
    tt = Tuple{MtlDeviceVector{UInt,1}}
    if LLVM.version() >= v"17"
        tt_relocs = kernel_relocations(reloc_typetag_kernel, tt)
        @test !isempty(tt_relocs)
        @test any(rec -> rec.target isa GPUCompiler.CGlobalRef, tt_relocs.records)
    end

    out = Metal.zeros(UInt, 1)
    @metal threads=1 reloc_typetag_kernel(out)
    synchronize()
    # the word is resolved in this session, so it matches the host's current type-tag word
    @test Array(out)[1] == UInt(unsafe_load(cglobal(:jl_float32_type, Ptr{UInt})))

    # This kernel doubles as the canary for a dangling or misindexed table: only the address
    # of the words travels to the device, so a mistake there is a silently wrong `isa`
    # elsewhere. Here the expected word is known a priori, and the buffer must hold exactly
    # the resolved words in record order.
    if LLVM.version() >= v"17"
        kernel = Metal.mtlfunction(reloc_typetag_kernel, tt)
        @test kernel.reloc_table isa MTL.MTLBuffer
        relocs = Metal.compile_or_lookup(kernel_job(reloc_typetag_kernel, tt)).relocations
        words = GPUCompiler.resolved_relocation_table(relocs)
        ptr = convert(Ptr{UInt}, MTL.contents(kernel.reloc_table))
        @test [unsafe_load(ptr, i) for i in 1:length(words)] == words
    end

    # 2. JuliaValueRef: this kernel references a heap object through a whole-word slot (a
    #    Symbol — from the `UInt(x.r)` conversion's `InexactError` path, not from the `isa`,
    #    which only tests the union selector byte).
    # Julia-value records only exist where codegen emits relocatable global declarations;
    # on 1.10 it embeds the addresses as `inttoptr` constants instead, leaving nothing for
    # the collector to see (`GPUCompiler.supports_relocatable_ir`).
    if GPUCompiler.supports_relocatable_ir()
        isa_relocs = kernel_relocations(reloc_isa_kernel,
                                        Tuple{MtlDeviceVector{UInt,1}, Bool, Int32})
        @test !isempty(isa_relocs)
        @test any(rec -> rec.target isa GPUCompiler.JuliaValueRef, isa_relocs.records)
    end

    out = Metal.zeros(UInt, 1)
    @metal threads=1 reloc_isa_kernel(out, false, Int32(5))
    synchronize()
    @test Array(out)[1] == 11   # RelocRGB(11,22,33).r

    out = Metal.zeros(UInt, 1)
    @metal threads=1 reloc_isa_kernel(out, true, Int32(7))
    synchronize()
    @test Array(out)[1] == 7    # RelocRGB(7,7,7).r

    # 3. JuliaValueRef(DataType): a non-smalltag isbits *constant* in a type-unstable
    #    position materializes a boxed replica whose header word is an interior relocation
    #    targeting the type. Boxed-union kernels need `demote_boxed_constants!`
    #    (LLVM 17+ / Julia 1.12+).
    if LLVM.version() >= v"17"
        dt_relocs = kernel_relocations(reloc_dt_kernel,
                                       Tuple{MtlDeviceVector{Int32,1}, Bool, Int32})
        @test any(rec -> rec.target isa GPUCompiler.JuliaValueRef &&
                         rec.target.value === RelocRGB, dt_relocs.records)
        @test any(rec -> rec.kind === GPUCompiler.InteriorSite, dt_relocs.records)

        # Launching this kernel used to be broken (the extinit box survived to a downgrade-
        # incompatible shape). The `:table` lowering demotes the relocatable box to a
        # per-function alloca whose header word is loaded from the table, so both union
        # alternatives become plain thread-memory pointers and the kernel builds and runs.
        out = Metal.zeros(Int32, 1)
        @metal threads=1 reloc_dt_kernel(out, false, Int32(7))
        synchronize()
        @test Array(out)[1] == 11   # the boxed constant's payload (RelocRGB(11,22,33).r)

        out = Metal.zeros(Int32, 1)
        @metal threads=1 reloc_dt_kernel(out, true, Int32(7))
        synchronize()
        @test Array(out)[1] == -2   # the inline (non-box) alternative
    end

    # 4. JuliaValueRef(Symbol) compared against a runtime *argument* — CUDA's `name === sym`
    #    shape, and the one relocation source whose other operand does not come from the
    #    module: a `Symbol` has no fields, so the host passes its bare address word and the
    #    kernel compares that against its own resolved word for `:foo`/`:bar`.
    if GPUCompiler.supports_relocatable_ir()
        sym_relocs = kernel_relocations(reloc_sym_kernel,
                                        Tuple{MtlDeviceVector{Int32,1}, Symbol})
        @test any(rec -> rec.target isa GPUCompiler.JuliaValueRef && rec.target.value === :foo,
                  sym_relocs.records)
    end

    out = Metal.zeros(Int32, 1)
    for (sym, expected) in ((:foo, 1), (:bar, 2), (:baz, -1))
        @metal threads=1 reloc_sym_kernel(out, sym)
        synchronize()
        @test Array(out)[1] == expected
    end
end

# Delivering relocations as run-time data keeps every session value out of the metallib, so a
# relocation-carrying kernel compiles to byte-identical bytes across repeated compiles in a
# session — strictly stronger than under function constants, where the AIR still had to name
# the constants deterministically. This restores pkgimage persistence and content-keyed
# archive hits for these kernels.
#
# The two kernels that carry a relocation *in the final metallib* — the type-tag (`cglobal`)
# and the DataType box — are asserted stable. The `isa` kernel's symbol relocation is
# optimized away entirely (it becomes relocation-free), and its inlined `InexactError`
# thrower leaks Julia's per-session codegen counter into block labels / inlined debug
# metadata; that residual debug-info non-determinism is the same one that keeps the archive
# cache off (see src/compiler/archive.jl) and is out of scope here, as is cross-process
# determinism.
@testset "byte-stable metallibs" begin
    kernel_metallib(@nospecialize(f), @nospecialize(tt)) =
        Metal.compile_to_metallib(kernel_job(f, tt)).metallib

    # byte-stability is a property of the `:table` lowering; on LLVM < 17 Metal bakes
    # session addresses instead, and the DataType-box kernel cannot compile at all
    if LLVM.version() >= v"17"
        for (f, tt) in ((reloc_typetag_kernel, Tuple{MtlDeviceVector{UInt,1}}),
                        (reloc_dt_kernel, Tuple{MtlDeviceVector{Int32,1}, Bool, Int32}))
            lib1 = kernel_metallib(f, tt)
            lib2 = kernel_metallib(f, tt)
            # on mismatch, preserve both libraries for offline comparison (uploaded as CI
            # artifacts by `dump_artifacts`); the failure reproduces on CI but not locally
            lib1 == lib2 || Metal.dump_artifacts(".a.metallib" => lib1, ".b.metallib" => lib2)
            @test lib1 == lib2
        end
    end
end

# `compile_to_metallib` returns the (session-portable) relocation manifest: `nothing` for a
# relocation-free kernel, a populated `Relocations` for kernels that carry records through to
# the metallib (type-tag `cglobal`, DataType box).
@testset "relocation manifest" begin
    kernel_manifest(@nospecialize(f), @nospecialize(tt)) =
        Metal.compile_to_metallib(kernel_job(f, tt)).relocations

    @test kernel_manifest(identity, Tuple{Nothing}) === nothing
    # populated manifests are a `:table` property; `:bake` (LLVM < 17) resolves eagerly
    # and stores the relocation-free marker
    if LLVM.version() >= v"17"
        for (f, tt) in ((reloc_typetag_kernel, Tuple{MtlDeviceVector{UInt,1}}),
                        (reloc_dt_kernel, Tuple{MtlDeviceVector{Int32,1}, Bool, Int32}))
            relocs = kernel_manifest(f, tt)
            @test relocs isa GPUCompiler.Relocations
            @test !isempty(relocs)
        end
    end
end
