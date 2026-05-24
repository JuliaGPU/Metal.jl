# Single-block scaled dot-product attention kernel built from
# `MtlSimdgroupMatrix`. This is the smallest readable example of composing
# the SIMD-group matrix primitives into an attention-style kernel.
#
# Scope:
#   - one simdgroup (32 lanes) per threadgroup, one threadgroup total
#   - Q, K_t, V are fixed at 8×8 (Br = Bc = D = 8)
#   - K is host-transposed to K_t so the in-kernel matmul Q · K_t equals
#     mathematical Q · K^T (Metal.jl's `simdgroup_load` always issues a
#     transposed-from-MSL load to read Julia's column-major data, so
#     getting K^T from a col-major K without an extra binding is awkward)
#   - softmax is done in scalar code through threadgroup memory
#
# A "real" FA kernel adds a KV-block loop with online-softmax state
# (`m`, `l` per row) and tiles D across multiple simdgroups; see
# philipturner/metal-flash-attention for a production reference.

using Metal
using Test

const Br = 8
const Bc = 8
const D  = 8

function fa_kernel!(O::AbstractMatrix{Float16},
                    Q::AbstractMatrix{Float16},
                    K_t::AbstractMatrix{Float16},
                    V::AbstractMatrix{Float16},
                    scale::Float32)
    # Stage scratch.
    Ss = MtlThreadGroupArray(Float32, (Br, Bc))   # scores, then P
    Sh = MtlThreadGroupArray(Float16, (Br, Bc))   # P cast back to fp16

    # 1. S = Q · K_t (single 8x8 simdgroup_matrix multiply)
    Qm = simdgroup_load(MtlSimdgroupMatrix{Float16, 8, 8}, Q)
    Km = simdgroup_load(MtlSimdgroupMatrix{Float16, 8, 8}, K_t)
    Sm = Qm * Km

    # 2. Spill to threadgroup memory for the row-wise softmax in scalar code.
    Sh_tmp = MtlThreadGroupArray(Float16, (Br, Bc))
    simdgroup_store(Sm, Sh_tmp)
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)

    # Cast to Float32 and scale; 32 threads cover the 64 elements at 2 per lane.
    tid = Int(thread_index_in_threadgroup()) - 1   # 0..31
    @inbounds for k in 0:1
        idx = tid * 2 + k
        r = idx ÷ Bc + 1
        c = idx % Bc + 1
        Ss[r, c] = Float32(Sh_tmp[r, c]) * scale
    end
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)

    # 3. Row-wise softmax. 8 of 32 lanes do real work; the rest idle.
    if tid < Br
        m = -Inf32
        @inbounds for j in 1:Bc
            v = Ss[tid + 1, j]
            m = v > m ? v : m
        end
        s = 0.0f0
        @inbounds for j in 1:Bc
            p = exp(Ss[tid + 1, j] - m)
            Ss[tid + 1, j] = p
            s += p
        end
        inv_s = 1.0f0 / s
        @inbounds for j in 1:Bc
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

function flash_attention(Q::MtlMatrix{Float16}, K::MtlMatrix{Float16},
                         V::MtlMatrix{Float16})
    @assert size(Q) == (Br, D) "Q must be ($Br, $D)"
    @assert size(K) == (Bc, D) "K must be ($Bc, $D)"
    @assert size(V) == (Bc, D) "V must be ($Bc, $D)"

    K_t = MtlMatrix(collect(transpose(Array(K))))
    O   = similar(Q)
    scale = inv(sqrt(Float32(D)))

    Metal.@sync @metal threads = 32 fa_kernel!(O, Q, K_t, V, scale)
    return O
end

let
    T = Float16
    Q = MtlArray(rand(T, Br, D))
    K = MtlArray(rand(T, Bc, D))
    V = MtlArray(rand(T, Bc, D))

    O = flash_attention(Q, K, V)

    # Reference attention computed in Float32 on the CPU.
    Qh, Kh, Vh = Float32.(Array(Q)), Float32.(Array(K)), Float32.(Array(V))
    scale = inv(sqrt(Float32(D)))
    S = (Qh * Kh') .* scale
    S .-= maximum(S; dims = 2)
    P = exp.(S)
    P ./= sum(P; dims = 2)
    O_ref = P * Vh

    @test Float32.(Array(O)) ≈ O_ref rtol = 1e-2
end
