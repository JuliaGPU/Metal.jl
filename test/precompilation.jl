using GPUCompiler
using LLVM: LLVM

# `:table` restores `can_persist_results`, so compiled kernels ride in the package image
# and a fresh session can launch them without invoking the compiler. This is demonstrated
# with a user package that precompiles a broadcast kernel; a separate process then launches
# it and counts compiler invocations (`Metal.compilations`).
#
# On Julia 1.13, external CodeInstances from a precompile workload survive only flakily (a
# known Julia serialization bug — GPUCompiler's own precompile test skips the equivalent
# check on 1.13). The zero-compilation goal is therefore marked `broken` there and should
# flip to a pass once Julia fixes external-CI serialization.

# the mechanism itself; on LLVM < 17 (Julia < 1.12) Metal falls back to session-local
# `:bake` and forgoes persistence, and the boxed-union workload kernel cannot compile,
# so the whole demonstration is 1.12+
if GPUCompiler.supports_relocatable_ir() && LLVM.version() >= v"17"
    local dev = Metal.device()
    local cfg = Metal.compiler_config(dev; kernel=true, name=nothing)
    local src = Metal.methodinstance(typeof(identity), Tuple{Nothing}, Base.get_world_counter())
    local job = GPUCompiler.CompilerJob(src, cfg, Base.get_world_counter())
    @test GPUCompiler.can_persist_results(job)

    # the main Metal project resolves Metal + PrecompileTools (+ the dev'd GPUCompiler)
    metal_project = joinpath(dirname(dirname(pathof(Metal))), "Project.toml")
    mktempdir() do load_path
        # The workload precompiles both a plain (relocation-free) broadcast kernel and a
        # relocation-carrying kernel: the isbits-`Union` return boxes a non-smalltag `RGB`
        # constant, whose header word is a `DataType` relocation. Delivering that word through
        # the kernel state's relocation table keeps the metallib session-portable, so it now
        # precompiles (the old session-local bake refused to). Both must launch in the fresh
        # process without re-invoking the compiler.
        write(joinpath(load_path, "MetalPersistWorkload.jl"), """
        module MetalPersistWorkload
        using Metal, PrecompileTools
        struct RGB; r::Int32; g::Int32; b::Int32; end
        @noinline produce(cond::Bool, a::Int32) = cond ? a : RGB(11, 22, 33)
        function reloc_kernel(out, cond::Bool, a::Int32)
            x = produce(cond, a)
            @inbounds out[1] = x isa RGB ? x.r : Int32(-2)
            return
        end
        @compile_workload begin
            let a = MtlArray(Float32[1, 2, 3])
                a .+ 1f0
                Metal.synchronize()
            end
            let out = Metal.zeros(Int32, 1)
                @metal threads=1 reloc_kernel(out, false, Int32(7))
                Metal.synchronize()
            end
        end
        end
        """)

        env = copy(ENV)
        env["JULIA_LOAD_PATH"] = join([load_path, metal_project, "@stdlib"], Sys.iswindows() ? ';' : ':')
        jl = Base.julia_cmd()
        # `julia_cmd` propagates `--code-coverage` from the parent (CI runs tests under
        # coverage), and a coverage-enabled session refuses precompiled code for the packages
        # it tracks — the fresh process would recompile everything, defeating exactly what
        # this test measures. Run the child sessions without coverage.
        filter!(arg -> !startswith(arg, "--code-coverage"), jl.exec)

        # process A: precompile the workload package
        run(setenv(`$jl -e 'using MetalPersistWorkload'`, env))

        # process B: fresh session — load the image, launch both kernels, count compiler
        # invocations. The relocation-carrying kernel must also produce correct results, with
        # its relocation table resolved in this session.
        proc_b = raw"""
        using MetalPersistWorkload, Metal
        using .MetalPersistWorkload: reloc_kernel
        c0 = Metal.compilations[]
        a = MtlArray(Float32[1, 2, 3])
        b = a .+ 1f0
        Metal.synchronize()
        out = Metal.zeros(Int32, 1)
        @metal threads=1 reloc_kernel(out, false, Int32(7))
        Metal.synchronize()
        println("RESULT=", Array(b) == Float32[2, 3, 4] && Array(out)[1] == 11)
        println("COMPILATIONS=", Metal.compilations[] - c0)
        """
        out = read(setenv(`$jl -e $proc_b`, env), String)

        result = contains(out, "RESULT=true")
        m = match(r"COMPILATIONS=(\d+)", out)
        compilations = m === nothing ? -1 : parse(Int, m.captures[1])

        @test result
        # the headline: zero compiler invocations in the warm session. On 1.13 external
        # CodeInstances survive only flakily (see above), so the count is skipped rather
        # than marked broken: a lucky run would otherwise error as an unexpected pass.
        # On 1.12 < 1.12.7, owned CodeInstances never revalidate after a cross-process
        # pkgimage load: `jl_record_edges` (staticdata_utils.c) skips empty-edge CIs,
        # leaving leaves like `Core.checked_trunc_sint` at the revalidation sentinel,
        # which transitively invalidates every kernel CI whose edge graph contains one.
        # The 1.13 serialization rework fixed this and 1.12.7 backported it (verified
        # empirically: 3 compilations on 1.12.6, 0 on 1.12.7); kernels still run on the
        # broken versions (recompiled once per session), so only the count is affected.
        if v"1.12-" <= VERSION < v"1.13-"
            # deterministic on 1.12: pre-1.12.7 always recompiles, 1.12.7+ never does
            @test compilations == 0 broken=(VERSION < v"1.12.7")
        else
            external_cis_flaky = v"1.13.0-" <= VERSION < v"1.14-"
            @test compilations == 0 skip=external_cis_flaky
        end
    end
end
