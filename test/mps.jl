using LinearAlgebra

if MPS.is_supported(current_device())

@testset "mixed-precision matrix multiplication" begin
    N = 10
    rows_a = N
    cols_a = N

    rows_b = N
    cols_b = N

    rows_c = rows_a
    cols_c = cols_b

    alpha = Float64(1)
    beta  = Float64(1)

    for (input_jl_type, accum_jl_type) in MPS.MPS_VALID_MATMUL_TYPES
        @testset "$(input_jl_type) => $accum_jl_type" begin
            arr_a = rand(input_jl_type, (rows_a,cols_a))
            arr_b = rand(input_jl_type, (rows_b,cols_b))
            arr_c = zeros(accum_jl_type, (rows_c,cols_c))

            buf_a = MtlArray{input_jl_type}(arr_a)
            buf_b = MtlArray{input_jl_type}(arr_b)
            buf_c = MtlArray{accum_jl_type}(undef, (rows_c,cols_c))

            truth_c = (alpha .* accum_jl_type.(arr_a)) *  accum_jl_type.(arr_b) .+ (beta .* arr_c)

            Metal.@sync MPS.matmul!(buf_c, buf_a, buf_b, alpha, beta)

            @test all(Array(buf_c) .≈ truth_c)
        end
    end
end

@testset "decompositions" begin
    A = MtlMatrix(rand(Float32, 1024, 1024))
    lua = lu(A)
    @test lua.L * lua.U ≈ MtlMatrix(lua.P) * A

    A = MtlMatrix(rand(Float32, 1024, 512))
    lua = lu(A)
    @test lua.L * lua.U ≈ MtlMatrix(lua.P) * A
    
    A = MtlMatrix(rand(Float32, 512, 1024))
    lua = lu(A)
    @test lua.L * lua.U ≈ MtlMatrix(lua.P) * A

    a = rand(Float32, 1024, 1024)
    A = MtlMatrix(a)
    B = MtlMatrix(a)
    lua = lu!(A)
    @test lua.L * lua.U ≈ MtlMatrix(lua.P) * B

    A = MtlMatrix{Float32}([1 2; 0 0])
    @test_throws SingularException lu(A)
end

end