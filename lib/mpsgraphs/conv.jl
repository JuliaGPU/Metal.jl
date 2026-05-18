struct Conv2DGraphKey
    size_x::Tuple{Vararg{Int}}
    size_w::Tuple{Vararg{Int}}
    size_y::Tuple{Vararg{Int}}
    eltype_xw::DataType
    eltype_y::DataType
    stride::NTuple{2, Int}
    dilation::NTuple{2, Int}
    padding::NTuple{4, Int}
    groups::Int
end

function Conv2DGraphKey(
        x::MtlArray{Tx, 4}, w::MtlArray{Tx, 4}, y::MtlArray{Ty, 4},
        stride::NTuple{2, Int}, dilation::NTuple{2, Int},
        padding::NTuple{4, Int}, groups::Integer
    ) where {Tx, Ty}
    return Conv2DGraphKey(size(x), size(w), size(y), Tx, Ty, stride, dilation, padding, Int(groups))
end

struct CachedConv2DGraph
    graph::MPSGraph
    place_y::MPSGraphTensor
    place_x::MPSGraphTensor
    place_w::MPSGraphTensor
    result::MPSGraphTensor
end

function CachedConv2DGraph(key::Conv2DGraphKey)
    graph = MPSGraph()

    placeX = placeholderTensor(graph, key.size_x, key.eltype_xw)
    placeW = placeholderTensor(graph, key.size_w, key.eltype_xw)
    placeY = placeholderTensor(graph, key.size_y, key.eltype_y)

    castT = key.eltype_xw <: Integer ? key.eltype_y : key.eltype_xw
    castX = castTensor(graph, placeX, castT, "castX")
    castW = castTensor(graph, placeW, castT, "castW")

    conv_desc = MPSGraphConvolution2DOpDescriptor(;
        stride = key.stride,
        dilation = key.dilation,
        padding = key.padding,
        groups = key.groups,
        dataLayout = MPSGraphTensorNamedDataLayoutNCHW,
        weightsLayout = MPSGraphTensorNamedDataLayoutOIHW,
        paddingStyle = MPSGraphPaddingStyleExplicit,
    )

    conv = convolution2DWithSourceTensor(graph, castX, castW, conv_desc)
    castY = castTensor(graph, conv, key.eltype_y, "castY")

    return CachedConv2DGraph(graph, placeY, placeX, placeW, castY)
end

function _get_cached_graph!(graph_cache_lock, graph_cache, key::Conv2DGraphKey)
    cached = get(graph_cache, key, nothing)
    if cached !== nothing
        return cached
    end

    return @lock graph_cache_lock get!(graph_cache, key) do
        CachedConv2DGraph(key)
    end
end

const _conv2d_graph_cache = Dict{Conv2DGraphKey, CachedConv2DGraph}()
const _conv2d_graph_cache_lock = ReentrantLock()

@inline _conv2d_padding(padding::Integer) = (Int(padding), Int(padding), Int(padding), Int(padding))
@inline _conv2d_padding(padding::NTuple{2, <:Integer}) = (Int(padding[1]), Int(padding[1]), Int(padding[2]), Int(padding[2]))
@inline _conv2d_padding(padding::NTuple{4, <:Integer}) = (Int(padding[1]), Int(padding[2]), Int(padding[3]), Int(padding[4]))

@autoreleasepool function _conv2d!(
        y::MtlArray{Ty, 4}, x::MtlArray{Tx, 4}, w::MtlArray{Tx, 4},
        stride::NTuple{2, Int}, dilation::NTuple{2, Int},
        padding::NTuple{4, Int}, groups::Integer
    ) where {Ty, Tx}
    key = Conv2DGraphKey(x, w, y, stride, dilation, padding, groups)
    cached = _get_cached_graph!(_conv2d_graph_cache_lock, _conv2d_graph_cache, key)

    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        cached.place_x => MPSGraphTensorData(x),
        cached.place_w => MPSGraphTensorData(w),
        cached.place_y => MPSGraphTensorData(y),
    )

    resultdict = Dict{MPSGraphTensor, MPSGraphTensorData}(
        cached.result => feeds[cached.place_y],
    )

    cmdbuf = MPSCommandBuffer(Metal.global_queue(device()))
    encode!(cmdbuf, cached.graph, NSDictionary(feeds), NSDictionary(resultdict), nil, default_exec_desc())
    commit!(cmdbuf)
    wait_completed(cmdbuf)

    y
end

function graph_conv!(
        y::MtlArray{Ty, 4}, x::MtlArray{Tx, 4}, w::MtlArray{Tx, 4};
        stride::NTuple{2, <:Integer} = (1, 1),
        dilation::NTuple{2, <:Integer} = (1, 1),
        padding::Union{Integer, NTuple{2, <:Integer}, NTuple{4, <:Integer}} = (0, 0, 0, 0),
        groups::Integer = 1
    ) where {Ty, Tx}
    return _conv2d!(
        y, x, w, (Int(stride[1]), Int(stride[2])), (Int(dilation[1]), Int(dilation[2])),
        _conv2d_padding(padding), groups
    )
end
