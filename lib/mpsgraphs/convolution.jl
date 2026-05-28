# FFT-based convolution for MtlArrays
#
# Implements linear convolution using the FFT convolution theorem:
#   conv(u, v) = ifft(fft(u) .* fft(v))
#
# Supported types:
#   - Float32, Float16 (real inputs - uses rfft/irfft for efficiency)
#   - ComplexF32, ComplexF16 (complex inputs - uses fft/ifft)
#
# For double precision, convert to Float32 first or use CPU DSP.jl.

using AbstractFFTs

export conv, conv_fft, conv_fft!, xcorr, imfilter
export clear_fused_conv_cache!

# Helper Functions

"""
    nextfastfft(n::Integer)

Return the smallest integer >= n that has only factors of 2, 3, 5, and 7.
These sizes are efficient for FFT computation.
"""
function nextfastfft(n::Integer)
    n <= 0 && return 1
    while true
        m = n
        for p in (2, 3, 5, 7)
            while m % p == 0
                m ÷= p
            end
        end
        m == 1 && return n
        n += 1
    end
    return
end

# Output size of a 1-D convolution dimension, per mode.
function _conv_output_size(signal_size::Int, kernel_size::Int, mode::Symbol)
    full_size = signal_size + kernel_size - 1
    if mode == :full
        return full_size
    elseif mode == :same
        return signal_size
    elseif mode == :valid
        return max(signal_size - kernel_size + 1, 0)
    else
        throw(ArgumentError("Unknown convolution mode: $mode. Use :full, :same, or :valid"))
    end
end

# Extract the requested portion of a 1-D convolution result, per mode.
function _extract_conv_result(
        result::MtlArray{T, 1}, output_size::Int, full_size::Int, mode::Symbol
    ) where {T}
    if mode == :full
        return result[1:output_size]
    elseif mode == :same
        # Center the output around the same size as input
        offset = (full_size - output_size) ÷ 2
        return result[(offset + 1):(offset + output_size)]
    elseif mode == :valid
        # Only fully overlapping region
        kernel_size = full_size - output_size + 1 - 1  # Solve for K from N + K - 1 = full, valid = N - K + 1
        offset = full_size - output_size
        return result[(offset ÷ 2 + 1):(offset ÷ 2 + output_size)]
    end
end

# Multi-dimensional version
function _extract_conv_result(
        result::MtlArray{T, N}, output_sizes::NTuple{N, Int}, full_sizes::NTuple{N, Int},
        mode::Symbol, dims::Union{Int, Tuple}
    ) where {T, N}
    dims_tuple = dims isa Int ? (dims,) : Tuple(dims)

    # Build index ranges for each dimension
    ranges = ntuple(N) do i
        if i in dims_tuple
            full_size = full_sizes[i]
            output_size = output_sizes[i]
            if mode == :full
                1:output_size
            elseif mode == :same
                offset = (full_size - output_size) ÷ 2
                (offset + 1):(offset + output_size)
            else  # :valid
                offset = full_size - output_size
                (offset ÷ 2 + 1):(offset ÷ 2 + output_size)
            end
        else
            1:size(result, i)
        end
    end

    return result[ranges...]
end

# Fused MPSGraph Convolution (Single Graph Execution)

# Cache key for fused convolution graphs
struct FusedConvGraphKey
    signal_fft_size::Tuple{Vararg{Int}}  # Padded size for FFT
    kernel_fft_size::Tuple{Vararg{Int}}  # Should match signal_fft_size
    output_size::Tuple{Vararg{Int}}      # Output shape after extraction
    eltype::DataType                      # Float32 or Float16
end

# Cached fused convolution graph
struct CachedFusedConvGraph
    graph::MPSGraph
    signal_placeholder::MPSGraphTensor
    kernel_placeholder::MPSGraphTensor
    result::MPSGraphTensor
end

# Thread-safe cache for fused convolution graphs (bounded FIFO; see _record_and_evict!)
const _FUSED_CONV_CACHE_MAX_ENTRIES = 32
const _fused_conv_graph_cache = Dict{FusedConvGraphKey, CachedFusedConvGraph}()
const _fused_conv_graph_cache_lock = ReentrantLock()
const _fused_conv_graph_cache_order = FusedConvGraphKey[]

# Drop the oldest cached entry once a cache exceeds the size cap (call under the
# cache's lock). Keeps the graph cache and buffer pool from growing unboundedly
# when many distinct convolution sizes are used.
function _record_and_evict!(cache::AbstractDict, order::AbstractVector, key)
    push!(order, key)
    if length(order) > _FUSED_CONV_CACHE_MAX_ENTRIES
        delete!(cache, popfirst!(order))
    end
    return nothing
end

# Buffer Pooling for Fused Convolution

# Key for buffer pool: (fft_sizes, eltype)
struct BufferPoolKey
    fft_sizes::Tuple{Vararg{Int}}
    eltype::DataType
end

# Cached buffers for fused convolution
mutable struct CachedFusedConvBuffers{T, N}
    signal_padded::MtlArray{T, N}
    kernel_padded::MtlArray{T, N}
    output::MtlArray{T, N}
end

# Thread-safe buffer pool (bounded FIFO)
const _fused_conv_buffer_pool = Dict{BufferPoolKey, CachedFusedConvBuffers}()
const _fused_conv_buffer_pool_lock = ReentrantLock()
const _fused_conv_buffer_pool_order = BufferPoolKey[]

# Get or create pooled padded signal/kernel/output buffers for a given FFT size.
function _get_cached_buffers(fft_sizes::NTuple{N, Int}, ::Type{T}) where {N, T}
    key = BufferPoolKey(fft_sizes, T)
    cached = get(_fused_conv_buffer_pool, key, nothing)
    if cached !== nothing
        return cached
    end
    return lock(_fused_conv_buffer_pool_lock) do
        cached = get(_fused_conv_buffer_pool, key, nothing)
        if cached !== nothing
            return cached
        end
        # Allocate new buffers
        signal_padded = MtlArray{T, N}(undef, fft_sizes)
        kernel_padded = MtlArray{T, N}(undef, fft_sizes)
        output = MtlArray{T, N}(undef, fft_sizes)
        cached = CachedFusedConvBuffers{T, N}(signal_padded, kernel_padded, output)
        _fused_conv_buffer_pool[key] = cached
        _record_and_evict!(_fused_conv_buffer_pool, _fused_conv_buffer_pool_order, key)
        return cached
    end
end

"""
    clear_fused_conv_buffer_pool!()

Clear the fused convolution buffer pool, freeing GPU memory.
"""
function clear_fused_conv_buffer_pool!()
    lock(_fused_conv_buffer_pool_lock) do
        empty!(_fused_conv_buffer_pool)
        empty!(_fused_conv_buffer_pool_order)
    end
    return nothing
end

# Fast Padding Kernel (Single kernel for copy + zero-pad)

# Custom Metal kernel that copies source data and zero-pads in one operation
# This is ~4.5x faster than separate copyto! + broadcast zero operations
function _pad_copy_kernel_1d!(dest, src, src_len)
    i = thread_position_in_grid_1d()
    if i <= src_len
        @inbounds dest[i] = src[i]
    elseif i <= length(dest)
        @inbounds dest[i] = zero(eltype(dest))
    end
    return
end

# Copy a 1-D source into a zero-padded destination with a single GPU kernel
# (faster than separate copyto! + broadcast fill).
function _fast_pad_copy!(dest::MtlVector{T}, src::MtlVector{T}) where {T}
    src_len = length(src)
    dest_len = length(dest)
    threads = min(256, dest_len)
    groups = cld(dest_len, threads)
    @metal threads = threads groups = groups _pad_copy_kernel_1d!(dest, src, src_len)
    return dest
end


# Build the fused N-D convolution graph (rfft * rfft -> irfft -> scale) as a single
# MPSGraph, for any dimensionality.
function _build_fused_conv_graph_nd(fft_sizes::NTuple{N, Int}, ::Type{T}) where {N, T <: Union{Float32, Float16}}
    graph = MPSGraph()

    # Placeholders for padded signal and kernel (same shape)
    signal_ph = placeholderTensor(graph, fft_sizes, T)
    kernel_ph = placeholderTensor(graph, fft_sizes, T)

    # FFT descriptor for forward transform
    fft_desc_fwd = MPSGraphFFTDescriptor(inverse = false)

    # Metal uses reversed axis ordering: axis 0 in Metal = last axis in Julia
    # For N-D, we transform all dimensions
    axes = NSArray([NSNumber(Int32(i)) for i in (N - 1):-1:0])

    # Forward rfft on both inputs
    signal_fft = realToHermiteanFFTWithTensor(graph, signal_ph, axes, fft_desc_fwd, "signal_rfft")
    kernel_fft = realToHermiteanFFTWithTensor(graph, kernel_ph, axes, fft_desc_fwd, "kernel_rfft")

    # Element-wise multiplication in frequency domain
    product = multiplicationWithPrimaryTensor(graph, signal_fft, kernel_fft, "freq_multiply")

    # Inverse rfft - scale factor is product of all FFT dimensions
    total_size = prod(fft_sizes)
    fft_desc_inv = MPSGraphFFTDescriptor(inverse = true)
    # For irfft, roundToOddHermitean depends on the first transformed dimension (last in Julia order)
    fft_desc_inv.roundToOddHermitean = isodd(fft_sizes[1])
    result_unscaled = HermiteanToRealFFTWithTensor(graph, product, axes, fft_desc_inv, "irfft")

    # Apply scaling: divide by total FFT size
    scale_factor = constantWithScalar(graph, T(1) / T(total_size), T)
    result_scaled = multiplicationWithPrimaryTensor(graph, result_unscaled, scale_factor, "scale")

    # Return full result - slicing done in Julia for flexibility
    return CachedFusedConvGraph(graph, signal_ph, kernel_ph, result_scaled)
end

# Get or create the cached fused convolution graph for a given FFT size.
function _get_cached_fused_conv_graph(key::FusedConvGraphKey)
    cached = get(_fused_conv_graph_cache, key, nothing)
    if cached !== nothing
        return cached
    end
    return lock(_fused_conv_graph_cache_lock) do
        cached = get(_fused_conv_graph_cache, key, nothing)
        if cached !== nothing
            return cached
        end
        # Build N-D fused graph
        cached = _build_fused_conv_graph_nd(key.signal_fft_size, key.eltype)
        _fused_conv_graph_cache[key] = cached
        _record_and_evict!(_fused_conv_graph_cache, _fused_conv_graph_cache_order, key)
        return cached
    end
end

"""
    conv_fft_fused(signal::MtlArray{T,N}, kernel::MtlArray{T,N}; mode=:full)

Compute N-D convolution using a fused MPSGraph that executes rfft → multiply → irfft → scale
in a single graph execution, minimizing command submission overhead.

Convolution is performed along all dimensions. For 1D, 2D, 3D, etc.
This is optimized for throughput when processing many convolutions.
"""
function conv_fft_fused(
        signal::MtlArray{T, N}, kernel::MtlArray{T, N}; mode::Symbol = :full
    ) where {T <: Union{Float32, Float16}, N}
    signal_sizes = size(signal)
    kernel_sizes = size(kernel)

    # Compute full and output sizes for each dimension
    full_sizes = ntuple(i -> signal_sizes[i] + kernel_sizes[i] - 1, N)
    output_sizes = ntuple(i -> _conv_output_size(signal_sizes[i], kernel_sizes[i], mode), N)
    fft_sizes = ntuple(i -> nextfastfft(full_sizes[i]), N)

    # Get cached fused graph
    key = FusedConvGraphKey(fft_sizes, fft_sizes, output_sizes, T)
    cached = _get_cached_fused_conv_graph(key)

    # Get cached buffers (avoids GPU memory allocation per call)
    buffers = _get_cached_buffers(fft_sizes, T)
    signal_padded = buffers.signal_padded
    kernel_padded = buffers.kernel_padded
    output = buffers.output

    # Copy data to padded arrays with zero-padding
    # Use fast single-kernel approach for 1D (4.5x faster than separate copy + zero-fill)
    if N == 1
        _fast_pad_copy!(signal_padded, signal)
        _fast_pad_copy!(kernel_padded, kernel)
    else
        # For N-D, use the standard approach (could be optimized further)
        signal_ranges = ntuple(i -> 1:signal_sizes[i], N)
        kernel_ranges = ntuple(i -> 1:kernel_sizes[i], N)
        signal_padded[signal_ranges...] = signal
        kernel_padded[kernel_ranges...] = kernel
        _zero_padding_regions_fused!(signal_padded, signal_sizes, fft_sizes)
        _zero_padding_regions_fused!(kernel_padded, kernel_sizes, fft_sizes)
    end

    # Execute fused graph
    @autoreleasepool begin
        feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
            cached.signal_placeholder => MPSGraphTensorData(signal_padded),
            cached.kernel_placeholder => MPSGraphTensorData(kernel_padded)
        )

        resultdict = Dict{MPSGraphTensor, MPSGraphTensorData}(
            cached.result => MPSGraphTensorData(output)
        )

        cmdbuf = MPSCommandBuffer(Metal.global_queue(current_device()))
        encode!(cmdbuf, cached.graph, NSDictionary(feeds), NSDictionary(resultdict), nil, default_exec_desc())
        commit!(cmdbuf)
        # No per-call host wait: the graph runs on the same in-order queue as the
        # padding above and the extraction copy below, so results are correct once
        # the caller synchronizes (e.g. via `Array`). Skipping the wait lets
        # successive convolutions pipeline on the GPU instead of serializing.

        # Extract the requested region. This copies, so the pooled `output` buffer
        # can be safely overwritten by the next call enqueued on the same queue.
        return _extract_conv_result_nd(output, output_sizes, full_sizes, mode)
    end
end

# Helper to zero padding regions for N-D arrays (all dimensions)
function _zero_padding_regions_fused!(arr::MtlArray{T, N}, data_sizes::NTuple{N, Int}, fft_sizes::NTuple{N, Int}) where {T, N}
    for dim in 1:N
        if data_sizes[dim] < fft_sizes[dim]
            # Build ranges: full range for other dims, padding range for this dim
            ranges = ntuple(N) do i
                if i == dim
                    (data_sizes[i] + 1):fft_sizes[i]
                else
                    1:fft_sizes[i]
                end
            end
            @view(arr[ranges...]) .= zero(T)
        end
    end
    return
end

# Helper for extracting result based on mode
function _extract_conv_result_nd(y::MtlArray{T, N}, output_sizes::NTuple{N, Int}, full_sizes::NTuple{N, Int}, mode::Symbol) where {T, N}
    if mode == :full
        # Just take the first output_size elements in each dimension
        ranges = ntuple(i -> 1:output_sizes[i], N)
        return y[ranges...]
    elseif mode == :same
        # Center the output
        ranges = ntuple(N) do i
            offset = (full_sizes[i] - output_sizes[i]) ÷ 2
            (offset + 1):(offset + output_sizes[i])
        end
        return y[ranges...]
    else  # :valid
        # Only the fully-overlapping region, centered within the full convolution
        # (matches _extract_conv_result and the direct path)
        ranges = ntuple(N) do i
            offset = full_sizes[i] - output_sizes[i]
            (offset ÷ 2 + 1):(offset ÷ 2 + output_sizes[i])
        end
        return y[ranges...]
    end
end

"""
    clear_fused_conv_cache!()

Clear the fused convolution graph cache and buffer pool, freeing GPU memory.
"""
function clear_fused_conv_cache!()
    lock(_fused_conv_graph_cache_lock) do
        empty!(_fused_conv_graph_cache)
        empty!(_fused_conv_graph_cache_order)
    end
    clear_fused_conv_buffer_pool!()
    return nothing
end

# Export the new function
# (added to exports at top of file)

# Efficient Padding Helpers

# Zero only the padding regions of an N-D array (avoids rewriting the data block).
function _zero_padding_regions!(
        arr::MtlArray{T, N}, data_sizes::NTuple{N, Int},
        padded_sizes::NTuple{N, Int}, dims::Tuple
    ) where {T, N}
    # For each dimension that needs padding
    for d in dims
        if data_sizes[d] < padded_sizes[d]
            # Build ranges for the padding strip in dimension d
            ranges = ntuple(N) do i
                if i == d
                    # Padding region in this dimension
                    (data_sizes[i] + 1):padded_sizes[i]
                elseif i < d
                    # For earlier dimensions, include entire padded size
                    # (to cover corner regions that previous strips may have missed)
                    1:padded_sizes[i]
                else
                    # For later dimensions, include only data region
                    # (corners will be covered by later strips)
                    1:data_sizes[i]
                end
            end
            @view(arr[ranges...]) .= zero(T)
        end
    end
    return nothing
end

# 1D FFT Convolution (Real Inputs - Optimized)

"""
    conv_fft(signal::MtlVector, kernel::MtlVector; mode=:full)

Compute the 1D linear convolution of `signal` and `kernel` using FFT.

# Arguments
- `signal`: Input signal (1D MtlArray)
- `kernel`: Convolution kernel (1D MtlArray)
- `mode`: Output mode
  - `:full` (default): Full convolution, output length = length(signal) + length(kernel) - 1
  - `:same`: Output has same length as signal (centered)
  - `:valid`: Only fully overlapping region, output length = max(length(signal) - length(kernel) + 1, 0)

# Returns
MtlArray with the convolution result.

# Example
```julia
using Metal

signal = MtlVector(randn(Float32, 1000))
kernel = MtlVector(randn(Float32, 100))
result = conv_fft(signal, kernel)  # length = 1099
result_same = conv_fft(signal, kernel; mode=:same)  # length = 1000
```

# Notes
- Uses `rfft`/`irfft` for real inputs (2x memory savings vs full FFT)
- Pads to next fast FFT size for optimal performance
- For complex inputs, use the complex-valued method
"""
function conv_fft(
        signal::MtlVector{T}, kernel::MtlVector{T}; mode::Symbol = :full
    ) where {T <: Union{Float32, Float16}}
    # Delegate to fused implementation for better performance
    # (single MPSGraph execution instead of 4+ separate operations)
    return conv_fft_fused(signal, kernel; mode = mode)
end

# 1D FFT Convolution (Complex Inputs)

"""
    conv_fft(signal::MtlVector{Complex{T}}, kernel::MtlVector{Complex{T}}; mode=:full)

Compute the 1D linear convolution of complex `signal` and `kernel` using FFT.
"""
function conv_fft(
        signal::MtlVector{Complex{T}}, kernel::MtlVector{Complex{T}}; mode::Symbol = :full
    ) where {T <: Union{Float32, Float16}}
    ns = length(signal)
    nk = length(kernel)

    # Compute sizes
    full_size = ns + nk - 1
    output_size = _conv_output_size(ns, nk, mode)

    # Find optimal FFT size
    nfft = nextfastfft(full_size)

    # Allocate padded arrays
    signal_padded = MtlArray{Complex{T}}(undef, nfft)
    kernel_padded = MtlArray{Complex{T}}(undef, nfft)

    # Copy data first, then zero only the padding region (not the entire buffer)
    copyto!(signal_padded, 1, signal, 1, ns)
    copyto!(kernel_padded, 1, kernel, 1, nk)

    # Zero only the padding regions
    if ns < nfft
        @view(signal_padded[(ns + 1):nfft]) .= zero(Complex{T})
    end
    if nk < nfft
        @view(kernel_padded[(nk + 1):nfft]) .= zero(Complex{T})
    end

    # FFT
    S = fft(signal_padded)
    K = fft(kernel_padded)

    # Multiply in frequency domain (in-place to avoid allocation)
    S .*= K

    # Inverse FFT
    y = ifft(S)

    # Extract appropriate region
    return _extract_conv_result(y, output_size, full_size, mode)
end

# N-D FFT Convolution (along specified dimensions)

"""
    conv_fft(signal::MtlArray, kernel::MtlArray; dims=1, mode=:full)

Compute N-dimensional linear convolution along specified dimensions using FFT.

# Arguments
- `signal`: Input signal (N-dimensional MtlArray)
- `kernel`: Convolution kernel (same number of dimensions as signal)
- `dims`: Dimension(s) along which to convolve (default: 1). Can be an integer or tuple.
- `mode`: Output mode (`:full`, `:same`, or `:valid`)

# Returns
MtlArray with the convolution result.

# Example
```julia
# 2D convolution along both dimensions
signal = MtlArray(randn(Float32, 100, 100))
kernel = MtlArray(randn(Float32, 5, 5))
result = conv_fft(signal, kernel; dims=(1,2))

# 1D convolution along rows only
result_rows = conv_fft(signal, kernel; dims=1)
```
"""
function conv_fft(
        signal::MtlArray{T, N}, kernel::MtlArray{T, N};
        dims::Union{Int, Tuple{Vararg{Int}}} = 1, mode::Symbol = :full
    ) where {T <: Union{Float32, Float16}, N}
    dims_tuple = dims isa Int ? (dims,) : Tuple(dims)

    # Validate dimensions
    for d in dims_tuple
        1 <= d <= N ||
            throw(ArgumentError("Invalid dimension $d for array with $N dimensions"))
    end

    # Use fused implementation when convolving along ALL dimensions (faster single-graph execution)
    if length(dims_tuple) == N && Set(dims_tuple) == Set(1:N)
        return conv_fft_fused(signal, kernel; mode = mode)
    end

    # Compute output sizes for each convolved dimension
    signal_sizes = size(signal)
    kernel_sizes = size(kernel)

    full_sizes = ntuple(N) do i
        if i in dims_tuple
            signal_sizes[i] + kernel_sizes[i] - 1
        else
            signal_sizes[i]
        end
    end

    output_sizes = ntuple(N) do i
        if i in dims_tuple
            _conv_output_size(signal_sizes[i], kernel_sizes[i], mode)
        else
            signal_sizes[i]
        end
    end

    # Compute FFT sizes
    fft_sizes = ntuple(N) do i
        if i in dims_tuple
            nextfastfft(full_sizes[i])
        else
            signal_sizes[i]
        end
    end

    # Pad signal and kernel with efficient memory operations
    signal_padded = MtlArray{T}(undef, fft_sizes)
    kernel_padded = MtlArray{T}(undef, fft_sizes)

    # Copy data to padded arrays first
    signal_ranges = ntuple(i -> 1:signal_sizes[i], N)
    kernel_ranges = ntuple(i -> 1:kernel_sizes[i], N)

    signal_padded[signal_ranges...] = signal
    kernel_padded[kernel_ranges...] = kernel

    # Zero only the padding regions (not the entire buffer)
    _zero_padding_regions!(signal_padded, signal_sizes, fft_sizes, dims_tuple)
    _zero_padding_regions!(kernel_padded, kernel_sizes, fft_sizes, dims_tuple)

    # FFT along specified dimensions (use rfft for real inputs)
    S = rfft(signal_padded, dims_tuple)
    K = rfft(kernel_padded, dims_tuple)

    # Multiply in frequency domain (in-place to avoid allocation)
    S .*= K

    # Inverse FFT
    # For irfft, we need the output size of the first transformed dimension
    first_dim = minimum(dims_tuple)
    y = irfft(S, fft_sizes[first_dim], dims_tuple)

    # Extract appropriate region
    return _extract_conv_result(y, output_sizes, full_sizes, mode, dims_tuple)
end

# Complex N-D version
function conv_fft(
        signal::MtlArray{Complex{T}, N}, kernel::MtlArray{Complex{T}, N};
        dims::Union{Int, Tuple{Vararg{Int}}} = 1, mode::Symbol = :full
    ) where {T <: Union{Float32, Float16}, N}
    dims_tuple = dims isa Int ? (dims,) : Tuple(dims)

    for d in dims_tuple
        1 <= d <= N ||
            throw(ArgumentError("Invalid dimension $d for array with $N dimensions"))
    end

    signal_sizes = size(signal)
    kernel_sizes = size(kernel)

    full_sizes = ntuple(N) do i
        if i in dims_tuple
            signal_sizes[i] + kernel_sizes[i] - 1
        else
            signal_sizes[i]
        end
    end

    output_sizes = ntuple(N) do i
        if i in dims_tuple
            _conv_output_size(signal_sizes[i], kernel_sizes[i], mode)
        else
            signal_sizes[i]
        end
    end

    fft_sizes = ntuple(N) do i
        if i in dims_tuple
            nextfastfft(full_sizes[i])
        else
            signal_sizes[i]
        end
    end

    # Pad signal and kernel with efficient memory operations
    signal_padded = MtlArray{Complex{T}}(undef, fft_sizes)
    kernel_padded = MtlArray{Complex{T}}(undef, fft_sizes)

    # Copy data to padded arrays first
    signal_ranges = ntuple(i -> 1:signal_sizes[i], N)
    kernel_ranges = ntuple(i -> 1:kernel_sizes[i], N)

    signal_padded[signal_ranges...] = signal
    kernel_padded[kernel_ranges...] = kernel

    # Zero only the padding regions (not the entire buffer)
    _zero_padding_regions!(signal_padded, signal_sizes, fft_sizes, dims_tuple)
    _zero_padding_regions!(kernel_padded, kernel_sizes, fft_sizes, dims_tuple)

    S = fft(signal_padded, dims_tuple)
    K = fft(kernel_padded, dims_tuple)

    # Multiply in frequency domain (in-place to avoid allocation)
    S .*= K

    y = ifft(S, dims_tuple)

    return _extract_conv_result(y, output_sizes, full_sizes, mode, dims_tuple)
end

# Cross-correlation

# GPU-friendly reverse along specified dimensions
# Uses broadcasting to avoid scalar indexing
function _gpu_reverse(v::MtlArray{T, 1}) where {T}
    n = length(v)
    return v[n:-1:1]
end

function _gpu_reverse(v::MtlArray{T, N}, dims::Tuple) where {T, N}
    # Build index arrays for each dimension
    indices = ntuple(N) do i
        if i in dims
            size(v, i):-1:1
        else
            1:size(v, i)
        end
    end
    return v[indices...]
end

"""
    xcorr(u::MtlArray, v::MtlArray; dims=1, mode=:full)

Compute cross-correlation of `u` and `v` using FFT.

Cross-correlation is related to convolution by:
    xcorr(u, v) = conv(u, reverse(conj(v)))

For real signals, this simplifies to:
    xcorr(u, v) = conv(u, reverse(v))

# Arguments
- `u`, `v`: Input arrays
- `dims`: Dimension(s) along which to compute correlation
- `mode`: Output mode (`:full`, `:same`, or `:valid`)

# Example
```julia
u = MtlVector(randn(Float32, 1000))
v = MtlVector(randn(Float32, 100))
r = xcorr(u, v)  # Cross-correlation
```
"""
function xcorr(
        u::MtlArray{T, N}, v::MtlArray{T, N};
        dims::Union{Int, Tuple{Vararg{Int}}} = 1, mode::Symbol = :full
    ) where {T <: Union{Float32, Float16}, N}
    # For real signals: xcorr(u, v) = conv(u, reverse(v, dims=dims))
    dims_tuple = dims isa Int ? (dims,) : Tuple(dims)
    v_reversed = N == 1 ? _gpu_reverse(v) : _gpu_reverse(v, dims_tuple)
    # 1D conv_fft doesn't take dims argument
    if N == 1
        return conv_fft(u, v_reversed; mode = mode)
    else
        return conv_fft(u, v_reversed; dims = dims, mode = mode)
    end
end

function xcorr(
        u::MtlArray{Complex{T}, N}, v::MtlArray{Complex{T}, N};
        dims::Union{Int, Tuple{Vararg{Int}}} = 1, mode::Symbol = :full
    ) where {T <: Union{Float32, Float16}, N}
    # For complex signals: xcorr(u, v) = conv(u, reverse(conj(v), dims=dims))
    dims_tuple = dims isa Int ? (dims,) : Tuple(dims)
    v_conj = conj(v)
    v_conj_reversed = N == 1 ? _gpu_reverse(v_conj) : _gpu_reverse(v_conj, dims_tuple)
    # 1D conv_fft doesn't take dims argument
    if N == 1
        return conv_fft(u, v_conj_reversed; mode = mode)
    else
        return conv_fft(u, v_conj_reversed; dims = dims, mode = mode)
    end
end

# In-place convolution (output pre-allocated)

"""
    conv_fft!(output, signal, kernel; dims=1, mode=:full)

Compute convolution and store result in pre-allocated `output` array.

The output array must have the correct size for the specified mode.
"""
function conv_fft!(
        output::MtlArray{T, N}, signal::MtlArray{T, N}, kernel::MtlArray{T, N};
        dims::Union{Int, Tuple{Vararg{Int}}} = 1, mode::Symbol = :full
    ) where {T, N}
    result = conv_fft(signal, kernel; dims = dims, mode = mode)
    @assert size(output) == size(result) "Output size $(size(output)) does not match expected size $(size(result))"
    copyto!(output, result)
    return output
end


"""
    imfilter(image::MtlMatrix, kernel::MtlMatrix)

Apply a 2-D filter `kernel` to `image` via FFT-based convolution (`:same` mode).

A convenience wrapper following the ImageFiltering.jl interface; the kernel is
centered on each pixel.

# Arguments
- `image`: 2D input image
- `kernel`: 2D filter kernel

# Returns
Filtered image with same size as input (`:same` mode).

# Example
```julia
using Metal

# Create test image
image = MtlMatrix(randn(Float32, 512, 512))

# Gaussian blur (5×5 approximation)
gaussian = MtlMatrix(Float32[
    1  4  6  4 1
    4 16 24 16 4
    6 24 36 24 6
    4 16 24 16 4
    1  4  6  4 1
] ./ 256)

blurred = imfilter(image, gaussian)

# Sobel edge detection
sobel_x = MtlMatrix(Float32[-1 0 1; -2 0 2; -1 0 1] ./ 8)
sobel_y = MtlMatrix(Float32[-1 -2 -1; 0 0 0; 1 2 1] ./ 8)
edges_x = imfilter(image, sobel_x)
edges_y = imfilter(image, sobel_y)
edges = sqrt.(edges_x.^2 .+ edges_y.^2)
```

# Notes
- Equivalent to `conv(image, kernel; dims=(1, 2), mode=:same)`.
- The kernel is centered on each pixel (like ImageFiltering.jl's `imfilter`).
"""
function imfilter(image::MtlMatrix{T}, kernel::MtlMatrix{T}) where {T <: Union{Float32, Float16}}
    return conv_fft(image, kernel; dims = (1, 2), mode = :same)
end

# Unified Convolution API (FFT-based)
#
# The unified `conv()` dispatches to the FFT convolution engine for 1D, 2D, and
# N-D arrays. It is the internal entry point behind the public DSP.conv /
# DSP.xcorr interface (provided by the DSP.jl extension).

"""
    conv(signal::MtlArray, kernel::MtlArray; mode=:full, dims=nothing)

Compute the linear convolution of `signal` and `kernel` via the FFT convolution
theorem. This is the internal engine entry point; the public interface is
`DSP.conv` (provided by the DSP.jl extension).

# Arguments
- `signal`: Input signal (1D, 2D, or N-D MtlArray)
- `kernel`: Convolution kernel (same dimensions as signal)
- `mode`: Output size mode
  - `:full` (default): Full convolution output
  - `:same`: Output has same size as signal (centered)
  - `:valid`: Only fully overlapping region
- `dims`: Dimensions along which to convolve
  - `nothing` (default): All dimensions for 1D/2D, dim 1 for N-D
  - Integer or tuple: Specific dimension(s)

# Returns
MtlArray with the convolution result.

# Examples

```julia
using Metal, Metal.MPSGraphs

# 1D signal processing
signal = MtlVector(randn(Float32, 10000))
kernel = MtlVector(Float32[0.25, 0.5, 0.25])  # Simple smoothing
smoothed = conv(signal, kernel; mode=:same)

# 2D image filtering
image = MtlMatrix(randn(Float32, 512, 512))
sobel_x = MtlMatrix(Float32[-1 0 1; -2 0 2; -1 0 1] ./ 8)
edges = conv(image, sobel_x; mode=:same)
```

# See Also
- `imfilter`: ImageFiltering.jl-style 2D filtering
- `xcorr`: Cross-correlation
"""
function conv(
        signal::MtlVector{T}, kernel::MtlVector{T};
        mode::Symbol = :full, dims = nothing
    ) where {T <: Union{Float32, Float16}}
    return conv_fft(signal, kernel; mode = mode)
end

# Complex 1D
function conv(
        signal::MtlVector{Complex{T}}, kernel::MtlVector{Complex{T}};
        mode::Symbol = :full, dims = nothing
    ) where {T <: Union{Float32, Float16}}
    return conv_fft(signal, kernel; mode = mode)
end

# 2D
function conv(
        signal::MtlMatrix{T}, kernel::MtlMatrix{T};
        mode::Symbol = :full, dims = nothing
    ) where {T <: Union{Float32, Float16}}
    conv_dims = dims === nothing ? (1, 2) : (dims isa Int ? (dims,) : Tuple(dims))
    return conv_fft(signal, kernel; dims = conv_dims, mode = mode)
end

# Complex 2D
function conv(
        signal::MtlMatrix{Complex{T}}, kernel::MtlMatrix{Complex{T}};
        mode::Symbol = :full, dims = nothing
    ) where {T <: Union{Float32, Float16}}
    conv_dims = dims === nothing ? (1, 2) : (dims isa Int ? (dims,) : Tuple(dims))
    return conv_fft(signal, kernel; dims = conv_dims, mode = mode)
end

# N-D generic (N > 2)
function conv(
        signal::MtlArray{T, N}, kernel::MtlArray{T, N};
        mode::Symbol = :full, dims = nothing
    ) where {T <: Union{Float32, Float16}, N}
    conv_dims = dims === nothing ? 1 : (dims isa Int ? (dims,) : Tuple(dims))
    return conv_fft(signal, kernel; dims = conv_dims, mode = mode)
end

# Complex N-D
function conv(
        signal::MtlArray{Complex{T}, N}, kernel::MtlArray{Complex{T}, N};
        mode::Symbol = :full, dims = nothing
    ) where {T <: Union{Float32, Float16}, N}
    conv_dims = dims === nothing ? 1 : (dims isa Int ? (dims,) : Tuple(dims))
    return conv_fft(signal, kernel; dims = conv_dims, mode = mode)
end

# Note: Batched convolution for 4D tensors can be added later if needed.
# The current implementation focuses on 2D images which covers most use cases.
