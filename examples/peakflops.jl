using Metal
using BenchmarkTools

function kernel_fma(a, b, c, out)
    i = thread_position_in_grid().x

    is_inbounds = i < length(a)

    if is_inbounds
        a_val = is_inbounds ? a[i] : 0f0
        b_val = is_inbounds ? b[i] : 0f0
        c_val = is_inbounds ? c[i] : 0f0
    end

    for j in 1:99
        a_val = fma(a_val, b_val, c_val)
        b_val = fma(a_val, b_val, c_val)
        c_val = fma(a_val, b_val, c_val)
    end

    if is_inbounds
        out[i] = fma(a_val, b_val, c_val)
    end

    return
end

# Return calculated TFLOPS of Metal device
function peakflops(len=1024*1024*100)
    a = MtlArray(rand(Float32, len))
    b = MtlArray(rand(Float32, len))
    c = MtlArray(rand(Float32, len))
    out = similar(a)

    fma_kernel = @metal launch=false kernel_fma(a, b, c, out)
    threads = fma_kernel.pipeline.maxTotalThreadsPerThreadgroup
    grid = cld(len, threads)

    bench = @benchmark Metal.@sync begin
        $fma_kernel($a, $b, $c, $out; threads=$threads, groups=$grid)
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
