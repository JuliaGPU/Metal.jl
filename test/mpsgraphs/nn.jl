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
        @test Array(y_d) ≈ y_ref

        MPSGraphs.graph_softmax_grad!(dx_d, dy_d, y_d; dims)
        @test Array(dx_d) ≈ ref_softmax_grad(dy, y_ref; dims)

        MPSGraphs.graph_logsoftmax!(y_d, x_d; dims)
        y_ref = ref_logsoftmax(x; dims)
        @test Array(y_d) ≈ y_ref

        MPSGraphs.graph_logsoftmax_grad!(dx_d, dy_d, y_d; dims)
        @test Array(dx_d) ≈ ref_logsoftmax_grad(dy, y_ref; dims)
    end
end

function ref_conv2d(x, w; stride=(1, 1), padding=(0, 0, 0, 0),
                    dilation=(1, 1), flipkernel=false)
    W, H, C, N = size(x)
    KW, KH, _, O = size(w)
    OW = (W + padding[1] + padding[2] - (KW - 1) * dilation[1] - 1) ÷ stride[1] + 1
    OH = (H + padding[3] + padding[4] - (KH - 1) * dilation[2] - 1) ÷ stride[2] + 1
    y = zeros(eltype(x), OW, OH, O, N)
    kproj(k, n) = flipkernel ? k : n - k + 1
    for n in 1:N, o in 1:O, oh in 1:OH, ow in 1:OW
        acc = zero(eltype(x))
        for c in 1:C, kh in 1:KH, kw in 1:KW
            iw = (ow - 1) * stride[1] - padding[1] + 1 + (kw - 1) * dilation[1]
            ih = (oh - 1) * stride[2] - padding[3] + 1 + (kh - 1) * dilation[2]
            if 1 <= iw <= W && 1 <= ih <= H
                acc = muladd(x[iw, ih, c, n], w[kproj(kw, KW), kproj(kh, KH), c, o], acc)
            end
        end
        y[ow, oh, o, n] = acc
    end
    return y
end

function ref_pool2d(op, x; kernel, stride, padding=(0, 0, 0, 0),
                    count_include_pad=true)
    W, H, C, N = size(x)
    KW, KH = kernel
    OW = (W + padding[1] + padding[2] - KW) ÷ stride[1] + 1
    OH = (H + padding[3] + padding[4] - KH) ÷ stride[2] + 1
    y = zeros(eltype(x), OW, OH, C, N)
    for n in 1:N, c in 1:C, oh in 1:OH, ow in 1:OW
        vals = eltype(x)[]
        for kh in 1:KH, kw in 1:KW
            iw = (ow - 1) * stride[1] - padding[1] + kw
            ih = (oh - 1) * stride[2] - padding[3] + kh
            if 1 <= iw <= W && 1 <= ih <= H
                push!(vals, x[iw, ih, c, n])
            elseif op === :mean && count_include_pad
                push!(vals, zero(eltype(x)))
            end
        end
        y[ow, oh, c, n] = op === :max ? maximum(vals) : sum(vals) / length(vals)
    end
    return y
end

@testset "conv2d ($T)" for T in (Float16, Float32)
    x = randn(T, 7, 6, 2, 3)
    w = randn(T, 3, 2, 2, 4)

    @testset "flipkernel=$flipkernel" for flipkernel in (false, true)
        y_ref = ref_conv2d(x, w; stride=(2, 1), padding=(1, 1, 0, 1),
                           dilation=(1, 1), flipkernel)
        y = MtlArray(similar(y_ref))
        MPSGraphs.graph_conv!(y, MtlArray(x), MtlArray(w); stride=(2, 1),
                              padding=(1, 1, 0, 1), dilation=(1, 1), flipkernel)
        @test Array(y) ≈ y_ref
    end
end

@testset "pool2d ($T)" for T in (Float16, Float32)
    x = randn(T, 7, 6, 2, 3)

    y_ref = ref_pool2d(:max, x; kernel=(3, 2), stride=(2, 1))
    y = MtlArray(similar(y_ref))
    MPSGraphs.graph_maxpool!(y, MtlArray(x); kernel=(3, 2), stride=(2, 1),
                             padding=(0, 0, 0, 0))
    @test Array(y) ≈ y_ref

    y_ref = ref_pool2d(:mean, x; kernel=(3, 2), stride=(2, 1),
                       padding=(1, 1, 0, 1), count_include_pad=true)
    y = MtlArray(similar(y_ref))
    MPSGraphs.graph_meanpool!(y, MtlArray(x); kernel=(3, 2), stride=(2, 1),
                              padding=(1, 1, 0, 1), count_include_pad=true)
    @test Array(y) ≈ y_ref
end
