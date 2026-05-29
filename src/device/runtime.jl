# device runtime libraries


## Julia library

# reset the runtime cache from global scope, so that any change triggers recompilation
GPUCompiler.reset_runtime()

function signal_exception()
    # raise a host-visible flag so the exception isn't silently swallowed.
    ptr = kernel_state().exception_flag
    atomic_fetch_or_explicit(ptr, UInt32(1))
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

    # bump allocator buffer
    #
    # the first 4 bytes are an atomically-incremented counter; allocations
    # start at offset 4 and continue until the buffer is exhausted.
    malloc_buf::Core.LLVMPtr{UInt8, AS.Device}

    # device-side exception mailbox
    #
    # a single `UInt32` in a shared (host+device visible) buffer. `signal_exception`
    # atomically sets it when a device exception is thrown; the host reads it after
    # synchronizing (`check_exceptions`) and rethrows as a `KernelException`.
    exception_flag::Core.LLVMPtr{UInt32, AS.Device}
end

@inline @generated kernel_state() = GPUCompiler.kernel_state_value(KernelState)
