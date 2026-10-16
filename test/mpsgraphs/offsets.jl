# Graph operations on arrays that start at a nonzero offset in their buffer (e.g. contiguous
# views), surrounded by sentinel values that must not be read or overwritten.

const OFFSET_PAD = 3

function offset_array(A::AbstractArray{T}) where {T}
    parent = MtlArray(fill(T(42), length(A) + 2 * OFFSET_PAD))
    view_ = reshape(view(parent, OFFSET_PAD .+ (1:length(A))), size(A))
    @assert view_ isa MtlArray && view_.offset != 0
    copyto!(view_, A)
    return view_, parent
end
offset_array(::Type{T}, dims...) where {T} = offset_array(zeros(T, dims...))

function padding_intact(parent::MtlArray{T}) where {T}
    host = Array(parent)
    return all(==(T(42)), host[1:OFFSET_PAD]) && all(==(T(42)), host[end-OFFSET_PAD+1:end])
end

@testset "reductions" begin
    A = rand(Float32, 3, 5)
    a, _ = offset_array(A)
    r, rp = offset_array(Float32, 1, 5)
    MPSGraphs.graph_mapreducedim!(+, r, a)
    @test Array(r) ≈ sum(A; dims=1)
    @test padding_intact(rp)
end

@testset "scan" begin
    A = rand(Int16(1):Int16(3), 7)
    a, _ = offset_array(A)
    b, bp = offset_array(Int16, 7)
    MPSGraphs.graph_scan!(+, b, a)
    @test Array(b) == cumsum(A)
    @test padding_intact(bp)
end

@testset "sort" begin
    A = rand(Float16, 5, 3)
    a, _ = offset_array(A)
    b, bp = offset_array(Float16, 5, 3)
    MPSGraphs.graph_sort!(b, a; dim=1)
    @test Array(b) == sort(A; dims=1)
    @test padding_intact(bp)

    i, ip = offset_array(Int32, 5, 3)
    MPSGraphs.graph_sortperm!(i, a; dim=1)
    @test Array(i) == sortperm(A; dims=1)
    @test padding_intact(ip)
end

@testset "matmul" begin
    A = rand(Float32, 4, 3)
    B = rand(Float32, 3, 5)
    a, _ = offset_array(A)
    b, _ = offset_array(B)
    c, cp = offset_array(Float32, 4, 5)
    MPSGraphs.graph_matmul!(c, a, b)
    @test Array(c) ≈ A * B
    @test padding_intact(cp)

    x, _ = offset_array(rand(Float32, 3))
    y, yp = offset_array(Float32, 4)
    MPSGraphs.graph_matvecmul!(y, a, x)
    @test Array(y) ≈ A * Array(x)
    @test padding_intact(yp)
end

@testset "softmax" begin
    X = randn(Float32, 5, 3)
    x, _ = offset_array(X)
    y, yp = offset_array(Float32, 5, 3)
    MPSGraphs.graph_softmax!(y, x; dims=1)
    @test Array(y) ≈ exp.(X) ./ sum(exp.(X); dims=1)
    @test padding_intact(yp)
end

@testset "misaligned offset" begin
    parent = MtlArray(zeros(UInt8, 17))
    a = reinterpret(Float32, view(parent, 2:17))
    @test a isa MtlArray && a.offset % sizeof(Float32) != 0
    @test_throws ArgumentError MPSGraphs.graph_scan!(+, similar(a), a)
end
