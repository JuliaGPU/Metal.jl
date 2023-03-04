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


## getproperty and setproperty! generators

# the function below operate on a list of properties, which consists of tuples
# (getter, tye, setter), where `setter` is optional, and `type` can be a plain
# Symbol or type, or a pair in case a conversion needs to happen (by calling the
# destination type's constructor)

# generate a method body for `getproperty`
function emit_getproperties(obj, typ, field, properties)
    ex = nothing
    current = nothing
    for tup in properties
        property = tup[1]
        type = tup[2]
        if type isa Pair
            srcTyp, dstTyp = type
        else
            srcTyp = type
            dstTyp = type
        end

        test = :($field === $(QuoteNode(property)))

        body = quote
            val = @objc [$obj::id{$typ} $property]::$srcTyp
        end

        # if we're dealing with a typed object pointer, do a nil check and create an object
        if Meta.isexpr(srcTyp, :curly) && srcTyp.args[1] == :id
            objTyp = srcTyp.args[2]
            append!(body.args, (quote
                val == nil && return nothing
                val = $objTyp(val)
            end).args)
        end

        # convert the value, if necessary
        if srcTyp != dstTyp
            append!(body.args, (quote
                val = convert($dstTyp, val)
            end).args)
        end

        push!(body.args, :(return val))

        if ex === nothing
            current = Expr(:if, test, body)
            ex = current
        else
            new = Expr(:elseif, test, body)
            push!(current.args, new)
            current = new
        end
    end

    # finally, call getfield
    final = :(getfield($obj, f))
    push!(current.args, final)

    return ex
end

# same, but for `setproperty!`
function emit_setproperties(obj, typ, field, val, properties)
    ex = nothing
    current = nothing
    for tup in properties
        length(tup) == 3 || continue
        property = tup[1]
        type = tup[2]
        setter = tup[3]
        if type isa Pair
            srcTyp, dstTyp = type
        else
            srcTyp = type
            dstTyp = type
        end

        test = :($field === $(QuoteNode(property)))

        body = quote
            @objc [$obj::id{$typ} $setter:$val::$srcTyp]::Cvoid
        end

        if ex === nothing
            current = Expr(:if, test, body)
            ex = current
        else
            new = Expr(:elseif, test, body)
            push!(current.args, new)
            current = new
        end
    end

    # finally, call getfield
    final = :(getfield($obj, f))
    push!(current.args, final)

    return ex
end
