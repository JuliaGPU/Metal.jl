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

"""
    MPSGraphs.matmul!(C, A, B, α=true, β=false; tA='N', tB='N') -> C

Compute `C = α * opA(A) * opB(B) + β * C`, where `opA` and `opB` are the identity (`'N'`),
`transpose` (`'T'`) or `adjoint` (`'C'`), as selected by `tA` and `tB`.

`A`, `B` and `C` are `MtlArray` matrices, or 3D arrays holding equally many matrices along
the last dimension, which are multiplied pairwise. `A` and `B` have the same element type,
which together with that of `C` is one of the combinations in
`MPSGraphs.MPSGRAPH_VALID_MATMUL_TYPES`; integer inputs are multiplied in the output
type. `α` and `β` are converted to the element types of `A` and `C`. As with BLAS, `C` is
not read when `β` is zero. `C` must not overlap `A` or `B`.

The multiplication executes asynchronously, ordered with the other work submitted from the
current task. Use [`MPSGraphs.supports`](@ref) to check whether a call is supported
without throwing.
"""
function matmul!(C, A, B, alpha::Number=true, beta::Number=false; tA::AbstractChar='N',
                 tB::AbstractChar='N')
    check_supported(matmul!, C, A, B, alpha, beta; tA, tB)
    isempty(C) && return C
    (isempty(A) || isempty(B)) && return scale_output!(C, beta)
    return _matmul!(C, A, B, alpha, beta, Char(tA), Char(tB))
end

function unsupported(::typeof(matmul!), C, A, B, alpha::Number=true, beta::Number=false;
                     tA::AbstractChar='N', tB::AbstractChar='N')
    err = unsupported_arrays(C, A, B)
    err === nothing || return err
    err = unsupported_matmul_types(C, A, B, MPSGRAPH_VALID_MATMUL_TYPES)
    err === nothing || return err
    tA in ('N', 'T', 'C') && tB in ('N', 'T', 'C') ||
        return ArgumentError("MPSGraph matmul supports transpose flags 'N', 'T' and 'C', got '$tA' and '$tB'")
    ndims(A) == ndims(B) == ndims(C) && ndims(C) in (2, 3) ||
        return ArgumentError("MPSGraph matmul requires matrices or 3D arrays of matrices, got $(ndims(C))D, $(ndims(A))D and $(ndims(B))D arrays")
    m, k = tA == 'N' ? (size(A, 1), size(A, 2)) : (size(A, 2), size(A, 1))
    kB, n = tB == 'N' ? (size(B, 1), size(B, 2)) : (size(B, 2), size(B, 1))
    k == kB && size(C, 1) == m && size(C, 2) == n && size(A, 3) == size(B, 3) == size(C, 3) ||
        return DimensionMismatch("cannot multiply arrays of size $(size(A)) ('$tA') and $(size(B)) ('$tB') into one of size $(size(C))")
    return nothing
end

"""
    MPSGraphs.matvecmul!(y, A, x, α=true, β=false; tA='N') -> y

Compute `y = α * opA(A) * x + β * y`, where `opA` is the identity (`'N'`), `transpose`
(`'T'`) or `adjoint` (`'C'`), as selected by `tA`.

`A` is an `MtlArray` matrix and `x` and `y` are `MtlArray` vectors. `A` and `x` have the
same element type, which together with that of `y` is one of the combinations in
`MPSGraphs.MPSGRAPH_VALID_MATVECMUL_TYPES`. Otherwise, this behaves like
[`MPSGraphs.matmul!`](@ref).
"""
function matvecmul!(y, A, x, alpha::Number=true, beta::Number=false; tA::AbstractChar='N')
    check_supported(matvecmul!, y, A, x, alpha, beta; tA)
    isempty(y) && return y
    isempty(x) && return scale_output!(y, beta)
    return _matmul!(y, A, x, alpha, beta, Char(tA), 'N')
end

function unsupported(::typeof(matvecmul!), y, A, x, alpha::Number=true,
                     beta::Number=false; tA::AbstractChar='N')
    err = unsupported_arrays(y, A, x)
    err === nothing || return err
    err = unsupported_matmul_types(y, A, x, MPSGRAPH_VALID_MATVECMUL_TYPES)
    err === nothing || return err
    tA in ('N', 'T', 'C') ||
        return ArgumentError("MPSGraph matvecmul supports transpose flags 'N', 'T' and 'C', got '$tA'")
    ndims(A) == 2 && ndims(x) == ndims(y) == 1 ||
        return ArgumentError("MPSGraph matvecmul requires a matrix and two vectors")
    m, k = tA == 'N' ? size(A) : reverse(size(A))
    length(x) == k && length(y) == m ||
        return DimensionMismatch("cannot multiply a matrix of size $(size(A)) ('$tA') with a vector of length $(length(x)) into one of length $(length(y))")
    return nothing
end

# a product with an empty inner dimension, which MPS can't handle: only β applies
scale_output!(C, beta) = iszero(beta) ? fill!(C, zero(eltype(C))) : (C .*= beta)

function unsupported_matmul_types(C, A, B, valid_types)
    eltype(A) == eltype(B) && (eltype(A), eltype(C)) in valid_types ||
        return ArgumentError("MPSGraph matrix multiplication does not support element types $(eltype(A)) and $(eltype(B)) into $(eltype(C))")
    return nothing
end
