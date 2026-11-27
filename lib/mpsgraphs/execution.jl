
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

# An execution descriptor that compiles graphs at optimization level 0 instead of 1: level 1
# executes operations on eltypes <= 16 bytes on the neural engine instead of the GPU, which
# performs worse and hangs when the matrices are too big. `relaxed` also allows MPSGraph to
# round `Float32` operands to a 19-bit format (TF32's), for `Metal.matmul_precision =
# :relaxed`; MPSGraph has this option from macOS 26 on.
function exec_desc(relaxed::Bool)
    compDesc = MPSGraphCompilationDescriptor()
    compDesc.optimizationLevel = MPSGraphOptimizationLevel0
    if relaxed && Metal.macos_version() >= v"26"
        compDesc.reducedPrecisionFastMath =
            MPSGraphReducedPrecisionFastMathAllowConvertingOperandsFromFP32ToFP19
    end

    execDesc = MPSGraphExecutionDescriptor()
    execDesc.compilationDescriptor = compDesc
    return execDesc
end
default_exec_desc() = @memoize begin
    exec_desc(false)
end::MPSGraphExecutionDescriptor
relaxed_exec_desc() = @memoize begin
    exec_desc(true)
end::MPSGraphExecutionDescriptor

function MPS.encode!(commandBuffer::MPSCommandBuffer, executable::MPSGraphExecutable,
                     inputs::NSArray, results::NSArray, executionDescriptor=nil)
    @objc [executable::id{MPSGraphExecutable} encodeToCommandBuffer:commandBuffer::id{MPSCommandBuffer}
                                                         inputsArray:inputs::id{NSArray}
                                                        resultsArray:results::id{NSArray}
                                                 executionDescriptor:executionDescriptor::id{Object}]::id{NSArray}
    return results
end

# Graphs are built once per configuration and device, and reused; doing so dominates the
# run time of small operations. They are encoded as graphs, which MPSGraph compiles and
# caches itself. Compiling them to an MPSGraphExecutable would save a few µs of host time
# per call, but encoding an executable keeps every output buffer it is given alive.

"""
    CachedGraph(graph, inputs, outputs; constants=[])

Cache `graph`, given the placeholders it reads (`inputs`) and the tensors it produces
(`outputs`), in the order in which [`run!`](@ref) binds arrays to them. `constants` pairs
further placeholders with arrays that are bound on every run; unlike graph constants,
which MPSGraph converts through Float64, they hold any value exactly.
"""
struct CachedGraph
    graph::MPSGraph
    # the inputs passed to `run!`, followed by the constants
    placeholders::Vector{MPSGraphTensor}
    outputs::Vector{MPSGraphTensor}
    constants::Vector{MtlArray}
    # concurrent encoding of one graph is not documented to be safe
    lock::ReentrantLock
end

function CachedGraph(graph::MPSGraph, inputs::Vector{MPSGraphTensor},
                     outputs::Vector{MPSGraphTensor};
                     constants::Vector{<:Pair{MPSGraphTensor}}=Pair{MPSGraphTensor,MtlArray}[])
    return CachedGraph(graph, [inputs; first.(constants)], outputs, last.(constants),
                       ReentrantLock())
end

"""
    build_graph(key)::CachedGraph

Build the graph that `key` describes. Each operation defines a key type, holding everything
that determines the graph's structure (shapes, element types, flags), and a method for it.
"""
function build_graph end

const graph_cache = Dict{Any, CachedGraph}()
const graph_cache_lock = ReentrantLock()

function cached_graph(key)
    @lock graph_cache_lock get!(() -> build_graph(key), graph_cache, (device(), key))
end

"""
    run!(graph::CachedGraph, outputs, inputs; relaxed=false)

Encode `graph` on the current task's queue, reading the arrays in `inputs` and writing those
in `outputs`, and commit it without waiting for completion. `relaxed` lets MPSGraph reduce
the precision of `Float32` operands (see `exec_desc`); graphs that are run both ways
should be cached under different keys.
"""
function run!(cached::CachedGraph, outputs::Tuple, inputs::Tuple; relaxed::Bool=false)
    ninputs = length(cached.placeholders) - length(cached.constants)
    noutputs = length(cached.outputs)
    length(inputs) == ninputs && length(outputs) == noutputs ||
        throw(ArgumentError("graph takes $ninputs inputs and $noutputs outputs"))
    # MPS aborts the process on empty buffers; operations must handle empty arrays
    (any(isempty, inputs) || any(isempty, outputs)) &&
        throw(ArgumentError("cannot run a graph on empty arrays"))
    feeds = Dict{MPSGraphTensor,MPSGraphTensorData}(
        zip(cached.placeholders, map(MPSGraphTensorData, (inputs..., cached.constants...))))
    results = Dict{MPSGraphTensor,MPSGraphTensorData}(
        zip(cached.outputs, map(MPSGraphTensorData, outputs)))

    cmdbuf = MPSCommandBuffer(Metal.global_queue(device()))
    @lock cached.lock begin
        encode!(cmdbuf, cached.graph, NSDictionary(feeds), NSDictionary(results), nil,
                relaxed ? relaxed_exec_desc() : default_exec_desc())
    end
    commit!(cmdbuf)
    return
end
