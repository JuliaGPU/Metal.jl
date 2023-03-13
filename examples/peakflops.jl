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
function peakflops(len=1024*1024*100)
    a = MtlArray(rand(Float32, len))
    b = MtlArray(rand(Float32, len))
    c = MtlArray(rand(Float32, len))
    out = similar(a)

    threads = 1024
    grid = cld(len, threads)

    bench = @benchmark Metal.@sync begin
        @metal threads=$threads groups=$grid kernel_fma($a, $b, $c, $out)
    end

    # Cleanup memory
    finalize(a)
    finalize(b)
    finalize(c)
    finalize(out)

    flopcount = (99*3+1) * 2 * len
    secs = minimum(bench.times) * 1e-9
    flops = flopcount / secs

    println("TFlops: $(round(flops/1e12; digits=2))")
    return
end

peakflops()
