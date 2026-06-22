const MPSGRAPH_VALID_SCAN_TYPES = Union{Float16, Float32}

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

scan_operation(::typeof(+)) = :sum
scan_operation(::typeof(Base.add_sum)) = :sum
scan_operation(::typeof(*)) = :product
scan_operation(::typeof(Base.mul_prod)) = :product
scan_operation(::typeof(max)) = :maximum
scan_operation(::typeof(min)) = :minimum
scan_operation(op) =
    throw(ArgumentError("MPSGraph scan supports +, *, max, and min"))

function scanWithTensor(graph::MPSGraph, op::Symbol, tensor::MPSGraphTensor,
                        axis::Integer, name = "scan")
    if op === :sum
        cumulativeSumWithTensor(graph, tensor, axis, false, false, name)
    elseif op === :product
        cumulativeProductWithTensor(graph, tensor, axis, false, false, name)
    elseif op === :maximum
        cumulativeMaximumWithTensor(graph, tensor, axis, false, false, name)
    elseif op === :minimum
        cumulativeMinimumWithTensor(graph, tensor, axis, false, false, name)
    else
        throw(ArgumentError("MPSGraph scan supports +, *, max, and min"))
    end
end

struct ScanGraphKey{T}
    shape::Tuple{Vararg{Int}}
    dim::Int
    op::Symbol
end

struct CachedScanGraph
    graph::MPSGraph
    place_x::MPSGraphTensor
    result::MPSGraphTensor
end

function CachedScanGraph(key::ScanGraphKey{T}) where {T}
    graph = MPSGraph()
    place_x = placeholderTensor(graph, key.shape, T)
    result = scanWithTensor(graph, key.op, place_x, mps_axis(key.shape, key.dim),
                            "scan")
    return CachedScanGraph(graph, place_x, result)
end

const scan_graph_cache = Dict{ScanGraphKey, CachedScanGraph}()
const scan_graph_cache_lock = ReentrantLock()

function check_scan_args(out::MtlArray{T}, input::MtlArray{T}, dim::Integer) where {T}
    T <: MPSGRAPH_VALID_SCAN_TYPES ||
        throw(ArgumentError("MPSGraph scan supports Float16 and Float32"))
    size(out) == size(input) ||
        throw(DimensionMismatch("output has dimensions $(size(out)), input has dimensions $(size(input))"))
    1 <= dim <= ndims(input) || throw(ArgumentError("dimension out of range"))
    check_mpsgraph_offsets(out, input)
    return Int(dim)
end

@autoreleasepool function graph_scan!(op, out::MtlArray{T}, input::MtlArray{T};
                                      dim::Integer = 1) where {T}
    dim = check_scan_args(out, input, dim)
    isempty(input) && return copyto!(out, input)
    key = ScanGraphKey{T}(size(input), dim, scan_operation(op))
    cached = @lock scan_graph_cache_lock get!(scan_graph_cache, key) do
        CachedScanGraph(key)
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
