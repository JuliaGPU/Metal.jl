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
    if VERSION >= v"1.12.0-DEV.745" || v"1.11-rc1" <= VERSION < v"1.12-"
        # this requires that the overlay method f′ is consistent with f, i.e.,
        #   - if f(x) returns a value, f′(x) must return the identical value.
        #   - if f(x) throws an exception, f′(x) must also throw an exception
        #     (although the exceptions do not need to be identical).
        # in return, calls that only reach overlays through their error paths (e.g.
        # `checked_add` via `throw_overflowerr_binaryop`) remain eligible for concrete
        # evaluation, which e.g. keyword-argument handling relies on.
        esc(quote
            Base.Experimental.@consistent_overlay($method_table, $ex)
        end)
    else
        esc(quote
            Base.Experimental.@overlay($method_table, $ex)
        end)
    end
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
