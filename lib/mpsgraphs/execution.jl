
MPS.encode!(commandBuffer::MPSCommandBuffer, graph::MPSGraph, feeds::MPSGraphTensorDataDictionary, resultsDictionary::MPSGraphTensorDataDictionary) = @inline MPS.encode!(commandBuffer, graph, feeds, resultsDictionary, nil, MPSGraphExecutionDescriptor())
function MPS.encode!(commandBuffer::MPSCommandBuffer, graph::MPSGraph, feeds::MPSGraphTensorDataDictionary, resultsDictionary::MPSGraphTensorDataDictionary, targetOperations, executionDescriptor::MPSGraphExecutionDescriptor)
    @objc [graph::id{MPSGraph} encodeToCommandBuffer:commandBuffer::id{MPSCommandBuffer}
                                                  feeds:feeds::id{MPSGraphTensorDataDictionary}
                                       targetOperations:targetOperations::id{Object}
                                      resultsDictionary:resultsDictionary::id{MPSGraphTensorDataDictionary}
                                    executionDescriptor:executionDescriptor::id{MPSGraphExecutionDescriptor}]::Nothing
    return resultsDictionary
end

function MPS.encode!(commandBuffer::MPSCommandBuffer, graph::MPSGraph, feeds::MPSGraphTensorDataDictionary, targetTensors::NSArray, targetOperations=nil, executionDescriptor::MPSGraphExecutionDescriptor=MPSGraphExecutionDescriptor())
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

const MPSGraphTensorShapedTypeDictionary = NSDictionary#{MPSGraphTensor, MPSGraphTensorShapedType}

compile(graph::MPSGraph, dev::MTLDevice, feeds::MPSGraphTensorShapedTypeDictionary, targetTensors::NSArray, targetOperations=nil, compilationDescriptor=nil) = compile(graph, MPSGraphDevice(dev), feeds, targetTensors, targetOperations, compilationDescriptor)
function compile(graph::MPSGraph, dev::MPSGraphDevice, feeds::MPSGraphTensorShapedTypeDictionary, targetTensors::NSArray, targetOperations=nil, compilationDescriptor=nil)
    exec = @objc [graph::id{MPSGraph} compileWithDevice:dev::id{MPSGraphDevice}
                                     feeds:feeds::id{MPSGraphTensorShapedTypeDictionary}
                             targetTensors:targetTensors::id{NSArray}
                          targetOperations:targetOperations::id{Object}
                     compilationDescriptor:compilationDescriptor::id{Object}]::id{MPSGraphExecutable}
    return MPSGraphExecutable(exec)
end

function MPSGraphExecutableSerializationDescriptor()
    tmp = @objc [MPSGraphExecutableSerializationDescriptor alloc]::id{MPSGraphExecutableSerializationDescriptor}
    obj = MPSGraphExecutableSerializationDescriptor(tmp)
    return obj
end

serialize(graphExe::MPSGraphExecutable, url, descriptor=MPSGraphExecutableSerializationDescriptor()) = serialize(graphExe, NSFileURL(url), descriptor)
function serialize(graphExe::MPSGraphExecutable, url::NSURL, descriptor=MPSGraphExecutableSerializationDescriptor())
    @objc [graphExe::id{MPSGraphExecutable} serializeToMPSGraphPackageAtURL:url::id{NSURL}
                              descriptor:descriptor::id{MPSGraphExecutableSerializationDescriptor}]::Nothing
end
