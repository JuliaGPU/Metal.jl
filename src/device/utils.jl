# local method table for device functions
Base.Experimental.@MethodTable(method_table)

# throw a device-side exception, recording its type name and reason in the exception
# mailbox so the host can report them (see `device/runtime.jl`, `compiler/exceptions.jl`).
# the recording happens in a single out-of-line helper (`record_exception!`): GPUCompiler
# force-inlines throwing functions into their callers, so anything in this macro lands at
# every single throw site of every kernel.
macro gputhrow(name::String, reason::String)
    name_q = QuoteNode(Symbol(name))
    reason_q = QuoteNode(Symbol(reason))
    return quote
        # the gate folds to a constant, so `-g0` kernels don't even carry the call
        if kernel_debug_level() >= 1
            record_exception!(kernel_state().exception_info, Val($name_q), Val($reason_q))
        end
        throw(nothing)
    end
end

const HAS_CONSISTENT_OVERLAY = VERSION >= v"1.12.0-DEV.745" || v"1.11-rc1" <= VERSION < v"1.12-"

macro device_override(ex)
    esc(GPUToolbox.Overlays.device_override(__module__, GlobalRef(Metal, :method_table), ex))
end

macro device_function(ex)
    esc(GPUToolbox.Overlays.device_function(__module__, GlobalRef(Metal, :method_table), ex))
end
