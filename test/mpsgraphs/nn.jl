function ref_softmax(x; dims)
    shifted = x .- maximum(x; dims)
    y = exp.(shifted)
    return y ./ sum(y; dims)
end

function ref_logsoftmax(x; dims)
    shifted = x .- maximum(x; dims)
    return shifted .- log.(sum(exp, shifted; dims))
end

function ref_softmax_grad(dy, y; dims)
    dy_y = dy .* y
    return dy_y .- y .* sum(dy_y; dims)
end

function ref_logsoftmax_grad(dy, y; dims)
    return dy .- sum(dy; dims) .* exp.(y)
end

@testset "softmax ($T)" for T in (Float16, Float32)
    rtol = T === Float16 ? 1f-2 : 1f-5

    @testset "dims=$dims" for dims in 1:3
        x = randn(T, 5, 4, 3)
        dy = randn(T, size(x))
        dx = similar(x)
        y = similar(x)

        dx_d = MtlArray(dx)
        dy_d = MtlArray(dy)
        x_d = MtlArray(x)
        y_d = MtlArray(y)

        MPSGraphs.graph_softmax!(y_d, x_d; dims)
        y_ref = ref_softmax(x; dims)
        @test Array(y_d) ≈ y_ref rtol=rtol

        MPSGraphs.graph_softmax_grad!(dx_d, dy_d, y_d; dims)
        @test Array(dx_d) ≈ ref_softmax_grad(dy, y_ref; dims) rtol=rtol

        MPSGraphs.graph_logsoftmax!(y_d, x_d; dims)
        y_ref = ref_logsoftmax(x; dims)
        @test Array(y_d) ≈ y_ref rtol=rtol

        MPSGraphs.graph_logsoftmax_grad!(dx_d, dy_d, y_d; dims)
        @test Array(dx_d) ≈ ref_logsoftmax_grad(dy, y_ref; dims) rtol=rtol
    end
end
