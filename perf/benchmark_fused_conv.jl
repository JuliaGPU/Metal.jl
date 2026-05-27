using Metal
using Metal.MPSGraphs: conv_fft, conv_fft_fused
using DSP
using Statistics

println("=" ^ 60)
println("LATENCY BENCHMARK: Fused vs Existing vs CPU")
println("=" ^ 60)

# Test configurations
configs = [
    (10_000, 100),
    (100_000, 100),
    (100_000, 500),
    (500_000, 500),
    (1_000_000, 500),
    (1_000_000, 1000),
]

results = []

for (signal_size, kernel_size) in configs
    println("\n--- Signal: $(signal_size), Kernel: $(kernel_size) ---")

    # Create test data
    signal_cpu = rand(Float32, signal_size)
    kernel_cpu = rand(Float32, kernel_size)
    signal_gpu = MtlVector(signal_cpu)
    kernel_gpu = MtlVector(kernel_cpu)

    # Warmup
    _ = conv_fft(signal_gpu, kernel_gpu)
    _ = conv_fft_fused(signal_gpu, kernel_gpu)
    Metal.synchronize()

    # Benchmark existing implementation
    n_iters = 10
    times_existing = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft(signal_gpu, kernel_gpu)
            Metal.synchronize()
        end
        push!(times_existing, t * 1000)  # ms
    end

    # Benchmark fused implementation
    times_fused = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft_fused(signal_gpu, kernel_gpu)
            Metal.synchronize()
        end
        push!(times_fused, t * 1000)  # ms
    end

    # Benchmark CPU (fewer iterations for large sizes)
    cpu_iters = signal_size > 500_000 ? 3 : 5
    times_cpu = Float64[]
    for _ in 1:cpu_iters
        t = @elapsed begin
            _ = DSP.conv(signal_cpu, kernel_cpu)
        end
        push!(times_cpu, t * 1000)  # ms
    end

    med_existing = median(times_existing)
    med_fused = median(times_fused)
    med_cpu = median(times_cpu)

    speedup_fused_vs_existing = med_existing / med_fused
    speedup_fused_vs_cpu = med_cpu / med_fused
    speedup_existing_vs_cpu = med_cpu / med_existing

    println("  Existing GPU:  $(round(med_existing, digits=3)) ms")
    println("  Fused GPU:     $(round(med_fused, digits=3)) ms")
    println("  CPU (DSP):     $(round(med_cpu, digits=3)) ms")
    println("  Fused vs Existing: $(round(speedup_fused_vs_existing, digits=2))x")
    println("  Fused vs CPU:      $(round(speedup_fused_vs_cpu, digits=2))x")
    println("  Existing vs CPU:   $(round(speedup_existing_vs_cpu, digits=2))x")

    push!(results, (signal_size, kernel_size, med_existing, med_fused, med_cpu))
end

println("\n" * "=" ^ 60)
println("SUMMARY TABLE")
println("=" ^ 60)
println("Signal    | Kernel | Existing | Fused   | CPU     | Fused/Exist | Fused/CPU")
println("-" ^ 80)
for (ss, ks, exist, fused, cpu) in results
    speedup1 = round(exist / fused, digits=2)
    speedup2 = round(cpu / fused, digits=2)
    println("$(lpad(ss, 9)) | $(lpad(ks, 6)) | $(lpad(round(exist, digits=2), 8)) | $(lpad(round(fused, digits=2), 7)) | $(lpad(round(cpu, digits=2), 7)) | $(lpad(speedup1, 11))x | $(lpad(speedup2, 9))x")
end
