
const MPSGRAPH_VALID_REDUCTION_TYPES = filter(T -> T <: Real, (MPS.jl_mps_to_typ |> values |> collect))

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

reduction_operation(::typeof(+)) = :sum
reduction_operation(::typeof(Base.add_sum)) = :sum
reduction_operation(::typeof(*)) = :product
reduction_operation(::typeof(Base.mul_prod)) = :product
reduction_operation(::typeof(max)) = :maximum
reduction_operation(::typeof(min)) = :minimum
reduction_operation(op) =
    throw(ArgumentError("MPSGraph reduction supports +, *, max, and min"))

function reduction_axes(out_shape::Tuple, input_shape::Tuple)
    length(out_shape) == length(input_shape) ||
        throw(DimensionMismatch("output and input must have the same rank"))
    dims = Int[]
    for dim in 1:length(input_shape)
        if out_shape[dim] == input_shape[dim]
            continue
        elseif out_shape[dim] == 1
            push!(dims, dim)
        else
            throw(DimensionMismatch("output has dimensions $out_shape, input has dimensions $input_shape"))
        end
    end
    isempty(dims) && throw(ArgumentError("no reduced dimensions found"))
    return Tuple(dims)
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
        throw(ArgumentError("MPSGraph reduction supports +, *, max, and min"))
    end
end

struct ReductionGraphKey{T}
    input_shape::Tuple{Vararg{Int}}
    output_shape::Tuple{Vararg{Int}}
    dims::Tuple{Vararg{Int}}
    op::Symbol
end

struct CachedReductionGraph
    graph::MPSGraph
    place_x::MPSGraphTensor
    result::MPSGraphTensor
end

function CachedReductionGraph(key::ReductionGraphKey{T}) where {T}
    graph = MPSGraph()
    place_x = placeholderTensor(graph, key.input_shape, T)
    axes = NSArray([NSNumber(mps_axis(key.input_shape, dim)) for dim in key.dims])
    reduced = reductionWithTensor(graph, key.op, place_x, axes, "reduction")
    output_shape = convert(MPSShape, reverse(key.output_shape))
    result = reshapeTensor(graph, reduced, output_shape, "reduction_reshape")
    return CachedReductionGraph(graph, place_x, result)
end

const reduction_graph_cache = Dict{ReductionGraphKey, CachedReductionGraph}()
const reduction_graph_cache_lock = ReentrantLock()

function check_reduction_args(out::MtlArray{T}, input::MtlArray{T}) where {T}
    T <: Union{MPSGRAPH_VALID_REDUCTION_TYPES...} ||
        throw(ArgumentError("MPSGraph reduction supports $(join(MPSGraphs.MPSGRAPH_VALID_REDUCTION_TYPES,", ", " and "))"))
    dims = reduction_axes(size(out), size(input))
    check_mpsgraph_offsets(out, input)
    return dims
end

@autoreleasepool function graph_mapreducedim!(op, out::MtlArray{T},
                                              input::MtlArray{T}) where {T}
    dims = check_reduction_args(out, input)
    key = ReductionGraphKey{T}(size(input), size(out), dims,
                               reduction_operation(op))
    cached = @lock reduction_graph_cache_lock get!(reduction_graph_cache, key) do
        CachedReductionGraph(key)
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
