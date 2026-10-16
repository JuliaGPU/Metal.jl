const MPSGRAPH_VALID_SCAN_TYPES = filter(T -> T <: Real && T != Bool, (MPS.jl_mps_to_typ |> values |> collect))

function cumulativeSumWithTensor(graph::MPSGraph, tensor::MPSGraphTensor,
                                 axis::Integer, exclusive::Bool,
                                 reverse::Bool, name = "cumulative_sum")
    @objc [graph::id{MPSGraph} cumulativeSumWithTensor:tensor::id{MPSGraphTensor}
                                                  axis:axis::NSInteger
                                             exclusive:exclusive::Bool
                                               reverse:reverse::Bool
                                                  name:name::id{NSString}]::MPSGraphTensor
end

function cumulativeProductWithTensor(graph::MPSGraph, tensor::MPSGraphTensor,
                                     axis::Integer, exclusive::Bool,
                                     reverse::Bool, name = "cumulative_product")
    @objc [graph::id{MPSGraph} cumulativeProductWithTensor:tensor::id{MPSGraphTensor}
                                                      axis:axis::NSInteger
                                                 exclusive:exclusive::Bool
                                                   reverse:reverse::Bool
                                                      name:name::id{NSString}]::MPSGraphTensor
end

function cumulativeMaximumWithTensor(graph::MPSGraph, tensor::MPSGraphTensor,
                                     axis::Integer, exclusive::Bool,
                                     reverse::Bool, name = "cumulative_maximum")
    @objc [graph::id{MPSGraph} cumulativeMaximumWithTensor:tensor::id{MPSGraphTensor}
                                                      axis:axis::NSInteger
                                                 exclusive:exclusive::Bool
                                                   reverse:reverse::Bool
                                                      name:name::id{NSString}]::MPSGraphTensor
end

function cumulativeMinimumWithTensor(graph::MPSGraph, tensor::MPSGraphTensor,
                                     axis::Integer, exclusive::Bool,
                                     reverse::Bool, name = "cumulative_minimum")
    @objc [graph::id{MPSGraph} cumulativeMinimumWithTensor:tensor::id{MPSGraphTensor}
                                                      axis:axis::NSInteger
                                                 exclusive:exclusive::Bool
                                                   reverse:reverse::Bool
                                                      name:name::id{NSString}]::MPSGraphTensor
end

function scanWithTensor(graph::MPSGraph, op::Symbol, tensor::MPSGraphTensor,
                        axis::Integer, exclusive::Bool, reverse::Bool, name = "scan")
    if op === :sum
        cumulativeSumWithTensor(graph, tensor, axis, exclusive, reverse, name)
    elseif op === :product
        cumulativeProductWithTensor(graph, tensor, axis, exclusive, reverse, name)
    elseif op === :minimum
        cumulativeMinimumWithTensor(graph, tensor, axis, exclusive, reverse, name)
    elseif op === :maximum
        cumulativeMaximumWithTensor(graph, tensor, axis, exclusive, reverse, name)
    else
        throw(ArgumentError("unsupported scan $op"))
    end
end


## array interface

# MPSGraph's cumulative max/min ignore NaNs, unlike Base's `max`/`min`
scan_operation(::Type, ::typeof(+)) = :sum
scan_operation(::Type, ::typeof(Base.add_sum)) = :sum
scan_operation(::Type, ::typeof(*)) = :product
scan_operation(::Type, ::typeof(Base.mul_prod)) = :product
scan_operation(::Type{<:Integer}, ::typeof(min)) = :minimum
scan_operation(::Type{<:Integer}, ::typeof(max)) = :maximum
scan_operation(::Type, op) = nothing

"""
    MPSGraphs.accumulate!(op, B, A; dims=nothing, init=nothing, inclusive=true, rev=false) -> B

Compute the cumulative `op` of `A` along dimension `dims`, and store it in `B`. `dims` can
only be omitted for vectors.

`op` is `+` or `*` (or `Base.add_sum` and `Base.mul_prod`), and for integers also `max` or
`min`. `B` and `A` are `MtlArray`s of the same size and the same real element type `T`:
`Float32`, `Float16`, `BFloat16`, or a signed or unsigned integer of 8 to 64 bits. `B` may
be `A`, but must not otherwise overlap it.

With `inclusive=true`, element `i` along `dims` combines elements `1` through `i` of `A`;
with `inclusive=false` it combines elements `1` through `i-1`, so the first is the
identity of `op`. `rev=true` accumulates from the end instead. If `init` is given, it must
be a `T`, and every result `x` becomes `op(init, x)`; for an exclusive scan, the first
element is `init`.

As with [`MPSGraphs.reduce!`](@ref), floating-point results can round differently from
Base, integer results wrap around on overflow, and the operation executes asynchronously,
ordered with the other work submitted from the current task.

Use [`MPSGraphs.supports`](@ref) to check whether a call is supported without throwing.
"""
function accumulate!(op, B, A; dims=nothing, init=nothing, inclusive::Bool=true,
                     rev::Bool=false)
    check_supported(accumulate!, op, B, A; dims, init, inclusive, rev)
    isempty(A) && return B
    T = eltype(A)

    # scan along one dimension of an array of at most three, the dimensions before and after
    # it merged; MPS on older macOS versions can only scan along the four innermost
    # dimensions, and extra singleton dimensions make MPS slower
    dim = something(dims, 1)
    sz = size(A)
    before, after = prod(sz[1:dim-1]), prod(sz[dim+1:end])
    shape = ((before == 1 ? () : (before,))..., sz[dim], (after == 1 ? () : (after,))...)
    axis = before == 1 ? 1 : 2
    key = ScanGraphKey{T}(shape, axis, scan_operation(T, op), init, inclusive, rev)
    run!(cached_graph(key), (reshape(B, shape),), (reshape(A, shape),))
    return B
end

function unsupported(::typeof(accumulate!), op, B, A; dims=nothing, init=nothing,
                     inclusive::Bool=true, rev::Bool=false)
    err = unsupported_arrays(B, A)
    err === nothing || return err
    T = eltype(A)
    eltype(B) == T ||
        return ArgumentError("MPSGraph scans require the output and input to have the same element type, got $(eltype(B)) and $T")
    T <: Union{MPSGRAPH_VALID_SCAN_TYPES...} ||
        return ArgumentError("MPSGraph scans do not support element type $T")
    scan_operation(T, op) === nothing &&
        return ArgumentError("MPSGraph scans support + and *, and max and min for integers, got $op for $T")
    init === nothing || init isa T ||
        return ArgumentError("MPSGraph scans require `init` to be a $T, got a $(typeof(init))")
    size(B) == size(A) ||
        return DimensionMismatch("output has dimensions $(size(B)), input has dimensions $(size(A))")
    return unsupported_dims(A, dims)
end

struct ScanGraphKey{T}
    shape::Tuple{Vararg{Int}}
    axis::Int
    op::Symbol
    init::Union{Nothing, T}
    inclusive::Bool
    rev::Bool
end

function build_graph(key::ScanGraphKey{T}) where {T}
    graph = MPSGraph()
    x = placeholderTensor(graph, key.shape, T)
    result = scanWithTensor(graph, key.op, x, mps_axis(key.shape, key.axis), !key.inclusive,
                            key.rev)
    key.init === nothing && return CachedGraph(graph, [x], [result])
    init = placeholderTensor(graph, (1,), T)
    result = binary_operation(graph, key.op, T, init, result)
    return CachedGraph(graph, [x], [result]; constants=[init => MtlArray([key.init])])
end
