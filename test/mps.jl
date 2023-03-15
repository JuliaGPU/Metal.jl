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

            buf_a = MtlArray{input_jl_type}(undef, (rows_a,cols_a))
            buf_b = MtlArray{input_jl_type}(undef, (rows_b,cols_b))
            buf_c = MtlArray{accum_jl_type}(undef, (rows_c,cols_c))

            arr_a = unsafe_wrap(Array{input_jl_type}, buf_a, (rows_a, cols_a))
            arr_b = unsafe_wrap(Array{input_jl_type}, buf_b, (rows_b, cols_b))
            arr_c = unsafe_wrap(Array{accum_jl_type}, buf_c, (rows_c, cols_c))

            rand!(arr_a)
            rand!(arr_b)
            buf_c .= 0

            truth_c = (alpha .* accum_jl_type.(arr_a)) *  accum_jl_type.(arr_b) .+ (beta .* arr_c)

            Metal.@sync MPS.matmul!(buf_c, buf_a, buf_b, alpha, beta)

            @test all(arr_c .≈ truth_c)
        end
    end
end

@testset "Square LU" begin
    A = MtlMatrix(rand(Float32, 1024, 1024))
    lua = lu(A)
    @test Matrix(lua.L) * Matrix(lua.U) ≈ Matrix(lua.P) * Matrix(A)
end

@testset "Thin LU" begin
    A = MtlMatrix(rand(Float32, 1024, 512))
    lua = lu(A)
    @test Matrix(lua.L) * Matrix(lua.U) ≈ Matrix(lua.P) * Matrix(A)
end
        
@testset "Fat LU" begin
    A = MtlMatrix(rand(Float32, 512, 1024))
    lua = lu(A)
    @test Matrix(lua.L) * Matrix(lua.U) ≈ Matrix(lua.P) * Matrix(A)
end

@testset "Singular matrices" begin
    A = MtlMatrix{Float32}([1 2; 0 0])
    @test_throws SingularException lu(A)
end