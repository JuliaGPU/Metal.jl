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

macro device_override(ex)
    ex = macroexpand(__module__, ex)
    esc(quote
        Base.Experimental.@overlay($method_table, $ex)
    end)
end

macro device_function(ex)
    ex = macroexpand(__module__, ex)
    def = splitdef(ex)

    # generate a function that errors
    def[:body] = quote
        error("This function is not intended for use on the CPU")
    end

    esc(quote
        $(combinedef(def))
        @device_override $ex
    end)
end
