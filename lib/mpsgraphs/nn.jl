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

function reduction_shape(shape::Tuple, axis::Integer)
    mpsshape = collect(reverse(shape))
    mpsshape[Int(axis) + 1] = 1
    return convert(MPSShape, mpsshape)
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


## array interface

# arrays of one element type that NN operations support, optionally all of rank `N`
function unsupported_nn_arrays(arrays...; N=nothing)
    err = unsupported_arrays(arrays...)
    err === nothing || return err
    T = eltype(first(arrays))
    all(A -> eltype(A) == T, arrays) ||
        return ArgumentError("MPSGraph NN operations require arrays of the same element type, got $(join(map(eltype, arrays), ", "))")
    T <: MPSGRAPH_VALID_NN_TYPES ||
        return ArgumentError("MPSGraph NN operations support Float16 and Float32, got $T")
    N === nothing || all(A -> ndims(A) == N, arrays) ||
        return ArgumentError("MPSGraph 2D convolution and pooling require 4D arrays in WHCN layout")
    return nothing
end

function unsupported_softmax(dims, x, ys...)
    err = unsupported_nn_arrays(x, ys...)
    err === nothing || return err
    all(y -> size(y) == size(x), ys) ||
        return DimensionMismatch("softmax arguments have dimensions $(join(map(size, (x, ys...)), ", "))")
    err = unsupported_rank(x)
    err === nothing || return err
    dims isa Integer && 1 <= dims <= ndims(x) ||
        return ArgumentError("`dims` must be a dimension of the input, got $dims")
    return nothing
end

function softmax_impl!(op::Symbol, y, x, dims)
    isempty(x) && return y
    key = SoftmaxGraphKey{eltype(x)}(op, size(x), mps_axis(ndims(x), dims))
    run!(cached_graph(key), (y,), (x,))
    return y
end

function softmax_grad_impl!(op::Symbol, dx, dy, y, dims)
    isempty(y) && return dx
    key = SoftmaxGradGraphKey{eltype(y)}(op, size(y), mps_axis(ndims(y), dims))
    run!(cached_graph(key), (dx,), (dy, y))
    return dx
end

"""
    MPSGraphs.softmax!(y, x; dims=1) -> y

Compute the softmax `exp.(x) ./ sum(exp.(x); dims)` along dimension `dims` of `x`, and
store it in `y`.

`x` and `y` are `MtlArray`s of the same size with element type `Float16` or `Float32`. The
operation executes asynchronously, ordered with the other work submitted from the current
task. Use [`MPSGraphs.supports`](@ref) to check whether a call is supported without
throwing.
"""
function softmax!(y, x; dims=1)
    check_supported(softmax!, y, x; dims)
    return softmax_impl!(:softmax, y, x, dims)
end
unsupported(::typeof(softmax!), y, x; dims=1) = unsupported_softmax(dims, x, y)

"""
    MPSGraphs.logsoftmax!(y, x; dims=1) -> y

Compute the log-softmax `x .- log.(sum(exp.(x); dims))` along dimension `dims` of `x`,
and store it in `y`. The requirements of [`MPSGraphs.softmax!`](@ref) apply.
"""
function logsoftmax!(y, x; dims=1)
    check_supported(logsoftmax!, y, x; dims)
    return softmax_impl!(:logsoftmax, y, x, dims)
end
unsupported(::typeof(logsoftmax!), y, x; dims=1) = unsupported_softmax(dims, x, y)

"""
    MPSGraphs.softmax_grad!(dx, dy, y; dims=1) -> dx

Compute the gradient `dx` of [`MPSGraphs.softmax!`](@ref) with respect to its input,
given its output `y` and the gradient `dy` with respect to that output. All arrays have
the same size, and the requirements of `softmax!` apply.
"""
function softmax_grad!(dx, dy, y; dims=1)
    check_supported(softmax_grad!, dx, dy, y; dims)
    return softmax_grad_impl!(:softmax, dx, dy, y, dims)
end
unsupported(::typeof(softmax_grad!), dx, dy, y; dims=1) = unsupported_softmax(dims, y, dy, dx)

"""
    MPSGraphs.logsoftmax_grad!(dx, dy, y; dims=1) -> dx

Compute the gradient `dx` of [`MPSGraphs.logsoftmax!`](@ref) with respect to its input,
given its output `y` and the gradient `dy` with respect to that output. All arrays have
the same size, and the requirements of `softmax!` apply.
"""
function logsoftmax_grad!(dx, dy, y; dims=1)
    check_supported(logsoftmax_grad!, dx, dy, y; dims)
    return softmax_grad_impl!(:logsoftmax, dx, dy, y, dims)
end
unsupported(::typeof(logsoftmax_grad!), dx, dy, y; dims=1) =
    unsupported_softmax(dims, y, dy, dx)

# the spatial extent of a convolution or pooling output, as in NNlib
function conv_output_size(input::NTuple{2, Int}, kernel::NTuple{2, Int}, stride, padding,
                          dilation)
    pads = ((padding[1], padding[2]), (padding[3], padding[4]))
    return ntuple(2) do i
        div(input[i] + sum(pads[i]) - dilation[i] * (kernel[i] - 1) - 1, stride[i]) + 1
    end
end

function unsupported_window(kernel, stride, padding, dilation)
    all(>(0), kernel) && all(>(0), stride) && all(>(0), dilation) && all(>=(0), padding) ||
        return ArgumentError("kernel, stride and dilation must be positive, and padding nonnegative; got kernel=$kernel, stride=$stride, padding=$padding, dilation=$dilation")
    return nothing
end

# x, w and y of a 2D convolution, in WHCN and (KW, KH, Cin/groups, Cout) layout
function unsupported_conv(y, x, w, stride, padding, dilation, groups)
    err = unsupported_nn_arrays(y, x, w; N=4)
    err === nothing || return err
    err = unsupported_window(size(w)[1:2], stride, padding, dilation)
    err === nothing || return err
    groups >= 1 && size(x, 3) == groups * size(w, 3) && size(w, 4) % groups == 0 ||
        return DimensionMismatch("input channels ($(size(x, 3))) must be `groups` ($groups) times the kernel's input channels ($(size(w, 3))), and output channels ($(size(w, 4))) divisible by it")
    expected = (conv_output_size(size(x)[1:2], size(w)[1:2], stride, padding, dilation)...,
                size(w, 4), size(x, 4))
    size(y) == expected ||
        return DimensionMismatch("convolution output has dimensions $(size(y)), expected $expected")
    return nothing
end

const CONV_DOC = """
The arrays use NNlib's layout: `x` and `y` are `(width, height, channels, batch)`, and the
kernel `w` is `(width, height, input channels ÷ groups, output channels)`. `padding` is
`(left, right, top, bottom)`. By default the kernel is flipped, i.e. this computes a
convolution rather than a cross-correlation; `flipkernel=true` computes the latter. All
arrays are 4D `MtlArray`s with element type `Float16` or `Float32`.

The operation executes asynchronously, ordered with the other work submitted from the
current task. Use [`MPSGraphs.supports`](@ref) to check whether a call is supported
without throwing.
"""

"""
    MPSGraphs.conv!(y, x, w; stride=(1, 1), padding=(0, 0, 0, 0), dilation=(1, 1),
                    groups=1, flipkernel=false) -> y

Compute the 2D convolution of `x` with the kernel `w`, and store it in `y`.

$CONV_DOC
"""
function conv!(y, x, w; stride::NTuple{2, Int}=(1, 1), padding::NTuple{4, Int}=(0, 0, 0, 0),
               dilation::NTuple{2, Int}=(1, 1), groups::Integer=1, flipkernel::Bool=false)
    check_supported(conv!, y, x, w; stride, padding, dilation, groups, flipkernel)
    isempty(y) && return y
    # an empty sum over input channels or the batch
    (isempty(x) || isempty(w)) && return fill!(y, zero(eltype(y)))
    key = Conv2DGraphKey{eltype(x)}(size(y), size(x), size(w), stride, padding, dilation,
                                    groups, flipkernel)
    run!(cached_graph(key), (y,), (x, w))
    return y
end

function unsupported(::typeof(conv!), y, x, w; stride::NTuple{2, Int}=(1, 1),
                     padding::NTuple{4, Int}=(0, 0, 0, 0), dilation::NTuple{2, Int}=(1, 1),
                     groups::Integer=1, flipkernel::Bool=false)
    return unsupported_conv(y, x, w, stride, padding, dilation, groups)
end

"""
    MPSGraphs.conv_data_grad!(dx, dy, w; stride=(1, 1), padding=(0, 0, 0, 0),
                              dilation=(1, 1), groups=1, flipkernel=false) -> dx

Compute the gradient `dx` of [`MPSGraphs.conv!`](@ref) with respect to its input `x`,
given the gradient `dy` with respect to its output and the kernel `w`.

$CONV_DOC
"""
function conv_data_grad!(dx, dy, w; stride::NTuple{2, Int}=(1, 1),
                         padding::NTuple{4, Int}=(0, 0, 0, 0),
                         dilation::NTuple{2, Int}=(1, 1), groups::Integer=1,
                         flipkernel::Bool=false)
    check_supported(conv_data_grad!, dx, dy, w; stride, padding, dilation, groups,
                    flipkernel)
    isempty(dx) && return dx
    (isempty(dy) || isempty(w)) && return fill!(dx, zero(eltype(dx)))
    key = Conv2DDataGradGraphKey{eltype(dy)}(size(dx), size(dy), size(w), stride, padding,
                                             dilation, groups, flipkernel)
    run!(cached_graph(key), (dx,), (dy, w))
    return dx
end

function unsupported(::typeof(conv_data_grad!), dx, dy, w; stride::NTuple{2, Int}=(1, 1),
                     padding::NTuple{4, Int}=(0, 0, 0, 0), dilation::NTuple{2, Int}=(1, 1),
                     groups::Integer=1, flipkernel::Bool=false)
    return unsupported_conv(dy, dx, w, stride, padding, dilation, groups)
end

"""
    MPSGraphs.conv_filter_grad!(dw, x, dy; stride=(1, 1), padding=(0, 0, 0, 0),
                                dilation=(1, 1), groups=1, flipkernel=false) -> dw

Compute the gradient `dw` of [`MPSGraphs.conv!`](@ref) with respect to its kernel, given
its input `x` and the gradient `dy` with respect to its output.

$CONV_DOC
"""
function conv_filter_grad!(dw, x, dy; stride::NTuple{2, Int}=(1, 1),
                           padding::NTuple{4, Int}=(0, 0, 0, 0),
                           dilation::NTuple{2, Int}=(1, 1), groups::Integer=1,
                           flipkernel::Bool=false)
    check_supported(conv_filter_grad!, dw, x, dy; stride, padding, dilation, groups,
                    flipkernel)
    isempty(dw) && return dw
    (isempty(x) || isempty(dy)) && return fill!(dw, zero(eltype(dw)))
    key = Conv2DFilterGradGraphKey{eltype(x)}(size(dw), size(x), size(dy), stride, padding,
                                              dilation, groups, flipkernel)
    run!(cached_graph(key), (dw,), (x, dy))
    return dw
end

function unsupported(::typeof(conv_filter_grad!), dw, x, dy; stride::NTuple{2, Int}=(1, 1),
                     padding::NTuple{4, Int}=(0, 0, 0, 0), dilation::NTuple{2, Int}=(1, 1),
                     groups::Integer=1, flipkernel::Bool=false)
    return unsupported_conv(dy, x, dw, stride, padding, dilation, groups)
end

# x and y of a 2D pooling, in WHCN layout
function unsupported_pool(y, x, kernel, stride, padding, dilation)
    err = unsupported_nn_arrays(y, x; N=4)
    err === nothing || return err
    err = unsupported_window(kernel, stride, padding, dilation)
    err === nothing || return err
    isempty(x) && !isempty(y) &&
        return ArgumentError("pooling requires a nonempty input for a nonempty output")
    expected = (conv_output_size(size(x)[1:2], kernel, stride, padding, dilation)...,
                size(x, 3), size(x, 4))
    size(y) == expected ||
        return DimensionMismatch("pooling output has dimensions $(size(y)), expected $expected")
    return nothing
end

const POOL_DOC = """
The arrays use NNlib's layout: `x` and `y` are 4D `MtlArray`s of `(width, height,
channels, batch)` with element type `Float16` or `Float32`. `kernel`, `stride` and
`dilation` are `(width, height)`, and `padding` is `(left, right, top, bottom)`.

The operation executes asynchronously, ordered with the other work submitted from the
current task. Use [`MPSGraphs.supports`](@ref) to check whether a call is supported
without throwing.
"""

function pool_impl!(op::Symbol, y, x, kernel, stride, padding, dilation,
                    count_include_pad)
    isempty(y) && return y
    key = Pool2DGraphKey{eltype(x)}(op, size(y), size(x), kernel, stride, padding,
                                    dilation, count_include_pad)
    run!(cached_graph(key), (y,), (x,))
    return y
end

function pool_grad_impl!(op::Symbol, dx, dy, x, kernel, stride, padding, dilation,
                         count_include_pad)
    isempty(dx) && return dx
    isempty(dy) && return fill!(dx, zero(eltype(dx)))
    key = Pool2DGradGraphKey{eltype(x)}(op, size(dx), size(dy), size(x), kernel, stride,
                                        padding, dilation, count_include_pad)
    run!(cached_graph(key), (dx,), (dy, x))
    return dx
end

function unsupported_pool_grad(dx, dy, x, kernel, stride, padding, dilation)
    err = unsupported_nn_arrays(dx, dy, x; N=4)
    err === nothing || return err
    size(dx) == size(x) ||
        return DimensionMismatch("input gradient has dimensions $(size(dx)), input has dimensions $(size(x))")
    return unsupported_pool(dy, x, kernel, stride, padding, dilation)
end

"""
    MPSGraphs.maxpool!(y, x; kernel, stride=kernel, padding=(0, 0, 0, 0),
                       dilation=(1, 1)) -> y

Compute the maximum of `x` over each 2D window of size `kernel`, and store it in `y`.

$POOL_DOC
"""
function maxpool!(y, x; kernel::NTuple{2, Int}, stride::NTuple{2, Int}=kernel,
                  padding::NTuple{4, Int}=(0, 0, 0, 0), dilation::NTuple{2, Int}=(1, 1))
    check_supported(maxpool!, y, x; kernel, stride, padding, dilation)
    return pool_impl!(:max, y, x, kernel, stride, padding, dilation, false)
end

function unsupported(::typeof(maxpool!), y, x; kernel::NTuple{2, Int},
                     stride::NTuple{2, Int}=kernel, padding::NTuple{4, Int}=(0, 0, 0, 0),
                     dilation::NTuple{2, Int}=(1, 1))
    return unsupported_pool(y, x, kernel, stride, padding, dilation)
end

"""
    MPSGraphs.maxpool_grad!(dx, dy, x; kernel, stride=kernel, padding=(0, 0, 0, 0),
                            dilation=(1, 1)) -> dx

Compute the gradient `dx` of [`MPSGraphs.maxpool!`](@ref) with respect to its input `x`,
given the gradient `dy` with respect to its output.

$POOL_DOC
"""
function maxpool_grad!(dx, dy, x; kernel::NTuple{2, Int}, stride::NTuple{2, Int}=kernel,
                       padding::NTuple{4, Int}=(0, 0, 0, 0), dilation::NTuple{2, Int}=(1, 1))
    check_supported(maxpool_grad!, dx, dy, x; kernel, stride, padding, dilation)
    return pool_grad_impl!(:max, dx, dy, x, kernel, stride, padding, dilation, false)
end

function unsupported(::typeof(maxpool_grad!), dx, dy, x; kernel::NTuple{2, Int},
                     stride::NTuple{2, Int}=kernel, padding::NTuple{4, Int}=(0, 0, 0, 0),
                     dilation::NTuple{2, Int}=(1, 1))
    return unsupported_pool_grad(dx, dy, x, kernel, stride, padding, dilation)
end

"""
    MPSGraphs.meanpool!(y, x; kernel, stride=kernel, padding=(0, 0, 0, 0),
                        dilation=(1, 1), count_include_pad=true) -> y

Compute the mean of `x` over each 2D window of size `kernel`, and store it in `y`. With
`count_include_pad`, padding counts towards the number of averaged elements.

$POOL_DOC
"""
function meanpool!(y, x; kernel::NTuple{2, Int}, stride::NTuple{2, Int}=kernel,
                   padding::NTuple{4, Int}=(0, 0, 0, 0), dilation::NTuple{2, Int}=(1, 1),
                   count_include_pad::Bool=true)
    check_supported(meanpool!, y, x; kernel, stride, padding, dilation)
    return pool_impl!(:mean, y, x, kernel, stride, padding, dilation, count_include_pad)
end

function unsupported(::typeof(meanpool!), y, x; kernel::NTuple{2, Int},
                     stride::NTuple{2, Int}=kernel, padding::NTuple{4, Int}=(0, 0, 0, 0),
                     dilation::NTuple{2, Int}=(1, 1), count_include_pad::Bool=true)
    return unsupported_pool(y, x, kernel, stride, padding, dilation)
end

"""
    MPSGraphs.meanpool_grad!(dx, dy, x; kernel, stride=kernel, padding=(0, 0, 0, 0),
                             dilation=(1, 1), count_include_pad=true) -> dx

Compute the gradient `dx` of [`MPSGraphs.meanpool!`](@ref) with respect to its input `x`,
given the gradient `dy` with respect to its output.

$POOL_DOC
"""
function meanpool_grad!(dx, dy, x; kernel::NTuple{2, Int}, stride::NTuple{2, Int}=kernel,
                        padding::NTuple{4, Int}=(0, 0, 0, 0), dilation::NTuple{2, Int}=(1, 1),
                        count_include_pad::Bool=true)
    check_supported(meanpool_grad!, dx, dy, x; kernel, stride, padding, dilation)
    return pool_grad_impl!(:mean, dx, dy, x, kernel, stride, padding, dilation,
                           count_include_pad)
end

function unsupported(::typeof(meanpool_grad!), dx, dy, x; kernel::NTuple{2, Int},
                     stride::NTuple{2, Int}=kernel, padding::NTuple{4, Int}=(0, 0, 0, 0),
                     dilation::NTuple{2, Int}=(1, 1), count_include_pad::Bool=true)
    return unsupported_pool_grad(dx, dy, x, kernel, stride, padding, dilation)
end
