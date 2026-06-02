using Metal, LinearAlgebra
using ScopedValues: with
with(Metal.matmul_alg => :native) do
    A = MtlArray(rand(Float32, 128, 96)); B = MtlArray(rand(Float32, 96, 64))
    C = A * B
    println("*(F32)         err=", maximum(abs.(Array(C) - Array(A) * Array(B))))

    At = MtlArray(rand(Float32, 96, 128)); Cc = MtlArray(rand(Float32, 128, 64))
    ref = 2f0 .* (Array(At)' * Array(B)) .+ 0.5f0 .* Array(Cc)
    mul!(Cc, At', B, 2f0, 0.5f0)
    println("mul!(transpose,a,b) err=", maximum(abs.(Array(Cc) - ref)))

    Av = MtlArray(rand(Float32, 100, 70)); v = MtlArray(rand(Float32, 70))
    y = Av * v
    println("matvec         err=", maximum(abs.(Array(y) - Array(Av) * Array(v))))

    Ac = MtlArray(rand(ComplexF32, 40, 30)); Bc = MtlArray(rand(ComplexF32, 30, 20))
    Cc2 = Ac * Bc
    println("*(ComplexF32)  err=", maximum(abs.(Array(Cc2) - Array(Ac) * Array(Bc))))
end
println("dispatch OK")
