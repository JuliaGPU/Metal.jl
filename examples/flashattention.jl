# Flash Attention reference implementations on Apple Silicon.
#
# Four ways to spell scaled dot-product attention on Metal, illustrating
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
#   attention_tensor(Q, K, V)
#       Two kernels (QKᵀ + softmax, then PV) using the Metal 4
#       `tensor_ops::matmul2d` primitives. Each kernel builds
#       `tensor_inline` views over the `MtlDeviceArray` inputs, so the
#       kernel signature stays buffer-shaped — no host-side `MTLTensor`
#       / `MTL4ComputeCommandEncoder` wrapping is needed. The matmuls
#       lower to externally-defined `__tensorops_impl_matmul2d_op_*`
#       symbols (linked from the MetalPerformancePrimitives runtime),
#       not `air.*` intrinsics. Requires macOS 26+; on M3/M4 the runtime
#       still lowers to the same simdgroup MMA hardware. Limited to N =
#       D = 64 because the matmul descriptor is specialized to that
#       single 64x64 tile. Splitting QK and PV across two dispatches —
#       rather than one fused kernel — works around an Apple back-end
#       crash on two `__tensorops_impl_matmul2d_op_run_*` calls in a
#       single kernel; it also means the scores tile is materialized in
#       device memory (`cooperative_tensor` would keep it in registers
#       for true postfix-fusion, but the device-side dynamic-alloca
#       support that requires isn't wired up yet).
#
# All implementations take Julia 4-D `(head_dim, seq, num_heads, batch)`
# inputs — MPSGraph sees these reversed as `(batch, num_heads, seq,
# head_dim)`, the layout Apple's SDPA expects.

using Metal
using Test

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


## Custom kernel with Metal 4 tensor ops (matmul2d, inline tensors)

# Step 1: compute Q^T K into a Float32 scores buffer, then a row-wise softmax
# (cast to Float16) into a P buffer. The matmul writes its (M, N) output in a
# layout that Julia reads as K^T Q (the transpose of Q^T K), so we apply a
# *column*-wise softmax — that's what corresponds to row-wise softmax of the
# implicit Q^T K, and it's the right direction for column-major contiguous
# memory access.
function _fa_tensor_qk_softmax!(Q::AbstractMatrix{Float16},
                                K::AbstractMatrix{Float16},
                                S::AbstractMatrix{Float32},
                                P::AbstractMatrix{Float16},
                                D::UInt32, N::UInt32, scale::Float32,
                                ::Val{TN}, ::Val{TD},
                                ::Val{NSIMD}) where {TN, TD, NSIMD}
    tid = Int32(thread_position_in_threadgroup_3d().x) - Int32(1)

    A = MtlInlineTensor(Q, (D, N))
    B = MtlInlineTensor(K, (D, N))
    C = MtlInlineTensor(S, (N, N))
    op = TensorOpsMatmul2D{matmul2d_descriptor(TN, TN, TD; transpose_right = true),
                           Int32(NSIMD)}()
    op(A, B, C)
    threadgroup_barrier(Metal.MemoryFlagDevice)

    # Column-wise softmax. 64 of 128 threads do real work; the rest wait.
    @inbounds if tid < Int32(N)
        col = tid + Int32(1)
        m = -Inf32
        for i in Int32(1):Int32(N)
            v = S[i, col] * scale
            m = v > m ? v : m
        end
        s = 0.0f0
        for i in Int32(1):Int32(N)
            p = exp(S[i, col] * scale - m)
            S[i, col] = p
            s += p
        end
        inv_s = 1.0f0 / s
        for i in Int32(1):Int32(N)
            P[i, col] = Float16(S[i, col] * inv_s)
        end
    end
    return
end

# Step 2: O = V · P (in Julia view; equivalent to V · P_attn^T because the
# softmax output is stored in the transposed layout).
function _fa_tensor_pv!(O::AbstractMatrix{Float16},
                        V::AbstractMatrix{Float16},
                        P::AbstractMatrix{Float16},
                        D::UInt32, N::UInt32,
                        ::Val{TN}, ::Val{TD},
                        ::Val{NSIMD}) where {TN, TD, NSIMD}
    A = MtlInlineTensor(P, (N, N))
    B = MtlInlineTensor(V, (D, N))
    C = MtlInlineTensor(O, (D, N))
    op = TensorOpsMatmul2D{matmul2d_descriptor(TN, TD, TN), Int32(NSIMD)}()
    op(A, B, C)
    return
end

function attention_tensor(Q::MtlArray{Float16,4}, K::MtlArray{Float16,4},
                          V::MtlArray{Float16,4};
                          scale = inv(sqrt(Float32(size(Q, 1)))))
    @assert size(Q) == size(K) == size(V)
    D, N, H, B = size(Q)
    # MPP requires a real tile, and the (m, n, k) descriptor below is
    # specialized to (N, N, D); allowing other shapes would mean dispatching
    # multiple threadgroups.
    @assert D == N "tensor-ops kernel currently expects D == N"
    O = similar(Q)

    # Allocate persistent scratch for the scores / softmax outputs. One per
    # (head, batch) pair would let us overlap; for clarity we reuse a single
    # pair across all dispatches.
    S = MtlArray{Float32}(undef, N, N)
    P = MtlArray{Float16}(undef, N, N)

    simdgroup_size = 32
    nsimd = 4                       # matches `execution_simdgroups<4>` in the op desc
    threads = nsimd * simdgroup_size

    # The matmul descriptors carry (TN, TD) — the static tile shape per head.
    TN_val = Val(Int32(N))
    TD_val = Val(Int32(D))
    NS_val = Val(Int32(nsimd))

    for b in 1:B, h in 1:H
        Qm = view(Q, :, :, h, b)
        Km = view(K, :, :, h, b)
        Vm = view(V, :, :, h, b)
        Om = view(O, :, :, h, b)
        @metal threads = threads _fa_tensor_qk_softmax!(Qm, Km, S, P,
                                                       UInt32(D), UInt32(N),
                                                       Float32(scale),
                                                       TN_val, TD_val, NS_val)
        @metal threads = threads _fa_tensor_pv!(Om, Vm, P, UInt32(D), UInt32(N),
                                                TN_val, TD_val, NS_val)
    end
    Metal.synchronize()
    return O
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

    # The simdgroup kernel is locked to 8x8 tiles, and the tensor-ops kernel
    # uses a 64x64 matmul descriptor. Run each at its natural shape.
    let D = N = 8
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
    end

    if Metal.macos_version() >= v"26.0.0"
        let D = N = 64
            Q = MtlArray(randn(T, D, N, 1, 1))
            K = MtlArray(randn(T, D, N, 1, 1))
            V = MtlArray(randn(T, D, N, 1, 1))

            O_cpu      = attention_cpu(Array(Q), Array(K), Array(V))
            O_mps      = attention_mps(Q, K, V)
            O_tensor   = attention_tensor(Q, K, V)

            @test Array(O_mps)    ≈ O_cpu rtol = 1e-2
            @test Array(O_tensor) ≈ O_cpu rtol = 1e-2
        end
    end
end

isinteractive() || main()
