# Scaled-dot-product attention via the existing MPS / MPSGraph dispatch.
#
# This is the trivial baseline: rely on Metal.jl's automatic dispatch of `*`
# to MPSMatrixMultiplication / MPSGraph and on the GPUArrays broadcast for
# the softmax. It is NOT a Flash Attention algorithm — the full N×N scores
# matrix is materialized in device memory — but it is the right reference
# implementation to verify a custom kernel against.

using Metal
using Test

function attention_reference(Q, K, V)
    d = size(Q, 2)
    scale = inv(sqrt(eltype(Q)(d)))

    S = (Q * K') .* scale                 # N_q × N_kv, dispatched to MPS
    S = S .- maximum(S; dims = 2)         # row-wise max for numerical stability
    P = exp.(S)
    P = P ./ sum(P; dims = 2)             # row-wise softmax

    return P * V                          # N_q × D, dispatched to MPS
end

let
    N_q, N_kv, D = 64, 64, 32
    T = Float32

    Q = MtlArray(randn(T, N_q, D))
    K = MtlArray(randn(T, N_kv, D))
    V = MtlArray(randn(T, N_kv, D))

    O_gpu = attention_reference(Q, K, V)

    # CPU reference
    Qh, Kh, Vh = Array(Q), Array(K), Array(V)
    scale = inv(sqrt(T(D)))
    S = (Qh * Kh') .* scale
    S .-= maximum(S; dims = 2)
    P = exp.(S)
    P ./= sum(P; dims = 2)
    O_cpu = P * Vh

    @test Array(O_gpu) ≈ O_cpu rtol = sqrt(eps(T))
end
