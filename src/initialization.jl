const _functional = Ref{Bool}(false)
functional() = _functional[]

function __init__()
    precompiling = ccall(:jl_generating_output, Cint, ()) != 0
    precompiling && return

    if !Sys.isapple()
        @error("Metal.jl is only supported on macOS")
        return
    end

    # we use Python_jll, but don't actually want its environment to be active
    # (this breaks the call to pygmentize in GPUCompiler).
    # XXX: the JLL should only set PYTHONHOME when the executable is called
    delete!(ENV, "PYTHONHOME")

    if Base.JLOptions().debug_level >= 2
        # enable Metal API validation
        ENV["MTL_DEBUG_LAYER"] = "1"
        # ... but make it non-fatal
        ENV["MTL_DEBUG_LAYER_ERROR_MODE"] = "nslog"
        ENV["MTL_DEBUG_LAYER_WARNING_MODE"] = "nslog"

        if macos_version() >= v"13"
            # enable Metal shader validation
            ENV["MTL_SHADER_VALIDATION"] = "4"
        end
    end

    @autoreleasepool try
        load_framework("CoreGraphics")
        ver = MTL.MTLCompileOptions().languageVersion
        @debug "Successfully loaded Metal; targeting v$ver."
        _functional[] = true
    catch err
        @error "Failed to load Metal" exception=(err,catch_backtrace())
        return
    end

    # ensure that operations executed by the REPL back-end finish before returning,
    # because displaying values happens on a different task
    if isdefined(Base, :active_repl_backend)
        push!(Base.active_repl_backend.ast_transforms, synchronize_metal_tasks)
    end

    @static if !isdefined(Base, :get_extension)
        @require SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b" begin
            include("../ext/SpecialFunctionsExt.jl")
        end
    end
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
