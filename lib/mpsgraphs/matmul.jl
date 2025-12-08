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
    alpha::Float64  # Normalized to Float64 for hashing
    beta::Float64
    transpose_a::Bool
    transpose_b::Bool
end

# Cached graph with all tensors needed for execution
struct CachedMatmulGraph
    graph::MPSGraph
    place_c::MPSGraphTensor
    place_a::MPSGraphTensor
    place_b::MPSGraphTensor
    result::MPSGraphTensor
end

# Thread-safe graph cache with lock
const _matmul_graph_cache = Dict{MatmulGraphKey, CachedMatmulGraph}()
const _matmul_graph_cache_lock = ReentrantLock()

# Build graph key from matmul parameters
function _make_matmul_key(a::MtlArray{Tab, Na}, b::MtlArray{Tab, Nb}, c::MtlArray{Tc},
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

# Build a new matmul graph (called only on cache miss)
function _build_matmul_graph(size_a::Tuple, size_b::Tuple, size_c::Tuple,
                             Tab::DataType, Tc::DataType,
                             Na::Int, Nb::Int,
                             transpose_a::Bool, transpose_b::Bool,
                             alpha::Number, beta::Number)
    graph = MPSGraph()

    placeA = placeholderTensor(graph, size_a, Tab)
    placeB = placeholderTensor(graph, size_b, Tab)
    placeC = placeholderTensor(graph, size_c, Tc)

    # cast to output eltype if input type is an integer type
    castT = Tab <: Integer ? Tc : Tab
    castA = castTensor(graph, placeA, castT, "castA")
    castB = castTensor(graph, placeB, castT, "castB")

    transA = transpose_a ? transposeTensor(graph, castA, Na-2, Na-1, "transpose_a") : castA
    transB = transpose_b ? transposeTensor(graph, castB, Nb-2, Nb-1, "transpose_b") : castB

    nBatchA = Na == 2 ? 1 : size_a[1]
    nBatchB = Nb == 2 ? 1 : size_b[1]

    # for batched matmul between different sized tensors
    broadcastA, broadcastB = if nBatchA == nBatchB
        transA, transB
    elseif Na == 1
        broadcastTensor(graph, transA, convert(MPSShape, [nBatchB, size(transA)[2:end]...])), transB
    elseif Nb == 1
        transA, broadcastTensor(graph, transB, convert(MPSShape, [nBatchA, size(transB)[2:end]...]))
    else
        transA, transB
    end

    matmul = matrixMultiplicationWithPrimaryTensor(graph, broadcastB, broadcastA)

    afteralpha = let alphatensor = constantWithScalar(graph, alpha, castT)
        multiplicationWithPrimaryTensor(graph, alphatensor, matmul)
    end

    afterbeta = let betatensor = constantWithScalar(graph, beta, castT)
        castplaceC = castTensor(graph, placeC, castT, "castplaceC")
        betaC = multiplicationWithPrimaryTensor(graph, betatensor, castplaceC)
        additionWithPrimaryTensor(graph, afteralpha, betaC)
    end

    castC = castTensor(graph, afterbeta, Tc, "castC")

    CachedMatmulGraph(graph, placeC, placeA, placeB, castC)
end

# Get or create cached graph
function _get_cached_graph(key::MatmulGraphKey)
    # Fast path: check cache without lock (safe for reads)
    cached = get(_matmul_graph_cache, key, nothing)
    if cached !== nothing
        return cached
    end

    # Slow path: acquire lock and build graph
    lock(_matmul_graph_cache_lock) do
        # Double-check after acquiring lock
        cached = get(_matmul_graph_cache, key, nothing)
        if cached !== nothing
            return cached
        end

        # Build new graph
        cached = _build_matmul_graph(
            key.size_a, key.size_b, key.size_c,
            key.eltype_ab, key.eltype_c,
            key.ndims_a, key.ndims_b,
            key.transpose_a, key.transpose_b,
            key.alpha, key.beta
        )
        _matmul_graph_cache[key] = cached
        return cached
    end
end

@autoreleasepool function _matmul!(c::MtlArray{Tc}, a::MtlArray{Tab, Na}, b::MtlArray{Tab, Nb},
                                   alpha::Number, beta::Number,
                                   transpose_a, transpose_b) where {Tc, Tab, Na, Nb}
    # Get or create cached graph
    key = _make_matmul_key(a, b, c, alpha, beta, transpose_a, transpose_b)
    cached = _get_cached_graph(key)

    # Build feed and result dictionaries with current data
    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        cached.place_a => MPSGraphTensorData(a),
        cached.place_b => MPSGraphTensorData(b),
        cached.place_c => MPSGraphTensorData(c)
    )

    resultdict = Dict{MPSGraphTensor, MPSGraphTensorData}(
        cached.result => MPSGraphTensorData(c)
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
