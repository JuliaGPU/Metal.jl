
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

function identityWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "identity")
    obj = @objc [graph::id{MPSGraph} identityWithTensor:tensor::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

run(graph::MPSGraph, feeds::Dict, targetTensors::Vector) = run(graph, MPSGraphTensorDataDictionary(feeds), NSArray(targetTensors))
function run(graph::MPSGraph, feeds::MPSGraphTensorDataDictionary, targetTensors::NSArray)
    obj = @objc [graph::id{MPSGraph} runWithFeeds:feeds::id{MPSGraphTensorDataDictionary}
                                            targetTensors:targetTensors::id{NSArray}
                                         targetOperations:nil::id{Object}]::id{MPSGraphTensorDataDictionary}
    MPSGraphTensorDataDictionary(obj)
end

run(graph::MPSGraph, commandQueue::MTLCommandQueue, feeds::Dict, targetTensors::Vector) = run(graph, commandQueue, MPSGraphTensorDataDictionary(feeds), NSArray(targetTensors))
function run(graph::MPSGraph, commandQueue::MTLCommandQueue, feeds::MPSGraphTensorDataDictionary, targetTensors::NSArray)
    obj = @objc [graph::id{MPSGraph} runWithMTLCommandQueue:commandQueue::id{MTLCommandQueue}
                                                    feeds:feeds::id{MPSGraphTensorDataDictionary}
                                            targetTensors:targetTensors::id{NSArray}
                                         targetOperations:nil::id{Object}]::id{MPSGraphTensorDataDictionary}
    MPSGraphTensorDataDictionary(obj)
end
