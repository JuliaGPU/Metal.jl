
const MPSGRAPH_VALID_REDUCTION_TYPES = filter(T -> T <: Real && T != Bool, (MPS.jl_mps_to_typ |> values |> collect))

function reductionSumWithTensor(graph::MPSGraph, tensor::MPSGraphTensor,
                                axes::NSArray, name = "reduction_sum")
    @objc [graph::id{MPSGraph} reductionSumWithTensor:tensor::id{MPSGraphTensor}
                                                 axes:axes::id{NSArray}
                                                 name:name::id{NSString}]::MPSGraphTensor
end

function reductionProductWithTensor(graph::MPSGraph, tensor::MPSGraphTensor,
                                    axes::NSArray, name = "reduction_product")
    @objc [graph::id{MPSGraph} reductionProductWithTensor:tensor::id{MPSGraphTensor}
                                                     axes:axes::id{NSArray}
                                                     name:name::id{NSString}]::MPSGraphTensor
end

function reductionMaximumPropagateNaNWithTensor(graph::MPSGraph,
                                                tensor::MPSGraphTensor,
                                                axes::NSArray,
                                                name = "reduction_maximum")
    @objc [graph::id{MPSGraph} reductionMaximumPropagateNaNWithTensor:tensor::id{MPSGraphTensor}
                                                                 axes:axes::id{NSArray}
                                                                 name:name::id{NSString}]::MPSGraphTensor
end

function reductionMinimumPropagateNaNWithTensor(graph::MPSGraph,
                                                tensor::MPSGraphTensor,
                                                axes::NSArray,
                                                name = "reduction_minimum")
    @objc [graph::id{MPSGraph} reductionMinimumPropagateNaNWithTensor:tensor::id{MPSGraphTensor}
                                                                 axes:axes::id{NSArray}
                                                                 name:name::id{NSString}]::MPSGraphTensor
end

function reductionWithTensor(graph::MPSGraph, op::Symbol, tensor::MPSGraphTensor,
                             axes::NSArray, name = "reduction")
    if op === :sum
        reductionSumWithTensor(graph, tensor, axes, name)
    elseif op === :product
        reductionProductWithTensor(graph, tensor, axes, name)
    elseif op === :maximum
        reductionMaximumPropagateNaNWithTensor(graph, tensor, axes, name)
    elseif op === :minimum
        reductionMinimumPropagateNaNWithTensor(graph, tensor, axes, name)
    else
        throw(ArgumentError("unsupported reduction $op"))
    end
end


## array interface

reduction_operation(::typeof(+)) = :sum
reduction_operation(::typeof(Base.add_sum)) = :sum
reduction_operation(::typeof(*)) = :product
reduction_operation(::typeof(Base.mul_prod)) = :product
reduction_operation(::typeof(max)) = :maximum
reduction_operation(::typeof(min)) = :minimum
reduction_operation(op) = nothing

function reduction_function(op)
    name = reduction_operation(op)
    return name === :sum ? (+) : name === :product ? (*) : name === :maximum ? max : min
end

"""
    MPSGraphs.reduce!(op, R, A; init=nothing) -> R

Reduce `A` with `op` along every dimension where `R` has extent 1 and `A` does not, and
store the result in `R`, overwriting its contents.

`op` is one of `+`, `*`, `max` and `min` (or `Base.add_sum` and `Base.mul_prod`). `R` and `A`
are `MtlArray`s of the same rank and the same real element type `T`: `Float32`, `Float16`,
`BFloat16`, or a signed or unsigned integer of 8 to 64 bits. Each dimension of `R` has the
extent of `A` in that dimension, or 1. `R` must not overlap `A`.

If `init` is given, it must be a `T`, and every element of `R` is `op(init, x)`, where `x`
is the reduction of the corresponding elements of `A`; `init` is applied exactly once. If
`A` is empty along a reduced dimension, the result is `init`, or without `init` zero for
`+` and one for `*` (`max` and `min` then require `init`).

The results can differ from `Base.reduce`:
- floating-point sums and products are associated differently, and may round differently;
- integer sums and products wrap around on overflow in `T`; they are not widened;
- `max` and `min` propagate NaN like Base, but the sign of a zero result is unspecified
  (`max(0.0, -0.0)` may return `-0.0`), and a sum of negative zeros may return `0.0`.

The reduction executes asynchronously, ordered with the other work submitted from the
current task (kernels, copies, other MPSGraph operations).

Use [`MPSGraphs.supports`](@ref) to check whether a call is supported without throwing.
"""
function reduce!(op, R, A; init=nothing)
    check_supported(reduce!, op, R, A; init)
    T = eltype(A)
    isempty(R) && return R
    if isempty(A)
        return fill!(R, something(init, reduction_neutral(op, T)))
    end

    shape, reduced = reduction_layout(size(R), size(A))
    if !any(reduced)
        # `op` itself may widen (`Base.add_sum`), so apply the operator it stands for
        init === nothing ? copyto!(R, A) : (R .= reduction_function(op).(init, A))
        return R
    end
    key = ReductionGraphKey{T}(shape, reduced, reduction_operation(op), init)
    run!(cached_graph(key), (reshape(R, reduced_shape(key)),), (reshape(A, shape),))
    return R
end

function unsupported(::typeof(reduce!), op, R, A; init=nothing)
    err = unsupported_arrays(R, A)
    err === nothing || return err
    T = eltype(A)
    eltype(R) == T ||
        return ArgumentError("MPSGraph reductions require the output and input to have the same element type, got $(eltype(R)) and $T")
    T <: Union{MPSGRAPH_VALID_REDUCTION_TYPES...} ||
        return ArgumentError("MPSGraph reductions do not support element type $T")
    reduction_operation(op) === nothing &&
        return ArgumentError("MPSGraph reductions support +, *, max and min, got $op")
    init === nothing || init isa T ||
        return ArgumentError("MPSGraph reductions require `init` to be a $T, got a $(typeof(init))")
    ndims(R) == ndims(A) ||
        return DimensionMismatch("output has $(ndims(R)) dimensions, input has $(ndims(A))")
    all(d -> size(R, d) == size(A, d) || size(R, d) == 1, 1:ndims(A)) ||
        return DimensionMismatch("output has dimensions $(size(R)), input has dimensions $(size(A))")
    if isempty(A) && !isempty(R) && init === nothing && reduction_operation(op) in (:maximum, :minimum)
        return ArgumentError("reducing over an empty collection is not allowed; consider supplying `init`")
    end
    length(first(reduction_layout(size(R), size(A)))) <= 16 ||
        return ArgumentError("MPSGraph reductions support up to 16 alternating reduced and kept dimensions")
    return nothing
end

reduction_neutral(op, ::Type{T}) where {T} =
    reduction_operation(op) === :sum ? zero(T) : one(T)

# The reduction on `A` with the fewest dimensions: drop singletons, and merge neighboring
# dimensions that are both reduced or both kept. Besides keeping cache keys canonical, this
# keeps most reductions within the four innermost dimensions, the only ones MPS on older
# macOS versions reportedly reduces along.
function reduction_layout(Rsize::Dims, Asize::Dims)
    shape = Int[]
    reduced = Bool[]
    for (r, a) in zip(Rsize, Asize)
        a == 1 && continue
        red = r != a
        if !isempty(reduced) && reduced[end] == red
            shape[end] *= a
        else
            push!(shape, a)
            push!(reduced, red)
        end
    end
    return Tuple(shape), Tuple(reduced)
end

struct ReductionGraphKey{T}
    shape::Tuple{Vararg{Int}}
    reduced::Tuple{Vararg{Bool}}
    op::Symbol
    init::Union{Nothing, T}
end

reduced_shape(key::ReductionGraphKey) = map((n, r) -> r ? 1 : n, key.shape, key.reduced)

function build_graph(key::ReductionGraphKey{T}) where {T}
    graph = MPSGraph()
    x = placeholderTensor(graph, key.shape, T)
    axes = NSArray([NSNumber(mps_axis(key.shape, d)) for d in eachindex(key.shape)
                    if key.reduced[d]])
    result = reductionWithTensor(graph, key.op, x, axes)
    result = reshapeTensor(graph, result, convert(MPSShape, reverse(reduced_shape(key))))
    key.init === nothing && return CachedGraph(graph, [x], [result])
    init = placeholderTensor(graph, (1,), T)
    result = binary_operation(graph, key.op, T, init, result)
    return CachedGraph(graph, [x], [result]; constants=[init => MtlArray([key.init])])
end
