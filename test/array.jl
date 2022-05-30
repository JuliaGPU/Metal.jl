@testset "arrays" begin

mtl_arr = MtlArray{Int}(undef, 1)
arr = Array(mtl_arr)

@test sizeof(arr) == 8
@test length(arr) == 1
@test eltype(arr) == Int

end
