using Metal
using BenchmarkTools

function transfer_kernel(in, out)
    idx = thread_position_in_grid_1d()
    @inbounds if idx <= length(out)
        out[idx] = in[idx]
    end
    return
end

function peaktransfer()
    _size=1024*1024*256
    a = round.(rand(Float32, _size) * 100)
    d_a = MtlArray(a)
    d_b = MtlArray{Float32}(undef, _size)

    kernel = @metal launch=false transfer_kernel(d_a, d_b)
    config = launch_configuration(kernel.fun; max_threads=_size)
    threads = config.threads
    grid = cld(_size, threads)

    # Warmup
    Metal.@sync kernel(d_a, d_b)

    bench = @benchmark Metal.@sync kernel($d_a, $d_b; threads=$threads, grid=$grid)

    bytes_transfered = sizeof(Float32) * _size
    secs = minimum(bench.times) * 1e-9

    return bytes_transfered/secs
end

isinteractive() || println("One way peak transfer speed: $(Base.format_bytes(peaktransfer()))/s")