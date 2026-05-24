if MPS.is_supported(device()) && Metal.macos_version() >= v"14"

using .MPS: MPSCommandBuffer, commit!, wait_completed
using .MPSGraphs: MPSGraph, MPSGraphTensor, MPSGraphTensorData,
                  placeholderTensor, scaledDotProductAttentionWithQueryTensor,
                  encode!, default_exec_desc
using ObjectiveC.Foundation: NSDictionary, nil

# Reference attention in 4-D `(head_dim, seq, num_heads, batch)` Julia layout.
# Mask (if provided) is `(N_kv, N_q, num_heads, batch)` — that's MPS's natural
# `(B, H, N_q, N_kv)` layout reversed for Julia col-major.
function _ref_attention(Q, K, V, scale, mask = nothing)
    D, N_q, H, B = size(Q)
    N_kv = size(K, 2)
    O = similar(Q)
    for b in 1:B, h in 1:H
        Qm, Km, Vm = Q[:, :, h, b], K[:, :, h, b], V[:, :, h, b]
        S = (Qm' * Km) .* scale
        if mask !== nothing
            S .+= transpose(mask[:, :, h, b])
        end
        S .-= maximum(S; dims = 2)
        P = exp.(S)
        P ./= sum(P; dims = 2)
        O[:, :, h, b] = Vm * P'
    end
    return O
end

function _run_sdpa(Q, K, V, scale; mask = nothing)
    O = similar(Q)
    graph = MPSGraph()
    qph = placeholderTensor(graph, size(Q), eltype(Q))
    kph = placeholderTensor(graph, size(K), eltype(K))
    vph = placeholderTensor(graph, size(V), eltype(V))
    out = if mask === nothing
        scaledDotProductAttentionWithQueryTensor(graph, qph, kph, vph, Float32(scale))
    else
        mph = placeholderTensor(graph, size(mask), eltype(mask))
        scaledDotProductAttentionWithQueryTensor(graph, qph, kph, vph, mph,
                                                  Float32(scale))
    end

    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        qph => MPSGraphTensorData(Q),
        kph => MPSGraphTensorData(K),
        vph => MPSGraphTensorData(V),
    )
    if mask !== nothing
        feeds[graph.placeholderTensors[end]] = MPSGraphTensorData(mask)
    end
    results = Dict{MPSGraphTensor, MPSGraphTensorData}(
        out => MPSGraphTensorData(O),
    )

    cmdbuf = MPSCommandBuffer(Metal.global_queue(device()))
    encode!(cmdbuf, graph, NSDictionary(feeds), NSDictionary(results), nil,
            default_exec_desc())
    commit!(cmdbuf)
    wait_completed(cmdbuf)
    return O
end

@testset "scaled dot-product attention ($T)" for T in (Float16, Float32)
    D, N_q, N_kv, H, B = 8, 12, 16, 2, 1
    Q = MtlArray(randn(T, D, N_q, H, B))
    K = MtlArray(randn(T, D, N_kv, H, B))
    V = MtlArray(randn(T, D, N_kv, H, B))
    scale = inv(sqrt(T(D)))

    @testset "no mask" begin
        O = _run_sdpa(Q, K, V, scale)
        O_ref = _ref_attention(Array(Q), Array(K), Array(V), scale)
        @test Array(O) ≈ O_ref rtol = (T === Float16 ? 1e-2 : sqrt(eps(T)))
    end

    @testset "with mask" begin
        mask = MtlArray(randn(T, N_kv, N_q, H, B))
        O = _run_sdpa(Q, K, V, scale; mask)
        O_ref = _ref_attention(Array(Q), Array(K), Array(V), scale, Array(mask))
        @test Array(O) ≈ O_ref rtol = (T === Float16 ? 1e-2 : sqrt(eps(T)))
    end
end

end # MPS.is_supported(device()) && macOS 14+
