# Flash Attention reference implementations on Apple Silicon.
#
# Three ways to spell scaled dot-product attention on Metal, illustrating
# the programming models Metal.jl exposes:
#
#   attention_mps(Q, K, V)
#       The trivial baseline. Uses standard Julia operators (`*`,
#       broadcasting, `maximum`, `sum`, `exp`) on `MtlArray`. The matrix
#       multiplies are dispatched to MPSGraph / MPSMatrixMultiplication by
#       `src/linalg.jl`; the rest is GPUArrays. Not actually a Flash
#       Attention algorithm — the full N×N scores matrix is materialized
#       in device memory — but it's the right reference and the fastest
#       path to "attention runs on GPU" when you don't need a custom
#       kernel. Works on macOS 13+ / M1+.
#
#   attention_mpsgraph(Q, K, V)
#       The high-level MPS path. Builds a one-node MPSGraph using
#       `scaledDotProductAttentionWithQueryTensor` (macOS 14+), which
#       fuses Q·Kᵀ → scale → softmax → ·V into a single op. Apple uses
#       the same op as the backbone of their own SDPA paths (MLX falls
#       back to it; Core ML lowers attention to it), so it's the closest
#       thing to "ask Apple for attention" that Metal.jl can give you.
#
#   attention_simdgroup(Q, K, V)
#       A single-block scaled dot-product attention kernel built from
#       `MtlSimdgroupMatrix{Float16, 8, 8}`. One simdgroup of 32 lanes
#       does the QKᵀ and PV matrix multiplies via two `simdgroup_matrix`
#       ops; the row-wise softmax is done in scalar code through
#       threadgroup memory. Limited to N = D = 8, single head, single
#       batch — illustrative, not production. See
#       https://github.com/philipturner/metal-flash-attention for a
#       tuned reference. Works on macOS 13+ / M1+.
#
# A fourth path would use the Metal 4 `cooperative_tensor` /
# `tensor_ops::matmul2d` primitives with postfix-fusion of the softmax
# epilogue. Apple positions this as the preferred programming model for
# ML on M5; on M3/M4 it lowers to the same simdgroup MMA hardware the
# `attention_simdgroup` path already drives. That path isn't yet wired up
# in Metal.jl — the ObjC classes are generated in `lib/mtl/libmtl.jl`
# (gated on `macos(v"26.0.0")`), but the host-side `MTLTensor` /
# `MTL4ComputeCommandEncoder` wrappers and the device-side
# `MtlCooperativeTensor` are not. Note that the device-side ops lower to
# externally-defined `__tensorops_impl_matmul2d_op_*` symbols rather than
# `air.*` intrinsics, so the binding pattern differs from the simdgroup
# case.
#
# All three implementations take Julia 4-D `(head_dim, seq, num_heads,
# batch)` inputs — MPSGraph sees these reversed as `(batch, num_heads,
# seq, head_dim)`, the layout Apple's SDPA expects.

using Metal
using Test
using BenchmarkTools

using Metal.MPS: MPSCommandBuffer, commit!, wait_completed
using Metal.MPSGraphs: MPSGraph, MPSGraphTensor, MPSGraphTensorData,
                       placeholderTensor, scaledDotProductAttentionWithQueryTensor,
                       encode!, default_exec_desc
using Metal.Foundation: NSDictionary, nil


## MPS / GPUArrays path

function attention_mps(Q::MtlArray{T,4}, K::MtlArray{T,4}, V::MtlArray{T,4};
                       scale = inv(sqrt(T(size(Q, 1))))) where {T}
    _, _, H, B = size(Q)
    O = similar(Q)
    for b in 1:B, h in 1:H
        Qm, Km, Vm = Q[:, :, h, b], K[:, :, h, b], V[:, :, h, b]
        S = (transpose(Qm) * Km) .* scale
        S = S .- maximum(S; dims = 2)
        P = exp.(S)
        P = P ./ sum(P; dims = 2)
        O[:, :, h, b] = Vm * transpose(P)
    end
    return O
end


## MPSGraph SDPA path

function attention_mpsgraph(Q::MtlArray{T,4}, K::MtlArray{T,4}, V::MtlArray{T,4};
                            scale = inv(sqrt(T(size(Q, 1))))) where {T}
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
    encode!(cmdbuf, graph, NSDictionary(feeds), NSDictionary(results), nil,
            default_exec_desc())
    commit!(cmdbuf)
    wait_completed(cmdbuf)
    return O
end


## Custom kernel with MtlSimdgroupMatrix

function _fa_kernel!(O::AbstractMatrix{Float16},
                    Q::AbstractMatrix{Float16},
                    K_t::AbstractMatrix{Float16},
                    V::AbstractMatrix{Float16},
                    scale::Float32)
    Ss = MtlThreadGroupArray(Float32, (8, 8))      # scores, then P
    Sh = MtlThreadGroupArray(Float16, (8, 8))      # P cast back to fp16

    # 1. S = Q · K_t  (single 8x8 simdgroup_matrix multiply)
    Qm = simdgroup_load(MtlSimdgroupMatrix{Float16, 8, 8}, Q)
    Km = simdgroup_load(MtlSimdgroupMatrix{Float16, 8, 8}, K_t)
    Sm = Qm * Km

    # 2. Spill to threadgroup memory for the row-wise softmax in scalar code.
    Sh_tmp = MtlThreadGroupArray(Float16, (8, 8))
    simdgroup_store(Sm, Sh_tmp)
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)

    tid = Int(thread_index_in_threadgroup()) - 1   # 0..31
    @inbounds for k in 0:1
        idx = tid * 2 + k
        r = idx ÷ 8 + 1
        c = idx % 8 + 1
        Ss[r, c] = Float32(Sh_tmp[r, c]) * scale
    end
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)

    # 3. Row-wise softmax. 8 of 32 lanes do real work.
    if tid < 8
        m = -Inf32
        @inbounds for j in 1:8
            v = Ss[tid + 1, j]
            m = v > m ? v : m
        end
        s = 0.0f0
        @inbounds for j in 1:8
            p = exp(Ss[tid + 1, j] - m)
            Ss[tid + 1, j] = p
            s += p
        end
        inv_s = 1.0f0 / s
        @inbounds for j in 1:8
            Sh[tid + 1, j] = Float16(Ss[tid + 1, j] * inv_s)
        end
    end
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)

    # 4. O = P · V (second 8x8 simdgroup_matrix multiply)
    Pm = simdgroup_load(MtlSimdgroupMatrix{Float16, 8, 8}, Sh)
    Vm = simdgroup_load(MtlSimdgroupMatrix{Float16, 8, 8}, V)
    Om = Pm * Vm

    simdgroup_store(Om, O)
    return
end

function attention_simdgroup(Q::MtlArray{Float16,4}, K::MtlArray{Float16,4},
                             V::MtlArray{Float16,4};
                             scale = inv(sqrt(Float32(size(Q, 1)))))
    @assert size(Q) == size(K) == size(V) == (8, 8, 1, 1) "simdgroup kernel only handles (D=8, N=8, H=1, B=1)"

    # Inputs are (D, N, 1, 1). Kernel works with Q and V in (N, D), and K_t in
    # (D, N) — the latter is the user-facing K already transposed, so reshape
    # of the (D, N) slice gives us K_t for free.
    Q2  = permutedims(reshape(Q, 8, 8), (2, 1))
    V2  = permutedims(reshape(V, 8, 8), (2, 1))
    K_t = reshape(K, 8, 8)
    O2  = similar(Q2)

    Metal.@sync @metal threads = 32 _fa_kernel!(O2, Q2, K_t, V2, Float32(scale))
    return reshape(permutedims(O2, (2, 1)), 8, 8, 1, 1)
end


## CPU reference + driver

function attention_cpu(Q, K, V; scale = inv(sqrt(eltype(Q)(size(Q, 1)))))
    D, N_q, H, B = size(Q)
    O = similar(Q)
    for b in 1:B, h in 1:H
        Qm, Km, Vm = Q[:, :, h, b], K[:, :, h, b], V[:, :, h, b]
        S = (Qm' * Km) .* scale
        S .-= maximum(S; dims = 2)
        P = exp.(S)
        P ./= sum(P; dims = 2)
        O[:, :, h, b] = Vm * P'
    end
    return O
end

function main()
    T = Float16    # simdgroup path requires fp16
    D = N = 8      # constrained by the simdgroup kernel

    Q = MtlArray(randn(T, D, N, 1, 1))
    K = MtlArray(randn(T, D, N, 1, 1))
    V = MtlArray(randn(T, D, N, 1, 1))

    O_cpu       = attention_cpu(Array(Q), Array(K), Array(V))
    O_mps       = attention_mps(Q, K, V)
    O_mpsgraph  = attention_mpsgraph(Q, K, V)
    O_simdgroup = attention_simdgroup(Q, K, V)

    @test Array(O_mps)       ≈ O_cpu rtol = 1e-2
    @test Array(O_mpsgraph)  ≈ O_cpu rtol = 1e-2
    @test Array(O_simdgroup) ≈ O_cpu rtol = 1e-2

    if get(ENV, "TESTING", "false") != "true"
        println("\nattention_mps:")
        @btime Metal.@sync attention_mps($Q, $K, $V)
        println("attention_mpsgraph:")
        @btime Metal.@sync attention_mpsgraph($Q, $K, $V)
        println("attention_simdgroup:")
        @btime Metal.@sync attention_simdgroup($Q, $K, $V)
    end
end

isinteractive() || main()
