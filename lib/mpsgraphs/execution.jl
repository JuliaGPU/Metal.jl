
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

function MPS.encode!(commandBuffer::MPSCommandBuffer, executable::MPSGraphExecutable,
                     inputs::NSArray, results::NSArray, executionDescriptor=nil)
    @objc [executable::id{MPSGraphExecutable} encodeToCommandBuffer:commandBuffer::id{MPSCommandBuffer}
                                                         inputsArray:inputs::id{NSArray}
                                                        resultsArray:results::id{NSArray}
                                                 executionDescriptor:executionDescriptor::id{Object}]::id{NSArray}
    return results
end

# Graphs are built and compiled once per configuration and device, and reused; doing so
# dominates the run time of small operations. Executing a compiled graph also avoids the
# per-call lookup that MPSGraph performs to find its own compiled version.

"""
    CachedGraph(graph, inputs, outputs; constants=[])

Compile `graph` for the current device, given the placeholders it reads (`inputs`) and
the tensors it produces (`outputs`), in the order in which [`run!`](@ref) binds arrays to
them. `constants` pairs further placeholders with arrays that are bound on every run;
unlike graph constants, which MPSGraph converts through Float64, they hold any value
exactly.
"""
struct CachedGraph
    executable::MPSGraphExecutable
    # for each input of the executable, which it orders itself, the position in the
    # inputs passed to `run!` followed by the constants
    input_order::Vector{Int}
    noutputs::Int
    constants::Vector{MtlArray}
    # concurrent encoding of one executable is not documented to be safe
    lock::ReentrantLock
end

function CachedGraph(graph::MPSGraph, inputs::Vector{MPSGraphTensor},
                     outputs::Vector{MPSGraphTensor};
                     constants::Vector{<:Pair{MPSGraphTensor}}=Pair{MPSGraphTensor,MtlArray}[])
    placeholders = [inputs; first.(constants)]
    feeds = Dict(x => MPSGraphShapedType(x.shape, x.dataType) for x in placeholders)
    executable = compile(graph, device(), NSDictionary(feeds), NSArray(outputs), nil,
                         default_exec_desc().compilationDescriptor)
    input_order = map(executable.feedTensors) do x
        something(findfirst(y -> pointer(y) == pointer(x), placeholders))
    end
    return CachedGraph(executable, input_order, length(outputs), last.(constants),
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
    run!(graph::CachedGraph, outputs, inputs)

Encode `graph` on the current task's queue, reading the arrays in `inputs` and writing those
in `outputs`, and commit it without waiting for completion.
"""
function run!(cached::CachedGraph, outputs::Tuple, inputs::Tuple)
    ninputs = length(cached.input_order) - length(cached.constants)
    length(inputs) == ninputs && length(outputs) == cached.noutputs ||
        throw(ArgumentError("graph takes $ninputs inputs and $(cached.noutputs) outputs"))
    # MPS aborts the process on empty buffers; operations must handle empty arrays
    (any(isempty, inputs) || any(isempty, outputs)) &&
        throw(ArgumentError("cannot run a graph on empty arrays"))
    all_inputs = (inputs..., cached.constants...)
    input_data = NSArray([MPSGraphTensorData(all_inputs[i]) for i in cached.input_order])
    output_data = NSArray([MPSGraphTensorData(arr) for arr in outputs])

    cmdbuf = MPSCommandBuffer(Metal.global_queue(device()))
    @lock cached.lock begin
        encode!(cmdbuf, cached.executable, input_data, output_data)
    end
    commit!(cmdbuf)
    return
end
