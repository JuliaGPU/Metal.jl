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

struct CachedSortGraph
    graph::MPSGraph
    place_x::MPSGraphTensor
    result::MPSGraphTensor
end

function CachedSortGraph(key::SortGraphKey{T}) where {T}
    graph = MPSGraph()
    place_x = placeholderTensor(graph, key.shape, T)
    result = sortWithTensor(graph, place_x, mps_axis(key.shape, key.dim),
                            key.descending, "sort")
    return CachedSortGraph(graph, place_x, result)
end

const sort_graph_cache = Dict{SortGraphKey, CachedSortGraph}()
const sort_graph_cache_lock = ReentrantLock()

struct SortPermGraphKey{T, Ti}
    shape::Tuple{Vararg{Int}}
    dim::Int
    descending::Bool
end

struct CachedSortPermGraph
    graph::MPSGraph
    place_x::MPSGraphTensor
    result::MPSGraphTensor
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

function CachedSortPermGraph(key::SortPermGraphKey{T, Ti}) where {T, Ti}
    graph = MPSGraph()
    place_x = placeholderTensor(graph, key.shape, T)
    arg = argSortWithTensor(graph, place_x, mps_axis(key.shape, key.dim),
                            key.descending, "argsort")
    result = linear_sortperm_tensor(graph, arg, key)
    return CachedSortPermGraph(graph, place_x, result)
end

const sortperm_graph_cache = Dict{SortPermGraphKey, CachedSortPermGraph}()
const sortperm_graph_cache_lock = ReentrantLock()

function check_sort_args(out::MtlArray{T}, input::MtlArray{T}, dim::Integer) where {T}
    T <: Union{MPSGRAPH_VALID_SORT_TYPES...} || throw(ArgumentError("MPSGraph sort supports $(join(MPSGraphs.MPSGRAPH_VALID_SORT_TYPES,", ", " and "))"))
    size(out) == size(input) ||
        throw(DimensionMismatch("output has dimensions $(size(out)), input has dimensions $(size(input))"))
    1 <= dim <= ndims(input) || throw(ArgumentError("dimension out of range"))
    check_mpsgraph_offsets(out, input)
    return Int(dim)
end

function check_sortperm_args(index::MtlArray{Ti}, input::MtlArray{T},
                             dim::Integer) where {Ti, T}
    T <: Union{MPSGRAPH_VALID_SORT_TYPES...} || throw(ArgumentError("MPSGraph sortperm supports $(join(MPSGraphs.MPSGRAPH_VALID_SORT_TYPES,", ", " and ")) inputs"))
    Ti <: MPSGRAPH_SORTPERM_INDEX_TYPES || throw(ArgumentError("MPSGraph sortperm supports Int32 and Int64 indices"))
    size(index) == size(input) ||
        throw(DimensionMismatch("index output has dimensions $(size(index)), input has dimensions $(size(input))"))
    1 <= dim <= ndims(input) || throw(ArgumentError("dimension out of range"))
    check_mpsgraph_offsets(index, input)
    return Int(dim)
end

@autoreleasepool function graph_sort!(out::MtlArray{T}, input::MtlArray{T};
                                      dim::Integer = 1,
                                      rev::Bool = false) where {T}
    dim = check_sort_args(out, input, dim)
    isempty(input) && return copyto!(out, input)
    key = SortGraphKey{T}(size(input), dim, rev)
    cached = @lock sort_graph_cache_lock get!(sort_graph_cache, key) do
        CachedSortGraph(key)
    end

    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        cached.place_x => MPSGraphTensorData(input),
    )
    results = Dict{MPSGraphTensor, MPSGraphTensorData}(
        cached.result => MPSGraphTensorData(out),
    )

    cmdbuf = MPSCommandBuffer(Metal.global_queue(device()))
    encode!(cmdbuf, cached.graph, NSDictionary(feeds), NSDictionary(results), nil,
            default_exec_desc())
    commit!(cmdbuf)
    synchronize(cmdbuf)

    return out
end

@autoreleasepool function graph_sortperm!(index::MtlArray{Ti}, input::MtlArray{T};
                                          dim::Integer = 1,
                                          rev::Bool = false) where {Ti, T}
    dim = check_sortperm_args(index, input, dim)
    isempty(input) && return index
    key = SortPermGraphKey{T, Ti}(size(input), dim, rev)
    cached = @lock sortperm_graph_cache_lock get!(sortperm_graph_cache, key) do
        CachedSortPermGraph(key)
    end

    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        cached.place_x => MPSGraphTensorData(input),
    )
    results = Dict{MPSGraphTensor, MPSGraphTensorData}(
        cached.result => MPSGraphTensorData(index),
    )

    cmdbuf = MPSCommandBuffer(Metal.global_queue(device()))
    encode!(cmdbuf, cached.graph, NSDictionary(feeds), NSDictionary(results), nil,
            default_exec_desc())
    commit!(cmdbuf)
    synchronize(cmdbuf)

    return index
end
