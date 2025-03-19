function _matmul!(c::MtlArray{Tc}, a::MtlArray{Tab, Na}, b::MtlArray{Tab, Nb}, alpha::Number, beta::Number, transpose_a, transpose_b) where {Tc, Tab, Na, Nb}
    graph = MPSGraph()

    placeA = placeholderTensor(graph, size(a), Tab)
    placeB = placeholderTensor(graph, size(b), Tab)
    placeC = placeholderTensor(graph, size(c), Tc)

    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        placeA => MPSGraphTensorData(a),
        placeB => MPSGraphTensorData(b),
        placeC => MPSGraphTensorData(c)
    )

    # cast to Float32 for better performance
    castA = castTensor(graph, placeA, Float32, "castA")
    castB = castTensor(graph, placeB, Float32, "castB")

    transA = transpose_a ? transposeTensor(graph, castA, Na-2, Na-1, "transpose_a") : castA
    transB = transpose_b ? transposeTensor(graph, castB, Nb-2, Nb-1, "transpose_b") : castB

    nBatchA = Na == 2 ? 1 : size(transA)[1]
    nBatchB = Nb == 2 ? 1 : size(transB)[1]

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

    afteralpha = let
        alphatensor = constantWithScalar(graph, alpha, Float32)
        multiplicationWithPrimaryTensor(graph, alphatensor, matmul)
    end

    afterbeta = let
        betatensor = constantWithScalar(graph, beta, Float32)
        castplaceC = castTensor(graph, placeC, Float32, "castplaceC")
        betaC = multiplicationWithPrimaryTensor(graph, betatensor, castplaceC)
        afterbeta = additionWithPrimaryTensor(graph, afteralpha, betaC)
    end

    castC = castTensor(graph, afterbeta, Tc, "castC")

    resultdict = Dict{MPSGraphTensor, MPSGraphTensorData}(
        castC => feeds[placeC]
    )

    cmdbuf = MPSCommandBuffer(Metal.global_queue(device()))
    encode!(cmdbuf, graph, NSDictionary(feeds), NSDictionary(resultdict))
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
