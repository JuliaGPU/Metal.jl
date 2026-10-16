function softMaxWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, axis::Integer,
                           name = "softmax")
    @objc [graph::id{MPSGraph} softMaxWithTensor:tensor::id{MPSGraphTensor}
                                            axis:axis::NSInteger
                                            name:name::id{NSString}]::MPSGraphTensor
end

function softMaxGradientWithIncomingGradient(graph::MPSGraph, gradient::MPSGraphTensor,
                                             source::MPSGraphTensor, axis::Integer,
                                             name = "softmax_grad")
    @objc [graph::id{MPSGraph} softMaxGradientWithIncomingGradient:gradient::id{MPSGraphTensor}
                                                      sourceTensor:source::id{MPSGraphTensor}
                                                              axis:axis::NSInteger
                                                              name:name::id{NSString}]::MPSGraphTensor
end

function logarithmWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "log")
    @objc [graph::id{MPSGraph} logarithmWithTensor:tensor::id{MPSGraphTensor}
                                             name:name::id{NSString}]::MPSGraphTensor
end

function exponentWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "exp")
    @objc [graph::id{MPSGraph} exponentWithTensor:tensor::id{MPSGraphTensor}
                                            name:name::id{NSString}]::MPSGraphTensor
end

function subtractionWithPrimaryTensor(graph::MPSGraph, primary::MPSGraphTensor,
                                      secondary::MPSGraphTensor, name = "sub")
    @objc [graph::id{MPSGraph} subtractionWithPrimaryTensor:primary::id{MPSGraphTensor}
                                            secondaryTensor:secondary::id{MPSGraphTensor}
                                                       name:name::id{NSString}]::MPSGraphTensor
end

function reductionSumWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, axis::Integer,
                                name = "sum")
    @objc [graph::id{MPSGraph} reductionSumWithTensor:tensor::id{MPSGraphTensor}
                                                axis:axis::NSInteger
                                                name:name::id{NSString}]::MPSGraphTensor
end

function reductionMaximumWithTensor(graph::MPSGraph, tensor::MPSGraphTensor,
                                    axis::Integer, name = "max")
    @objc [graph::id{MPSGraph} reductionMaximumWithTensor:tensor::id{MPSGraphTensor}
                                                     axis:axis::NSInteger
                                                     name:name::id{NSString}]::MPSGraphTensor
end

function reverseTensor(graph::MPSGraph, tensor::MPSGraphTensor, axes::Vector{Int},
                       name = "reverse")
    @objc [graph::id{MPSGraph} reverseTensor:tensor::id{MPSGraphTensor}
                                        axes:NSArray(NSNumber.(axes))::id{NSArray}
                                        name:name::id{NSString}]::MPSGraphTensor
end

function MPSGraphConvolution2DOpDescriptor(stride, padding, dilation, groups)
    return @objc [MPSGraphConvolution2DOpDescriptor descriptorWithStrideInX:stride[1]::NSUInteger
                                                                   strideInY:stride[2]::NSUInteger
                                                             dilationRateInX:dilation[1]::NSUInteger
                                                             dilationRateInY:dilation[2]::NSUInteger
                                                                      groups:groups::NSUInteger
                                                                 paddingLeft:padding[1]::NSUInteger
                                                                paddingRight:padding[2]::NSUInteger
                                                                  paddingTop:padding[3]::NSUInteger
                                                               paddingBottom:padding[4]::NSUInteger
                                                                paddingStyle:MPSGraphPaddingStyleExplicit::MPSGraphPaddingStyle
                                                                  dataLayout:MPSGraphTensorNamedDataLayoutNCHW::MPSGraphTensorNamedDataLayout
                                                               weightsLayout:MPSGraphTensorNamedDataLayoutOIHW::MPSGraphTensorNamedDataLayout]::MPSGraphConvolution2DOpDescriptor
end

function MPSGraphPooling2DOpDescriptor(kernel, stride, padding, dilation,
                                       include_zero_pad::Bool)
    desc = @objc [MPSGraphPooling2DOpDescriptor descriptorWithKernelWidth:kernel[1]::NSUInteger
                                                             kernelHeight:kernel[2]::NSUInteger
                                                                strideInX:stride[1]::NSUInteger
                                                                strideInY:stride[2]::NSUInteger
                                                          dilationRateInX:dilation[1]::NSUInteger
                                                          dilationRateInY:dilation[2]::NSUInteger
                                                              paddingLeft:padding[1]::NSUInteger
                                                             paddingRight:padding[2]::NSUInteger
                                                               paddingTop:padding[3]::NSUInteger
                                                            paddingBottom:padding[4]::NSUInteger
                                                             paddingStyle:MPSGraphPaddingStyleExplicit::MPSGraphPaddingStyle
                                                               dataLayout:MPSGraphTensorNamedDataLayoutNCHW::MPSGraphTensorNamedDataLayout]::MPSGraphPooling2DOpDescriptor
    desc.includeZeroPadToAverage = include_zero_pad
    return desc
end

function convolution2DWithSourceTensor(graph::MPSGraph, source::MPSGraphTensor,
                                       weights::MPSGraphTensor,
                                       descriptor::MPSGraphConvolution2DOpDescriptor,
                                       name = "conv")
    @objc [graph::id{MPSGraph} convolution2DWithSourceTensor:source::id{MPSGraphTensor}
                                               weightsTensor:weights::id{MPSGraphTensor}
                                                  descriptor:descriptor::id{MPSGraphConvolution2DOpDescriptor}
                                                        name:name::id{NSString}]::MPSGraphTensor
end

function convolution2DDataGradientWithIncomingGradientTensor(
    graph::MPSGraph, gradient::MPSGraphTensor, weights::MPSGraphTensor,
    output_shape::MPSShape, descriptor::MPSGraphConvolution2DOpDescriptor,
    name = "conv_data_grad")
    @objc [graph::id{MPSGraph} convolution2DDataGradientWithIncomingGradientTensor:gradient::id{MPSGraphTensor}
                                                                     weightsTensor:weights::id{MPSGraphTensor}
                                                                       outputShape:output_shape::id{MPSShape}
                                                      forwardConvolutionDescriptor:descriptor::id{MPSGraphConvolution2DOpDescriptor}
                                                                              name:name::id{NSString}]::MPSGraphTensor
end

function convolution2DWeightsGradientWithIncomingGradientTensor(
    graph::MPSGraph, gradient::MPSGraphTensor, source::MPSGraphTensor,
    output_shape::MPSShape, descriptor::MPSGraphConvolution2DOpDescriptor,
    name = "conv_filter_grad")
    @objc [graph::id{MPSGraph} convolution2DWeightsGradientWithIncomingGradientTensor:gradient::id{MPSGraphTensor}
                                                                        sourceTensor:source::id{MPSGraphTensor}
                                                                         outputShape:output_shape::id{MPSShape}
                                                        forwardConvolutionDescriptor:descriptor::id{MPSGraphConvolution2DOpDescriptor}
                                                                                name:name::id{NSString}]::MPSGraphTensor
end

function maxPooling2DWithSourceTensor(graph::MPSGraph, source::MPSGraphTensor,
                                      descriptor::MPSGraphPooling2DOpDescriptor,
                                      name = "maxpool")
    @objc [graph::id{MPSGraph} maxPooling2DWithSourceTensor:source::id{MPSGraphTensor}
                                                 descriptor:descriptor::id{MPSGraphPooling2DOpDescriptor}
                                                       name:name::id{NSString}]::MPSGraphTensor
end

function avgPooling2DWithSourceTensor(graph::MPSGraph, source::MPSGraphTensor,
                                      descriptor::MPSGraphPooling2DOpDescriptor,
                                      name = "meanpool")
    @objc [graph::id{MPSGraph} avgPooling2DWithSourceTensor:source::id{MPSGraphTensor}
                                                 descriptor:descriptor::id{MPSGraphPooling2DOpDescriptor}
                                                       name:name::id{NSString}]::MPSGraphTensor
end

function maxPooling2DGradientWithGradientTensor(graph::MPSGraph, gradient::MPSGraphTensor,
                                                source::MPSGraphTensor,
                                                descriptor::MPSGraphPooling2DOpDescriptor,
                                                name = "maxpool_grad")
    @objc [graph::id{MPSGraph} maxPooling2DGradientWithGradientTensor:gradient::id{MPSGraphTensor}
                                                         sourceTensor:source::id{MPSGraphTensor}
                                                           descriptor:descriptor::id{MPSGraphPooling2DOpDescriptor}
                                                                 name:name::id{NSString}]::MPSGraphTensor
end

function avgPooling2DGradientWithGradientTensor(graph::MPSGraph, gradient::MPSGraphTensor,
                                                source::MPSGraphTensor,
                                                descriptor::MPSGraphPooling2DOpDescriptor,
                                                name = "meanpool_grad")
    @objc [graph::id{MPSGraph} avgPooling2DGradientWithGradientTensor:gradient::id{MPSGraphTensor}
                                                         sourceTensor:source::id{MPSGraphTensor}
                                                           descriptor:descriptor::id{MPSGraphPooling2DOpDescriptor}
                                                                 name:name::id{NSString}]::MPSGraphTensor
end

const MPSGRAPH_VALID_NN_TYPES = Union{Float16, Float32}

function softmax_axis(shape::Tuple, dims::Integer)
    dim = Int(dims)
    1 <= dim <= length(shape) || throw(ArgumentError("dims must be between 1 and $(length(shape))"))
    return length(shape) - dim
end

function reduction_shape(shape::Tuple, axis::Integer)
    mpsshape = collect(reverse(shape))
    mpsshape[Int(axis) + 1] = 1
    return convert(MPSShape, mpsshape)
end

function check_softmax_args(y::MtlArray{T}, x::MtlArray{T}, dims::Integer) where {T}
    T <: MPSGRAPH_VALID_NN_TYPES || throw(ArgumentError("MPSGraph NN operations support Float16 and Float32"))
    size(y) == size(x) || throw(DimensionMismatch("output has dimensions $(size(y)), input has dimensions $(size(x))"))
    return softmax_axis(size(x), dims)
end

function check_softmax_grad_args(dx::MtlArray{T}, dy::MtlArray{T}, y::MtlArray{T},
                                 dims::Integer) where {T}
    T <: MPSGRAPH_VALID_NN_TYPES || throw(ArgumentError("MPSGraph NN operations support Float16 and Float32"))
    size(dx) == size(dy) == size(y) ||
        throw(DimensionMismatch("softmax gradient inputs must have matching dimensions"))
    return softmax_axis(size(y), dims)
end

struct SoftmaxGraphKey{T}
    op::Symbol
    shape::Tuple{Vararg{Int}}
    axis::Int
end

function logsoftmax_tensor(graph::MPSGraph, x::MPSGraphTensor,
                           key::SoftmaxGraphKey)
    maxval = reductionMaximumWithTensor(graph, x, key.axis, "logsoftmax_max")
    maxval = reshapeTensor(graph, maxval, reduction_shape(key.shape, key.axis),
                           "logsoftmax_max_reshape")
    shifted = subtractionWithPrimaryTensor(graph, x, maxval, "logsoftmax_shift")
    expval = exponentWithTensor(graph, shifted, "logsoftmax_exp")
    sumval = reductionSumWithTensor(graph, expval, key.axis, "logsoftmax_sum")
    sumval = reshapeTensor(graph, sumval, reduction_shape(key.shape, key.axis),
                           "logsoftmax_sum_reshape")
    return subtractionWithPrimaryTensor(graph, shifted,
                                        logarithmWithTensor(graph, sumval, "logsoftmax_logsum"),
                                        "logsoftmax")
end

function build_graph(key::SoftmaxGraphKey{T}) where {T}
    graph = MPSGraph()
    place_x = placeholderTensor(graph, key.shape, T)
    result = if key.op === :softmax
        softMaxWithTensor(graph, place_x, key.axis, "softmax")
    elseif key.op === :logsoftmax
        logsoftmax_tensor(graph, place_x, key)
    else
        throw(ArgumentError("unsupported softmax graph operation: $(key.op)"))
    end
    return CachedGraph(graph, [place_x], [result])
end

function run_softmax!(op::Symbol, y::MtlArray{T}, x::MtlArray{T},
                                       dims::Integer) where {T}
    axis = check_softmax_args(y, x, dims)
    key = SoftmaxGraphKey{T}(op, size(x), axis)
    run!(cached_graph(key), (y,), (x,))

    return y
end

function graph_softmax!(y::MtlArray{T}, x::MtlArray{T}; dims::Integer = 1) where {T}
    return run_softmax!(:softmax, y, x, dims)
end

function graph_logsoftmax!(y::MtlArray{T}, x::MtlArray{T}; dims::Integer = 1) where {T}
    return run_softmax!(:logsoftmax, y, x, dims)
end

struct SoftmaxGradGraphKey{T}
    op::Symbol
    shape::Tuple{Vararg{Int}}
    axis::Int
end

function softmax_grad_tensor(graph::MPSGraph, dy::MPSGraphTensor, y::MPSGraphTensor,
                             key::SoftmaxGradGraphKey)
    dy_y = multiplicationWithPrimaryTensor(graph, dy, y, "softmax_grad_product")
    sumval = reductionSumWithTensor(graph, dy_y, key.axis, "softmax_grad_sum")
    sumval = reshapeTensor(graph, sumval, reduction_shape(key.shape, key.axis),
                           "softmax_grad_sum_reshape")
    return subtractionWithPrimaryTensor(
        graph, dy_y, multiplicationWithPrimaryTensor(graph, y, sumval, "softmax_grad_scale"),
        "softmax_grad")
end

function logsoftmax_grad_tensor(graph::MPSGraph, dy::MPSGraphTensor, y::MPSGraphTensor,
                                key::SoftmaxGradGraphKey)
    sumval = reductionSumWithTensor(graph, dy, key.axis, "logsoftmax_grad_sum")
    sumval = reshapeTensor(graph, sumval, reduction_shape(key.shape, key.axis),
                           "logsoftmax_grad_sum_reshape")
    exp_y = exponentWithTensor(graph, y, "logsoftmax_grad_exp")
    return subtractionWithPrimaryTensor(
        graph, dy, multiplicationWithPrimaryTensor(graph, sumval, exp_y,
                                                   "logsoftmax_grad_scale"),
        "logsoftmax_grad")
end

function build_graph(key::SoftmaxGradGraphKey{T}) where {T}
    graph = MPSGraph()
    place_dy = placeholderTensor(graph, key.shape, T)
    place_y = placeholderTensor(graph, key.shape, T)
    result = if key.op === :softmax
        softmax_grad_tensor(graph, place_dy, place_y, key)
    elseif key.op === :logsoftmax
        logsoftmax_grad_tensor(graph, place_dy, place_y, key)
    else
        throw(ArgumentError("unsupported softmax gradient graph operation: $(key.op)"))
    end
    return CachedGraph(graph, [place_dy, place_y], [result])
end

function run_softmax_grad!(op::Symbol, dx::MtlArray{T},
                                            dy::MtlArray{T}, y::MtlArray{T},
                                            dims::Integer) where {T}
    axis = check_softmax_grad_args(dx, dy, y, dims)
    key = SoftmaxGradGraphKey{T}(op, size(y), axis)
    run!(cached_graph(key), (dx,), (dy, y))

    return dx
end

function graph_softmax_grad!(dx::MtlArray{T}, dy::MtlArray{T}, y::MtlArray{T};
                             dims::Integer = 1) where {T}
    return run_softmax_grad!(:softmax, dx, dy, y, dims)
end

function graph_logsoftmax_grad!(dx::MtlArray{T}, dy::MtlArray{T}, y::MtlArray{T};
                                dims::Integer = 1) where {T}
    return run_softmax_grad!(:logsoftmax, dx, dy, y, dims)
end

struct Conv2DGraphKey{T}
    size_y::NTuple{4, Int}
    size_x::NTuple{4, Int}
    size_w::NTuple{4, Int}
    stride::NTuple{2, Int}
    padding::NTuple{4, Int}
    dilation::NTuple{2, Int}
    groups::Int
    flipkernel::Bool
end

function conv_weights_tensor(graph::MPSGraph, weights::MPSGraphTensor, flipkernel::Bool)
    return flipkernel ? weights : reverseTensor(graph, weights, [2, 3], "conv_weights_reverse")
end

function build_graph(key::Conv2DGraphKey{T}) where {T}
    graph = MPSGraph()
    place_x = placeholderTensor(graph, key.size_x, T)
    place_w = placeholderTensor(graph, key.size_w, T)
    desc = MPSGraphConvolution2DOpDescriptor(key.stride, key.padding, key.dilation,
                                             key.groups)
    result = convolution2DWithSourceTensor(graph, place_x,
                                           conv_weights_tensor(graph, place_w,
                                                               key.flipkernel),
                                           desc, "conv")
    return CachedGraph(graph, [place_x, place_w], [result])
end

struct Conv2DDataGradGraphKey{T}
    size_dx::NTuple{4, Int}
    size_dy::NTuple{4, Int}
    size_w::NTuple{4, Int}
    stride::NTuple{2, Int}
    padding::NTuple{4, Int}
    dilation::NTuple{2, Int}
    groups::Int
    flipkernel::Bool
end

function build_graph(key::Conv2DDataGradGraphKey{T}) where {T}
    graph = MPSGraph()
    place_dy = placeholderTensor(graph, key.size_dy, T)
    place_w = placeholderTensor(graph, key.size_w, T)
    desc = MPSGraphConvolution2DOpDescriptor(key.stride, key.padding, key.dilation,
                                             key.groups)
    result = convolution2DDataGradientWithIncomingGradientTensor(
        graph, place_dy, conv_weights_tensor(graph, place_w, key.flipkernel),
        convert(MPSShape, reverse(key.size_dx)), desc, "conv_data_grad")
    return CachedGraph(graph, [place_dy, place_w], [result])
end

struct Conv2DFilterGradGraphKey{T}
    size_dw::NTuple{4, Int}
    size_x::NTuple{4, Int}
    size_dy::NTuple{4, Int}
    stride::NTuple{2, Int}
    padding::NTuple{4, Int}
    dilation::NTuple{2, Int}
    groups::Int
    flipkernel::Bool
end

function build_graph(key::Conv2DFilterGradGraphKey{T}) where {T}
    graph = MPSGraph()
    place_x = placeholderTensor(graph, key.size_x, T)
    place_dy = placeholderTensor(graph, key.size_dy, T)
    desc = MPSGraphConvolution2DOpDescriptor(key.stride, key.padding, key.dilation,
                                             key.groups)
    result = convolution2DWeightsGradientWithIncomingGradientTensor(
        graph, place_dy, place_x, convert(MPSShape, reverse(key.size_dw)), desc,
        "conv_filter_grad")
    result = conv_weights_tensor(graph, result, key.flipkernel)
    return CachedGraph(graph, [place_x, place_dy], [result])
end

function check_conv2d_groups(groups::Integer, in_channels::Int, kernel_in_channels::Int,
                             out_channels::Int)
    groups >= 1 || throw(ArgumentError("groups must be positive"))
    in_channels == groups * kernel_in_channels ||
        throw(DimensionMismatch("input channel count must match groups times kernel input channels"))
    out_channels % groups == 0 ||
        throw(DimensionMismatch("output channel count must be divisible by groups"))
    return
end

function check_conv2d_args(y::MtlArray{T,4}, x::MtlArray{T,4}, w::MtlArray{T,4},
                           groups::Integer) where {T}
    T <: MPSGRAPH_VALID_NN_TYPES || throw(ArgumentError("MPSGraph NN operations support Float16 and Float32"))
    check_conv2d_groups(groups, size(x, 3), size(w, 3), size(w, 4))
    size(y, 3) == size(w, 4) || throw(DimensionMismatch("output and kernel channel counts do not match"))
    size(y, 4) == size(x, 4) || throw(DimensionMismatch("input and output batch sizes do not match"))
    return
end

function check_conv2d_data_grad_args(dx::MtlArray{T,4}, dy::MtlArray{T,4},
                                     w::MtlArray{T,4}, groups::Integer) where {T}
    T <: MPSGRAPH_VALID_NN_TYPES || throw(ArgumentError("MPSGraph NN operations support Float16 and Float32"))
    check_conv2d_groups(groups, size(dx, 3), size(w, 3), size(w, 4))
    size(dy, 3) == size(w, 4) || throw(DimensionMismatch("output gradient and kernel channel counts do not match"))
    size(dy, 4) == size(dx, 4) || throw(DimensionMismatch("input and output gradient batch sizes do not match"))
    return
end

function check_conv2d_filter_grad_args(dw::MtlArray{T,4}, x::MtlArray{T,4},
                                       dy::MtlArray{T,4}, groups::Integer) where {T}
    T <: MPSGRAPH_VALID_NN_TYPES || throw(ArgumentError("MPSGraph NN operations support Float16 and Float32"))
    check_conv2d_groups(groups, size(x, 3), size(dw, 3), size(dw, 4))
    size(dy, 3) == size(dw, 4) || throw(DimensionMismatch("output and kernel gradient channel counts do not match"))
    size(dy, 4) == size(x, 4) || throw(DimensionMismatch("input and output gradient batch sizes do not match"))
    return
end

function graph_conv!(y::MtlArray{T,4}, x::MtlArray{T,4}, w::MtlArray{T,4};
                                      stride::NTuple{2, Int} = (1, 1),
                                      padding::NTuple{4, Int} = (0, 0, 0, 0),
                                      dilation::NTuple{2, Int} = (1, 1),
                                      groups::Integer = 1,
                                      flipkernel::Bool = false) where {T}
    check_conv2d_args(y, x, w, groups)
    key = Conv2DGraphKey{T}(size(y), size(x), size(w), stride, padding, dilation,
                            groups, flipkernel)
    run!(cached_graph(key), (y,), (x, w))

    return y
end

function graph_conv_data_grad!(dx::MtlArray{T,4}, dy::MtlArray{T,4},
                                                w::MtlArray{T,4};
                                                stride::NTuple{2, Int} = (1, 1),
                                                padding::NTuple{4, Int} = (0, 0, 0, 0),
                                                dilation::NTuple{2, Int} = (1, 1),
                                                groups::Integer = 1,
                                                flipkernel::Bool = false) where {T}
    check_conv2d_data_grad_args(dx, dy, w, groups)
    key = Conv2DDataGradGraphKey{T}(size(dx), size(dy), size(w), stride, padding,
                                    dilation, groups, flipkernel)
    run!(cached_graph(key), (dx,), (dy, w))

    return dx
end

function graph_conv_filter_grad!(dw::MtlArray{T,4}, x::MtlArray{T,4},
                                                  dy::MtlArray{T,4};
                                                  stride::NTuple{2, Int} = (1, 1),
                                                  padding::NTuple{4, Int} = (0, 0, 0, 0),
                                                  dilation::NTuple{2, Int} = (1, 1),
                                                  groups::Integer = 1,
                                                  flipkernel::Bool = false) where {T}
    check_conv2d_filter_grad_args(dw, x, dy, groups)
    key = Conv2DFilterGradGraphKey{T}(size(dw), size(x), size(dy), stride, padding,
                                      dilation, groups, flipkernel)
    run!(cached_graph(key), (dw,), (x, dy))

    return dw
end

struct Pool2DGraphKey{T}
    op::Symbol
    size_y::NTuple{4, Int}
    size_x::NTuple{4, Int}
    kernel::NTuple{2, Int}
    stride::NTuple{2, Int}
    padding::NTuple{4, Int}
    dilation::NTuple{2, Int}
    include_zero_pad::Bool
end

function build_graph(key::Pool2DGraphKey{T}) where {T}
    graph = MPSGraph()
    place_x = placeholderTensor(graph, key.size_x, T)
    desc = MPSGraphPooling2DOpDescriptor(key.kernel, key.stride, key.padding,
                                         key.dilation, key.include_zero_pad)
    result = if key.op === :max
        maxPooling2DWithSourceTensor(graph, place_x, desc, "maxpool")
    elseif key.op === :mean
        avgPooling2DWithSourceTensor(graph, place_x, desc, "meanpool")
    else
        throw(ArgumentError("unsupported pooling graph operation: $(key.op)"))
    end
    return CachedGraph(graph, [place_x], [result])
end

struct Pool2DGradGraphKey{T}
    op::Symbol
    size_dx::NTuple{4, Int}
    size_dy::NTuple{4, Int}
    size_x::NTuple{4, Int}
    kernel::NTuple{2, Int}
    stride::NTuple{2, Int}
    padding::NTuple{4, Int}
    dilation::NTuple{2, Int}
    include_zero_pad::Bool
end

function build_graph(key::Pool2DGradGraphKey{T}) where {T}
    graph = MPSGraph()
    place_dy = placeholderTensor(graph, key.size_dy, T)
    place_x = placeholderTensor(graph, key.size_x, T)
    desc = MPSGraphPooling2DOpDescriptor(key.kernel, key.stride, key.padding,
                                         key.dilation, key.include_zero_pad)
    result = if key.op === :max
        maxPooling2DGradientWithGradientTensor(graph, place_dy, place_x, desc,
                                               "maxpool_grad")
    elseif key.op === :mean
        avgPooling2DGradientWithGradientTensor(graph, place_dy, place_x, desc,
                                               "meanpool_grad")
    else
        throw(ArgumentError("unsupported pooling gradient graph operation: $(key.op)"))
    end
    return CachedGraph(graph, [place_dy, place_x], [result])
end

function check_pool2d_args(y::MtlArray{T,4}, x::MtlArray{T,4}) where {T}
    T <: MPSGRAPH_VALID_NN_TYPES || throw(ArgumentError("MPSGraph NN operations support Float16 and Float32"))
    size(y, 3) == size(x, 3) || throw(DimensionMismatch("input and output channel counts do not match"))
    size(y, 4) == size(x, 4) || throw(DimensionMismatch("input and output batch sizes do not match"))
    return nothing
end

function check_pool2d_grad_args(dx::MtlArray{T,4}, dy::MtlArray{T,4},
                                x::MtlArray{T,4}) where {T}
    T <: MPSGRAPH_VALID_NN_TYPES || throw(ArgumentError("MPSGraph NN operations support Float16 and Float32"))
    size(dx) == size(x) || throw(DimensionMismatch("input gradient and input dimensions do not match"))
    size(dy, 3) == size(x, 3) || throw(DimensionMismatch("input and output gradient channel counts do not match"))
    size(dy, 4) == size(x, 4) || throw(DimensionMismatch("input and output gradient batch sizes do not match"))
    return nothing
end

function run_pool2d!(op::Symbol, y::MtlArray{T,4}, x::MtlArray{T,4};
                                      kernel::NTuple{2, Int},
                                      stride::NTuple{2, Int},
                                      padding::NTuple{4, Int},
                                      dilation::NTuple{2, Int} = (1, 1),
                                      include_zero_pad::Bool = false) where {T}
    check_pool2d_args(y, x)
    key = Pool2DGraphKey{T}(op, size(y), size(x), kernel, stride, padding,
                            dilation, include_zero_pad)
    run!(cached_graph(key), (y,), (x,))

    return y
end

function run_pool2d_grad!(op::Symbol, dx::MtlArray{T,4},
                                           dy::MtlArray{T,4}, x::MtlArray{T,4};
                                           kernel::NTuple{2, Int},
                                           stride::NTuple{2, Int},
                                           padding::NTuple{4, Int},
                                           dilation::NTuple{2, Int} = (1, 1),
                                           include_zero_pad::Bool = false) where {T}
    check_pool2d_grad_args(dx, dy, x)
    key = Pool2DGradGraphKey{T}(op, size(dx), size(dy), size(x), kernel, stride,
                                padding, dilation, include_zero_pad)
    run!(cached_graph(key), (dx,), (dy, x))

    return dx
end

function graph_maxpool!(y::MtlArray{T,4}, x::MtlArray{T,4}; kernel::NTuple{2, Int},
                        stride::NTuple{2, Int}, padding::NTuple{4, Int},
                        dilation::NTuple{2, Int} = (1, 1)) where {T}
    return run_pool2d!(:max, y, x; kernel, stride, padding, dilation)
end

function graph_meanpool!(y::MtlArray{T,4}, x::MtlArray{T,4}; kernel::NTuple{2, Int},
                         stride::NTuple{2, Int}, padding::NTuple{4, Int},
                         dilation::NTuple{2, Int} = (1, 1),
                         count_include_pad::Bool = true) where {T}
    return run_pool2d!(:mean, y, x; kernel, stride, padding, dilation,
                       include_zero_pad=count_include_pad)
end

function graph_maxpool_grad!(dx::MtlArray{T,4}, dy::MtlArray{T,4}, x::MtlArray{T,4};
                             kernel::NTuple{2, Int}, stride::NTuple{2, Int},
                             padding::NTuple{4, Int},
                             dilation::NTuple{2, Int} = (1, 1)) where {T}
    return run_pool2d_grad!(:max, dx, dy, x; kernel, stride, padding, dilation)
end

function graph_meanpool_grad!(dx::MtlArray{T,4}, dy::MtlArray{T,4}, x::MtlArray{T,4};
                              kernel::NTuple{2, Int}, stride::NTuple{2, Int},
                              padding::NTuple{4, Int},
                              dilation::NTuple{2, Int} = (1, 1),
                              count_include_pad::Bool = true) where {T}
    return run_pool2d_grad!(:mean, dx, dy, x; kernel, stride, padding, dilation,
                            include_zero_pad=count_include_pad)
end
