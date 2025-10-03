# device runtime libraries


## Julia library

# reset the runtime cache from global scope, so that any change triggers recompilation
GPUCompiler.reset_runtime()

function signal_exception()
    return
end

function report_exception(ex)
    # @cuprintf("""
    #     ERROR: a %s was thrown during kernel execution.
    #            Run Julia on debug level 2 for device stack traces.
    #     """, ex)
    return
end

report_oom(sz) = return #@cuprintf("ERROR: Out of dynamic GPU memory (trying to allocate %i bytes)\n", sz)

function report_exception_name(ex)
    # @cuprintf("""
    #     ERROR: a %s was thrown during kernel execution.
    #     Stacktrace:
    #     """, ex)
    return
end

function report_exception_frame(idx, func, file, line)
    # @cuprintf(" [%i] %s at %s:%i\n", idx, func, file, line)
    return
end

## kernel state

struct KernelState
    random_seed::UInt32
end

@inline @generated kernel_state() = GPUCompiler.kernel_state_value(KernelState)
