# World age captured at __init__ time. Used to invoke the GPU-compiler stack
# (typeinf_local etc.) in a frozen world so precompiled native code for that
# infrastructure keeps applying even when later method definitions would have
# invalidated it. This only freezes the *host-side* dispatch within the
# compiler pipeline: the user's kernel is still inferred and compiled against
# the user's current world, because GPUCompiler plumbs `tls_world_age()`
# through `CompilerJob.world` into `GPUInterpreter.world`, and the abstract
# interpreter uses that for all method lookups in user code (including overlay
# tables and `@device_override` methods). The sentinel `typemax(UInt)` means
# "use the current world", which `Base.invoke_in_world` clamps to — that's the
# correct behavior during precompilation (before `__init__` runs).
const _initialization_world = Ref{UInt}(typemax(UInt))

"""
    invoke_frozen(f, args...; kwargs...)

Invoke `f(args...; kwargs...)` in the world age captured at `__init__` time.
Lets precompiled native code for the GPU-compiler stack be reused even when
downstream packages add methods that would otherwise invalidate it. Method
lookups for the user's kernel are unaffected — see [`_initialization_world`].
"""
@inline function invoke_frozen(f, args...; kwargs...)
    if isempty(kwargs)
        return Base.invoke_in_world(_initialization_world[], f, args...)
    end
    kwargs = merge(NamedTuple(), kwargs)
    return Base.invoke_in_world(_initialization_world[], Core.kwcall, kwargs, f, args...)
end

@static if isdefined(Base, :OncePerProcess) # VERSION >= v"1.12.0-DEV.1421"
    const functional = OncePerProcess{Bool}() do
        try
            dev = device()
            return supports_family(dev, MTL.MTLGPUFamilyApple7) &&
            supports_family(dev, MTL.MTLGPUFamilyMetal3)
        catch
            return false
        end
    end
else
    # Becomes `nothing` once it has been determined that the device is on macOS
    const _functional = Ref{Union{Nothing,Bool}}(false)

    function functional()
        if isnothing(_functional[])
            dev = device()

            _functional[] =
                supports_family(dev, MTL.MTLGPUFamilyApple7) &&
                supports_family(dev, MTL.MTLGPUFamilyMetal3)
        end
        _functional[]
    end
end

function __init__()
    precompiling = ccall(:jl_generating_output, Cint, ()) != 0
    precompiling && return

    if !Sys.isapple()
        @error "Metal.jl is only supported on macOS"
        return
    end

    if macos_version() < v"13"
        @error "Metal.jl requires macOS 13 or later"
        return
    elseif macos_version() >= v"27"
        @warn "Metal.jl has not been tested on macOS 27 or later, you may run into issues."
    end

    if Base.JLOptions().debug_level >= 2
        # enable Metal API validation
        ENV["MTL_DEBUG_LAYER"] = "1"
        # ... but make it non-fatal
        ENV["MTL_DEBUG_LAYER_ERROR_MODE"] = "nslog"
        ENV["MTL_DEBUG_LAYER_WARNING_MODE"] = "nslog"

        # enable Metal shader validation
        ENV["MTL_SHADER_VALIDATION"] = "4"
    end

    @autoreleasepool try
        load_framework("CoreGraphics")
        load_framework("MetalPerformanceShadersGraph")
        ver = MTL.MTLCompileOptions().languageVersion
        @debug "Successfully loaded Metal; targeting v$ver."

        # Successful loading of CoreGraphics means there's a
        # chance the graphics device is supported
        if @isdefined _functional
            _functional[] = nothing  # VERSION <= v"1.12.0-DEV.1421"
        end
    catch err
        @error "Failed to load Metal" exception=(err,catch_backtrace())
        return
    end

    # ensure that operations executed by the REPL back-end finish before returning,
    # because displaying values happens on a different task
    if isdefined(Base, :active_repl_backend) && !isnothing(Base.active_repl_backend)
        push!(Base.active_repl_backend.ast_transforms, synchronize_metal_tasks)
    end

    # Capture the world age last, so the GPU-compiler stack runs in the world we
    # finished initialization in. Methods defined by downstream packages after
    # this point won't invalidate the precompiled GPUCompiler infrastructure.
    _initialization_world[] = Base.get_world_counter()
end

function synchronize_metal_tasks(ex)
    quote
        try
            $(ex)
        finally
            if haskey($task_local_storage(), :MTLDevice)
                $device_synchronize()
            end
        end
    end
end
