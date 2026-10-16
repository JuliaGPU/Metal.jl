const MPSGRAPH_VALID_SORT_TYPES = filter(T -> T <: Real, (MPS.jl_mps_to_typ |> values |> collect))
const MPSGRAPH_SORTPERM_INDEX_TYPES = Union{Int32, Int64}

function sortWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, axis::Integer,
                        descending::Bool, name = "sort")
    @objc [graph::id{MPSGraph} sortWithTensor:tensor::id{MPSGraphTensor}
                                         axis:axis::NSInteger
                                   descending:descending::Bool
                                         name:name::id{NSString}]::MPSGraphTensor
end

function argSortWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, axis::Integer,
                           descending::Bool, name = "argsort")
    @objc [graph::id{MPSGraph} argSortWithTensor:tensor::id{MPSGraphTensor}
                                            axis:axis::NSInteger
                                      descending:descending::Bool
                                            name:name::id{NSString}]::MPSGraphTensor
end

function coordinateAlongAxis(graph::MPSGraph, axis::Integer, shape::MPSShape,
                             name = "coordinate")
    @objc [graph::id{MPSGraph} coordinateAlongAxis:axis::NSInteger
                                         withShape:shape::id{MPSShape}
                                              name:name::id{NSString}]::MPSGraphTensor
end

struct SortGraphKey{T}
    shape::Tuple{Vararg{Int}}
    dim::Int
    descending::Bool
end

function build_graph(key::SortGraphKey{T}) where {T}
    graph = MPSGraph()
    place_x = placeholderTensor(graph, key.shape, T)
    result = sortWithTensor(graph, place_x, mps_axis(key.shape, key.dim),
                            key.descending, "sort")
    return CachedGraph(graph, [place_x], [result])
end

struct SortPermGraphKey{T, Ti}
    shape::Tuple{Vararg{Int}}
    dim::Int
    descending::Bool
end

function linear_sortperm_tensor(graph::MPSGraph, arg, key::SortPermGraphKey{T, Ti}) where {T, Ti}
    shape = key.shape
    mpsshape = convert(MPSShape, reverse(shape))
    axis_index = castTensor(graph, arg, Ti, "sortperm_axis_index")
    result = nothing

    for dim in 1:length(shape)
        coord = if dim == key.dim
            axis_index
        else
            coordinateAlongAxis(graph, mps_axis(shape, dim), mpsshape,
                                "sortperm_coordinate_$dim")
        end
        coord = castTensor(graph, coord, Ti, "sortperm_coordinate_cast_$dim")
        stride = dim == 1 ? 1 : prod(shape[1:dim - 1])
        term = if stride == 1
            coord
        else
            multiplicationWithPrimaryTensor(
                graph, coord, constantWithScalar(graph, stride, Ti),
                "sortperm_stride_$dim")
        end
        result = result === nothing ? term :
                 additionWithPrimaryTensor(graph, result, term, "sortperm_add_$dim")
    end

    return additionWithPrimaryTensor(graph, result, constantWithScalar(graph, 1, Ti),
                                     "sortperm_one_based")
end

function build_graph(key::SortPermGraphKey{T, Ti}) where {T, Ti}
    graph = MPSGraph()
    place_x = placeholderTensor(graph, key.shape, T)
    arg = argSortWithTensor(graph, place_x, mps_axis(key.shape, key.dim),
                            key.descending, "argsort")
    result = linear_sortperm_tensor(graph, arg, key)
    return CachedGraph(graph, [place_x], [result])
end

"""
    MPSGraphs.sort!(B, A; dims=nothing, rev=false) -> B

Sort `A` along dimension `dims` in ascending order (descending with `rev=true`), and store
the result in `B`. `dims` can only be omitted for vectors.

`B` and `A` are `MtlArray`s of the same size and the same real element type. `B` must not
overlap `A`. Elements are ordered with `isless`, so NaNs sort last.

The sort executes asynchronously, ordered with the other work submitted from the current
task. Use [`MPSGraphs.supports`](@ref) to check whether a call is supported without
throwing.
"""
function sort!(B, A; dims=nothing, rev::Bool=false)
    check_supported(sort!, B, A; dims, rev)
    isempty(A) && return B
    key = SortGraphKey{eltype(A)}(size(A), something(dims, 1), rev)
    run!(cached_graph(key), (B,), (A,))
    return B
end

function unsupported(::typeof(sort!), B, A; dims=nothing, rev::Bool=false)
    err = unsupported_arrays(B, A)
    err === nothing || return err
    T = eltype(A)
    eltype(B) == T ||
        return ArgumentError("MPSGraph sorting requires the output and input to have the same element type, got $(eltype(B)) and $T")
    T <: Union{MPSGRAPH_VALID_SORT_TYPES...} ||
        return ArgumentError("MPSGraph sorting does not support element type $T")
    size(B) == size(A) ||
        return DimensionMismatch("output has dimensions $(size(B)), input has dimensions $(size(A))")
    err = unsupported_rank(A)
    err === nothing || return err
    return unsupported_dims(A, dims)
end

"""
    MPSGraphs.sortperm!(I, A; dims=nothing, rev=false) -> I

Store in `I` the linear indices that sort `A` along dimension `dims`, in ascending order
(descending with `rev=true`), like `sortperm(A; dims)`. `dims` can only be omitted for
vectors.

`A` is an `MtlArray` with a real element type, and `I` an `MtlArray{Int32}` or
`MtlArray{Int64}` of the same size. Elements are ordered with `isless`, so NaNs sort last.
The permutation is not guaranteed to be stable: equal elements can appear in any order.

The operation executes asynchronously, ordered with the other work submitted from the
current task. Use [`MPSGraphs.supports`](@ref) to check whether a call is supported
without throwing.
"""
function sortperm!(I, A; dims=nothing, rev::Bool=false)
    check_supported(sortperm!, I, A; dims, rev)
    isempty(A) && return I
    key = SortPermGraphKey{eltype(A), eltype(I)}(size(A), something(dims, 1), rev)
    run!(cached_graph(key), (I,), (A,))
    return I
end

function unsupported(::typeof(sortperm!), I, A; dims=nothing, rev::Bool=false)
    err = unsupported_arrays(I, A)
    err === nothing || return err
    eltype(A) <: Union{MPSGRAPH_VALID_SORT_TYPES...} ||
        return ArgumentError("MPSGraph sorting does not support element type $(eltype(A))")
    eltype(I) <: MPSGRAPH_SORTPERM_INDEX_TYPES ||
        return ArgumentError("MPSGraph sortperm requires Int32 or Int64 indices, got $(eltype(I))")
    size(I) == size(A) ||
        return DimensionMismatch("index output has dimensions $(size(I)), input has dimensions $(size(A))")
    err = unsupported_rank(A)
    err === nothing || return err
    return unsupported_dims(A, dims)
end
