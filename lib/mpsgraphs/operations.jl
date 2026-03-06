function broadcastTensor(graph::MPSGraph, tensor::MPSGraphTensor, shape::MPSShape, name = "broadcast")
    obj = @objc [
        graph::id{MPSGraph} broadcastTensor:tensor::id{MPSGraphTensor}
        toShape:shape::id{MPSShape}
        name:name::id{NSString}
    ]::id{MPSGraphTensor}
    return MPSGraphTensor(obj)
end
function broadcastTensor(graph::MPSGraph, tensor::MPSGraphTensor, shapeTensor::MPSGraphTensor, name = "broadcast")
    obj = @objc [
        graph::id{MPSGraph} broadcastTensor:tensor::id{MPSGraphTensor}
        toShapeTensor:shapeTensor::id{MPSGraphTensor}
        name:name::id{NSString}
    ]::id{MPSGraphTensor}
    return MPSGraphTensor(obj)
end

function castTensor(graph::MPSGraph, tensor::MPSGraphTensor, toType, name = "cast")
    obj = @objc [
        graph::id{MPSGraph} castTensor:tensor::id{MPSGraphTensor}
        toType:toType::MPSDataType
        name:name::id{NSString}
    ]::id{MPSGraphTensor}
    return MPSGraphTensor(obj)
end

function constantWithScalar(graph::MPSGraph, scalar::Number, dataType)
    obj = @objc [
        graph::id{MPSGraph} constantWithScalar:scalar::Float64
        dataType:dataType::MPSDataType
    ]::id{MPSGraphTensor}
    return MPSGraphTensor(obj)
end

function matrixMultiplicationWithPrimaryTensor(graph::MPSGraph, primary::MPSGraphTensor, secondary::MPSGraphTensor, name = "matmul")
    obj = @objc [
        graph::id{MPSGraph} matrixMultiplicationWithPrimaryTensor:primary::id{MPSGraphTensor}
        secondaryTensor:secondary::id{MPSGraphTensor}
        name:name::id{NSString}
    ]::id{MPSGraphTensor}
    return MPSGraphTensor(obj)
end

function multiplicationWithPrimaryTensor(graph::MPSGraph, primary::MPSGraphTensor, secondary::MPSGraphTensor, name = "mul")
    obj = @objc [
        graph::id{MPSGraph} multiplicationWithPrimaryTensor:primary::id{MPSGraphTensor}
        secondaryTensor:secondary::id{MPSGraphTensor}
        name:name::id{NSString}
    ]::id{MPSGraphTensor}
    return MPSGraphTensor(obj)
end
function additionWithPrimaryTensor(graph::MPSGraph, primary::MPSGraphTensor, secondary::MPSGraphTensor, name = "add")
    obj = @objc [
        graph::id{MPSGraph} additionWithPrimaryTensor:primary::id{MPSGraphTensor}
        secondaryTensor:secondary::id{MPSGraphTensor}
        name:name::id{NSString}
    ]::id{MPSGraphTensor}
    return MPSGraphTensor(obj)
end

function transposeTensor(graph::MPSGraph, tensor::MPSGraphTensor, dimension, withDimension, name = "transpose")
    obj = @objc [
        graph::id{MPSGraph} transposeTensor:tensor::id{MPSGraphTensor}
        dimension:dimension::NSUInteger
        withDimension:withDimension::NSUInteger
        name:name::id{NSString}
    ]::id{MPSGraphTensor}
    return MPSGraphTensor(obj)
end

function shapeOfTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "shapeOfTensor")
    obj = @objc [
        graph::id{MPSGraph} shapeOfTensor:tensor::id{MPSGraphTensor}
        name:name::id{NSString}
    ]::id{MPSGraphTensor}
    return MPSGraphTensor(obj)
end

function identityWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "identity")
    obj = @objc [
        graph::id{MPSGraph} identityWithTensor:tensor::id{MPSGraphTensor}
        name:name::id{NSString}
    ]::id{MPSGraphTensor}
    return MPSGraphTensor(obj)
end

function MPSGraphConvolution2DOpDescriptor(;
        stride::NTuple{2, <:Integer} = (1, 1),
        dilation::NTuple{2, <:Integer} = (1, 1),
        padding::NTuple{4, <:Integer} = (0, 0, 0, 0),
        groups::Integer = 1,
        dataLayout = MPSGraphTensorNamedDataLayoutNCHW,
        weightsLayout = MPSGraphTensorNamedDataLayoutOIHW,
        paddingStyle = MPSGraphPaddingStyleExplicit
    )
    desc = MPSGraphConvolution2DOpDescriptor(@objc [MPSGraphConvolution2DOpDescriptor new]::id{MPSGraphConvolution2DOpDescriptor})
    desc.strideInX = UInt64(stride[1])
    desc.strideInY = UInt64(stride[2])
    desc.dilationRateInX = UInt64(dilation[1])
    desc.dilationRateInY = UInt64(dilation[2])
    desc.paddingLeft = UInt64(padding[1])
    desc.paddingRight = UInt64(padding[2])
    desc.paddingTop = UInt64(padding[3])
    desc.paddingBottom = UInt64(padding[4])
    desc.paddingStyle = paddingStyle
    desc.dataLayout = dataLayout
    desc.weightsLayout = weightsLayout
    desc.groups = UInt64(groups)
    return desc
end

function convolution2DWithSourceTensor(
        graph::MPSGraph, source::MPSGraphTensor, weights::MPSGraphTensor,
        descriptor::MPSGraphConvolution2DOpDescriptor, name = "conv2d"
    )
    obj = @objc [
        graph::id{MPSGraph} convolution2DWithSourceTensor:source::id{MPSGraphTensor}
        weightsTensor:weights::id{MPSGraphTensor}
        descriptor:descriptor::id{MPSGraphConvolution2DOpDescriptor}
        name:name::id{NSString}
    ]::id{MPSGraphTensor}
    return MPSGraphTensor(obj)
end

"""
    dump_graph(graph::MPSGraph)

Dumps the `graph`.

!!! warning
    This function is undocumented from Apple so it may stop working at any time.
"""
dump_graph(graph::MPSGraph) = @objc [graph::id{MPSGraph} dump]::Nothing ## COV_EXCL_LINE
