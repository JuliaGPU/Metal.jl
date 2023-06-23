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

    macos=macos_version()

    # create GPUCompiler objects
    target = MetalCompilerTarget(macos; kwargs...)
    params = MetalCompilerParams()
    CompilerConfig(target, params; kernel, name, always_inline)
end

# compile to executable machine code
function compile(@nospecialize(job::CompilerJob))
    # TODO: on 1.9, this actually creates a context. cache those.
    image, meta = JuliaContext() do ctx
        GPUCompiler.compile(:obj, job)
    end
    entry = LLVM.name(meta.entry)

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
        metallib = tempname(cleanup=false) * ".metallib"
        write(metallib, compiled.image)
        error("""Compilation to native code failed; see below for details.
                 If you think this is a bug, please file an issue and attach $(metallib).""")
    end

    # most of the time, we don't need the function object,
    # so don't keep it alive unconditionally in GPUCompiler's caches
    pipeline_state, return_function ? fun : nothing
end
