function _matmul!(c::MtlArray{Tc}, a::MtlArray{Tab}, b::MtlArray{Tab}, alpha::Number, beta::Number, transpose_a, transpose_b) where {Tc, Tab}
    graph = MPSGraph()

    placeA = placeholderTensor(graph, size(a), Tab)
    placeB = placeholderTensor(graph, size(b), Tab)
    outputTensorData = MPSGraphTensorData(c)

    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        placeA => MPSGraphTensorData(a),
        placeB => MPSGraphTensorData(b)
    )

    castA, castB = if Tab != Float32
        castTensor(graph, placeA, Float32, "castA"),
            castTensor(graph, placeB, Float32, "castB")
    else
        placeA, placeB
    end

    transA = if transpose_a
        transposeTensor(graph, castA, 0, 1, "transpose_a")
    else
        castA
    end

    transB = if transpose_b
        transposeTensor(graph, castB, 0, 1, "transpose_b")
    else
        castB
    end

    matmul = matrixMultiplicationWithPrimaryTensor(graph, transB, transA)

    afteralpha = if alpha == 1
        matmul
    else
        alphatensor = constantWithScalar(graph, alpha, Tc)
        multiplicationWithPrimaryTensor(graph, alphatensor, matmul)
    end

    afterbeta = if beta == 0
        afteralpha
    else
        placeC = placeholderTensor(graph, size(c), Tc)
        feeds[placeC] = outputTensorData
        betatensor = constantWithScalar(graph, beta, Tc)
        betaC = multiplicationWithPrimaryTensor(graph, betatensor, placeC)
        additionWithPrimaryTensor(graph, afteralpha, betaC)
    end

    castC = if Tc != Float32
        castTensor(graph, afterbeta, Tc, "castC")
    else
        afterbeta
    end

    resultdict = Dict{MPSGraphTensor, MPSGraphTensorData}(
        castC => outputTensorData
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
