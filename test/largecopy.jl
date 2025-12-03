# Test inspired by https://github.com/pytorch/pytorch/pull/126104
@testset "large_copyto!" begin
    N = 2^30 + 11
    A = MtlVector{Float32}(undef, N)
    fill!(A, 1)

    B = MtlVector{Float32}(undef, N)
    fill!(B, 0)
    Metal.synchronize()

    @test all(isone.(A))
    @test all(iszero(B))

    #gpu -> gpu
    Metal.@sync copyto!(B, A)
    @test all(isone.(B))
end
