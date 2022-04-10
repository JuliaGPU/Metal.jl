using Metal
using BenchmarkTools

function kernel_fma(a, b, c, out)
    i = thread_position_in_grid_1d()
    a_val = a[i]
    b_val = b[i]
    c_val = c[i]

    for j in 1:99
        a_val = fma(a_val, b_val, c_val)
        b_val = fma(a_val, b_val, c_val)
        c_val = fma(a_val, b_val, c_val)
    end
    out[i] = fma(a_val, b_val, c_val)

    return
end
"Return calculated TFLOPS of Metal device"
function peakflops(_size=1024*1024*100)
    @info "Device: $(device().name)"
    a = round.(rand(Float32, _size) * 100)
    d_a = MtlArray(a)
    a = round.(rand(Float32, _size) * 100)
    d_b = MtlArray(a)
    a = round.(rand(Float32, _size) * 100)
    d_c = MtlArray(a)
    out = similar(a)
    d_out = MtlArray(out)

    _grid = cld(_size, 1024)

    # Warmup
    Metal.@sync @metal threads=1024 grid=_grid kernel_fma(d_a, d_b, d_c, d_out)

    bench = @benchmark Metal.@sync @metal threads=1024 grid=$_grid kernel_fma($d_a, $d_b, $d_c, $d_out)

    # Cleanup memory
    finalize(d_a)
    finalize(d_b)
    finalize(d_c)
    finalize(d_out)

    flopcount = (99*3+1) * 2 * _size
    secs = minimum(bench.times) * 1e-9
    flops = flopcount / secs

    @info "TFlops: $(round(flops/1e12; digits=2))"
    return
end

peakflops()