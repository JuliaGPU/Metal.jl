using Metal
using Metal.MPSGraphs: conv_fft_inline_pad, conv_fft_fused
using DSP
using Statistics

println("=" ^ 70)
println("INLINE PADDING BENCHMARK: Fused vs Inline-Pad vs CPU")
println("=" ^ 70)

configs_1d = [
    (10_000, 100),
    (50_000, 100),
    (100_000, 100),
    (100_000, 500),
    (500_000, 500),
    (1_000_000, 500),
]

println("\n1D CONVOLUTION")
println("-" ^ 70)
println("Signal     | Kernel | Fused(ms) | Inline(ms) | Speedup | CPU(ms)")
println("-" ^ 70)

for (signal_size, kernel_size) in configs_1d
    signal_cpu = rand(Float32, signal_size)
    kernel_cpu = rand(Float32, kernel_size)
    signal_gpu = MtlVector(signal_cpu)
    kernel_gpu = MtlVector(kernel_cpu)

    # Warmup
    _ = conv_fft_fused(signal_gpu, kernel_gpu)
    _ = conv_fft_inline_pad(signal_gpu, kernel_gpu)
    Metal.synchronize()

    n_iters = 10

    # Benchmark fused
    times_fused = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft_fused(signal_gpu, kernel_gpu)
            Metal.synchronize()
        end
        Base.push!(times_fused, t * 1000)
    end

    # Benchmark inline pad
    times_inline = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft_inline_pad(signal_gpu, kernel_gpu)
            Metal.synchronize()
        end
        Base.push!(times_inline, t * 1000)
    end

    # Benchmark CPU
    cpu_iters = signal_size > 500_000 ? 3 : 5
    times_cpu = Float64[]
    for _ in 1:cpu_iters
        t = @elapsed begin
            _ = DSP.conv(signal_cpu, kernel_cpu)
        end
        Base.push!(times_cpu, t * 1000)
    end

    med_fused = median(times_fused)
    med_inline = median(times_inline)
    med_cpu = median(times_cpu)
    speedup = med_fused / med_inline

    println("$(lpad(signal_size, 10)) | $(lpad(kernel_size, 6)) | $(lpad(round(med_fused, digits=2), 9)) | $(lpad(round(med_inline, digits=2), 10)) | $(lpad(round(speedup, digits=2), 7))x | $(lpad(round(med_cpu, digits=2), 6))")
end

println("\n2D CONVOLUTION")
println("-" ^ 70)
println("Image      | Kernel | Fused(ms) | Inline(ms) | Speedup | CPU(ms)")
println("-" ^ 70)

configs_2d = [
    ((128, 128), (5, 5)),
    ((256, 256), (5, 5)),
    ((256, 256), (15, 15)),
    ((512, 512), (15, 15)),
    ((1024, 1024), (15, 15)),
]

for (image_size, kernel_size) in configs_2d
    image_cpu = rand(Float32, image_size...)
    kernel_cpu = rand(Float32, kernel_size...)
    image_gpu = MtlMatrix(image_cpu)
    kernel_gpu = MtlMatrix(kernel_cpu)

    # Warmup
    _ = conv_fft_fused(image_gpu, kernel_gpu)
    _ = conv_fft_inline_pad(image_gpu, kernel_gpu)
    Metal.synchronize()

    n_iters = 10

    times_fused = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft_fused(image_gpu, kernel_gpu)
            Metal.synchronize()
        end
        Base.push!(times_fused, t * 1000)
    end

    times_inline = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft_inline_pad(image_gpu, kernel_gpu)
            Metal.synchronize()
        end
        Base.push!(times_inline, t * 1000)
    end

    cpu_iters = prod(image_size) > 500_000 ? 3 : 5
    times_cpu = Float64[]
    for _ in 1:cpu_iters
        t = @elapsed DSP.conv(image_cpu, kernel_cpu)
        Base.push!(times_cpu, t * 1000)
    end

    med_fused = median(times_fused)
    med_inline = median(times_inline)
    med_cpu = median(times_cpu)
    speedup = med_fused / med_inline

    image_str = "$(image_size[1])x$(image_size[2])"
    kernel_str = "$(kernel_size[1])x$(kernel_size[2])"
    println("$(lpad(image_str, 10)) | $(lpad(kernel_str, 6)) | $(lpad(round(med_fused, digits=2), 9)) | $(lpad(round(med_inline, digits=2), 10)) | $(lpad(round(speedup, digits=2), 7))x | $(lpad(round(med_cpu, digits=2), 6))")
end

println("\n3D CONVOLUTION")
println("-" ^ 70)
println("Volume     | Kernel | Fused(ms) | Inline(ms) | Speedup | CPU(ms)")
println("-" ^ 70)

configs_3d = [
    ((32, 32, 32), (3, 3, 3)),
    ((64, 64, 64), (3, 3, 3)),
    ((64, 64, 64), (5, 5, 5)),
    ((128, 128, 128), (5, 5, 5)),
]

for (vol_size, kernel_size) in configs_3d
    vol_cpu = rand(Float32, vol_size...)
    kernel_cpu = rand(Float32, kernel_size...)
    vol_gpu = MtlArray(vol_cpu)
    kernel_gpu = MtlArray(kernel_cpu)

    # Warmup
    _ = conv_fft_fused(vol_gpu, kernel_gpu)
    _ = conv_fft_inline_pad(vol_gpu, kernel_gpu)
    Metal.synchronize()

    n_iters = 8

    times_fused = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft_fused(vol_gpu, kernel_gpu)
            Metal.synchronize()
        end
        Base.push!(times_fused, t * 1000)
    end

    times_inline = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft_inline_pad(vol_gpu, kernel_gpu)
            Metal.synchronize()
        end
        Base.push!(times_inline, t * 1000)
    end

    cpu_iters = prod(vol_size) > 500_000 ? 2 : 3
    times_cpu = Float64[]
    for _ in 1:cpu_iters
        t = @elapsed DSP.conv(vol_cpu, kernel_cpu)
        Base.push!(times_cpu, t * 1000)
    end

    med_fused = median(times_fused)
    med_inline = median(times_inline)
    med_cpu = median(times_cpu)
    speedup = med_fused / med_inline

    vol_str = "$(vol_size[1])x$(vol_size[2])x$(vol_size[3])"
    kernel_str = "$(kernel_size[1])x$(kernel_size[2])x$(kernel_size[3])"
    println("$(lpad(vol_str, 10)) | $(lpad(kernel_str, 6)) | $(lpad(round(med_fused, digits=2), 9)) | $(lpad(round(med_inline, digits=2), 10)) | $(lpad(round(speedup, digits=2), 7))x | $(lpad(round(med_cpu, digits=2), 6))")
end
