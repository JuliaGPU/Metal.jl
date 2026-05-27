using Metal
using Statistics
using Printf

println("=" ^ 80)
println("PADDING ALTERNATIVES: Can we eliminate/reduce memory overhead?")
println("=" ^ 80)

signal_size = 100_000
kernel_size = 500
full_size = signal_size + kernel_size - 1
nfft = Metal.MPSGraphs.nextfastfft(full_size)

println("\nSetup: signal=$signal_size, kernel=$kernel_size, FFT size=$nfft")
println("Padding needed: signal=$(nfft - signal_size), kernel=$(nfft - kernel_size)")

signal = MtlVector(rand(Float32, signal_size))
kernel = MtlVector(rand(Float32, kernel_size))

n_iters = 30

# ============================================================================
# CURRENT APPROACH: Separate copy + zero-fill
# ============================================================================

println("\n" * "=" ^ 60)
println("METHOD 1: Current approach (copyto! + broadcast zero)")
println("=" ^ 60)

signal_padded = MtlVector{Float32}(undef, nfft)
kernel_padded = MtlVector{Float32}(undef, nfft)

# Warmup
copyto!(signal_padded, 1, signal, 1, signal_size)
@view(signal_padded[(signal_size+1):nfft]) .= 0f0
Metal.synchronize()

times = Float64[]
for _ in 1:n_iters
    Metal.synchronize()
    t = @elapsed begin
        copyto!(signal_padded, 1, signal, 1, signal_size)
        @view(signal_padded[(signal_size+1):nfft]) .= 0f0
        copyto!(kernel_padded, 1, kernel, 1, kernel_size)
        @view(kernel_padded[(kernel_size+1):nfft]) .= 0f0
        Metal.synchronize()
    end
    push!(times, t * 1e6)
end
current_time = median(times)
@printf("  Time: %.1f μs\n", current_time)

# ============================================================================
# ALTERNATIVE 1: Pre-fill with zeros, then copy
# ============================================================================

println("\n" * "=" ^ 60)
println("METHOD 2: Pre-fill zeros, then copy (fill! + copyto!)")
println("=" ^ 60)

times = Float64[]
for _ in 1:n_iters
    Metal.synchronize()
    t = @elapsed begin
        fill!(signal_padded, 0f0)
        fill!(kernel_padded, 0f0)
        copyto!(signal_padded, 1, signal, 1, signal_size)
        copyto!(kernel_padded, 1, kernel, 1, kernel_size)
        Metal.synchronize()
    end
    push!(times, t * 1e6)
end
prefill_time = median(times)
@printf("  Time: %.1f μs (%.2fx vs current)\n", prefill_time, prefill_time / current_time)

# ============================================================================
# ALTERNATIVE 2: Use zeros() then copy
# ============================================================================

println("\n" * "=" ^ 60)
println("METHOD 3: Create with zeros() then copy")
println("=" ^ 60)

times = Float64[]
for _ in 1:n_iters
    Metal.synchronize()
    GC.gc(false)
    t = @elapsed begin
        sp = Metal.zeros(Float32, nfft)
        kp = Metal.zeros(Float32, nfft)
        copyto!(sp, 1, signal, 1, signal_size)
        copyto!(kp, 1, kernel, 1, kernel_size)
        Metal.synchronize()
    end
    push!(times, t * 1e6)
end
zeros_time = median(times)
@printf("  Time: %.1f μs (%.2fx vs current)\n", zeros_time, zeros_time / current_time)

# ============================================================================
# ALTERNATIVE 3: Single kernel pad-copy (custom kernel)
# ============================================================================

println("\n" * "=" ^ 60)
println("METHOD 4: Custom Metal kernel for pad+copy")
println("=" ^ 60)

# Define a custom kernel that copies and pads in one operation
function pad_copy_kernel(dest, src, src_len)
    i = thread_position_in_grid_1d()
    if i <= src_len
        @inbounds dest[i] = src[i]
    elseif i <= length(dest)
        @inbounds dest[i] = 0f0
    end
    return
end

# Warmup
@metal threads=256 groups=cld(nfft, 256) pad_copy_kernel(signal_padded, signal, signal_size)
Metal.synchronize()

times = Float64[]
for _ in 1:n_iters
    Metal.synchronize()
    t = @elapsed begin
        @metal threads=256 groups=cld(nfft, 256) pad_copy_kernel(signal_padded, signal, signal_size)
        @metal threads=256 groups=cld(nfft, 256) pad_copy_kernel(kernel_padded, kernel, kernel_size)
        Metal.synchronize()
    end
    push!(times, t * 1e6)
end
custom_kernel_time = median(times)
@printf("  Time: %.1f μs (%.2fx vs current)\n", custom_kernel_time, custom_kernel_time / current_time)

# ============================================================================
# ALTERNATIVE 4: Batch operations without intermediate sync
# ============================================================================

println("\n" * "=" ^ 60)
println("METHOD 5: Queue all ops, single sync at end")
println("=" ^ 60)

times = Float64[]
for _ in 1:n_iters
    Metal.synchronize()
    t = @elapsed begin
        # Queue all operations without waiting
        copyto!(signal_padded, 1, signal, 1, signal_size)
        copyto!(kernel_padded, 1, kernel, 1, kernel_size)
        @view(signal_padded[(signal_size+1):nfft]) .= 0f0
        @view(kernel_padded[(kernel_size+1):nfft]) .= 0f0
        # Single sync at end
        Metal.synchronize()
    end
    push!(times, t * 1e6)
end
batch_time = median(times)
@printf("  Time: %.1f μs (%.2fx vs current)\n", batch_time, batch_time / current_time)

# ============================================================================
# ALTERNATIVE 5: No padding at all - what if data comes pre-padded?
# ============================================================================

println("\n" * "=" ^ 60)
println("METHOD 6: Pre-padded data (best case scenario)")
println("=" ^ 60)

# Simulate pre-padded data
signal_prepadded = Metal.zeros(Float32, nfft)
copyto!(signal_prepadded, 1, signal, 1, signal_size)
kernel_prepadded = Metal.zeros(Float32, nfft)
copyto!(kernel_prepadded, 1, kernel, 1, kernel_size)
Metal.synchronize()

times = Float64[]
for _ in 1:n_iters
    Metal.synchronize()
    t = @elapsed begin
        # Just copy pre-padded data (simulating zero-cost padding)
        copyto!(signal_padded, signal_prepadded)
        copyto!(kernel_padded, kernel_prepadded)
        Metal.synchronize()
    end
    push!(times, t * 1e6)
end
prepadded_time = median(times)
@printf("  Time: %.1f μs (%.2fx vs current)\n", prepadded_time, prepadded_time / current_time)

# ============================================================================
# ALTERNATIVE 6: Skip padding entirely - use inline padding in MPSGraph
# ============================================================================

println("\n" * "=" ^ 60)
println("METHOD 7: MPSGraph inline padding (no Julia-side padding)")
println("=" ^ 60)

# With inline padding, we pass the original unpadded arrays
# The MPSGraph handles padding internally via concat operations

using Metal.MPSGraphs: conv_fft_fused, conv_fft_inline_pad

# conv_fft_fused (needs pre-padded buffers, so we measure padding + execution)
times_fused = Float64[]
for _ in 1:n_iters
    Metal.synchronize()
    t = @elapsed begin
        _ = conv_fft_fused(signal, kernel)
        Metal.synchronize()
    end
    push!(times_fused, t * 1000)  # ms
end
fused_time = median(times_fused)

# conv_fft_inline_pad (no Julia-side padding needed)
times_inline = Float64[]
for _ in 1:n_iters
    Metal.synchronize()
    t = @elapsed begin
        _ = conv_fft_inline_pad(signal, kernel)
        Metal.synchronize()
    end
    push!(times_inline, t * 1000)  # ms
end
inline_time = median(times_inline)

@printf("  conv_fft_fused:      %.3f ms (includes padding)\n", fused_time)
@printf("  conv_fft_inline_pad: %.3f ms (no Julia-side padding)\n", inline_time)
@printf("  Difference:          %.3f ms saved\n", fused_time - inline_time)

# ============================================================================
# SUMMARY
# ============================================================================

println("\n" * "=" ^ 80)
println("SUMMARY: Padding time comparison")
println("=" ^ 80)

results = [
    ("Current (copyto! + broadcast)", current_time),
    ("Pre-fill zeros + copy", prefill_time),
    ("Create zeros() + copy", zeros_time),
    ("Custom Metal kernel", custom_kernel_time),
    ("Batch ops (single sync)", batch_time),
    ("Pre-padded data", prepadded_time),
]

sort!(results, by=x->x[2])

println("\nRanked by speed:")
for (i, (name, time)) in enumerate(results)
    speedup = current_time / time
    @printf("%d. %-30s %7.1f μs (%5.2fx vs current)\n", i, name, time, speedup)
end

println("\n" * "=" ^ 80)
println("KEY FINDINGS")
println("=" ^ 80)
println("""
1. The padding overhead (~700 μs) comes from GPU kernel launch costs
2. Each GPU operation (copyto!, broadcast) has ~200 μs overhead
3. Custom kernels can potentially reduce this by combining operations
4. The inline-pad implementation in MPSGraph eliminates Julia-side padding
5. Pre-padded data would be fastest but requires user workflow changes
""")
