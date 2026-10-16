# Cache key for matmul graphs - includes all structural parameters
struct MatmulGraphKey{Tab<: Number, Tc <: Number}
    size_a::Tuple{Vararg{Int}}
    size_b::Tuple{Vararg{Int}}
    size_c::Tuple{Vararg{Int}}
    ndims_a::Int
    ndims_b::Int
    alpha::Tab
    beta::Tc
    transpose_a::Char
    transpose_b::Char
end
# Build graph key from matmul parameters
function MatmulGraphKey(a::MtlArray{Tab, Na}, b::MtlArray{Tab, Nb}, c::MtlArray{Tc},
                          alpha::Number, beta::Number,
                          transpose_a, transpose_b) where {Tc, Tab, Na, Nb}
    MatmulGraphKey{Tab, Tc}(
        size(a), size(b), size(c),
        Na, Nb,
        Tab(alpha), Tc(beta),
        transpose_a, transpose_b
    )
end

# inputs: A, B and (unless β is zero) C; output: C
function build_graph(key::MatmulGraphKey{Tab, Tc}) where {Tab, Tc}
    graph = MPSGraph()

    placeA = placeholderTensor(graph, key.size_a, Tab)
    placeB = placeholderTensor(graph, key.size_b, Tab)

    # cast to output eltype if input type is an integer type
    castTab = Tab <: Integer ? Tc : Tab
    castA = castTensor(graph, placeA, castTab, "castA")
    castB = castTensor(graph, placeB, castTab, "castB")

    conjA = if key.transpose_a == 'C'
        conjugateWithTensor(graph, castA, "conjA")
    else
        castA
    end

    conjB = if key.transpose_b == 'C'
        conjugateWithTensor(graph, castB, "conjB")
    else
        castB
    end

    transA = (key.transpose_a == 'T' || key.transpose_a == 'C') ? transposeTensor(graph, conjA, key.ndims_a - 2, key.ndims_a - 1, "transpose_a") : conjA
    transB = (key.transpose_b == 'T' || key.transpose_b == 'C') ? transposeTensor(graph, conjB, key.ndims_b - 2, key.ndims_b - 1, "transpose_b") : conjB

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

    afteralpha = let
        alphatensor = if castTab <: Real
            constantWithScalar(graph, key.alpha, castTab)
        else
            complexConstant(graph, key.alpha, castTab)
        end
        multiplicationWithPrimaryTensor(graph, alphatensor, matmul)
    end

    castC = castTensor(graph, afteralpha, Tc, "castC")

    # like BLAS, β = 0 means C is not read, so that NaNs or uninitialized memory in C don't
    # propagate into the result
    iszero(key.beta) && return CachedGraph(graph, [placeA, placeB], [castC])

    placeC = placeholderTensor(graph, key.size_c, Tc)
    afterbeta = let
        betatensor = if Tc <: Real
            constantWithScalar(graph, key.beta, Tc)
        else
            complexConstant(graph, key.beta, Tc)
        end
        castplaceC = castTensor(graph, placeC, Tc, "castplaceC")
        betaC = multiplicationWithPrimaryTensor(graph, betatensor, castplaceC)
        additionWithPrimaryTensor(graph, castC, betaC)
    end

    CachedGraph(graph, [placeA, placeB, placeC], [afterbeta])
end

function _matmul!(c::MtlArray{Tc}, a::MtlArray{Tab, Na}, b::MtlArray{Tab, Nb},
                  alpha::Number, beta::Number,
                  transpose_a, transpose_b) where {Tc, Tab, Na, Nb}
    key = MatmulGraphKey(a, b, c, alpha, beta, transpose_a, transpose_b)
    inputs = iszero(key.beta) ? (a, b) : (a, b, c)
    run!(cached_graph(key), (c,), inputs)
    return c
end

function graph_matmul!(c::MtlArray{Tc, N}, a::MtlArray{Tab, N}, b::MtlArray{Tab, N}, alpha::Number = true, beta::Number = false, transpose_a = 'N', transpose_b = 'N') where {Tc, Tab, N}
    _matmul!(c, a, b, alpha, beta, transpose_a, transpose_b)
end

function graph_matvecmul!(c::MtlVector{Tc}, a::MtlMatrix{Tab}, b::MtlVector{Tab}, alpha::Number = true, beta::Number = false, transpose = 'N') where {Tc, Tab}
    _matmul!(c, a, b, alpha, beta, transpose, 'N')
end
