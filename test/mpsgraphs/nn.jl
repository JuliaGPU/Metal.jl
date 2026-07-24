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
                    dilation=(1, 1), groups=1, flipkernel=false)
    W, H, C, N = size(x)
    KW, KH, CG, O = size(w)
    OW = (W + padding[1] + padding[2] - (KW - 1) * dilation[1] - 1) ÷ stride[1] + 1
    OH = (H + padding[3] + padding[4] - (KH - 1) * dilation[2] - 1) ÷ stride[2] + 1
    y = zeros(eltype(x), OW, OH, O, N)
    kproj(k, n) = flipkernel ? k : n - k + 1
    out_per_group = O ÷ groups
    @assert C == CG * groups
    for n in 1:N, o in 1:O, oh in 1:OH, ow in 1:OW
        acc = zero(eltype(x))
        group = (o - 1) ÷ out_per_group
        for cg in 1:CG, kh in 1:KH, kw in 1:KW
            c = group * CG + cg
            iw = (ow - 1) * stride[1] - padding[1] + 1 + (kw - 1) * dilation[1]
            ih = (oh - 1) * stride[2] - padding[3] + 1 + (kh - 1) * dilation[2]
            if 1 <= iw <= W && 1 <= ih <= H
                acc = muladd(x[iw, ih, c, n],
                             w[kproj(kw, KW), kproj(kh, KH), cg, o], acc)
            end
        end
        y[ow, oh, o, n] = acc
    end
    return y
end

function ref_conv2d_data_grad(dy, w, size_x; stride=(1, 1), padding=(0, 0, 0, 0),
                              dilation=(1, 1), groups=1, flipkernel=false)
    W, H, C, N = size_x
    KW, KH, CG, O = size(w)
    OW, OH = size(dy, 1), size(dy, 2)
    dx = zeros(eltype(dy), size_x)
    kproj(k, n) = flipkernel ? k : n - k + 1
    out_per_group = O ÷ groups
    @assert C == CG * groups
    for n in 1:N, o in 1:O, oh in 1:OH, ow in 1:OW
        group = (o - 1) ÷ out_per_group
        for cg in 1:CG, kh in 1:KH, kw in 1:KW
            c = group * CG + cg
            iw = (ow - 1) * stride[1] - padding[1] + 1 + (kw - 1) * dilation[1]
            ih = (oh - 1) * stride[2] - padding[3] + 1 + (kh - 1) * dilation[2]
            if 1 <= iw <= W && 1 <= ih <= H
                dx[iw, ih, c, n] +=
                    dy[ow, oh, o, n] * w[kproj(kw, KW), kproj(kh, KH), cg, o]
            end
        end
    end
    return dx
end

function ref_conv2d_filter_grad(x, dy, size_w; stride=(1, 1), padding=(0, 0, 0, 0),
                                dilation=(1, 1), groups=1, flipkernel=false)
    W, H, C, N = size(x)
    KW, KH, CG, O = size_w
    OW, OH = size(dy, 1), size(dy, 2)
    dw = zeros(eltype(x), size_w)
    kproj(k, n) = flipkernel ? k : n - k + 1
    out_per_group = O ÷ groups
    @assert C == CG * groups
    for n in 1:N, o in 1:O, oh in 1:OH, ow in 1:OW
        group = (o - 1) ÷ out_per_group
        for cg in 1:CG, kh in 1:KH, kw in 1:KW
            c = group * CG + cg
            iw = (ow - 1) * stride[1] - padding[1] + 1 + (kw - 1) * dilation[1]
            ih = (oh - 1) * stride[2] - padding[3] + 1 + (kh - 1) * dilation[2]
            if 1 <= iw <= W && 1 <= ih <= H
                dw[kproj(kw, KW), kproj(kh, KH), cg, o] +=
                    x[iw, ih, c, n] * dy[ow, oh, o, n]
            end
        end
    end
    return dw
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

function ref_pool2d_grad(op, dy, x; kernel, stride, padding=(0, 0, 0, 0),
                         count_include_pad=true)
    W, H, C, N = size(x)
    KW, KH = kernel
    OW, OH = size(dy, 1), size(dy, 2)
    dx = zeros(eltype(x), size(x))
    y = op === :max ? ref_pool2d(op, x; kernel, stride, padding) : nothing
    for n in 1:N, c in 1:C, oh in 1:OH, ow in 1:OW
        count = 0
        for kh in 1:KH, kw in 1:KW
            iw = (ow - 1) * stride[1] - padding[1] + kw
            ih = (oh - 1) * stride[2] - padding[3] + kh
            count += (1 <= iw <= W && 1 <= ih <= H)
        end
        denom = count_include_pad ? KW * KH : count
        for kh in 1:KH, kw in 1:KW
            iw = (ow - 1) * stride[1] - padding[1] + kw
            ih = (oh - 1) * stride[2] - padding[3] + kh
            if 1 <= iw <= W && 1 <= ih <= H
                if op === :max
                    x[iw, ih, c, n] == y[ow, oh, c, n] &&
                        (dx[iw, ih, c, n] += dy[ow, oh, c, n])
                else
                    dx[iw, ih, c, n] += dy[ow, oh, c, n] / denom
                end
            end
        end
    end
    return dx
end

@testset "conv2d ($T)" for T in (Float16, Float32)
    configs = (
        (randn(T, 7, 6, 2, 3), randn(T, 3, 2, 2, 4), 1),
        (randn(T, 7, 6, 4, 3), randn(T, 3, 2, 2, 6), 2),
        (randn(T, 7, 6, 4, 3), randn(T, 3, 2, 1, 8), 4),
    )

    @testset "groups=$groups, flipkernel=$flipkernel" for (x, w, groups) in configs,
                                                            flipkernel in (false, true)
        y_ref = ref_conv2d(x, w; stride=(2, 1), padding=(1, 1, 0, 1),
                           dilation=(1, 1), groups, flipkernel)
        y = MtlArray(similar(y_ref))
        MPSGraphs.graph_conv!(y, MtlArray(x), MtlArray(w); stride=(2, 1),
                              padding=(1, 1, 0, 1), dilation=(1, 1), groups,
                              flipkernel)
        @test Array(y) ≈ y_ref

        dy = randn(T, size(y_ref))
        dx_ref = ref_conv2d_data_grad(dy, w, size(x); stride=(2, 1),
                                      padding=(1, 1, 0, 1), dilation=(1, 1),
                                      groups, flipkernel)
        dx = MtlArray(similar(x))
        MPSGraphs.graph_conv_data_grad!(dx, MtlArray(dy), MtlArray(w);
                                        stride=(2, 1), padding=(1, 1, 0, 1),
                                        dilation=(1, 1), groups, flipkernel)
        dx = Array(dx)
        # MPSGraph's grouped convolution data-gradient kernel drops the first
        # input channel of each group under Metal GPU validation.
        @test dx ≈ dx_ref broken=(runtime_validation && shader_validation && groups == 2 && macos_version() < v"27.0")

        dw_ref = ref_conv2d_filter_grad(x, dy, size(w); stride=(2, 1),
                                        padding=(1, 1, 0, 1), dilation=(1, 1),
                                        groups, flipkernel)
        dw = MtlArray(similar(w))
        MPSGraphs.graph_conv_filter_grad!(dw, MtlArray(x), MtlArray(dy);
                                          stride=(2, 1), padding=(1, 1, 0, 1),
                                          dilation=(1, 1), groups, flipkernel)
        @test Array(dw) ≈ dw_ref
    end
end

@testset "pool2d ($T)" for T in (Float16, Float32)
    x = reshape(T.(1:(7 * 6 * 2 * 3)) ./ T(100), 7, 6, 2, 3)

    y_ref = ref_pool2d(:max, x; kernel=(3, 2), stride=(2, 1))
    y = MtlArray(similar(y_ref))
    MPSGraphs.graph_maxpool!(y, MtlArray(x); kernel=(3, 2), stride=(2, 1),
                             padding=(0, 0, 0, 0))
    @test Array(y) ≈ y_ref

    dy = randn(T, size(y_ref))
    dx_ref = ref_pool2d_grad(:max, dy, x; kernel=(3, 2), stride=(2, 1))
    dx = MtlArray(similar(x))
    MPSGraphs.graph_maxpool_grad!(dx, MtlArray(dy), MtlArray(x); kernel=(3, 2),
                                  stride=(2, 1), padding=(0, 0, 0, 0))
    @test Array(dx) ≈ dx_ref

    y_ref = ref_pool2d(:mean, x; kernel=(3, 2), stride=(2, 1),
                       padding=(1, 1, 0, 1), count_include_pad=true)
    y = MtlArray(similar(y_ref))
    MPSGraphs.graph_meanpool!(y, MtlArray(x); kernel=(3, 2), stride=(2, 1),
                              padding=(1, 1, 0, 1), count_include_pad=true)
    @test Array(y) ≈ y_ref

    dy = randn(T, size(y_ref))
    dx_ref = ref_pool2d_grad(:mean, dy, x; kernel=(3, 2), stride=(2, 1),
                             padding=(1, 1, 0, 1), count_include_pad=true)
    dx = MtlArray(similar(x))
    MPSGraphs.graph_meanpool_grad!(dx, MtlArray(dy), MtlArray(x);
                                   kernel=(3, 2), stride=(2, 1),
                                   padding=(1, 1, 0, 1), count_include_pad=true)
    @test Array(dx) ≈ dx_ref

    y_ref = ref_pool2d(:mean, x; kernel=(3, 2), stride=(2, 1),
                       padding=(1, 1, 0, 1), count_include_pad=false)
    dy = randn(T, size(y_ref))
    dx_ref = ref_pool2d_grad(:mean, dy, x; kernel=(3, 2), stride=(2, 1),
                             padding=(1, 1, 0, 1), count_include_pad=false)
    dx = MtlArray(similar(x))
    MPSGraphs.graph_meanpool_grad!(dx, MtlArray(dy), MtlArray(x);
                                   kernel=(3, 2), stride=(2, 1),
                                   padding=(1, 1, 0, 1), count_include_pad=false)
    @test Array(dx) ≈ dx_ref
end
