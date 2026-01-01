#=
Creates a default MPSGraphExecutionDescriptor with a MPSGraphCompilationDescriptor
 set to use optimization level 0 instead of 1. This is because level 1 causes operations
 on eltypes <= 16 bytes to be executed on the ANE instead of the GPU, leading to worse
 performance and hangs when the matrices are too big
=#
@static if isdefined(Base, :OncePerProcess) # VERSION >= v"1.12.0-DEV.1421"
    const default_exec_desc = OncePerProcess{MPSGraphExecutionDescriptor}() do
        compDesc = MPSGraphCompilationDescriptor()
        # Use optimization level 0 to avoid operations being moved to the neural engine
        compDesc.optimizationLevel = MPSGraphOptimizationLevel0

        execDesc = MPSGraphExecutionDescriptor()
        execDesc.compilationDescriptor = compDesc
        execDesc
    end
else
    const _default_exec_desc::Ref{MPSGraphExecutionDescriptor} = Ref{MPSGraphExecutionDescriptor}()
    function default_exec_desc()
        if !isassigned(_default_exec_desc)
            compDesc = MPSGraphCompilationDescriptor()
            # Use optimization level 0 to avoid operations being moved to the neural engine
            compDesc.optimizationLevel = MPSGraphOptimizationLevel0

            _default_exec_desc[] = MPSGraphExecutionDescriptor()
            _default_exec_desc[].compilationDescriptor = compDesc
        end
        _default_exec_desc[]
    end
end


#=
MPSGraph caching infrastructure.

Creating an MPSGraph takes ~2ms per call, which dominates matmul time for small-medium
matrices. By caching graphs keyed by their structural parameters (shapes, types, flags),
we achieve significant speedup for repeated operations with the same configuration.

The cache key includes all parameters that affect graph structure:
- Input/output shapes and element types
- Transpose flags
- Alpha/beta values (baked into graph as constants)
=#

# Cache key for matmul graphs - includes all structural parameters
struct MatmulGraphKey
    size_a::Tuple{Vararg{Int}}
    size_b::Tuple{Vararg{Int}}
    size_c::Tuple{Vararg{Int}}
    eltype_ab::DataType
    eltype_c::DataType
    ndims_a::Int
    ndims_b::Int
    alpha::Float64
    beta::Float64
    transpose_a::Bool
    transpose_b::Bool
end
# Build graph key from matmul parameters
function MatmulGraphKey(a::MtlArray{Tab, Na}, b::MtlArray{Tab, Nb}, c::MtlArray{Tc},
                          alpha::Number, beta::Number,
                          transpose_a::Bool, transpose_b::Bool) where {Tc, Tab, Na, Nb}
    MatmulGraphKey(
        size(a), size(b), size(c),
        Tab, Tc,
        Na, Nb,
        Float64(alpha), Float64(beta),
        transpose_a, transpose_b
    )
end

# Cached graph with all tensors needed for execution
struct CachedMatmulGraph
    graph::MPSGraph
    place_c::MPSGraphTensor
    place_a::MPSGraphTensor
    place_b::MPSGraphTensor
    result::MPSGraphTensor
end
# Build a new matmul graph (called only on cache miss)
function CachedMatmulGraph(key::MatmulGraphKey)
    graph = MPSGraph()

    placeA = placeholderTensor(graph, key.size_a, key.eltype_ab)
    placeB = placeholderTensor(graph, key.size_b, key.eltype_ab)
    placeC = placeholderTensor(graph, key.size_c, key.eltype_c)

    # cast to output eltype if input type is an integer type
    castT = key.eltype_ab <: Integer ? key.eltype_c : key.eltype_ab
    castA = castTensor(graph, placeA, castT, "castA")
    castB = castTensor(graph, placeB, castT, "castB")

    transA = key.transpose_a ? transposeTensor(graph, castA, key.ndims_a - 2, key.ndims_a - 1, "transpose_a") : castA
    transB = key.transpose_b ? transposeTensor(graph, castB, key.ndims_b - 2, key.ndims_b - 1, "transpose_b") : castB

    nBatchA = key.ndims_a == 2 ? 1 : key.size_a[1]
    nBatchB = key.ndims_b == 2 ? 1 : key.size_b[1]

    # for batched matmul between different sized tensors
    broadcastA, broadcastB = if nBatchA == nBatchB
        transA, transB
    elseif key.ndims_a == 1
        broadcastTensor(graph, transA, convert(MPSShape, [nBatchB, size(transA)[2:end]...])), transB
    elseif key.ndims_b == 1
        transA, broadcastTensor(graph, transB, convert(MPSShape, [nBatchA, size(transB)[2:end]...]))
    else
        transA, transB
    end

    matmul = matrixMultiplicationWithPrimaryTensor(graph, broadcastB, broadcastA)

    afteralpha = let alphatensor = constantWithScalar(graph, key.alpha, castT)
        multiplicationWithPrimaryTensor(graph, alphatensor, matmul)
    end

    afterbeta = let betatensor = constantWithScalar(graph, key.beta, castT)
        castplaceC = castTensor(graph, placeC, castT, "castplaceC")
        betaC = multiplicationWithPrimaryTensor(graph, betatensor, castplaceC)
        additionWithPrimaryTensor(graph, afteralpha, betaC)
    end

    castC = castTensor(graph, afterbeta, key.eltype_c, "castC")

    CachedMatmulGraph(graph, placeC, placeA, placeB, castC)
end

# Get or create cached graph
function _get_cached_graph!(graph_cache_lock, graph_cache, key::MatmulGraphKey)
    # Fast path: check cache without lock (safe for reads)
    cached = get(graph_cache, key, nothing)
    if cached !== nothing
        return cached
    end

    # Slow path: acquire lock and build graph
    @lock graph_cache_lock get!(graph_cache, key) do
        CachedMatmulGraph(key)
    end
end

# Thread-safe graph cache with lock
const _matmul_graph_cache = Dict{MatmulGraphKey, CachedMatmulGraph}()
const _matmul_graph_cache_lock = ReentrantLock()
@autoreleasepool function _matmul!(c::MtlArray{Tc}, a::MtlArray{Tab, Na}, b::MtlArray{Tab, Nb},
                                   alpha::Number, beta::Number,
                                   transpose_a, transpose_b) where {Tc, Tab, Na, Nb}
    # Get or create cached graph
    key = MatmulGraphKey(a, b, c, alpha, beta, transpose_a, transpose_b)
    cached = _get_cached_graph!(_matmul_graph_cache_lock, _matmul_graph_cache, key)

    # Build feed and result dictionaries with current data
    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        cached.place_a => MPSGraphTensorData(a),
        cached.place_b => MPSGraphTensorData(b),
        cached.place_c => MPSGraphTensorData(c)
    )

    resultdict = Dict{MPSGraphTensor, MPSGraphTensorData}(
        cached.result => feeds[cached.place_c]
    )

    cmdbuf = MPSCommandBuffer(Metal.global_queue(device()))
    encode!(cmdbuf, cached.graph, NSDictionary(feeds), NSDictionary(resultdict), nil, default_exec_desc())
    commit!(cmdbuf)
    wait_completed(cmdbuf)

    return c
end

function graph_matmul!(c::MtlArray{Tc, N}, a::MtlArray{Tab, N}, b::MtlArray{Tab, N}, alpha::Number = true, beta::Number = false, transpose_a = false, transpose_b = false) where {Tc, Tab, N}
    _matmul!(c, a, b, alpha, beta, transpose_a, transpose_b)
end

function graph_matvecmul!(c::MtlVector{Tc}, a::MtlMatrix{Tab}, b::MtlVector{Tab}, alpha::Number = true, beta::Number = false, transpose = false) where {Tc, Tab}
    _matmul!(c, a, b, alpha, beta, transpose, false)
end
