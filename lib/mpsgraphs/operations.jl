
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
