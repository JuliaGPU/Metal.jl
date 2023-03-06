function unsafe_string_maybe(ptr::Cstring)
    if ptr == C_NULL
        return ""
    else
        return unsafe_string(ptr)
    end
end

function NsError_maybe(ptr::MtlError)
    if ptr === C_NULL
        return nothing
    else
        return MtlError(ptr)
    end
end


## redeclare enum values without a prefix

# this is useful when enum values from an underlying C library, typically prefixed for the
# lack of namespacing in C, are to be used in Julia where we do have module namespacing.
macro enum_without_prefix(enum, prefix)
    if isa(enum, Symbol)
        mod = __module__
    elseif Meta.isexpr(enum, :(.))
        mod = getfield(__module__, enum.args[1])
        enum = enum.args[2].value
    else
        error("Do not know how to refer to $enum")
    end
    enum = getfield(mod, enum)
    prefix = String(prefix)

    ex = quote end
    for instance in instances(enum)
        name = String(Symbol(instance))
        @assert startswith(name, prefix)
        push!(ex.args, :(const $(Symbol(name[length(prefix) + 1:end])) = $(mod).$(Symbol(name))))
    end

    return esc(ex)
end

##
Base.convert(::Type{MtResourceOptions}, val::UInt32) =
    MtResourceOptions(val)

##
"""
    @mtlthrows error_var function(..., error_var)

Marks that this Metal function has an argument error_var which
must be passed by reference in the underlying ccall, and when
the function returns checks that no error has been set.

Expands roughly to
```julia
error_var = Ref{MTLError}()
result = function(..., error_var)
error[] != C_NULL && throw(MtlError(error[]))
```
"""
macro mtlthrows(error, fun)
    expr = quote
        $error = Ref{MTLError}(C_NULL)
        result = $fun
        if $error[] != C_NULL
            throw(MtlError($(error)[]))
        end
        result
    end
    return esc(expr)
end
