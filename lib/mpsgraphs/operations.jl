
function broadcastTensor(graph::MPSGraph, tensor::MPSGraphTensor, shape::MPSShape, name="broadcast")
    obj = @objc [graph::id{MPSGraph} broadcastTensor:tensor::id{MPSGraphTensor}
                                toShape:shape::id{MPSShape}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end
function broadcastTensor(graph::MPSGraph, tensor::MPSGraphTensor, shapeTensor::MPSGraphTensor, name="broadcast")
    obj = @objc [graph::id{MPSGraph} broadcastTensor:tensor::id{MPSGraphTensor}
                                toShapeTensor:shapeTensor::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function castTensor(graph::MPSGraph, tensor::MPSGraphTensor, toType, name = "cast")
    obj = @objc [graph::id{MPSGraph} castTensor:tensor::id{MPSGraphTensor}
                                toType:toType::MPSDataType
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function constantWithScalar(graph::MPSGraph, scalar::Number, dataType)
    obj = @objc [graph::id{MPSGraph} constantWithScalar:scalar::Float64
                                dataType:dataType::MPSDataType]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function matrixMultiplicationWithPrimaryTensor(graph::MPSGraph, primary::MPSGraphTensor, secondary::MPSGraphTensor, name = "matmul")
    obj = @objc [graph::id{MPSGraph} matrixMultiplicationWithPrimaryTensor:primary::id{MPSGraphTensor}
                                secondaryTensor:secondary::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function multiplicationWithPrimaryTensor(graph::MPSGraph, primary::MPSGraphTensor, secondary::MPSGraphTensor, name = "mul")
    obj = @objc [graph::id{MPSGraph} multiplicationWithPrimaryTensor:primary::id{MPSGraphTensor}
                                secondaryTensor:secondary::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end
function additionWithPrimaryTensor(graph::MPSGraph, primary::MPSGraphTensor, secondary::MPSGraphTensor, name = "add")
    obj = @objc [graph::id{MPSGraph} additionWithPrimaryTensor:primary::id{MPSGraphTensor}
                                secondaryTensor:secondary::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function transposeTensor(graph::MPSGraph, tensor::MPSGraphTensor, dimension, withDimension, name = "transpose")
    obj = @objc [graph::id{MPSGraph} transposeTensor:tensor::id{MPSGraphTensor}
                                dimension:dimension::NSUInteger
                                withDimension:withDimension::NSUInteger
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function shapeOfTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "shapeOfTensor")
    obj = @objc [graph::id{MPSGraph} shapeOfTensor:tensor::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function identityWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "identity")
    obj = @objc [graph::id{MPSGraph} identityWithTensor:tensor::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

"""
    dump_graph(graph::MPSGraph)

Dumps the `graph`.

!!! warning
    This function is undocumented from Apple so it may stop working at any time.
"""
dump_graph(graph::MPSGraph) = @objc [graph::id{MPSGraph} dump]::Nothing ## COV_EXCL_LINE

## Convolution support (used by convolution.jl)

function concatTensors(graph::MPSGraph, tensors::NSArray, dimension::Int, name = "concat")
    obj = @objc [graph::id{MPSGraph} concatTensors:tensors::id{NSArray}
                                dimension:dimension::NSInteger
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

"""
    convolution2DWithSourceTensor(graph, source, weights, descriptor, name="conv2d")

2D convolution operation using MPSGraph.

# Arguments
- `graph`: MPSGraph instance
- `source`: Input tensor in NHWC or NCHW format (depending on descriptor)
- `weights`: Convolution kernel/weights in OIHW or HWIO format (depending on descriptor)
- `descriptor`: MPSGraphConvolution2DOpDescriptor configuring stride, padding, dilation, etc.
- `name`: Operation name for debugging

# Returns
MPSGraphTensor with the convolution result.
"""
function convolution2DWithSourceTensor(
        graph::MPSGraph, source::MPSGraphTensor, weights::MPSGraphTensor,
        descriptor::MPSGraphConvolution2DOpDescriptor, name = "conv2d"
    )
    obj = @objc [graph::id{MPSGraph} convolution2DWithSourceTensor:source::id{MPSGraphTensor}
                                weightsTensor:weights::id{MPSGraphTensor}
                                descriptor:descriptor::id{MPSGraphConvolution2DOpDescriptor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

"""
    MPSGraphConvolution2DOpDescriptor(;
        strideX=1, strideY=1,
        dilationX=1, dilationY=1,
        paddingLeft=0, paddingRight=0, paddingTop=0, paddingBottom=0,
        paddingStyle=MPSGraphPaddingStyleExplicit,
        dataLayout=MPSGraphTensorNamedDataLayoutNHWC,
        weightsLayout=MPSGraphTensorNamedDataLayoutHWIO,
        groups=1
    )

Create a 2D convolution operation descriptor.

# Arguments
- `strideX`, `strideY`: Stride in X and Y directions
- `dilationX`, `dilationY`: Dilation rate in X and Y directions
- `paddingLeft/Right/Top/Bottom`: Explicit padding values
- `paddingStyle`: One of:
  - `MPSGraphPaddingStyleExplicit` (default) - use explicit padding values
  - `MPSGraphPaddingStyleTF_VALID` - no padding
  - `MPSGraphPaddingStyleTF_SAME` - pad to keep output same size as input
- `dataLayout`: Input/output tensor layout (NHWC or NCHW)
- `weightsLayout`: Kernel tensor layout (HWIO or OIHW)
- `groups`: Number of groups for grouped convolution
"""
function MPSGraphConvolution2DOpDescriptor(;
        strideX::Integer = 1, strideY::Integer = 1,
        dilationX::Integer = 1, dilationY::Integer = 1,
        paddingLeft::Integer = 0, paddingRight::Integer = 0,
        paddingTop::Integer = 0, paddingBottom::Integer = 0,
        paddingStyle::MPSGraphPaddingStyle = MPSGraphPaddingStyleExplicit,
        dataLayout::MPSGraphTensorNamedDataLayout = MPSGraphTensorNamedDataLayoutNHWC,
        weightsLayout::MPSGraphTensorNamedDataLayout = MPSGraphTensorNamedDataLayoutHWIO,
        groups::Integer = 1
    )
    # Create descriptor via alloc/init
    desc = @objc [MPSGraphConvolution2DOpDescriptor alloc]::id{MPSGraphConvolution2DOpDescriptor}
    desc = @objc [desc::id{MPSGraphConvolution2DOpDescriptor} init]::id{MPSGraphConvolution2DOpDescriptor}
    descriptor = MPSGraphConvolution2DOpDescriptor(desc)

    # Set properties
    descriptor.strideInX = UInt64(strideX)
    descriptor.strideInY = UInt64(strideY)
    descriptor.dilationRateInX = UInt64(dilationX)
    descriptor.dilationRateInY = UInt64(dilationY)
    descriptor.paddingLeft = UInt64(paddingLeft)
    descriptor.paddingRight = UInt64(paddingRight)
    descriptor.paddingTop = UInt64(paddingTop)
    descriptor.paddingBottom = UInt64(paddingBottom)
    descriptor.paddingStyle = paddingStyle
    descriptor.dataLayout = dataLayout
    descriptor.weightsLayout = weightsLayout
    descriptor.groups = UInt64(groups)

    return descriptor
end
