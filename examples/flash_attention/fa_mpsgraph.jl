# Fused scaled-dot-product attention via MPSGraph's
# `scaledDotProductAttentionWithQueryTensor` op (macOS 14+). One graph node
# does Q·Kᵀ → scale → softmax → ·V end-to-end; MPSGraph picks the kernel.
#
# Higher-level than `fa_mps.jl`: there's no host-side composition of
# matmul + broadcast + softmax + matmul. Whether MPSGraph internally
# materializes the N×N scores matrix is a black box, but on macOS 14+
# Apple uses this same op as their backbone SDPA implementation
# (MLX falls back to it; Core ML lowers attention to it).
#
# This example uses the 4-D `(head_dim, seq, num_heads, batch)` Julia
# layout, which MPSGraph sees reversed as `(batch, num_heads, seq, head_dim)`
# — Apple's expected SDPA layout.

using Metal
using Metal.MPS: MPSCommandBuffer, commit!, wait_completed
using Metal.MPSGraphs: MPSGraph, MPSGraphTensor, MPSGraphTensorData,
                       placeholderTensor, scaledDotProductAttentionWithQueryTensor,
                       encode!, default_exec_desc
using Metal.Foundation: NSDictionary, nil
using Test

function mpsgraph_attention(Q::MtlArray{T,4}, K::MtlArray{T,4}, V::MtlArray{T,4};
                            scale = inv(sqrt(T(size(Q, 1))))) where {T}
    @assert size(Q, 1) == size(K, 1) == size(V, 1) "head dim mismatch"
    @assert size(K, 2) == size(V, 2) "K/V seq length mismatch"
    @assert size(Q)[3:4] == size(K)[3:4] == size(V)[3:4] "(heads, batch) mismatch"

    O = similar(Q)

    graph = MPSGraph()
    qph = placeholderTensor(graph, size(Q), T)
    kph = placeholderTensor(graph, size(K), T)
    vph = placeholderTensor(graph, size(V), T)
    out = scaledDotProductAttentionWithQueryTensor(graph, qph, kph, vph,
                                                             Float32(scale))

    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        qph => MPSGraphTensorData(Q),
        kph => MPSGraphTensorData(K),
        vph => MPSGraphTensorData(V),
    )
    results = Dict{MPSGraphTensor, MPSGraphTensorData}(
        out => MPSGraphTensorData(O),
    )

    cmdbuf = MPSCommandBuffer(Metal.global_queue(device()))
    encode!(cmdbuf, graph, NSDictionary(feeds), NSDictionary(results),
                      nil, default_exec_desc())
    commit!(cmdbuf)
    wait_completed(cmdbuf)
    return O
end

# CPU reference attention, 4-D (head_dim, seq, num_heads, batch) Julia layout.
function cpu_attention(Q, K, V; scale = inv(sqrt(eltype(Q)(size(Q, 1)))))
    D, N_q, H, B = size(Q)
    N_kv = size(K, 2)
    O = similar(Q)
    for b in 1:B, h in 1:H
        Qm, Km, Vm = Q[:, :, h, b], K[:, :, h, b], V[:, :, h, b]   # each is (D, N)
        S = (Qm' * Km) .* scale                                     # (N_q, N_kv)
        S .-= maximum(S; dims = 2)
        P = exp.(S)
        P ./= sum(P; dims = 2)
        O[:, :, h, b] = Vm * P'                                     # (D, N_q)
    end
    return O
end

let
    T = Float32
    D, N_q, N_kv, H, B = 16, 24, 32, 2, 1

    Q = MtlArray(randn(T, D, N_q, H, B))
    K = MtlArray(randn(T, D, N_kv, H, B))
    V = MtlArray(randn(T, D, N_kv, H, B))

    O_gpu = mpsgraph_attention(Q, K, V)
    O_cpu = cpu_attention(Array(Q), Array(K), Array(V))

    @test Array(O_gpu) ≈ O_cpu rtol = sqrt(eps(T))
end
