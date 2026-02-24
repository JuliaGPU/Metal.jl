if MPS.is_supported(device())

    function conv2d_reference(x, w; stride = (1, 1), dilation = (1, 1), padding = (0, 0, 0, 0), groups = 1)
        W, H, Cin, N = size(x)
        Kw, Kh, CinPerGroup, Cout = size(w)

        sx, sy = stride
        dx, dy = dilation
        pl, pr, pt, pb = padding

        @assert CinPerGroup * groups == Cin
        @assert Cout % groups == 0

        Wout = fld(W + pl + pr - dx * (Kw - 1) - 1, sx) + 1
        Hout = fld(H + pt + pb - dy * (Kh - 1) - 1, sy) + 1

        Tout = promote_type(eltype(x), eltype(w))
        y = zeros(Tout, Wout, Hout, Cout, N)

        CoutPerGroup = div(Cout, groups)
        for n in 1:N, co in 1:Cout, oh in 1:Hout, ow in 1:Wout
            g = div(co - 1, CoutPerGroup) + 1
            acc = zero(Tout)

            for ci_local in 1:CinPerGroup, kh in 1:Kh, kw in 1:Kw
                ci = (g - 1) * CinPerGroup + ci_local
                iw = (ow - 1) * sx - pl + (kw - 1) * dx + 1
                ih = (oh - 1) * sy - pt + (kh - 1) * dy + 1
                if 1 <= iw <= W && 1 <= ih <= H
                    acc += x[iw, ih, ci, n] * w[kw, kh, ci_local, co]
                end
            end

            y[ow, oh, co, n] = acc
        end

        return y
    end

    @testset "mpsgraph convolution 2D" begin
        x = rand(Float32, 9, 8, 4, 2)
        w = rand(Float32, 3, 2, 4, 6)
        stride = (2, 1)
        dilation = (1, 2)
        padding = (1, 0, 2, 1)

        y_ref = conv2d_reference(x, w; stride, dilation, padding, groups = 1)
        y = Metal.zeros(Float32, size(y_ref))

        MPSGraphs.graph_conv!(y, MtlArray(x), MtlArray(w); stride, dilation, padding, groups = 1)
        @test Array(y) ≈ y_ref rtol = 1.0f-5 atol = 1.0f-5
    end

    @testset "mpsgraph grouped convolution 2D" begin
        x = rand(Float32, 10, 7, 4, 2)
        w = rand(Float32, 3, 3, 2, 6)
        stride = (1, 2)
        dilation = (1, 1)
        padding = (1, 1, 1, 1)
        groups = 2

        y_ref = conv2d_reference(x, w; stride, dilation, padding, groups)
        y = Metal.zeros(Float32, size(y_ref))

        MPSGraphs.graph_conv!(y, MtlArray(x), MtlArray(w); stride, dilation, padding, groups)
        @test Array(y) ≈ y_ref rtol = 1.0f-5 atol = 1.0f-5
    end

end # MPS.is_supported(device())
