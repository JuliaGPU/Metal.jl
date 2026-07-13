const FCs = ((identity, 'N'), (transpose, 'T'), (adjoint, 'C'))
alphabeta(::Type{T}) where T <: Complex = one(T) + 1im
alphabeta(::Type{T}) where T <: Real = one(T)

@testset "asynchronous execution ordering" begin
    N = 32
    a = rand(Float32, N, N) ./ N
    b = rand(Float32, N, N) ./ N

    buf_a = MtlArray(a)
    buf_b = MtlArray(b)
    buf_c = similar(buf_a)
    buf_d = similar(buf_a)
    buf_e = similar(buf_a)

    # Exercise both MPSGraph -> kernel and kernel -> MPSGraph dependencies.
    MPSGraphs.graph_matmul!(buf_c, buf_a, buf_b)
    buf_d .= 2f0 .* buf_c .+ 1f0
    MPSGraphs.graph_matmul!(buf_e, buf_d, buf_b)
    buf_e .+= 3f0

    @test Array(buf_e) ≈ (2f0 .* (a * b) .+ 1f0) * b .+ 3f0
end

@testset "mixed-precision matrix matrix multiplication" begin
    N = 10
    rows_a = N
    cols_a = N

    rows_b = N
    cols_b = N

    rows_c = rows_a
    cols_c = cols_b

    @testset "$(input_jl_type) => $accum_jl_type" for (input_jl_type, accum_jl_type) in MPSGraphs.MPSGRAPH_VALID_MATMUL_TYPES
        alpha = alphabeta(input_jl_type)
        beta  = alphabeta(accum_jl_type)

        @testset "$fA, $fB" for (fA,tA) in FCs, (fB,tB) in FCs
            arr_a = rand(input_jl_type, (rows_a, cols_a))
            arr_b = rand(input_jl_type, (rows_b, cols_b))
            arr_c = zeros(accum_jl_type, (rows_c, cols_c))

            buf_a = MtlArray{input_jl_type}(arr_a)
            buf_b = MtlArray{input_jl_type}(arr_b)
            buf_c = MtlArray{accum_jl_type}(arr_c)

            truth_c = (alpha .* accum_jl_type.(fA(arr_a))) * accum_jl_type.(fB(arr_b)) .+ (beta .* arr_c)

            MPSGraphs.graph_matmul!(buf_c, buf_a, buf_b, alpha, beta, tA, tB)

            @test Array(buf_c) ≈ truth_c
        end
    end
end

@testset "batched matrix matrix multiplication" begin
    M = 8
    N = 7
    P = 9
    batch_size = 3

    getsizes(_tA, _tB) = (_tA == 'N' ? (M, N) : (N, M)), (_tB == 'N' ? (N, P) : (P, N)), (M, P)

    @testset "$(input_jl_type) => $accum_jl_type" for (input_jl_type, accum_jl_type) in MPSGraphs.MPSGRAPH_VALID_MATMUL_TYPES
        alpha = alphabeta(input_jl_type)
        beta  = alphabeta(accum_jl_type)

        @testset "$fA, $fB" for (fA,tA) in FCs, (fB,tB) in FCs
            (rows_a, cols_a), (rows_b, cols_b), (rows_c, cols_c) = getsizes(tA, tB)

            arr_a = rand(input_jl_type, (rows_a, cols_a, batch_size))
            arr_b = rand(input_jl_type, (rows_b, cols_b, batch_size))
            arr_c = zeros(accum_jl_type, (rows_c, cols_c, batch_size))

            buf_a = MtlArray{input_jl_type}(arr_a)
            buf_b = MtlArray{input_jl_type}(arr_b)
            buf_c = MtlArray{accum_jl_type}(arr_c)
            truth_c = zeros(accum_jl_type, (rows_c, cols_c, batch_size))
            for i in 1:batch_size
                @views truth_c[:, :, i] = (alpha .* accum_jl_type.(fA(arr_a[:, :, i]))) * accum_jl_type.(fB(arr_b[:, :, i])) .+ (beta .* arr_c[:, :, i])
            end

            MPSGraphs.graph_matmul!(buf_c, buf_a, buf_b, alpha, beta, tA, tB)

            @test Array(buf_c) ≈ truth_c
        end
    end
end

@testset "mixed-precision matrix vector multiplication" begin
    N = 10
    rows = N
    cols = N

    @testset "$(input_jl_type) => $accum_jl_type" for (input_jl_type, accum_jl_type) in MPSGraphs.MPSGRAPH_VALID_MATVECMUL_TYPES
        alpha = alphabeta(input_jl_type)
        beta  = zero(accum_jl_type)

        @testset "$fA" for (fA,tA) in FCs
            arr_a = rand(input_jl_type, (rows, cols))
            arr_b = rand(input_jl_type, rows)
            arr_c = zeros(accum_jl_type, rows)

            buf_a = MtlArray{input_jl_type}(arr_a)
            buf_b = MtlArray{input_jl_type}(arr_b)
            buf_c = MtlArray{accum_jl_type}(arr_c)

            truth_c = (accum_jl_type(alpha) .* accum_jl_type.(fA(arr_a))) * accum_jl_type.(arr_b) .+ (accum_jl_type(beta) .* arr_c)

            MPSGraphs.graph_matvecmul!(buf_c, buf_a, buf_b, alpha, beta, tA)

            @test Array(buf_c) ≈ truth_c
        end
    end
end
