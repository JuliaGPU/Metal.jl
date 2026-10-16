# array-level operations: validation shared by the operations and `supports`

"""
    MPSGraphs.supports(f, args...; kwargs...)::Bool

Return whether the MPSGraph operation `f` supports being called as `f(args...; kwargs...)`:
whether the arguments' types, shapes, element types, memory layout and options are ones
that `f` handles on the current device. Calling `f` with arguments for which this returns
`false` throws an `ArgumentError` or `DimensionMismatch`.

The check only inspects the arguments; it does not build or run any graph. It can be used
to decide whether to use an MPSGraph operation or fall back to another implementation,
without duplicating the operation's requirements.

```julia
if MPSGraphs.supports(MPSGraphs.reduce!, +, R, A)
    MPSGraphs.reduce!(+, R, A)
else
    sum!(R, A)
end
```
"""
supports(f, args...; kwargs...) = unsupported(f, args...; kwargs...) === nothing

# Each operation `f` defines `unsupported(::typeof(f), args...; kwargs...)`, returning the
# exception `f` would throw for these arguments, or `nothing` if they are supported.
function unsupported end

function check_supported(f, args...; kwargs...)
    err = unsupported(f, args...; kwargs...)
    err === nothing || throw(err)
    return
end

# common requirements for the arrays passed to graph operations
function unsupported_array(A)
    A isa MtlArray || return ArgumentError("MPSGraph operations require MtlArray arguments, got a $(typeof(A))")
    MPS.is_supported(device(A)) ||
        return ArgumentError("MPSGraph is not supported on $(device(A).name)")
    # MPS silently reads garbage at misaligned offsets
    A.offset % sizeof(eltype(A)) == 0 ||
        return ArgumentError("MPSGraph operations require arrays at an offset that is a multiple of their element size")
    return nothing
end
function unsupported_arrays(As...)
    for A in As
        err = unsupported_array(A)
        err === nothing || return err
    end
    return nothing
end
