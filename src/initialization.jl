function __init__()
    # ensure that operations executed by the REPL back-end finish before returning,
    # because displaying values happens on a different task
    if isdefined(Base, :active_repl_backend)
        push!(Base.active_repl_backend.ast_transforms, synchronize_metal_tasks)
    end

    if Base.JLOptions().debug_level >= 2
        # enable Metal API validation
        ENV["METAL_DEVICE_WRAPPER_TYPE"] = "1"
        # ... but make it non-fatal
        ENV["METAL_DEBUG_ERROR_MODE"] = "5"
        ENV["METAL_ERROR_MODE"] = "5"
    end
end

function synchronize_metal_tasks(ex)
    quote
        try
            $(ex)
        finally
            if haskey($task_local_storage(), :MtlDevice)
                $device_synchronize()
            end
        end
    end
end
