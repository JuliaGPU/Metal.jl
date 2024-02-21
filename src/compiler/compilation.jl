## gpucompiler interface implementation

struct MetalCompilerParams <: AbstractCompilerParams end
const MetalCompilerConfig = CompilerConfig{MetalCompilerTarget, MetalCompilerParams}
const MetalCompilerJob = CompilerJob{MetalCompilerTarget, MetalCompilerParams}

GPUCompiler.runtime_module(::MetalCompilerJob) = Metal

const ci_cache = GPUCompiler.CodeCache()
GPUCompiler.ci_cache(::MetalCompilerJob) = ci_cache

GPUCompiler.method_table(::MetalCompilerJob) = method_table


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
@noinline function _compiler_config(dev; kernel=true, name=nothing, always_inline=false, kwargs...)
    # TODO: configure the compiler target based on the device

    macos = macos_version()
    metal = metal_support()
    # we support down to macOS 10.13, which support AIR 2.5
    # so always target that version for now
    air = v"2.5"
    @assert air <= air_support()

    # create GPUCompiler objects
    target = MetalCompilerTarget(; macos, air, metal, kwargs...)
    params = MetalCompilerParams()
    CompilerConfig(target, params; kernel, name, always_inline)
end

# compile to executable machine code
function compile(@nospecialize(job::CompilerJob))
    # TODO: on 1.9, this actually creates a context. cache those.
    ir, entry = JuliaContext() do ctx
        mod, meta = GPUCompiler.compile(:llvm, job)
        string(mod), LLVM.name(meta.entry)
    end

    # generate AIR
    air = let
        input = Pipe()
        output = Pipe()

        cmd = `$(LLVMDowngrader_jll.llvm_as()) --bitcode-version=5.0 -o -`
        proc = run(pipeline(cmd, stdout=output, stderr=stderr, stdin=input); wait=false)
        close(output.in)

        writer = @async begin
            write(input, ir)
            close(input)
        end
        reader = @async read(output)

        wait(proc)
        if !success(proc)
            file = tempname(cleanup=false) * ".ll"
            write(file, ir)
            error("""Compilation to AIR failed; see above for details.
                     If you think this is a bug, please file an issue and attach $(file)""")
        end
        fetch(reader)
    end

    # create a Metal library
    image = try
        metallib_fun = MetalLibFunction(entry, air;
                                        air_version=job.config.target.air,
                                        metal_version=job.config.target.metal)
        metallib = MetalLib(; functions = [metallib_fun])

        image_stream = IOBuffer()
        write(image_stream, metallib)
        take!(image_stream)
    catch err
        file = tempname(cleanup=false) * ".air"
        write(file, air)
        error("""Compilation to Metal library failed; see below for details.
                 If you think this is a bug, please file an issue and attach $(file)""")
    end

    return (; image, entry)
end

# link into an executable kernel
function link(@nospecialize(job::CompilerJob), compiled; return_function=false)
    dev = current_device()
    lib = MTLLibraryFromData(dev, compiled.image)
    fun = MTLFunction(lib, compiled.entry)
    pipeline_state = try
        MTLComputePipelineState(dev, fun)
    catch err
        isa(err, NSError) || rethrow()

        # the back-end compiler likely failed
        # XXX: check more accurately? the error domain doesn't help much here
        file = tempname(cleanup=false) * ".metallib"
        write(file, compiled.image)
        error("""Compilation to native code failed; see below for details.
                 If you think this is a bug, please file an issue and attach $(file)""")
    end

    # most of the time, we don't need the function object,
    # so don't keep it alive unconditionally in GPUCompiler's caches
    pipeline_state, return_function ? fun : nothing
end
