
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
    return @objc [graph::id{MPSGraph} encodeToCommandBuffer:commandBuffer::id{MPSCommandBuffer}
                                                         feeds:feeds::id{MPSGraphTensorDataDictionary}
                                                 targetTensors:targetTensors::id{NSArray}
                                              targetOperations:targetOperations::id{Object}
                                           executionDescriptor:executionDescriptor::id{MPSGraphExecutionDescriptor}]::MPSGraphTensorDataDictionary
end

function run(graph::MPSGraph, feeds::MPSGraphTensorDataDictionary, targetTensors::NSArray, targetOperations=nil)
    return @objc [graph::id{MPSGraph} runWithFeeds:feeds::id{MPSGraphTensorDataDictionary}
                                             targetTensors:targetTensors::id{NSArray}
                                          targetOperations:targetOperations::id{Object}]::MPSGraphTensorDataDictionary
end

function run(graph::MPSGraph, commandQueue, feeds::MPSGraphTensorDataDictionary, targetTensors::NSArray)
    Metal.flush!(commandQueue)
    # this executes synchronously, without going through Metal.jl's submission hook
    Metal.synchronize_pending!()
    return @objc [graph::id{MPSGraph} runWithMTLCommandQueue:commandQueue::id{MTLCommandQueue}
                                                     feeds:feeds::id{MPSGraphTensorDataDictionary}
                                             targetTensors:targetTensors::id{NSArray}
                                          targetOperations:nil::id{Object}]::MPSGraphTensorDataDictionary
end

const MPSGraphTensorShapedTypeDictionary = NSDictionary#{MPSGraphTensor, MPSGraphTensorShapedType}

compile(graph::MPSGraph, dev::MTLDevice, feeds::MPSGraphTensorShapedTypeDictionary, targetTensors::NSArray, targetOperations=nil, compilationDescriptor=nil) = compile(graph, MPSGraphDevice(dev), feeds, targetTensors, targetOperations, compilationDescriptor)
function compile(graph::MPSGraph, dev::MPSGraphDevice, feeds::MPSGraphTensorShapedTypeDictionary, targetTensors::NSArray, targetOperations=nil, compilationDescriptor=nil)
    return @objc [graph::id{MPSGraph} compileWithDevice:dev::id{MPSGraphDevice}
                                      feeds:feeds::id{MPSGraphTensorShapedTypeDictionary}
                              targetTensors:targetTensors::id{NSArray}
                           targetOperations:targetOperations::id{Object}
                      compilationDescriptor:compilationDescriptor::id{Object}]::MPSGraphExecutable
end

function MPSGraphExecutableSerializationDescriptor()
    return @objc [MPSGraphExecutableSerializationDescriptor alloc]::MPSGraphExecutableSerializationDescriptor
end

serialize(graphExe::MPSGraphExecutable, url, descriptor=MPSGraphExecutableSerializationDescriptor()) = serialize(graphExe, NSFileURL(url), descriptor)
function serialize(graphExe::MPSGraphExecutable, url::NSURL, descriptor=MPSGraphExecutableSerializationDescriptor())
    @objc [graphExe::id{MPSGraphExecutable} serializeToMPSGraphPackageAtURL:url::id{NSURL}
                              descriptor:descriptor::id{MPSGraphExecutableSerializationDescriptor}]::Nothing
end


## cached graphs

#=
Creates a default MPSGraphExecutionDescriptor with a MPSGraphCompilationDescriptor
 set to use optimization level 0 instead of 1. This is because level 1 causes operations
 on eltypes <= 16 bytes to be executed on the ANE instead of the GPU, leading to worse
 performance and hangs when the matrices are too big
=#
function default_exec_desc()
    @memoize begin
        compDesc = MPSGraphCompilationDescriptor()
        # Use optimization level 0 to avoid operations being moved to the neural engine
        compDesc.optimizationLevel = MPSGraphOptimizationLevel0

        execDesc = MPSGraphExecutionDescriptor()
        execDesc.compilationDescriptor = compDesc
        execDesc
    end::MPSGraphExecutionDescriptor
end

# Graphs are built once per configuration and reused; building one dominates the run time of
# small operations.

"""
    CachedGraph(graph, inputs, outputs)

A graph together with the placeholders it reads (`inputs`) and the tensors it produces
(`outputs`), in the order in which [`run!`](@ref) binds arrays to them.
"""
struct CachedGraph
    graph::MPSGraph
    inputs::Vector{MPSGraphTensor}
    outputs::Vector{MPSGraphTensor}
    # concurrent encoding of one graph is not documented to be safe
    lock::ReentrantLock
end
CachedGraph(graph, inputs, outputs) = CachedGraph(graph, inputs, outputs, ReentrantLock())

"""
    build_graph(key)::CachedGraph

Build the graph that `key` describes. Each operation defines a key type, holding everything
that determines the graph's structure (shapes, element types, flags), and a method for it.
"""
function build_graph end

const graph_cache = Dict{Any, CachedGraph}()
const graph_cache_lock = ReentrantLock()

cached_graph(key) = @lock graph_cache_lock get!(() -> build_graph(key), graph_cache, key)

"""
    run!(graph::CachedGraph, outputs, inputs)

Encode `graph` on the current task's queue, reading the arrays in `inputs` and writing those
in `outputs`, and commit it without waiting for completion.
"""
function run!(cached::CachedGraph, outputs::Tuple, inputs::Tuple)
    length(inputs) == length(cached.inputs) && length(outputs) == length(cached.outputs) ||
        throw(ArgumentError("graph takes $(length(cached.inputs)) inputs and $(length(cached.outputs)) outputs"))
    # MPS aborts the process on empty buffers; operations must handle empty arrays
    (any(isempty, inputs) || any(isempty, outputs)) &&
        throw(ArgumentError("cannot run a graph on empty arrays"))
    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        tensor => MPSGraphTensorData(arr) for (tensor, arr) in zip(cached.inputs, inputs))
    results = Dict{MPSGraphTensor, MPSGraphTensorData}(
        tensor => MPSGraphTensorData(arr) for (tensor, arr) in zip(cached.outputs, outputs))

    cmdbuf = MPSCommandBuffer(Metal.global_queue(device()))
    @lock cached.lock begin
        encode!(cmdbuf, cached.graph, NSDictionary(feeds), NSDictionary(results), nil,
                default_exec_desc())
    end
    commit!(cmdbuf)
    return
end
