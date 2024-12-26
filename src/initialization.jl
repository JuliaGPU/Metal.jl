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
    elseif macos_version() >= v"16"
        @warn "Metal.jl has not been tested on macOS 16 or later, you may run into issues."
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
