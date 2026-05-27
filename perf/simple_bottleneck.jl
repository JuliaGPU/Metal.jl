using Metal
using Metal.MPSGraphs: conv_fft, conv_fft_fused, conv_fft_inline_pad
using DSP
using Statistics
using Printf

println("=" ^ 80)
println("BOTTLENECK PROFILING: Current Implementation Analysis")
println("=" ^ 80)

# ============================================================================
# Test 1: Implementation comparison across sizes
# ============================================================================

function benchmark_latency(f, args...; n_warmup=3, n_iters=20)
    # Warmup
    for _ in 1:n_warmup
        f(args...)
    end
    Metal.synchronize()

    # Benchmark
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            f(args...)
            Metal.synchronize()
        end
        push!(times, t * 1000)  # ms
    end
    return median(times), minimum(times), maximum(times)
end

function benchmark_cpu(signal_cpu, kernel_cpu; n_iters=5)
    times = Float64[]
    for _ in 1:n_iters
        t = @elapsed DSP.conv(signal_cpu, kernel_cpu)
        push!(times, t * 1000)
    end
    return median(times)
end

println("\n" * "=" ^ 80)
println("SECTION 1: LATENCY COMPARISON ACROSS SIZES")
println("=" ^ 80)

configs = [
    (10_000, 100, "Small"),
    (50_000, 250, "Medium-Small"),
    (100_000, 500, "Medium"),
    (500_000, 500, "Medium-Large"),
    (1_000_000, 1000, "Large"),
]

println("\n| Size       | Signal   | Kernel | conv_fft | conv_fused | conv_inline | CPU (ms) | Best GPU |")
println("|------------|----------|--------|----------|------------|-------------|----------|----------|")

for (signal_size, kernel_size, label) in configs
    signal_cpu = rand(Float32, signal_size)
    kernel_cpu = rand(Float32, kernel_size)
    signal = MtlVector(signal_cpu)
    kernel = MtlVector(kernel_cpu)

    # Benchmark each
    t_fft, _, _ = benchmark_latency(conv_fft, signal, kernel)
    t_fused, _, _ = benchmark_latency(conv_fft_fused, signal, kernel)
    t_inline, _, _ = benchmark_latency(conv_fft_inline_pad, signal, kernel)
    t_cpu = benchmark_cpu(signal_cpu, kernel_cpu)

    # Find best GPU
    times = [("conv_fft", t_fft), ("fused", t_fused), ("inline", t_inline)]
    best_name, best_time = sort(times, by=x->x[2])[1]

    @printf("| %-10s | %8d | %6d | %8.3f | %10.3f | %11.3f | %8.2f | %-8s |\n",
            label, signal_size, kernel_size, t_fft, t_fused, t_inline, t_cpu, best_name)
end

# ============================================================================
# Test 2: Deep dive into memory operations
# ============================================================================

println("\n" * "=" ^ 80)
println("SECTION 2: MEMORY OPERATION OVERHEAD ANALYSIS")
println("=" ^ 80)

function analyze_memory_overhead(signal_size, kernel_size; n_iters=30)
    println("\n--- Signal=$signal_size, Kernel=$kernel_size ---")

    signal = MtlVector(rand(Float32, signal_size))
    kernel = MtlVector(rand(Float32, kernel_size))

    # Compute FFT size
    full_size = signal_size + kernel_size - 1
    nfft = Metal.MPSGraphs.nextfastfft(full_size)
    output_size = full_size

    println("FFT size: $nfft, Padding needed: $(nfft - signal_size) (signal), $(nfft - kernel_size) (kernel)")

    # Pre-allocate
    signal_padded = MtlVector{Float32}(undef, nfft)
    kernel_padded = MtlVector{Float32}(undef, nfft)

    # Test 1: copyto! queued (no sync)
    times_copyto_queue = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed copyto!(signal_padded, 1, signal, 1, signal_size)
        push!(times_copyto_queue, t * 1e6)
    end
    med_copyto_queue = median(times_copyto_queue)

    # Test 2: copyto! with sync
    times_copyto_sync = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            copyto!(signal_padded, 1, signal, 1, signal_size)
            Metal.synchronize()
        end
        push!(times_copyto_sync, t * 1e6)
    end
    med_copyto_sync = median(times_copyto_sync)

    # Test 3: broadcast zero-fill queued
    times_zero_queue = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed (@view(signal_padded[(signal_size+1):nfft]) .= 0f0)
        push!(times_zero_queue, t * 1e6)
    end
    med_zero_queue = median(times_zero_queue)

    # Test 4: broadcast zero-fill with sync
    times_zero_sync = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            @view(signal_padded[(signal_size+1):nfft]) .= 0f0
            Metal.synchronize()
        end
        push!(times_zero_sync, t * 1e6)
    end
    med_zero_sync = median(times_zero_sync)

    # Test 5: Combined copy + zero with one sync
    times_combined = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            copyto!(signal_padded, 1, signal, 1, signal_size)
            @view(signal_padded[(signal_size+1):nfft]) .= 0f0
            copyto!(kernel_padded, 1, kernel, 1, kernel_size)
            @view(kernel_padded[(kernel_size+1):nfft]) .= 0f0
            Metal.synchronize()
        end
        push!(times_combined, t * 1e6)
    end
    med_combined = median(times_combined)

    # Test 6: MtlArray allocation
    times_alloc = Float64[]
    for _ in 1:n_iters
        GC.gc(false)
        t = @elapsed MtlVector{Float32}(undef, nfft)
        push!(times_alloc, t * 1e6)
    end
    med_alloc = median(times_alloc)

    # Test 7: Metal.synchronize() alone (baseline)
    times_sync_alone = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed Metal.synchronize()
        push!(times_sync_alone, t * 1e6)
    end
    med_sync_alone = median(times_sync_alone)

    @printf("  copyto! (queue only):      %7.1f μs\n", med_copyto_queue)
    @printf("  copyto! (with sync):       %7.1f μs\n", med_copyto_sync)
    @printf("  Zero-fill (queue only):    %7.1f μs\n", med_zero_queue)
    @printf("  Zero-fill (with sync):     %7.1f μs\n", med_zero_sync)
    @printf("  Both inputs padded (sync): %7.1f μs\n", med_combined)
    @printf("  MtlArray allocation:       %7.1f μs\n", med_alloc)
    @printf("  Metal.synchronize() alone: %7.1f μs\n", med_sync_alone)

    # Calculate actual GPU work time
    gpu_work_time = med_copyto_sync - med_sync_alone
    @printf("  => Actual GPU copy time:   %7.1f μs\n", gpu_work_time)

    return med_combined
end

analyze_memory_overhead(10_000, 100)
analyze_memory_overhead(100_000, 500)
analyze_memory_overhead(1_000_000, 1000)

# ============================================================================
# Test 3: Async pipeline benefits
# ============================================================================

println("\n" * "=" ^ 80)
println("SECTION 3: ASYNC PIPELINE BENEFITS")
println("=" ^ 80)

function test_async_pipeline(signal_size, kernel_size; batch_sizes=[1, 5, 10, 20, 50])
    println("\n--- Signal=$signal_size, Kernel=$kernel_size ---")

    signal = MtlVector(rand(Float32, signal_size))
    kernel = MtlVector(rand(Float32, kernel_size))

    # Warmup
    for _ in 1:3
        _ = conv_fft_fused(signal, kernel)
    end
    Metal.synchronize()

    println("Batch | Sync (ms/op) | Async (ms/op) | Speedup | Throughput")
    println("-" ^ 60)

    for batch in batch_sizes
        # Sync mode
        Metal.synchronize()
        t_sync = @elapsed begin
            for _ in 1:batch
                _ = conv_fft_fused(signal, kernel)
                Metal.synchronize()
            end
        end
        ms_sync = (t_sync / batch) * 1000

        # Async mode
        Metal.synchronize()
        t_async = @elapsed begin
            for _ in 1:batch
                _ = conv_fft_fused(signal, kernel)
            end
            Metal.synchronize()
        end
        ms_async = (t_async / batch) * 1000

        speedup = ms_sync / ms_async
        throughput = batch / t_async

        @printf("%5d | %12.3f | %13.3f | %6.2fx | %7.1f ops/s\n",
                batch, ms_sync, ms_async, speedup, throughput)
    end
end

test_async_pipeline(100_000, 500)
test_async_pipeline(1_000_000, 1000)

# ============================================================================
# Test 4: GPU vs CPU crossover point
# ============================================================================

println("\n" * "=" ^ 80)
println("SECTION 4: GPU vs CPU CROSSOVER ANALYSIS")
println("=" ^ 80)

sizes = [1_000, 2_500, 5_000, 7_500, 10_000, 15_000, 25_000, 50_000, 100_000]
kernel_size = 100

println("\nKernel size fixed at $kernel_size")
println("Signal Size | GPU (ms) | CPU (ms) | GPU/CPU | Winner")
println("-" ^ 60)

for signal_size in sizes
    signal_cpu = rand(Float32, signal_size)
    kernel_cpu = rand(Float32, kernel_size)
    signal = MtlVector(signal_cpu)
    kernel = MtlVector(kernel_cpu)

    t_gpu, _, _ = benchmark_latency(conv_fft_fused, signal, kernel; n_iters=15)
    t_cpu = benchmark_cpu(signal_cpu, kernel_cpu; n_iters=5)

    ratio = t_gpu / t_cpu
    winner = t_gpu < t_cpu ? "GPU" : "CPU"

    @printf("%11d | %8.3f | %8.3f | %7.2fx | %s\n",
            signal_size, t_gpu, t_cpu, ratio, winner)
end

# ============================================================================
# Test 5: 2D and 3D analysis
# ============================================================================

println("\n" * "=" ^ 80)
println("SECTION 5: 2D CONVOLUTION ANALYSIS")
println("=" ^ 80)

configs_2d = [
    ((64, 64), (5, 5)),
    ((128, 128), (5, 5)),
    ((256, 256), (5, 5)),
    ((256, 256), (15, 15)),
    ((512, 512), (15, 15)),
    ((1024, 1024), (15, 15)),
]

println("\n| Image Size | Kernel | conv_fft | conv_fused | conv_inline | CPU (ms) | Speedup |")
println("|------------|--------|----------|------------|-------------|----------|---------|")

for (img_size, kern_size) in configs_2d
    img_cpu = rand(Float32, img_size...)
    kern_cpu = rand(Float32, kern_size...)
    img = MtlMatrix(img_cpu)
    kern = MtlMatrix(kern_cpu)

    t_fft, _, _ = benchmark_latency(x -> conv_fft(x, kern; dims=(1,2)), img; n_iters=15)
    t_fused, _, _ = benchmark_latency(conv_fft_fused, img, kern; n_iters=15)
    t_inline, _, _ = benchmark_latency(conv_fft_inline_pad, img, kern; n_iters=15)

    cpu_iters = prod(img_size) > 500_000 ? 3 : 5
    t_cpu = benchmark_cpu(img_cpu, kern_cpu; n_iters=cpu_iters)

    best_gpu = min(t_fft, t_fused, t_inline)
    speedup = t_cpu / best_gpu

    @printf("| %4dx%-5d | %2dx%-3d | %8.3f | %10.3f | %11.3f | %8.2f | %6.2fx |\n",
            img_size[1], img_size[2], kern_size[1], kern_size[2],
            t_fft, t_fused, t_inline, t_cpu, speedup)
end

println("\n" * "=" ^ 80)
println("SECTION 6: 3D CONVOLUTION ANALYSIS")
println("=" ^ 80)

configs_3d = [
    ((32, 32, 32), (3, 3, 3)),
    ((64, 64, 64), (3, 3, 3)),
    ((64, 64, 64), (5, 5, 5)),
    ((128, 128, 64), (5, 5, 5)),
]

println("\n| Volume Size    | Kernel | conv_fft | conv_fused | conv_inline | CPU (ms) | Speedup |")
println("|----------------|--------|----------|------------|-------------|----------|---------|")

for (vol_size, kern_size) in configs_3d
    vol_cpu = rand(Float32, vol_size...)
    kern_cpu = rand(Float32, kern_size...)
    vol = MtlArray(vol_cpu)
    kern = MtlArray(kern_cpu)

    t_fft, _, _ = benchmark_latency(x -> conv_fft(x, kern; dims=(1,2,3)), vol; n_iters=10)
    t_fused, _, _ = benchmark_latency(conv_fft_fused, vol, kern; n_iters=10)
    t_inline, _, _ = benchmark_latency(conv_fft_inline_pad, vol, kern; n_iters=10)

    cpu_iters = prod(vol_size) > 500_000 ? 2 : 3
    t_cpu = benchmark_cpu(vol_cpu, kern_cpu; n_iters=cpu_iters)

    best_gpu = min(t_fft, t_fused, t_inline)
    speedup = t_cpu / best_gpu

    @printf("| %3dx%3dx%-5d | %dx%dx%-1d | %8.3f | %10.3f | %11.3f | %8.2f | %6.2fx |\n",
            vol_size[1], vol_size[2], vol_size[3], kern_size[1], kern_size[2], kern_size[3],
            t_fft, t_fused, t_inline, t_cpu, speedup)
end

println("\n" * "=" ^ 80)
println("ANALYSIS COMPLETE")
println("=" ^ 80)
