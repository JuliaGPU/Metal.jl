# Correctness sweep for the `:native` GEMM, against a CPU oracle.
# Run: julia --project=. bin/gemm/validate.jl
using Metal, LinearAlgebra, Printf
using ScopedValues: with

# stored shapes for a given transpose char
storeA(M, K, t) = t == 'N' ? (M, K) : (K, M)
storeB(K, N, t) = t == 'N' ? (K, N) : (N, K)

opA(A, t) = t == 'N' ? A : t == 'C' ? A' : transpose(A)
opB(B, t) = t == 'N' ? B : t == 'C' ? B' : transpose(B)

function tol(T)
    Tr = real(T)
    Tr == Float16 ? 2.0f-1 : Tr == Float32 ? 1.0f-2 : 1e-4
end

fails = Ref(0); total = Ref(0)

function check(T, M, N, K, tA, tB, alpha, beta; offset=false, label="")
    total[] += 1
    sA = storeA(M, K, tA); sB = storeB(K, N, tB)
    rand_mat(sz) = T <: Integer ? rand(T(1):T(4), sz...) : rand(T, sz...)
    Ah = rand_mat(sA); Bh = rand_mat(sB); Ch = rand_mat((M, N))
    if offset
        # build padded buffers and take offset views that stay dense MtlMatrix
        dA = MtlArray(vcat(rand_mat((3, sA[2])), Ah))[4:end, :]
        dB = MtlArray(vcat(rand_mat((2, sB[2])), Bh))[3:end, :]
        dC = MtlArray(vcat(rand_mat((5, N)), Ch))[6:end, :]
    else
        dA = MtlArray(Ah); dB = MtlArray(Bh); dC = MtlArray(Ch)
    end
    ref = alpha .* (opA(Ah, tA) * opB(Bh, tB)) .+ beta .* Ch
    Metal.gemm!(dC, tA, tB, dA, dB, alpha, beta)
    got = Array(dC)
    err = isempty(ref) ? 0.0 : maximum(abs.(got .- ref)) / max(1, maximum(abs.(ref)))
    ok = err <= tol(T)
    if !ok
        fails[] += 1
        @printf("FAIL %-7s %-3s M=%d N=%d K=%d %c%c α=%s β=%s off=%s err=%.2e\n",
                string(T), label, M, N, K, tA, tB, alpha, beta, offset, err)
    end
    return ok
end

println("== fast path eltypes (Float32, Float16) ==")
for T in (Float32, Float16)
    for (tA, tB) in (('N','N'), ('N','T'), ('T','N'), ('T','T'))
        for (a, b) in ((1, 0), (2, 0), (1, 1), (1, 2))
            check(T, 64, 48, 32, tA, tB, T(a), T(b))
            check(T, 65, 47, 33, tA, tB, T(a), T(b))   # ragged (non 8-multiple)
            check(T, 17, 9, 100, tA, tB, T(a), T(b))   # skinny + large K
        end
    end
    # offsets, gemv, 1x1, mixed shapes
    check(T, 96, 80, 64, 'N', 'N', T(1), T(0); offset=true, label="offset")
    check(T, 96, 80, 64, 'T', 'N', T(1.5), T(0.5); offset=true, label="offset")
    check(T, 100, 1, 50, 'N', 'N', T(1), T(0), label="gemv-ish")
    check(T, 1, 1, 1, 'N', 'N', T(1), T(0), label="1x1")
    check(T, 33, 33, 8, 'N', 'N', T(1), T(0), label="exact-K8")
end

println("== robust path eltypes (ComplexF32, Int32) ==")
for T in (ComplexF32, Int32)
    for (tA, tB) in (('N','N'), ('N','T'), ('T','N'), ('C','N'), ('N','C'))
        a = T <: Integer ? T(2) : T(2)
        b = T <: Integer ? T(1) : T(1)
        check(T, 40, 24, 16, tA, tB, a, b)
        check(T, 41, 25, 17, tA, tB, a, b)  # ragged
    end
    check(T, 48, 32, 16, 'N', 'N', T <: Integer ? T(1) : T(1), T <: Integer ? T(0) : T(0); offset=true, label="offset")
end

println()
@printf("== %d/%d passed, %d failed ==\n", total[] - fails[], total[], fails[])
fails[] == 0 || error("validation failed")
