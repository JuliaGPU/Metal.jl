
MPS.encode!(commandBuffer::MPSCommandBuffer, graph::MPSGraph, feeds::MPSGraphTensorDataDictionary, resultsDictionary::MPSGraphTensorDataDictionary) = @inline MPS.encode!(commandBuffer, graph, feeds, nil, resultsDictionary, MPSGraphExecutionDescriptor())
function MPS.encode!(commandBuffer::MPSCommandBuffer, graph::MPSGraph, feeds::MPSGraphTensorDataDictionary, targetOperations, resultsDictionary::MPSGraphTensorDataDictionary, executionDescriptor)
    @objc [graph::id{MPSGraph} encodeToCommandBuffer:commandBuffer::id{MPSCommandBuffer}
                                                  feeds:feeds::id{MPSGraphTensorDataDictionary}
                                       targetOperations:targetOperations::id{Object}
                                      resultsDictionary:resultsDictionary::id{MPSGraphTensorDataDictionary}
                                    executionDescriptor:executionDescriptor::id{MPSGraphExecutionDescriptor}]::Nothing
    return resultsDictionary
end

function MPS.encode!(commandBuffer::MPSCommandBuffer, graph::MPSGraph, feeds::MPSGraphTensorDataDictionary, targetTensors::NSArray, targetOperations=nil, executionDescriptor=MPSGraphExecutionDescriptor())
    obj = @objc [graph::id{MPSGraph} encodeToCommandBuffer:commandBuffer::id{MPSCommandBuffer}
                                                        feeds:feeds::id{MPSGraphTensorDataDictionary}
                                                targetTensors:targetTensors::id{NSArray}
                                             targetOperations:targetOperations::id{Object}
                                          executionDescriptor:executionDescriptor::id{MPSGraphExecutionDescriptor}]::id{MPSGraphTensorDataDictionary}
    MPSGraphTensorDataDictionary(obj)
end

function run(graph::MPSGraph, feeds::MPSGraphTensorDataDictionary, targetTensors::NSArray, targetOperations=nil)
    obj = @objc [graph::id{MPSGraph} runWithFeeds:feeds::id{MPSGraphTensorDataDictionary}
                                            targetTensors:targetTensors::id{NSArray}
                                         targetOperations:targetOperations::id{Object}]::id{MPSGraphTensorDataDictionary}
    MPSGraphTensorDataDictionary(obj)
end

function run(graph::MPSGraph, commandQueue::MTLCommandQueue, feeds::MPSGraphTensorDataDictionary, targetTensors::NSArray)
    obj = @objc [graph::id{MPSGraph} runWithMTLCommandQueue:commandQueue::id{MTLCommandQueue}
                                                    feeds:feeds::id{MPSGraphTensorDataDictionary}
                                            targetTensors:targetTensors::id{NSArray}
                                         targetOperations:nil::id{Object}]::id{MPSGraphTensorDataDictionary}
    MPSGraphTensorDataDictionary(obj)
end
