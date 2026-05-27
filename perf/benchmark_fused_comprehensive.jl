using Metal
using Metal.MPSGraphs: conv_fft, conv_fft_fused
using DSP
using Statistics

println("=" ^ 70)
println("COMPREHENSIVE FUSED CONVOLUTION BENCHMARKS")
println("=" ^ 70)
println("Note: conv_fft() now uses fused implementation automatically")
println()

# ============================================================================
# 1D BENCHMARKS
# ============================================================================

println("=" ^ 70)
println("1D CONVOLUTION: GPU (Fused) vs CPU (DSP.jl)")
println("=" ^ 70)

configs_1d = [
    (10_000, 100),
    (50_000, 100),
    (100_000, 100),
    (100_000, 500),
    (500_000, 500),
    (1_000_000, 500),
    (1_000_000, 1000),
    (5_000_000, 1000),
]

results_1d = []

for (signal_size, kernel_size) in configs_1d
    # Create test data
    signal_cpu = rand(Float32, signal_size)
    kernel_cpu = rand(Float32, kernel_size)
    signal_gpu = MtlVector(signal_cpu)
    kernel_gpu = MtlVector(kernel_cpu)

    # Warmup
    _ = conv_fft(signal_gpu, kernel_gpu)
    Metal.synchronize()

    # Benchmark GPU
    n_iters = 10
    times_gpu = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft(signal_gpu, kernel_gpu)
            Metal.synchronize()
        end
        push!(times_gpu, t * 1000)
    end

    # Benchmark CPU
    cpu_iters = signal_size > 1_000_000 ? 3 : 5
    times_cpu = Float64[]
    for _ in 1:cpu_iters
        t = @elapsed begin
            _ = DSP.conv(signal_cpu, kernel_cpu)
        end
        push!(times_cpu, t * 1000)
    end

    med_gpu = median(times_gpu)
    med_cpu = median(times_cpu)
    speedup = med_cpu / med_gpu
    winner = speedup >= 1.0 ? "GPU" : "CPU"

    push!(results_1d, (signal_size, kernel_size, med_gpu, med_cpu, speedup, winner))
    println("Signal=$(signal_size), Kernel=$(kernel_size): GPU=$(round(med_gpu, digits=2))ms, CPU=$(round(med_cpu, digits=2))ms, Speedup=$(round(speedup, digits=2))x [$winner]")
end

# ============================================================================
# 2D BENCHMARKS
# ============================================================================

println("\n" * "=" ^ 70)
println("2D CONVOLUTION: GPU (Fused) vs CPU (imfilter-style)")
println("=" ^ 70)

configs_2d = [
    ((128, 128), (5, 5)),
    ((256, 256), (5, 5)),
    ((256, 256), (15, 15)),
    ((512, 512), (5, 5)),
    ((512, 512), (15, 15)),
    ((1024, 1024), (5, 5)),
    ((1024, 1024), (15, 15)),
    ((2048, 2048), (15, 15)),
]

results_2d = []

for (image_size, kernel_size) in configs_2d
    # Create test data
    image_cpu = rand(Float32, image_size...)
    kernel_cpu = rand(Float32, kernel_size...)
    image_gpu = MtlMatrix(image_cpu)
    kernel_gpu = MtlMatrix(kernel_cpu)

    # Warmup
    _ = conv_fft(image_gpu, kernel_gpu; dims=(1,2))
    Metal.synchronize()

    # Benchmark GPU
    n_iters = 10
    times_gpu = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft(image_gpu, kernel_gpu; dims=(1,2))
            Metal.synchronize()
        end
        push!(times_gpu, t * 1000)
    end

    # Benchmark CPU (using DSP.conv for 2D as reference)
    cpu_iters = prod(image_size) > 1_000_000 ? 3 : 5
    times_cpu = Float64[]
    for _ in 1:cpu_iters
        t = @elapsed begin
            _ = DSP.conv(image_cpu, kernel_cpu)
        end
        push!(times_cpu, t * 1000)
    end

    med_gpu = median(times_gpu)
    med_cpu = median(times_cpu)
    speedup = med_cpu / med_gpu
    winner = speedup >= 1.0 ? "GPU" : "CPU"

    push!(results_2d, (image_size, kernel_size, med_gpu, med_cpu, speedup, winner))
    println("Image=$(image_size), Kernel=$(kernel_size): GPU=$(round(med_gpu, digits=2))ms, CPU=$(round(med_cpu, digits=2))ms, Speedup=$(round(speedup, digits=2))x [$winner]")
end

# ============================================================================
# 3D BENCHMARKS
# ============================================================================

println("\n" * "=" ^ 70)
println("3D CONVOLUTION: GPU (Fused) vs CPU (DSP.conv)")
println("=" ^ 70)

configs_3d = [
    ((32, 32, 32), (3, 3, 3)),
    ((64, 64, 64), (3, 3, 3)),
    ((64, 64, 64), (5, 5, 5)),
    ((128, 128, 128), (3, 3, 3)),
    ((128, 128, 128), (5, 5, 5)),
    ((256, 256, 64), (5, 5, 5)),
    ((256, 256, 128), (5, 5, 5)),
]

results_3d = []

for (volume_size, kernel_size) in configs_3d
    # Create test data
    volume_cpu = rand(Float32, volume_size...)
    kernel_cpu = rand(Float32, kernel_size...)
    volume_gpu = MtlArray(volume_cpu)
    kernel_gpu = MtlArray(kernel_cpu)

    # Warmup
    _ = conv_fft(volume_gpu, kernel_gpu; dims=(1,2,3))
    Metal.synchronize()

    # Benchmark GPU
    n_iters = 8
    times_gpu = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft(volume_gpu, kernel_gpu; dims=(1,2,3))
            Metal.synchronize()
        end
        push!(times_gpu, t * 1000)
    end

    # Benchmark CPU
    cpu_iters = prod(volume_size) > 500_000 ? 2 : 3
    times_cpu = Float64[]
    for _ in 1:cpu_iters
        t = @elapsed begin
            _ = DSP.conv(volume_cpu, kernel_cpu)
        end
        push!(times_cpu, t * 1000)
    end

    med_gpu = median(times_gpu)
    med_cpu = median(times_cpu)
    speedup = med_cpu / med_gpu
    winner = speedup >= 1.0 ? "GPU" : "CPU"

    push!(results_3d, (volume_size, kernel_size, med_gpu, med_cpu, speedup, winner))
    println("Volume=$(volume_size), Kernel=$(kernel_size): GPU=$(round(med_gpu, digits=2))ms, CPU=$(round(med_cpu, digits=2))ms, Speedup=$(round(speedup, digits=2))x [$winner]")
end

# ============================================================================
# THROUGHPUT BENCHMARK
# ============================================================================

println("\n" * "=" ^ 70)
println("THROUGHPUT BENCHMARK (Async Pipeline, batch=50)")
println("=" ^ 70)

# 1D throughput
signal_1d = MtlVector(rand(Float32, 1_000_000))
kernel_1d = MtlVector(rand(Float32, 500))
signal_1d_cpu = rand(Float32, 1_000_000)
kernel_1d_cpu = rand(Float32, 500)

batch = 50
Metal.synchronize()
t_gpu_1d = @elapsed begin
    for _ in 1:batch
        _ = conv_fft(signal_1d, kernel_1d)
    end
    Metal.synchronize()
end
tput_gpu_1d = batch / t_gpu_1d

t_cpu_1d = @elapsed begin
    for _ in 1:batch
        _ = DSP.conv(signal_1d_cpu, kernel_1d_cpu)
    end
end
tput_cpu_1d = batch / t_cpu_1d

println("\n1D (1M × 500):")
println("  GPU: $(round(tput_gpu_1d, digits=1)) ops/sec ($(round(1000/tput_gpu_1d, digits=2)) ms/op)")
println("  CPU: $(round(tput_cpu_1d, digits=1)) ops/sec ($(round(1000/tput_cpu_1d, digits=2)) ms/op)")
println("  Speedup: $(round(tput_gpu_1d / tput_cpu_1d, digits=2))x")

# 2D throughput
image_2d = MtlMatrix(rand(Float32, 512, 512))
kernel_2d = MtlMatrix(rand(Float32, 15, 15))
image_2d_cpu = rand(Float32, 512, 512)
kernel_2d_cpu = rand(Float32, 15, 15)

Metal.synchronize()
t_gpu_2d = @elapsed begin
    for _ in 1:batch
        _ = conv_fft(image_2d, kernel_2d; dims=(1,2))
    end
    Metal.synchronize()
end
tput_gpu_2d = batch / t_gpu_2d

t_cpu_2d = @elapsed begin
    for _ in 1:batch
        _ = DSP.conv(image_2d_cpu, kernel_2d_cpu)
    end
end
tput_cpu_2d = batch / t_cpu_2d

println("\n2D (512×512 × 15×15):")
println("  GPU: $(round(tput_gpu_2d, digits=1)) ops/sec ($(round(1000/tput_gpu_2d, digits=2)) ms/op)")
println("  CPU: $(round(tput_cpu_2d, digits=1)) ops/sec ($(round(1000/tput_cpu_2d, digits=2)) ms/op)")
println("  Speedup: $(round(tput_gpu_2d / tput_cpu_2d, digits=2))x")

# 3D throughput
volume_3d = MtlArray(rand(Float32, 64, 64, 64))
kernel_3d = MtlArray(rand(Float32, 5, 5, 5))
volume_3d_cpu = rand(Float32, 64, 64, 64)
kernel_3d_cpu = rand(Float32, 5, 5, 5)

batch_3d = 20
Metal.synchronize()
t_gpu_3d = @elapsed begin
    for _ in 1:batch_3d
        _ = conv_fft(volume_3d, kernel_3d; dims=(1,2,3))
    end
    Metal.synchronize()
end
tput_gpu_3d = batch_3d / t_gpu_3d

t_cpu_3d = @elapsed begin
    for _ in 1:batch_3d
        _ = DSP.conv(volume_3d_cpu, kernel_3d_cpu)
    end
end
tput_cpu_3d = batch_3d / t_cpu_3d

println("\n3D (64³ × 5³):")
println("  GPU: $(round(tput_gpu_3d, digits=1)) ops/sec ($(round(1000/tput_gpu_3d, digits=2)) ms/op)")
println("  CPU: $(round(tput_cpu_3d, digits=1)) ops/sec ($(round(1000/tput_cpu_3d, digits=2)) ms/op)")
println("  Speedup: $(round(tput_gpu_3d / tput_cpu_3d, digits=2))x")

# ============================================================================
# SUMMARY TABLES
# ============================================================================

println("\n" * "=" ^ 70)
println("SUMMARY TABLES (for documentation)")
println("=" ^ 70)

println("\n### 1D Convolution Results")
println("| Signal | Kernel | GPU (ms) | CPU (ms) | Speedup | Winner |")
println("|--------|--------|----------|----------|---------|--------|")
for (ss, ks, gpu, cpu, speedup, winner) in results_1d
    speedup_str = speedup >= 1.0 ? "**$(round(speedup, digits=2))x**" : "$(round(speedup, digits=2))x"
    winner_str = winner == "GPU" ? "**GPU**" : "CPU"
    println("| $(ss) | $(ks) | $(round(gpu, digits=2)) | $(round(cpu, digits=2)) | $(speedup_str) | $(winner_str) |")
end

println("\n### 2D Convolution Results")
println("| Image | Kernel | GPU (ms) | CPU (ms) | Speedup | Winner |")
println("|-------|--------|----------|----------|---------|--------|")
for (is, ks, gpu, cpu, speedup, winner) in results_2d
    speedup_str = speedup >= 1.0 ? "**$(round(speedup, digits=2))x**" : "$(round(speedup, digits=2))x"
    winner_str = winner == "GPU" ? "**GPU**" : "CPU"
    println("| $(is[1])×$(is[2]) | $(ks[1])×$(ks[2]) | $(round(gpu, digits=2)) | $(round(cpu, digits=2)) | $(speedup_str) | $(winner_str) |")
end

println("\n### 3D Convolution Results")
println("| Volume | Kernel | GPU (ms) | CPU (ms) | Speedup | Winner |")
println("|--------|--------|----------|----------|---------|--------|")
for (vs, ks, gpu, cpu, speedup, winner) in results_3d
    speedup_str = speedup >= 1.0 ? "**$(round(speedup, digits=2))x**" : "$(round(speedup, digits=2))x"
    winner_str = winner == "GPU" ? "**GPU**" : "CPU"
    println("| $(vs[1])×$(vs[2])×$(vs[3]) | $(ks[1])×$(ks[2])×$(ks[3]) | $(round(gpu, digits=2)) | $(round(cpu, digits=2)) | $(speedup_str) | $(winner_str) |")
end
