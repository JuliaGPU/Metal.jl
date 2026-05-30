# local method table for device functions
Base.Experimental.@MethodTable(method_table)

# throw a device-side exception, recording its type name and reason in the exception
# mailbox so the host can report them (see `device/runtime.jl`, `compiler/exceptions.jl`).
macro gputhrow(name::String, reason::String)
    name_q = QuoteNode(Symbol(name))
    reason_q = QuoteNode(Symbol(reason))
    return quote
        info = kernel_state().exception_info
        if lock_output!(info)
            store_string!(info, Val(EXCEPTION_NAME_OFFSET),   Val(EXCEPTION_NAME_LEN),   Val($name_q))
            store_string!(info, Val(EXCEPTION_REASON_OFFSET), Val(EXCEPTION_REASON_LEN), Val($reason_q))
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
