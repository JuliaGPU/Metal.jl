using Metal
using Metal.MPSGraphs: conv_fft, conv_fft_fused
using DSP
using Statistics

println("=" ^ 70)
println("THROUGHPUT BENCHMARK: Async Pipeline Performance")
println("=" ^ 70)

# Test configuration: moderate size where GPU wins
signal_size = 1_000_000
kernel_size = 500

println("\nTest config: Signal=$(signal_size), Kernel=$(kernel_size)")
println("-" ^ 70)

# Create test data
signal_cpu = rand(Float32, signal_size)
kernel_cpu = rand(Float32, kernel_size)
signal_gpu = MtlVector(signal_cpu)
kernel_gpu = MtlVector(kernel_cpu)

# Warmup
for _ in 1:3
    _ = conv_fft_fused(signal_gpu, kernel_gpu)
end
Metal.synchronize()

# Test different batch sizes for throughput
batch_sizes = [1, 5, 10, 20, 50]

println("\n--- FUSED GPU: Sync vs Async Pipeline ---")
println("Batch | Sync (ms/op) | Async (ms/op) | Speedup")
println("-" ^ 50)

for batch in batch_sizes
    # Sync mode: wait after each operation
    Metal.synchronize()
    t_sync = @elapsed begin
        for _ in 1:batch
            _ = conv_fft_fused(signal_gpu, kernel_gpu)
            Metal.synchronize()
        end
    end
    ms_sync = (t_sync / batch) * 1000

    # Async mode: queue all, sync once
    Metal.synchronize()
    t_async = @elapsed begin
        for _ in 1:batch
            _ = conv_fft_fused(signal_gpu, kernel_gpu)
        end
        Metal.synchronize()
    end
    ms_async = (t_async / batch) * 1000

    speedup = ms_sync / ms_async
    println("$(lpad(batch, 5)) | $(lpad(round(ms_sync, digits=3), 12)) | $(lpad(round(ms_async, digits=3), 13)) | $(round(speedup, digits=2))x")
end

println("\n--- EXISTING GPU: Sync vs Async Pipeline ---")
println("Batch | Sync (ms/op) | Async (ms/op) | Speedup")
println("-" ^ 50)

for batch in batch_sizes
    # Sync mode
    Metal.synchronize()
    t_sync = @elapsed begin
        for _ in 1:batch
            _ = conv_fft(signal_gpu, kernel_gpu)
            Metal.synchronize()
        end
    end
    ms_sync = (t_sync / batch) * 1000

    # Async mode
    Metal.synchronize()
    t_async = @elapsed begin
        for _ in 1:batch
            _ = conv_fft(signal_gpu, kernel_gpu)
        end
        Metal.synchronize()
    end
    ms_async = (t_async / batch) * 1000

    speedup = ms_sync / ms_async
    println("$(lpad(batch, 5)) | $(lpad(round(ms_sync, digits=3), 12)) | $(lpad(round(ms_async, digits=3), 13)) | $(round(speedup, digits=2))x")
end

# Compare throughput: fused async vs existing async vs CPU
println("\n" * "=" ^ 70)
println("MAXIMUM THROUGHPUT COMPARISON (batch=50, async)")
println("=" ^ 70)

batch = 50

# Fused async
Metal.synchronize()
t_fused = @elapsed begin
    for _ in 1:batch
        _ = conv_fft_fused(signal_gpu, kernel_gpu)
    end
    Metal.synchronize()
end
tput_fused = batch / t_fused

# Existing async
Metal.synchronize()
t_existing = @elapsed begin
    for _ in 1:batch
        _ = conv_fft(signal_gpu, kernel_gpu)
    end
    Metal.synchronize()
end
tput_existing = batch / t_existing

# CPU
t_cpu = @elapsed begin
    for _ in 1:batch
        _ = DSP.conv(signal_cpu, kernel_cpu)
    end
end
tput_cpu = batch / t_cpu

println("\nFused GPU:    $(round(tput_fused, digits=1)) ops/sec ($(round(1000/tput_fused, digits=2)) ms/op)")
println("Existing GPU: $(round(tput_existing, digits=1)) ops/sec ($(round(1000/tput_existing, digits=2)) ms/op)")
println("CPU (DSP):    $(round(tput_cpu, digits=1)) ops/sec ($(round(1000/tput_cpu, digits=2)) ms/op)")
println("\nFused vs CPU:    $(round(tput_fused / tput_cpu, digits=2))x throughput")
println("Fused vs Existing: $(round(tput_fused / tput_existing, digits=2))x throughput")
