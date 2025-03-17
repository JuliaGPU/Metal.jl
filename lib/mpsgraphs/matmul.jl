function _matmul!(c::MPSMatrix, ::Type{Tc}, a::MPSMatrix, b::MPSMatrix, ::Type{Tab}, alpha::Number, beta::Number, transpose_a, transpose_b) where {Tc, Tab}
    graph = MPSGraph()

    placeA = placeholderTensor(graph, size(a), Tab)
    placeB = placeholderTensor(graph, size(b), Tab)

    castA, castB = if Tc != Tab
        castTensor(graph, placeA, Tc, "castA"),
            castTensor(graph, placeB, Tc, "castB")
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

    feed = Dict(
        placeA => MPSGraphTensorData(a),
        placeB => MPSGraphTensorData(b)
    )

    afterbeta = if beta == 0
        afteralpha
    else
        placeC = placeholderTensor(graph, UInt.(size(c)), Tc)
        feed[placeC] = MPSGraphTensorData(c)
        betatensor = constantWithScalar(graph, beta, Tc)
        betaC = multiplicationWithPrimaryTensor(graph, betatensor, placeC)
        additionWithPrimaryTensor(graph, afteralpha, betaC)
    end

    res = run(graph, feed, [afterbeta])
    resultdata = only(Dict{MPSGraphTensor, MPSGraphTensorData}(res)).second

    return MPSNDArray(resultdata)
end

function graph_matmul!(c::MtlArray{Tc, N}, a::MtlArray{Tab, N}, b::MtlArray{Tab, N}, alpha::Number = true, beta::Number = false, transpose_a = false, transpose_b = false) where {Tc, Tab, N}
    resultndarr = _matmul!(MPSMatrix(c), Tc, MPSMatrix(a), MPSMatrix(b), Tab, alpha, beta, transpose_a, transpose_b)
    return exportToMtlArray!(c, resultndarr)
end

function graph_matvecmul!(c::MtlVector{Tc}, a::MtlMatrix{Tab}, b::MtlVector{Tab}, alpha::Number = true, beta::Number = false, transpose = false) where {Tc, Tab}
    resultndarr = _matmul!(MPSMatrix(c), Tc, MPSMatrix(a), MPSMatrix(b), Tab, alpha, beta, transpose, false)
    return exportToMtlArray!(c, resultndarr)
end
