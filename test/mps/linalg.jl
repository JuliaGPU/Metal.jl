using LinearAlgebra

if MPS.is_supported(device())

@testset "mixed-precision matrix matrix multiplication" begin
    N = 10
    rows_a = N
    cols_a = N

    rows_b = N
    cols_b = N

    rows_c = rows_a
    cols_c = cols_b

    alpha = Float64(1)
    beta  = Float64(1)

    @testset "$(input_jl_type) => $accum_jl_type" for (input_jl_type, accum_jl_type) in MPS.MPS_VALID_MATMUL_TYPES
        arr_a = rand(input_jl_type, (rows_a,cols_a))
        arr_b = rand(input_jl_type, (rows_b,cols_b))
        arr_c = zeros(accum_jl_type, (rows_c,cols_c))

        buf_a = MtlArray{input_jl_type}(arr_a)
        buf_b = MtlArray{input_jl_type}(arr_b)
        buf_c = MtlArray{accum_jl_type}(undef, (rows_c,cols_c))

        truth_c = (alpha .* accum_jl_type.(arr_a)) *  accum_jl_type.(arr_b) .+ (beta .* arr_c)

        MPS.matmul!(buf_c, buf_a, buf_b, alpha, beta)

        @test all(Array(buf_c) .≈ truth_c)
    end
end

@testset "batched matrix matrix multiplication" begin
    N = 10
    batch_size = 3

    rows_a = N
    cols_a = N

    rows_b = N
    cols_b = N

    rows_c = rows_a
    cols_c = cols_b

    alpha = Float64(1)
    beta = Float64(1)

    @testset "$(input_jl_type) => $accum_jl_type" for (input_jl_type, accum_jl_type) in MPS.MPS_VALID_MATMUL_TYPES
        arr_a = rand(input_jl_type, (rows_a, cols_a, batch_size))
        arr_b = rand(input_jl_type, (rows_b, cols_b, batch_size))
        arr_c = zeros(accum_jl_type, (rows_c, cols_c, batch_size))

        buf_a = MtlArray{input_jl_type}(arr_a)
        buf_b = MtlArray{input_jl_type}(arr_b)
        buf_c = MtlArray{accum_jl_type}(undef, (rows_c, cols_c, batch_size))

        truth_c = Array{accum_jl_type}(undef, (rows_c, cols_c, batch_size))
        for i in 1:batch_size
            @views truth_c[:, :, i] = (alpha .* accum_jl_type.(arr_a[:, :, i])) * accum_jl_type.(arr_b[:, :, i]) .+ (beta .* arr_c[:, :, i])
        end

        MPS.matmul!(buf_c, buf_a, buf_b, alpha, beta)

        @test all(Array(buf_c) .≈ truth_c)
    end
end

@testset "mixed-precision matrix vector multiplication" begin
    N = 10
    rows = N
    cols = N

    alpha = Float64(1)
    beta  = Float64(0)

    @testset "$(input_jl_type) => $accum_jl_type" for (input_jl_type, accum_jl_type) in MPS.MPS_VALID_MATVECMUL_TYPES
        arr_a = rand(input_jl_type, (rows,cols))
        arr_b = rand(input_jl_type, (rows))
        arr_c = zeros(accum_jl_type, (rows))

        buf_a = MtlArray{input_jl_type}(arr_a)
        buf_b = MtlArray{input_jl_type}(arr_b)
        buf_c = MtlArray{accum_jl_type}(undef, (rows))

        truth_c = (alpha .* accum_jl_type.(arr_a)) *  accum_jl_type.(arr_b) .+ (beta .* arr_c)

        MPS.matvecmul!(buf_c, buf_a, buf_b, alpha, beta)

        @test all(Array(buf_c) .≈ truth_c)
    end
end

@testset "topk & topk!" begin
    # Modified from https://github.com/FluxML/NNlib.jl/pull/353
    function cpu_topk(x::Matrix{T}, k; rev=true, dims=1) where {T}
        if dims === nothing
            y = vec(x)
            perm = partialsortperm(y, 1:k; rev)
            return CartesianIndices(x)[perm], y[perm]
        else
            @assert dims isa Int
            sz1 = size(x)[1:dims-1]
            sz2 = size(x)[dims+1:end]
            slice1 = CartesianIndices(sz1)
            slice2 = CartesianIndices(sz2)
            perm = similar(x, Int, (sz1..., k, sz2...))
            y = similar(x, (sz1..., k, sz2...))
            for I1 in slice1
                for I2 in slice2
                    xI = x[I1,:,I2]
                    permI = partialsortperm(x[I1,:,I2], 1:k; rev)
                    perm[I1,:,I2] .= permI
                    y[I1,:,I2] .= xI[permI]
                end
            end
            return perm, y
        end
    end
    @testset "$ftype" for ftype in (Float16, Float32)
        # Normal operation
        for (shp,k) in [((3,1), 2), ((20,30), 5)]
            cpu_a = rand(ftype, shp...)

            #topk
            cpu_i, cpu_v = cpu_topk(cpu_a, k)

            a = MtlMatrix(cpu_a)
            i, v = MPS.topk(a, k)

            @test Array(i) == cpu_i
            @test Array(v) == cpu_v

            #topk!
            i = MtlMatrix{UInt32}(undef, (k, shp[2]))
            v = MtlMatrix{ftype}(undef, (k, shp[2]))

            i, v = MPS.topk!(a, i, v, k)

            @test Array(i) == cpu_i
            @test Array(v) == cpu_v
        end
        shp = (20,30)
        k = 17

        cpu_a = rand(ftype, shp...)
        cpu_i, cpu_v = cpu_topk(cpu_a, k)

        a = MtlMatrix(cpu_a)
        @test_throws "MPSMatrixFindTopK does not support values of k > 16" i, v = MPS.topk(a, k)

        #topk!
        i = MtlMatrix{UInt32}(undef, (k, shp[2]))
        v = MtlMatrix{ftype}(undef, (k, shp[2]))

        @test_throws "MPSMatrixFindTopK does not support values of k > 16" i, v = MPS.topk!(a, i, v, k)
    end
end

using .MPS: MPSMatrixSoftMax, MPSMatrixLogSoftMax
@testset "MPSMatrixSoftMax" begin
    cols = rand(Int)
    rows = rand(Int)

    skern = MPSMatrixSoftMax(device())
    skern.sourceColumns = cols
    skern.sourceRows = rows

    @test skern isa MPSMatrixSoftMax
    @test skern.sourceColumns == cols
    @test skern.sourceRows == rows

    lkern = MPSMatrixLogSoftMax(device())
    lkern.sourceColumns = cols
    lkern.sourceRows = rows

    @test lkern isa MPSMatrixLogSoftMax
    @test lkern.sourceColumns == cols
    @test lkern.sourceRows == rows
end

end
