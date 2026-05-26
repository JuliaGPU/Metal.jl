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
#       One fused kernel (QKᵀ → softmax → ·V) using the Metal 4
#       `tensor_ops::matmul2d` primitives. Single dispatch with grid =
#       (H, B), one threadgroup per (head, batch) pair, so all heads
#       run in parallel — the kernel reads its own `(h, b)` from
#       `threadgroup_position_in_grid`. The kernel builds
#       `tensor_inline` views over the `MtlDeviceArray` inputs, so the
#       kernel signature stays buffer-shaped — no host-side `MTLTensor`
#       / `MTL4ComputeCommandEncoder` wrapping is needed. The matmuls
#       lower to externally-defined `__tensorops_impl_matmul2d_op_*`
#       symbols (linked from the MetalPerformancePrimitives runtime),
#       not `air.*` intrinsics. Scratch for the scores and softmaxed P
#       lives in threadgroup memory for the lifetime of the kernel — no
#       device-memory round-trip between the two matmuls. Requires
#       macOS 26+; on M3/M4 the runtime still lowers to the same
#       simdgroup MMA hardware. Limited to N = D = 64 because the
#       matmul descriptor is specialized to that single 64×64 tile, and
#       the two matmul callsites only avoid Apple's back-end
#       "out of stack registers" crash when the `matmul2d` op is built
#       through Metal.jl's `TensorOpsMatmul2D{DESC, NSIMD}` wrapper
#       (descriptor + simdgroup count as type parameters, mirroring
#       MSL's `matmul2d<desc, execution_simdgroups<N>>`).
#       `cooperative_tensor` would keep the scores tile in registers for
#       true postfix-fusion, but the device-side dynamic-alloca support
#       that requires isn't wired up yet.
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

# One fused kernel per (head, batch): QKᵀ → softmax → ·V, with scores and
# softmaxed P kept in threadgroup memory. The matmul writes its (M, N) output
# in a layout that Julia reads as KᵀQ (the transpose of QᵀK), so we apply a
# *column*-wise softmax — that's what corresponds to row-wise softmax of the
# implicit QᵀK, and it's the right direction for column-major contiguous
# memory access.
function _fa_tensor!(O::MtlDeviceArray{Float16, 4},
                     Q::MtlDeviceArray{Float16, 4},
                     K::MtlDeviceArray{Float16, 4},
                     V::MtlDeviceArray{Float16, 4},
                     scale::Float32,
                     ::Val{TD}, ::Val{TN},
                     ::Val{NSIMD}) where {TD, TN, NSIMD}
    # One threadgroup per (head, batch) pair.
    tgid = threadgroup_position_in_grid_3d()
    h    = Int32(tgid.x) - Int32(1)
    b    = Int32(tgid.y) - Int32(1)
    tid  = Int32(thread_position_in_threadgroup_3d().x) - Int32(1)

    # Pointer arithmetic for the (h, b) slice of each 4-D buffer.
    H = Int32(size(Q, 3))
    DN = Int32(TD) * Int32(TN)
    slice_first = (b * H + h) * DN + Int32(1)
    Qb = MtlDeviceArray{Float16, 2, Metal.AS.Device}((Int32(TD), Int32(TN)), pointer(Q, slice_first))
    Kb = MtlDeviceArray{Float16, 2, Metal.AS.Device}((Int32(TD), Int32(TN)), pointer(K, slice_first))
    Vb = MtlDeviceArray{Float16, 2, Metal.AS.Device}((Int32(TD), Int32(TN)), pointer(V, slice_first))
    Ob = MtlDeviceArray{Float16, 2, Metal.AS.Device}((Int32(TD), Int32(TN)), pointer(O, slice_first))

    # Scratch lives in threadgroup memory for the entire kernel: scores tile
    # (Float32 for accumulator precision) and the softmaxed P (Float16 for the
    # second matmul).
    S = MtlThreadGroupArray(Float32, (TN, TN))
    P = MtlThreadGroupArray(Float16, (TN, TN))

    # Step 1: S = QᵀK (read as KᵀQ in Julia layout, see above).
    let tA = MtlInlineTensor(Qb, (Int32(TD), Int32(TN))),
        tB = MtlInlineTensor(Kb, (Int32(TD), Int32(TN))),
        tC = MtlInlineTensor(S,  (Int32(TN), Int32(TN)))
        op = TensorOpsMatmul2D{matmul2d_descriptor(TN, TN, TD;
                                                   transpose_right = true),
                               Int32(NSIMD)}()
        op(tA, tB, tC)
    end
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)

    # Step 2: column-wise softmax. TN of (NSIMD*32) threads do real work; the
    # rest wait at the barrier below.
    @inbounds if tid < Int32(TN)
        col = tid + Int32(1)
        m = -Inf32
        for i in Int32(1):Int32(TN)
            v = S[i, col] * scale
            m = v > m ? v : m
        end
        s = 0.0f0
        for i in Int32(1):Int32(TN)
            p = exp(S[i, col] * scale - m)
            S[i, col] = p
            s += p
        end
        inv_s = 1.0f0 / s
        for i in Int32(1):Int32(TN)
            P[i, col] = Float16(S[i, col] * inv_s)
        end
    end
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)

    # Step 3: O = V·P (Julia view; equivalent to V·Pᵀ in math notation because
    # the softmax output is stored in the transposed layout).
    let tA = MtlInlineTensor(P,  (Int32(TN), Int32(TN))),
        tB = MtlInlineTensor(Vb, (Int32(TD), Int32(TN))),
        tC = MtlInlineTensor(Ob, (Int32(TD), Int32(TN)))
        op = TensorOpsMatmul2D{matmul2d_descriptor(TN, TD, TN), Int32(NSIMD)}()
        op(tA, tB, tC)
    end
    return
end

function attention_tensor(Q::MtlArray{Float16,4}, K::MtlArray{Float16,4},
                          V::MtlArray{Float16,4};
                          scale = inv(sqrt(Float32(size(Q, 1)))))
    @assert size(Q) == size(K) == size(V)
    D, N, H, B = size(Q)
    # The matmul descriptor below is specialized to (N, N, D); allowing other
    # shapes would mean dispatching multiple threadgroups.
    @assert D == N "tensor-ops kernel currently expects D == N"
    O = similar(Q)

    simdgroup_size = 32
    nsimd = 4                       # matches `execution_simdgroups<4>` in the op desc
    threads = nsimd * simdgroup_size

    # Single dispatch covering all (head, batch) pairs: one threadgroup each,
    # grid = (H, B). The kernel uses `threadgroup_position_in_grid` to pick its
    # slice. The matmul descriptors carry (TN, TD) — the static tile shape per
    # head.
    Metal.@sync @metal threads = threads groups = (H, B, 1) _fa_tensor!(
        O, Q, K, V, Float32(scale),
        Val(Int32(D)), Val(Int32(N)), Val(Int32(nsimd)))
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
