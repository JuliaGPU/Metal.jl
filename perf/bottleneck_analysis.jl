using Metal
using Metal.MPSGraphs: conv_fft, conv_fft_fused, conv_fft_inline_pad
using Metal.MPSGraphs: _get_cached_fused_conv_graph, FusedConvGraphKey, nextfastfft, _conv_output_size
using Metal.MPSGraphs: MPSGraphTensorData, MPSCommandBuffer, NSDictionary, encode!, commit!, wait_completed, default_exec_desc, nil
using Metal.MPSGraphs: _get_cached_buffers
using Statistics
using Printf

println("=" ^ 80)
println("COMPREHENSIVE BOTTLENECK ANALYSIS")
println("=" ^ 80)

# ============================================================================
# SECTION 1: Component-level breakdown for FUSED implementation
# ============================================================================

function analyze_fused_components(signal_size, kernel_size; n_iters=50)
    println("\n" * "-" ^ 80)
    println("FUSED IMPLEMENTATION: Signal=$signal_size, Kernel=$kernel_size")
    println("-" ^ 80)

    # Setup
    signal = MtlVector(rand(Float32, signal_size))
    kernel = MtlVector(rand(Float32, kernel_size))

    # Warmup
    _ = conv_fft_fused(signal, kernel)
    Metal.synchronize()

    # Get sizes
    ns, nk = length(signal), length(kernel)
    full_size = ns + nk - 1
    output_size = _conv_output_size(ns, nk, :full)
    nfft = nextfastfft(full_size)

    println("FFT size: $nfft, Output size: $output_size")

    # Get cached graph and buffers
    key = FusedConvGraphKey((nfft,), (nfft,), (output_size,), Float32)
    cached = _get_cached_fused_conv_graph(key)
    buffers = _get_cached_buffers((nfft,), Float32)

    results = Dict{String, Float64}()

    # 1. Cache lookup (graph)
    times = Float64[]
    for _ in 1:n_iters
        t = @elapsed _get_cached_fused_conv_graph(key)
        push!(times, t * 1e6)
    end
    results["Graph cache lookup"] = median(times)

    # 2. Buffer pool lookup
    times = Float64[]
    for _ in 1:n_iters
        t = @elapsed _get_cached_buffers((nfft,), Float32)
        push!(times, t * 1e6)
    end
    results["Buffer pool lookup"] = median(times)

    # 3. copyto! for signal
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            copyto!(buffers.signal_padded, 1, signal, 1, ns)
            Metal.synchronize()
        end
        push!(times, t * 1e6)
    end
    results["copyto! signal (sync)"] = median(times)

    # 4. copyto! for kernel
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            copyto!(buffers.kernel_padded, 1, kernel, 1, nk)
            Metal.synchronize()
        end
        push!(times, t * 1e6)
    end
    results["copyto! kernel (sync)"] = median(times)

    # 5. Zero-padding signal
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            @view(buffers.signal_padded[(ns+1):nfft]) .= 0f0
            Metal.synchronize()
        end
        push!(times, t * 1e6)
    end
    results["Zero-pad signal (sync)"] = median(times)

    # 6. Zero-padding kernel
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            @view(buffers.kernel_padded[(nk+1):nfft]) .= 0f0
            Metal.synchronize()
        end
        push!(times, t * 1e6)
    end
    results["Zero-pad kernel (sync)"] = median(times)

    # 7. MPSGraphTensorData creation
    times = Float64[]
    for _ in 1:n_iters
        t = @elapsed begin
            td1 = MPSGraphTensorData(buffers.signal_padded)
            td2 = MPSGraphTensorData(buffers.kernel_padded)
            td3 = MPSGraphTensorData(buffers.output)
        end
        push!(times, t * 1e6)
    end
    results["MPSGraphTensorData (3x)"] = median(times)

    # 8. NSDictionary creation
    td1 = MPSGraphTensorData(buffers.signal_padded)
    td2 = MPSGraphTensorData(buffers.kernel_padded)
    td3 = MPSGraphTensorData(buffers.output)
    times = Float64[]
    for _ in 1:n_iters
        t = @elapsed begin
            feeds = NSDictionary(Dict(cached.signal_placeholder => td1, cached.kernel_placeholder => td2))
            results_dict = NSDictionary(Dict(cached.result => td3))
        end
        push!(times, t * 1e6)
    end
    results["NSDictionary creation"] = median(times)

    # 9. MPSCommandBuffer creation
    times = Float64[]
    for _ in 1:n_iters
        t = @elapsed MPSCommandBuffer(Metal.global_queue(Metal.current_device()))
        push!(times, t * 1e6)
    end
    results["MPSCommandBuffer"] = median(times)

    # 10. encode!
    times = Float64[]
    for _ in 1:n_iters
        td1 = MPSGraphTensorData(buffers.signal_padded)
        td2 = MPSGraphTensorData(buffers.kernel_padded)
        td3 = MPSGraphTensorData(buffers.output)
        feeds = NSDictionary(Dict(cached.signal_placeholder => td1, cached.kernel_placeholder => td2))
        results_ns = NSDictionary(Dict(cached.result => td3))
        cmdbuf = MPSCommandBuffer(Metal.global_queue(Metal.current_device()))
        t = @elapsed encode!(cmdbuf, cached.graph, feeds, results_ns, nil, default_exec_desc())
        push!(times, t * 1e6)
    end
    results["encode!"] = median(times)

    # 11. commit!
    times = Float64[]
    for _ in 1:n_iters
        td1 = MPSGraphTensorData(buffers.signal_padded)
        td2 = MPSGraphTensorData(buffers.kernel_padded)
        td3 = MPSGraphTensorData(buffers.output)
        feeds = NSDictionary(Dict(cached.signal_placeholder => td1, cached.kernel_placeholder => td2))
        results_ns = NSDictionary(Dict(cached.result => td3))
        cmdbuf = MPSCommandBuffer(Metal.global_queue(Metal.current_device()))
        encode!(cmdbuf, cached.graph, feeds, results_ns, nil, default_exec_desc())
        t = @elapsed commit!(cmdbuf)
        push!(times, t * 1e6)
    end
    results["commit!"] = median(times)

    # 12. wait_completed
    times = Float64[]
    for _ in 1:n_iters
        td1 = MPSGraphTensorData(buffers.signal_padded)
        td2 = MPSGraphTensorData(buffers.kernel_padded)
        td3 = MPSGraphTensorData(buffers.output)
        feeds = NSDictionary(Dict(cached.signal_placeholder => td1, cached.kernel_placeholder => td2))
        results_ns = NSDictionary(Dict(cached.result => td3))
        cmdbuf = MPSCommandBuffer(Metal.global_queue(Metal.current_device()))
        encode!(cmdbuf, cached.graph, feeds, results_ns, nil, default_exec_desc())
        commit!(cmdbuf)
        t = @elapsed wait_completed(cmdbuf)
        push!(times, t * 1e6)
    end
    results["wait_completed"] = median(times)

    # 13. Output slice copy
    output_arr = MtlVector{Float32}(undef, output_size)
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            copyto!(output_arr, 1, buffers.output, 1, output_size)
            Metal.synchronize()
        end
        push!(times, t * 1e6)
    end
    results["Output slice copy (sync)"] = median(times)

    # Full conv_fft_fused
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft_fused(signal, kernel)
            Metal.synchronize()
        end
        push!(times, t * 1e6)
    end
    results["TOTAL conv_fft_fused"] = median(times)

    # Print results
    println("\nComponent breakdown (μs):")
    total_components = 0.0
    for (name, time) in sort(collect(results), by=x->x[2], rev=true)
        if name != "TOTAL conv_fft_fused"
            total_components += time
            pct = 100 * time / results["TOTAL conv_fft_fused"]
            @printf("  %-30s %8.1f μs  (%5.1f%%)\n", name, time, pct)
        end
    end
    println()
    @printf("  %-30s %8.1f μs\n", "Sum of components:", total_components)
    @printf("  %-30s %8.1f μs\n", "Actual total:", results["TOTAL conv_fft_fused"])

    return results
end

# ============================================================================
# SECTION 2: Compare all three implementations
# ============================================================================

function compare_implementations(signal_size, kernel_size; n_iters=30)
    println("\n" * "=" ^ 80)
    println("IMPLEMENTATION COMPARISON: Signal=$signal_size, Kernel=$kernel_size")
    println("=" ^ 80)

    signal_cpu = rand(Float32, signal_size)
    kernel_cpu = rand(Float32, kernel_size)
    signal = MtlVector(signal_cpu)
    kernel = MtlVector(kernel_cpu)

    # Warmup all
    _ = conv_fft(signal, kernel)
    _ = conv_fft_fused(signal, kernel)
    _ = conv_fft_inline_pad(signal, kernel)
    Metal.synchronize()

    results = Dict{String, Float64}()

    # conv_fft (original, now uses fused internally)
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft(signal, kernel)
            Metal.synchronize()
        end
        push!(times, t * 1000)
    end
    results["conv_fft"] = median(times)

    # conv_fft_fused (explicit)
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft_fused(signal, kernel)
            Metal.synchronize()
        end
        push!(times, t * 1000)
    end
    results["conv_fft_fused"] = median(times)

    # conv_fft_inline_pad
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            _ = conv_fft_inline_pad(signal, kernel)
            Metal.synchronize()
        end
        push!(times, t * 1000)
    end
    results["conv_fft_inline_pad"] = median(times)

    println("\nLatency comparison (ms):")
    for (name, time) in sort(collect(results), by=x->x[2])
        @printf("  %-25s %8.3f ms\n", name, time)
    end

    fastest = minimum(values(results))
    println("\nSpeedups vs fastest:")
    for (name, time) in sort(collect(results), by=x->x[2])
        @printf("  %-25s %5.2fx\n", name, time / fastest)
    end

    return results
end

# ============================================================================
# SECTION 3: Async pipeline analysis
# ============================================================================

function analyze_async_pipeline(signal_size, kernel_size; batch_sizes=[1, 5, 10, 20, 50])
    println("\n" * "=" ^ 80)
    println("ASYNC PIPELINE ANALYSIS: Signal=$signal_size, Kernel=$kernel_size")
    println("=" ^ 80)

    signal = MtlVector(rand(Float32, signal_size))
    kernel = MtlVector(rand(Float32, kernel_size))

    # Warmup
    for _ in 1:3
        _ = conv_fft_fused(signal, kernel)
    end
    Metal.synchronize()

    println("\nBatch | Sync (ms/op) | Async (ms/op) | Pipeline Speedup")
    println("-" ^ 60)

    for batch in batch_sizes
        # Sync mode: wait after each
        Metal.synchronize()
        t_sync = @elapsed begin
            for _ in 1:batch
                _ = conv_fft_fused(signal, kernel)
                Metal.synchronize()
            end
        end
        ms_sync = (t_sync / batch) * 1000

        # Async mode: queue all, wait once
        Metal.synchronize()
        t_async = @elapsed begin
            for _ in 1:batch
                _ = conv_fft_fused(signal, kernel)
            end
            Metal.synchronize()
        end
        ms_async = (t_async / batch) * 1000

        speedup = ms_sync / ms_async
        @printf("%5d | %12.3f | %13.3f | %5.2fx\n", batch, ms_sync, ms_async, speedup)
    end
end

# ============================================================================
# SECTION 4: Memory operation breakdown
# ============================================================================

function analyze_memory_operations(signal_size, kernel_size; n_iters=50)
    println("\n" * "=" ^ 80)
    println("MEMORY OPERATION DEEP DIVE: Signal=$signal_size, Kernel=$kernel_size")
    println("=" ^ 80)

    ns, nk = signal_size, kernel_size
    full_size = ns + nk - 1
    nfft = nextfastfft(full_size)

    println("Sizes: signal=$ns, kernel=$nk, FFT=$nfft, padding_signal=$(nfft-ns), padding_kernel=$(nfft-nk)")

    signal = MtlVector(rand(Float32, signal_size))
    kernel = MtlVector(rand(Float32, kernel_size))

    # Pre-allocate
    signal_padded = MtlVector{Float32}(undef, nfft)
    kernel_padded = MtlVector{Float32}(undef, nfft)

    # Warmup
    copyto!(signal_padded, 1, signal, 1, ns)
    Metal.synchronize()

    results = Dict{String, Float64}()

    # Test 1: copyto! with sync
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            copyto!(signal_padded, 1, signal, 1, ns)
            Metal.synchronize()
        end
        push!(times, t * 1e6)
    end
    results["copyto! signal (with sync)"] = median(times)

    # Test 2: copyto! without sync (just queue time)
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed copyto!(signal_padded, 1, signal, 1, ns)
        push!(times, t * 1e6)
    end
    results["copyto! signal (queue only)"] = median(times)

    # Test 3: broadcast zero-fill with sync
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            @view(signal_padded[(ns+1):nfft]) .= 0f0
            Metal.synchronize()
        end
        push!(times, t * 1e6)
    end
    results["Zero-fill broadcast (with sync)"] = median(times)

    # Test 4: fill! for zeros
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            fill!(@view(signal_padded[(ns+1):nfft]), 0f0)
            Metal.synchronize()
        end
        push!(times, t * 1e6)
    end
    results["fill! zeros (with sync)"] = median(times)

    # Test 5: Full array fill
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            fill!(signal_padded, 0f0)
            Metal.synchronize()
        end
        push!(times, t * 1e6)
    end
    results["fill! full array (with sync)"] = median(times)

    # Test 6: MtlArray allocation
    times = Float64[]
    for _ in 1:n_iters
        GC.gc(false)
        t = @elapsed MtlVector{Float32}(undef, nfft)
        push!(times, t * 1e6)
    end
    results["MtlArray allocation"] = median(times)

    # Test 7: Combined copy + zero in one sync
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed begin
            copyto!(signal_padded, 1, signal, 1, ns)
            @view(signal_padded[(ns+1):nfft]) .= 0f0
            Metal.synchronize()
        end
        push!(times, t * 1e6)
    end
    results["copyto! + zero (one sync)"] = median(times)

    # Test 8: Metal.synchronize() alone
    times = Float64[]
    for _ in 1:n_iters
        Metal.synchronize()
        t = @elapsed Metal.synchronize()
        push!(times, t * 1e6)
    end
    results["Metal.synchronize() alone"] = median(times)

    println("\nMemory operation timings (μs):")
    for (name, time) in sort(collect(results), by=x->x[2], rev=true)
        @printf("  %-35s %8.1f μs\n", name, time)
    end

    return results
end

# ============================================================================
# RUN ANALYSIS
# ============================================================================

# Small signal (where GPU struggles)
analyze_fused_components(10_000, 100)
compare_implementations(10_000, 100)
analyze_memory_operations(10_000, 100)

# Medium signal
analyze_fused_components(100_000, 500)
compare_implementations(100_000, 500)

# Large signal (where GPU wins)
analyze_fused_components(1_000_000, 1000)
compare_implementations(1_000_000, 1000)

# Async pipeline analysis
analyze_async_pipeline(100_000, 500)

println("\n" * "=" ^ 80)
println("ANALYSIS COMPLETE")
println("=" ^ 80)
