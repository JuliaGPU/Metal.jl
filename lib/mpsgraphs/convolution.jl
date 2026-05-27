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

export conv, conv_fft, conv_fft!, conv_fft_fused, xcorr
export plan_conv_fft, ConvFFTPlan
export get_cached_conv_plan, clear_conv_plan_cache!, clear_fused_conv_cache!

# ============================================================================
# Helper Functions
# ============================================================================

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
end

"""
    _conv_output_size(signal_size, kernel_size, mode)

Compute the output size for convolution based on mode.
"""
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

"""
    _extract_conv_result(result, output_size, full_size, mode)

Extract the appropriate portion of the convolution result based on mode.
"""
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

# ============================================================================
# Convolution Plan (for repeated convolutions with same sizes)
# ============================================================================

"""
    ConvFFTPlan{T, N}

Pre-computed FFT convolution plan for efficient repeated convolutions.

When you need to convolve many signals with the same kernel, or perform
multiple convolutions with arrays of the same shape, creating a plan
avoids redundant allocations and FFT setup.

# Fields (internal)
- Pre-allocated padded signal/kernel buffers
- Pre-computed kernel FFT (when kernel is provided at plan time)
- Cached FFT size and output parameters

# Example
```julia
# Create plan for 1D convolution
signal_size = 1000
kernel_size = 100
plan = plan_conv_fft(signal_size, kernel_size, Float32)

# Use plan for multiple convolutions
for signal in signals
    result = plan * signal  # Uses pre-allocated buffers
end

# Or with pre-computed kernel FFT
kernel = MtlVector(randn(Float32, 100))
plan_with_kernel = plan_conv_fft(1000, kernel)
for signal in signals
    result = plan_with_kernel * signal  # Even faster - kernel FFT cached
end
```
"""
struct ConvFFTPlan{T, N, IsReal}
    signal_size::NTuple{N, Int}
    kernel_size::NTuple{N, Int}
    output_size::NTuple{N, Int}
    full_size::NTuple{N, Int}
    fft_size::NTuple{N, Int}
    dims::Tuple{Vararg{Int}}
    mode::Symbol
    # Pre-allocated buffers
    signal_padded::MtlArray{T, N}
    kernel_padded::MtlArray{T, N}
    # Pre-computed kernel FFT (if kernel was provided)
    kernel_fft::Union{Nothing, MtlArray{<:Complex, N}}
end

# Plan cache for automatic reuse
const _CONV_PLAN_CACHE = Dict{UInt64, ConvFFTPlan}()
const _CONV_PLAN_CACHE_LOCK = ReentrantLock()
const _CONV_PLAN_CACHE_MAX_SIZE = 32

"""
    _conv_plan_cache_key(signal_size, kernel_size, T, dims, mode)

Generate a unique key for caching convolution plans.
"""
function _conv_plan_cache_key(
        signal_size::NTuple{N, Int}, kernel_size::NTuple{N, Int},
        ::Type{T}, dims::Tuple, mode::Symbol
    ) where {N, T}
    return hash((signal_size, kernel_size, T, dims, mode))
end

"""
    plan_conv_fft(signal_size::Int, kernel_size::Int, T::Type; mode=:full)

Create an FFT convolution plan for 1D arrays of the specified sizes and element type.

# Arguments
- `signal_size`: Length of signals to convolve
- `kernel_size`: Length of kernels to convolve
- `T`: Element type (Float32, Float16, ComplexF32, or ComplexF16)
- `mode`: Output mode (`:full`, `:same`, or `:valid`)

# Returns
A `ConvFFTPlan` that can be used with `*` or `mul!` for efficient convolution.

# Example
```julia
plan = plan_conv_fft(1000, 100, Float32)
signal = MtlVector(randn(Float32, 1000))
kernel = MtlVector(randn(Float32, 100))
result = conv_fft(plan, signal, kernel)  # Uses pre-allocated buffers
```
"""
function plan_conv_fft(
        signal_size::Int, kernel_size::Int, ::Type{T}; mode::Symbol = :full
    ) where {T <: Union{Float32, Float16}}
    return _create_conv_plan((signal_size,), (kernel_size,), T, (1,), mode, true)
end

function plan_conv_fft(
        signal_size::Int, kernel_size::Int, ::Type{Complex{T}}; mode::Symbol = :full
    ) where {T <: Union{Float32, Float16}}
    return _create_conv_plan((signal_size,), (kernel_size,), Complex{T}, (1,), mode, false)
end

"""
    plan_conv_fft(signal_size::NTuple{N,Int}, kernel_size::NTuple{N,Int}, T::Type; dims=1, mode=:full)

Create an FFT convolution plan for N-dimensional arrays.
"""
function plan_conv_fft(
        signal_size::NTuple{N, Int}, kernel_size::NTuple{N, Int}, ::Type{T};
        dims::Union{Int, Tuple{Vararg{Int}}} = 1, mode::Symbol = :full
    ) where {N, T <: Union{Float32, Float16}}
    dims_tuple = dims isa Int ? (dims,) : Tuple(dims)
    return _create_conv_plan(signal_size, kernel_size, T, dims_tuple, mode, true)
end

function plan_conv_fft(
        signal_size::NTuple{N, Int}, kernel_size::NTuple{N, Int}, ::Type{Complex{T}};
        dims::Union{Int, Tuple{Vararg{Int}}} = 1, mode::Symbol = :full
    ) where {N, T <: Union{Float32, Float16}}
    dims_tuple = dims isa Int ? (dims,) : Tuple(dims)
    return _create_conv_plan(signal_size, kernel_size, Complex{T}, dims_tuple, mode, false)
end

"""
    plan_conv_fft(signal_size, kernel::MtlArray; dims=1, mode=:full)

Create an FFT convolution plan with a pre-computed kernel FFT.

This is the most efficient option when convolving many signals with the same kernel.
The kernel's FFT is computed once at plan creation time.

# Example
```julia
kernel = MtlVector(randn(Float32, 100))
plan = plan_conv_fft(1000, kernel)

# Each convolution now only requires one FFT (signal) instead of two
for signal in signals
    result = conv_fft(plan, signal)
end
```
"""
function plan_conv_fft(
        signal_size::Int, kernel::MtlVector{T}; mode::Symbol = :full
    ) where {T <: Union{Float32, Float16}}
    plan = _create_conv_plan((signal_size,), (length(kernel),), T, (1,), mode, true)
    return _precompute_kernel_fft!(plan, kernel)
end

function plan_conv_fft(
        signal_size::Int, kernel::MtlVector{Complex{T}}; mode::Symbol = :full
    ) where {T <: Union{Float32, Float16}}
    plan = _create_conv_plan((signal_size,), (length(kernel),), Complex{T}, (1,), mode, false)
    return _precompute_kernel_fft!(plan, kernel)
end

function plan_conv_fft(
        signal_size::NTuple{N, Int}, kernel::MtlArray{T, N};
        dims::Union{Int, Tuple{Vararg{Int}}} = 1, mode::Symbol = :full
    ) where {N, T <: Union{Float32, Float16}}
    dims_tuple = dims isa Int ? (dims,) : Tuple(dims)
    plan = _create_conv_plan(signal_size, size(kernel), T, dims_tuple, mode, true)
    return _precompute_kernel_fft!(plan, kernel)
end

function plan_conv_fft(
        signal_size::NTuple{N, Int}, kernel::MtlArray{Complex{T}, N};
        dims::Union{Int, Tuple{Vararg{Int}}} = 1, mode::Symbol = :full
    ) where {N, T <: Union{Float32, Float16}}
    dims_tuple = dims isa Int ? (dims,) : Tuple(dims)
    plan = _create_conv_plan(signal_size, size(kernel), Complex{T}, dims_tuple, mode, false)
    return _precompute_kernel_fft!(plan, kernel)
end

"""
Internal function to create a convolution plan.
"""
function _create_conv_plan(
        signal_size::NTuple{N, Int}, kernel_size::NTuple{N, Int},
        ::Type{T}, dims::Tuple{Vararg{Int}}, mode::Symbol, is_real::Bool
    ) where {N, T}
    # Validate dimensions
    for d in dims
        1 <= d <= N ||
            throw(ArgumentError("Invalid dimension $d for array with $N dimensions"))
    end

    # Compute sizes
    full_size = ntuple(N) do i
        if i in dims
            signal_size[i] + kernel_size[i] - 1
        else
            signal_size[i]
        end
    end

    output_size = ntuple(N) do i
        if i in dims
            _conv_output_size(signal_size[i], kernel_size[i], mode)
        else
            signal_size[i]
        end
    end

    fft_size = ntuple(N) do i
        if i in dims
            nextfastfft(full_size[i])
        else
            signal_size[i]
        end
    end

    # Allocate buffers
    signal_padded = MtlArray{T}(undef, fft_size)
    kernel_padded = MtlArray{T}(undef, fft_size)

    # Zero-fill once (will be overwritten in parts during convolution)
    fill!(signal_padded, zero(T))
    fill!(kernel_padded, zero(T))

    return ConvFFTPlan{T, N, is_real}(
        signal_size, kernel_size, output_size, full_size, fft_size,
        dims, mode, signal_padded, kernel_padded, nothing
    )
end

"""
Internal function to pre-compute kernel FFT for a plan.
"""
function _precompute_kernel_fft!(plan::ConvFFTPlan{T, N, IsReal}, kernel::MtlArray{T, N}) where {T, N, IsReal}
    # Copy kernel to padded buffer
    kernel_ranges = ntuple(i -> 1:plan.kernel_size[i], N)
    fill!(plan.kernel_padded, zero(T))
    plan.kernel_padded[kernel_ranges...] = kernel

    # Compute kernel FFT
    if IsReal
        kernel_fft = rfft(plan.kernel_padded, plan.dims)
    else
        kernel_fft = fft(plan.kernel_padded, plan.dims)
    end

    # Store in a new plan (since structs are immutable, we create a new one)
    # Note: This is a bit awkward, but avoids making the struct mutable
    return ConvFFTPlan{T, N, IsReal}(
        plan.signal_size, plan.kernel_size, plan.output_size,
        plan.full_size, plan.fft_size, plan.dims, plan.mode,
        plan.signal_padded, plan.kernel_padded, kernel_fft
    )
end

"""
    conv_fft(plan::ConvFFTPlan, signal, kernel)

Perform convolution using a pre-computed plan.

Uses pre-allocated buffers from the plan, avoiding allocations.
"""
function conv_fft(
        plan::ConvFFTPlan{T, N, true}, signal::MtlArray{T, N}, kernel::MtlArray{T, N}
    ) where {T <: Union{Float32, Float16}, N}
    @assert size(signal) == plan.signal_size "Signal size $(size(signal)) doesn't match plan $(plan.signal_size)"
    @assert size(kernel) == plan.kernel_size "Kernel size $(size(kernel)) doesn't match plan $(plan.kernel_size)"

    # Copy signal to padded buffer
    signal_ranges = ntuple(i -> 1:plan.signal_size[i], N)
    fill!(plan.signal_padded, zero(T))
    plan.signal_padded[signal_ranges...] = signal

    # FFT signal
    S = rfft(plan.signal_padded, plan.dims)

    # Kernel FFT (use cached if available, otherwise compute)
    K = if plan.kernel_fft !== nothing
        plan.kernel_fft
    else
        kernel_ranges = ntuple(i -> 1:plan.kernel_size[i], N)
        fill!(plan.kernel_padded, zero(T))
        plan.kernel_padded[kernel_ranges...] = kernel
        rfft(plan.kernel_padded, plan.dims)
    end

    # Multiply and inverse FFT
    Y = S .* K
    first_dim = minimum(plan.dims)
    y = irfft(Y, plan.fft_size[first_dim], plan.dims)

    # Extract result
    if N == 1
        return _extract_conv_result(y, plan.output_size[1], plan.full_size[1], plan.mode)
    else
        return _extract_conv_result(y, plan.output_size, plan.full_size, plan.mode, plan.dims)
    end
end

# Complex version
function conv_fft(
        plan::ConvFFTPlan{Complex{T}, N, false}, signal::MtlArray{Complex{T}, N},
        kernel::MtlArray{Complex{T}, N}
    ) where {T <: Union{Float32, Float16}, N}
    @assert size(signal) == plan.signal_size "Signal size $(size(signal)) doesn't match plan $(plan.signal_size)"
    @assert size(kernel) == plan.kernel_size "Kernel size $(size(kernel)) doesn't match plan $(plan.kernel_size)"

    # Copy signal to padded buffer
    signal_ranges = ntuple(i -> 1:plan.signal_size[i], N)
    fill!(plan.signal_padded, zero(Complex{T}))
    plan.signal_padded[signal_ranges...] = signal

    # FFT signal
    S = fft(plan.signal_padded, plan.dims)

    # Kernel FFT (use cached if available)
    K = if plan.kernel_fft !== nothing
        plan.kernel_fft
    else
        kernel_ranges = ntuple(i -> 1:plan.kernel_size[i], N)
        fill!(plan.kernel_padded, zero(Complex{T}))
        plan.kernel_padded[kernel_ranges...] = kernel
        fft(plan.kernel_padded, plan.dims)
    end

    # Multiply and inverse FFT
    Y = S .* K
    y = ifft(Y, plan.dims)

    # Extract result
    if N == 1
        return _extract_conv_result(y, plan.output_size[1], plan.full_size[1], plan.mode)
    else
        return _extract_conv_result(y, plan.output_size, plan.full_size, plan.mode, plan.dims)
    end
end

"""
    conv_fft(plan::ConvFFTPlan, signal)

Perform convolution using a plan with pre-computed kernel FFT.

This is the fastest option - only one FFT (for the signal) is needed.
"""
function conv_fft(
        plan::ConvFFTPlan{T, N, true}, signal::MtlArray{T, N}
    ) where {T <: Union{Float32, Float16}, N}
    plan.kernel_fft === nothing &&
        throw(ArgumentError("Plan has no pre-computed kernel FFT. Use conv_fft(plan, signal, kernel) or create plan with kernel."))

    @assert size(signal) == plan.signal_size "Signal size $(size(signal)) doesn't match plan $(plan.signal_size)"

    # Copy signal to padded buffer
    signal_ranges = ntuple(i -> 1:plan.signal_size[i], N)
    fill!(plan.signal_padded, zero(T))
    plan.signal_padded[signal_ranges...] = signal

    # FFT signal and multiply with cached kernel FFT
    S = rfft(plan.signal_padded, plan.dims)
    Y = S .* plan.kernel_fft

    # Inverse FFT
    first_dim = minimum(plan.dims)
    y = irfft(Y, plan.fft_size[first_dim], plan.dims)

    # Extract result
    if N == 1
        return _extract_conv_result(y, plan.output_size[1], plan.full_size[1], plan.mode)
    else
        return _extract_conv_result(y, plan.output_size, plan.full_size, plan.mode, plan.dims)
    end
end

# Complex version with pre-computed kernel
function conv_fft(
        plan::ConvFFTPlan{Complex{T}, N, false}, signal::MtlArray{Complex{T}, N}
    ) where {T <: Union{Float32, Float16}, N}
    plan.kernel_fft === nothing &&
        throw(ArgumentError("Plan has no pre-computed kernel FFT. Use conv_fft(plan, signal, kernel) or create plan with kernel."))

    @assert size(signal) == plan.signal_size "Signal size $(size(signal)) doesn't match plan $(plan.signal_size)"

    # Copy signal to padded buffer
    signal_ranges = ntuple(i -> 1:plan.signal_size[i], N)
    fill!(plan.signal_padded, zero(Complex{T}))
    plan.signal_padded[signal_ranges...] = signal

    # FFT signal and multiply with cached kernel FFT
    S = fft(plan.signal_padded, plan.dims)
    Y = S .* plan.kernel_fft

    # Inverse FFT
    y = ifft(Y, plan.dims)

    # Extract result
    if N == 1
        return _extract_conv_result(y, plan.output_size[1], plan.full_size[1], plan.mode)
    else
        return _extract_conv_result(y, plan.output_size, plan.full_size, plan.mode, plan.dims)
    end
end

"""
    get_cached_conv_plan(signal_size, kernel_size, T; dims=1, mode=:full)

Get or create a cached convolution plan for the given parameters.

Plans are cached globally and reused for repeated convolutions with the same sizes.
This is useful when array sizes are known in advance and convolutions are repeated.

# Thread Safety
Plan cache access is thread-safe using a lock.

# Cache Size
The cache holds up to $_CONV_PLAN_CACHE_MAX_SIZE plans. When full, the oldest plan
is evicted (FIFO).
"""
function get_cached_conv_plan(
        signal_size::NTuple{N, Int}, kernel_size::NTuple{N, Int}, ::Type{T};
        dims::Union{Int, Tuple{Vararg{Int}}} = 1, mode::Symbol = :full
    ) where {N, T}
    dims_tuple = dims isa Int ? (dims,) : Tuple(dims)
    key = _conv_plan_cache_key(signal_size, kernel_size, T, dims_tuple, mode)

    lock(_CONV_PLAN_CACHE_LOCK) do
        if haskey(_CONV_PLAN_CACHE, key)
            return _CONV_PLAN_CACHE[key]
        else
            # Create new plan
            is_real = T <: Real
            plan = _create_conv_plan(signal_size, kernel_size, T, dims_tuple, mode, is_real)

            # Evict oldest if cache is full
            if length(_CONV_PLAN_CACHE) >= _CONV_PLAN_CACHE_MAX_SIZE
                # Simple FIFO eviction - delete first key
                first_key = first(keys(_CONV_PLAN_CACHE))
                delete!(_CONV_PLAN_CACHE, first_key)
            end

            _CONV_PLAN_CACHE[key] = plan
            return plan
        end
    end
end

# 1D convenience
function get_cached_conv_plan(
        signal_size::Int, kernel_size::Int, ::Type{T}; mode::Symbol = :full
    ) where {T}
    return get_cached_conv_plan((signal_size,), (kernel_size,), T; dims = 1, mode = mode)
end

"""
    clear_conv_plan_cache!()

Clear the global convolution plan cache, freeing GPU memory.
"""
function clear_conv_plan_cache!()
    lock(_CONV_PLAN_CACHE_LOCK) do
        empty!(_CONV_PLAN_CACHE)
    end
    return nothing
end

# ============================================================================
# Fused MPSGraph Convolution (Single Graph Execution)
# ============================================================================

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

# Thread-safe cache for fused convolution graphs
const _fused_conv_graph_cache = Dict{FusedConvGraphKey, CachedFusedConvGraph}()
const _fused_conv_graph_cache_lock = ReentrantLock()

# ============================================================================
# Buffer Pooling for Fused Convolution
# ============================================================================

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

# Thread-safe buffer pool
const _fused_conv_buffer_pool = Dict{BufferPoolKey, CachedFusedConvBuffers}()
const _fused_conv_buffer_pool_lock = ReentrantLock()

"""
Get or create cached buffers for fused convolution.
Returns pre-allocated padded signal, kernel, and output buffers.
"""
function _get_cached_buffers(fft_sizes::NTuple{N, Int}, ::Type{T}) where {N, T}
    key = BufferPoolKey(fft_sizes, T)
    cached = get(_fused_conv_buffer_pool, key, nothing)
    if cached !== nothing
        return cached
    end
    lock(_fused_conv_buffer_pool_lock) do
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
    end
    return nothing
end

# ============================================================================
# Fast Padding Kernel (Single kernel for copy + zero-pad)
# ============================================================================

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

"""
Copy source array to destination with zero-padding using a single GPU kernel.
Much faster than separate copyto! + broadcast operations (~4.5x speedup).
"""
function _fast_pad_copy!(dest::MtlVector{T}, src::MtlVector{T}) where T
    src_len = length(src)
    dest_len = length(dest)
    threads = min(256, dest_len)
    groups = cld(dest_len, threads)
    @metal threads=threads groups=groups _pad_copy_kernel_1d!(dest, src, src_len)
    return dest
end

# N-D version: pad along all dimensions (linearized)
function _pad_copy_kernel_nd!(dest, src, src_linear_len)
    i = thread_position_in_grid_1d()
    if i <= src_linear_len
        @inbounds dest[i] = src[i]
    elseif i <= length(dest)
        @inbounds dest[i] = zero(eltype(dest))
    end
    return
end

"""
Fast N-D padding: copies source to destination buffer with zero-padding.
For N-D arrays, this only works correctly when source fits contiguously at the start.
For general N-D padding with different sizes per dimension, use _fast_pad_copy_nd!.
"""
function _fast_pad_copy_contiguous!(dest::MtlArray{T, N}, src::MtlArray{T, N}) where {T, N}
    src_len = length(src)
    dest_len = length(dest)
    threads = min(256, dest_len)
    groups = cld(dest_len, threads)
    @metal threads=threads groups=groups _pad_copy_kernel_nd!(dest, src, src_len)
    return dest
end

# ============================================================================
# In-Place Padding Graphs (Zero-copy padding inside MPSGraph)
# ============================================================================

# Cache key for graphs with inline padding
struct InlinePadConvGraphKey
    signal_sizes::Tuple{Vararg{Int}}  # Original signal shape
    kernel_sizes::Tuple{Vararg{Int}}  # Original kernel shape
    fft_sizes::Tuple{Vararg{Int}}     # Padded FFT size
    output_sizes::Tuple{Vararg{Int}}  # Output shape
    eltype::DataType
end

# Cached graph with inline padding
struct CachedInlinePadConvGraph
    graph::MPSGraph
    signal_placeholder::MPSGraphTensor
    kernel_placeholder::MPSGraphTensor
    result::MPSGraphTensor
end

const _inline_pad_conv_cache = Dict{InlinePadConvGraphKey, CachedInlinePadConvGraph}()
const _inline_pad_conv_cache_lock = ReentrantLock()

"""
Helper to create a zeros tensor of a given shape inside MPSGraph.
Uses constantWithScalar + broadcastTensor.
"""
function _create_zeros_tensor(graph::MPSGraph, shape::NTuple{N, Int}, ::Type{T}) where {N, T}
    zero_scalar = constantWithScalar(graph, T(0), T)
    mps_shape = MPSShape([NSNumber(Int32(s)) for s in reverse(shape)])
    return broadcastTensor(graph, zero_scalar, mps_shape, "zeros_$(join(shape, 'x'))")
end

"""
Build a fused N-D convolution graph with inline padding.
Accepts unpadded signal and kernel, pads inside the graph using concat.
"""
function _build_inline_pad_conv_graph_nd(
        signal_sizes::NTuple{N, Int}, kernel_sizes::NTuple{N, Int},
        fft_sizes::NTuple{N, Int}, ::Type{T}
    ) where {N, T <: Union{Float32, Float16}}
    graph = MPSGraph()

    # Placeholders for UNPADDED inputs
    signal_ph = placeholderTensor(graph, signal_sizes, T)
    kernel_ph = placeholderTensor(graph, kernel_sizes, T)

    # Create zeros tensors for padding (for each dimension)
    # Pad signal: concat(signal, zeros) along each dimension
    signal_padded = signal_ph
    for dim in 1:N
        pad_size = fft_sizes[dim] - signal_sizes[dim]
        if pad_size > 0
            # Create zeros for this dimension
            # Shape: same as current signal_padded but with pad_size in this dimension
            current_shape = ntuple(N) do i
                if i == dim
                    pad_size
                elseif i < dim
                    fft_sizes[i]  # Already padded dimensions
                else
                    signal_sizes[i]  # Not yet padded dimensions
                end
            end
            zeros_tensor = _create_zeros_tensor(graph, current_shape, T)
            # Concat along this dimension (Metal uses reversed axis order)
            metal_dim = N - dim  # Convert Julia dim to Metal axis
            tensors = NSArray([signal_padded, zeros_tensor])
            signal_padded = concatTensors(graph, tensors, metal_dim, "signal_pad_dim$(dim)")
        end
    end

    # Pad kernel similarly
    kernel_padded = kernel_ph
    for dim in 1:N
        pad_size = fft_sizes[dim] - kernel_sizes[dim]
        if pad_size > 0
            current_shape = ntuple(N) do i
                if i == dim
                    pad_size
                elseif i < dim
                    fft_sizes[i]
                else
                    kernel_sizes[i]
                end
            end
            zeros_tensor = _create_zeros_tensor(graph, current_shape, T)
            metal_dim = N - dim
            tensors = NSArray([kernel_padded, zeros_tensor])
            kernel_padded = concatTensors(graph, tensors, metal_dim, "kernel_pad_dim$(dim)")
        end
    end

    # Now proceed with FFT convolution on padded tensors
    fft_desc_fwd = MPSGraphFFTDescriptor(inverse = false)
    axes = NSArray([NSNumber(Int32(i)) for i in (N-1):-1:0])

    signal_fft = realToHermiteanFFTWithTensor(graph, signal_padded, axes, fft_desc_fwd, "signal_rfft")
    kernel_fft = realToHermiteanFFTWithTensor(graph, kernel_padded, axes, fft_desc_fwd, "kernel_rfft")

    product = multiplicationWithPrimaryTensor(graph, signal_fft, kernel_fft, "freq_multiply")

    total_size = prod(fft_sizes)
    fft_desc_inv = MPSGraphFFTDescriptor(inverse = true)
    fft_desc_inv.roundToOddHermitean = isodd(fft_sizes[1])
    result_unscaled = HermiteanToRealFFTWithTensor(graph, product, axes, fft_desc_inv, "irfft")

    scale_factor = constantWithScalar(graph, T(1) / T(total_size), T)
    result_scaled = multiplicationWithPrimaryTensor(graph, result_unscaled, scale_factor, "scale")

    return CachedInlinePadConvGraph(graph, signal_ph, kernel_ph, result_scaled)
end

"""
Get or create a cached inline-padding convolution graph.
"""
function _get_cached_inline_pad_conv_graph(key::InlinePadConvGraphKey)
    cached = get(_inline_pad_conv_cache, key, nothing)
    if cached !== nothing
        return cached
    end
    lock(_inline_pad_conv_cache_lock) do
        cached = get(_inline_pad_conv_cache, key, nothing)
        if cached !== nothing
            return cached
        end
        cached = _build_inline_pad_conv_graph_nd(
            key.signal_sizes, key.kernel_sizes, key.fft_sizes, key.eltype)
        _inline_pad_conv_cache[key] = cached
        return cached
    end
end

"""
    conv_fft_inline_pad(signal::MtlArray{T,N}, kernel::MtlArray{T,N}; mode=:full)

Compute N-D convolution using a fused MPSGraph with inline padding.
Eliminates Julia-side copy/zero kernel launches by moving padding into the graph.
"""
function conv_fft_inline_pad(
        signal::MtlArray{T, N}, kernel::MtlArray{T, N}; mode::Symbol = :full
    ) where {T <: Union{Float32, Float16}, N}
    signal_sizes = size(signal)
    kernel_sizes = size(kernel)

    # Compute sizes
    full_sizes = ntuple(i -> signal_sizes[i] + kernel_sizes[i] - 1, N)
    output_sizes = ntuple(i -> _conv_output_size(signal_sizes[i], kernel_sizes[i], mode), N)
    fft_sizes = ntuple(i -> nextfastfft(full_sizes[i]), N)

    # Get cached graph with inline padding
    key = InlinePadConvGraphKey(signal_sizes, kernel_sizes, fft_sizes, output_sizes, T)
    cached = _get_cached_inline_pad_conv_graph(key)

    # Get output buffer from pool
    buffers = _get_cached_buffers(fft_sizes, T)
    output = buffers.output

    # Execute graph - no Julia-side padding needed!
    @autoreleasepool begin
        feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
            cached.signal_placeholder => MPSGraphTensorData(signal),
            cached.kernel_placeholder => MPSGraphTensorData(kernel)
        )

        resultdict = Dict{MPSGraphTensor, MPSGraphTensorData}(
            cached.result => MPSGraphTensorData(output)
        )

        cmdbuf = MPSCommandBuffer(Metal.global_queue(current_device()))
        encode!(cmdbuf, cached.graph, NSDictionary(feeds), NSDictionary(resultdict), nil, default_exec_desc())
        commit!(cmdbuf)
        wait_completed(cmdbuf)

        return _extract_conv_result_nd(output, output_sizes, full_sizes, mode)
    end
end

"""
    clear_inline_pad_conv_cache!()

Clear the inline padding convolution graph cache.
"""
function clear_inline_pad_conv_cache!()
    lock(_inline_pad_conv_cache_lock) do
        empty!(_inline_pad_conv_cache)
    end
    return nothing
end

"""
Build a fused N-D convolution graph: rfft(signal) * rfft(kernel) → irfft → scale
All operations in a single MPSGraph for minimal command submission overhead.
Works for any dimensionality (1D, 2D, 3D, etc).
"""
function _build_fused_conv_graph_nd(fft_sizes::NTuple{N, Int}, ::Type{T}) where {N, T <: Union{Float32, Float16}}
    graph = MPSGraph()

    # Placeholders for padded signal and kernel (same shape)
    signal_ph = placeholderTensor(graph, fft_sizes, T)
    kernel_ph = placeholderTensor(graph, fft_sizes, T)

    # FFT descriptor for forward transform
    fft_desc_fwd = MPSGraphFFTDescriptor(inverse = false)

    # Metal uses reversed axis ordering: axis 0 in Metal = last axis in Julia
    # For N-D, we transform all dimensions
    axes = NSArray([NSNumber(Int32(i)) for i in (N-1):-1:0])

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

"""
Get or create a cached fused convolution graph.
"""
function _get_cached_fused_conv_graph(key::FusedConvGraphKey)
    cached = get(_fused_conv_graph_cache, key, nothing)
    if cached !== nothing
        return cached
    end
    lock(_fused_conv_graph_cache_lock) do
        cached = get(_fused_conv_graph_cache, key, nothing)
        if cached !== nothing
            return cached
        end
        # Build N-D fused graph
        cached = _build_fused_conv_graph_nd(key.signal_fft_size, key.eltype)
        _fused_conv_graph_cache[key] = cached
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
        wait_completed(cmdbuf)

        # Extract appropriate region based on mode (must copy since output buffer is reused)
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
    end
    clear_fused_conv_buffer_pool!()
    return nothing
end

# Export the new function
# (added to exports at top of file)

# ============================================================================
# Efficient Padding Helpers
# ============================================================================

"""
    _zero_padding_regions!(arr, data_sizes, padded_sizes, dims)

Zero only the padding regions of an N-D array, avoiding unnecessary writes.
For each dimension in `dims`, zeros elements from (data_size+1) to padded_size.
"""
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
                    (data_sizes[i]+1):padded_sizes[i]
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

# ============================================================================
# 1D FFT Convolution (Real Inputs - Optimized)
# ============================================================================

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
    return conv_fft_fused(signal, kernel; mode=mode)
end

# ============================================================================
# 1D FFT Convolution (Complex Inputs)
# ============================================================================

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
        @view(signal_padded[(ns+1):nfft]) .= zero(Complex{T})
    end
    if nk < nfft
        @view(kernel_padded[(nk+1):nfft]) .= zero(Complex{T})
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

# ============================================================================
# N-D FFT Convolution (along specified dimensions)
# ============================================================================

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
        return conv_fft_fused(signal, kernel; mode=mode)
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

# ============================================================================
# Cross-correlation
# ============================================================================

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

# ============================================================================
# In-place convolution (output pre-allocated)
# ============================================================================

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

# ============================================================================
# MPS Direct Convolution (for small kernels)
# ============================================================================
#
# Uses MPSGraph's convolution2D operation for direct (non-FFT) convolution.
# This is optimized for small kernels (3×3, 5×5, 7×7) where FFT overhead dominates.
#
# Note: MPSGraph convolution expects 4D tensors in NHWC or NCHW format:
# - N = batch size
# - H = height
# - W = width
# - C = channels
#
# For signal processing, we treat 2D arrays as single-channel images with batch size 1.

export conv_direct, imfilter

"""
    conv_direct(image::MtlMatrix, kernel::MtlMatrix; mode=:same, padding=:zeros)

Compute 2D convolution using MPS direct convolution (optimized for small kernels).

This function is optimized for small kernels (3×3, 5×5, 7×7) where it outperforms
FFT-based convolution. For large kernels, use `conv_fft` instead.

# Arguments
- `image`: 2D input image (H×W)
- `kernel`: 2D convolution kernel (Kh×Kw)
- `mode`: Output size mode
  - `:same` (default): Output has same size as input
  - `:valid`: Only fully overlapping region
  - `:full`: Full convolution output (not natively supported, falls back to FFT)
- `padding`: Padding type for `:same` mode
  - `:zeros` (default): Zero padding

# Returns
MtlMatrix with the convolution result.

# Example
```julia
image = MtlMatrix(randn(Float32, 256, 256))
kernel = MtlMatrix(Float32[
    1 0 -1
    2 0 -2
    1 0 -1
] ./ 8)  # Sobel edge detector
edges = conv_direct(image, kernel)
```

# Notes
- For 3×3 kernels on 256×256 images, expect ~10-50x speedup over FFT
- Kernel is flipped internally to match mathematical convolution definition
- Currently supports Float32 and Float16 only
"""
function conv_direct(
        image::MtlMatrix{T}, kernel::MtlMatrix{T};
        mode::Symbol = :same, padding::Symbol = :zeros
    ) where {T <: Union{Float32, Float16}}
    # For :full mode, fall back to FFT
    if mode == :full
        return conv_fft(image, kernel; dims = (1, 2), mode = :full)
    end

    H, W = size(image)
    Kh, Kw = size(kernel)

    # Validate kernel size (MPS works best with odd-sized kernels)
    if Kh % 2 == 0 || Kw % 2 == 0
        @warn "Even-sized kernels may have unexpected centering. Odd sizes (3×3, 5×5, 7×7) recommended." maxlog = 1
    end

    # Flip kernel for mathematical convolution (MPS does correlation by default)
    kernel_flipped = kernel[end:-1:1, end:-1:1]

    # Compute padding for :same mode
    # Note: MPSGraph padding is (top, bottom) for Y, (left, right) for X
    # In NHWC layout: H is the 2nd dim (padTop/padBottom), W is the 3rd dim (padLeft/padRight)
    if mode == :same
        # Symmetric padding to maintain size
        pad_top = (Kh - 1) ÷ 2
        pad_bottom = Kh - 1 - pad_top
        pad_left = (Kw - 1) ÷ 2
        pad_right = Kw - 1 - pad_left
    elseif mode == :valid
        pad_top = pad_bottom = pad_left = pad_right = 0
    else
        throw(ArgumentError("Unknown mode: $mode. Use :same, :valid, or :full"))
    end

    # Convert 2D arrays to 4D tensors for MPSGraph convolution
    # Due to shape reversal in placeholderTensor (Julia shape is reversed for MPSGraph),
    # we need to create 4D arrays where the Julia dimensions map correctly after reversal.
    #
    # We'll use NHWC layout with shapes that account for the reversal:
    # - Julia shape (a, b, c, d) → MPSGraph shape (d, c, b, a)
    #
    # For NHWC image (N=1, H, W, C=1), MPSGraph expects shape (1, H, W, 1)
    # So Julia must have shape (1, W, H, 1) which after reversal gives MPSGraph (1, H, W, 1)
    #
    # For HWIO kernel (Kh, Kw, Cin=1, Cout=1), MPSGraph expects shape (Kh, Kw, 1, 1)
    # So Julia must have shape (1, 1, Kw, Kh) which after reversal gives MPSGraph (Kh, Kw, 1, 1)

    # Transpose the image (H, W) → (W, H) so that after reshape and reversal it matches
    # Then add batch and channel dimensions
    image_transposed = permutedims(image, (2, 1))  # (W, H)
    image_4d = reshape(image_transposed, 1, W, H, 1)  # Julia: (1, W, H, 1) → MPSGraph: (1, H, W, 1)

    # For kernel: transpose (Kh, Kw) → (Kw, Kh) then reshape
    kernel_transposed = permutedims(kernel_flipped, (2, 1))  # (Kw, Kh)
    kernel_4d = reshape(kernel_transposed, 1, 1, Kw, Kh)  # Julia: (1, 1, Kw, Kh) → MPSGraph: (Kh, Kw, 1, 1)

    # Output size
    if mode == :same
        out_h, out_w = H, W
    else  # :valid
        out_h = H - Kh + 1
        out_w = W - Kw + 1
    end

    # Create output array with reversed dimensions
    # MPSGraph will produce (1, out_h, out_w, 1), which we specify as Julia (1, out_w, out_h, 1)
    output = MtlArray{T}(undef, 1, out_w, out_h, 1)

    # Build and execute MPSGraph
    @autoreleasepool begin
        _conv2d_mpsgraph!(output, image_4d, kernel_4d, pad_top, pad_bottom, pad_left, pad_right)
    end

    # Extract 2D result and transpose back to (H, W)
    result_transposed = reshape(output, out_w, out_h)  # (out_w, out_h)
    return permutedims(result_transposed, (2, 1))  # (out_h, out_w) = (H, W)
end

"""
Internal function to execute MPSGraph 2D convolution.
"""
function _conv2d_mpsgraph!(
        output::MtlArray{T, 4}, image::MtlArray{T, 4}, kernel::MtlArray{T, 4},
        pad_top::Int, pad_bottom::Int, pad_left::Int, pad_right::Int
    ) where {T}
    graph = MPSGraph()

    # Create placeholders
    placeImage = placeholderTensor(graph, size(image), T)
    placeKernel = placeholderTensor(graph, size(kernel), T)

    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        placeImage => MPSGraphTensorData(image),
        placeKernel => MPSGraphTensorData(kernel)
    )

    # Create convolution descriptor
    descriptor = MPSGraphConvolution2DOpDescriptor(;
        strideX = 1, strideY = 1,
        dilationX = 1, dilationY = 1,
        paddingLeft = pad_left, paddingRight = pad_right,
        paddingTop = pad_top, paddingBottom = pad_bottom,
        paddingStyle = MPSGraphPaddingStyleExplicit,
        dataLayout = MPSGraphTensorNamedDataLayoutNHWC,
        weightsLayout = MPSGraphTensorNamedDataLayoutHWIO,
        groups = 1
    )

    # Perform convolution
    convResult = convolution2DWithSourceTensor(graph, placeImage, placeKernel, descriptor, "conv2d")

    # Create result dictionary
    resultdict = Dict{MPSGraphTensor, MPSGraphTensorData}(
        convResult => MPSGraphTensorData(output)
    )

    # Execute
    cmdbuf = MPSCommandBuffer(Metal.global_queue(device()))
    encode!(cmdbuf, graph, NSDictionary(feeds), NSDictionary(resultdict), nil, default_exec_desc())
    commit!(cmdbuf)
    wait_completed(cmdbuf)

    return output
end

"""
    imfilter(image::MtlMatrix, kernel::MtlMatrix)

Apply a filter kernel to an image using direct convolution.

This is a convenience function following the ImageFiltering.jl interface.
It automatically selects between MPS direct convolution (for small kernels)
and FFT convolution (for large kernels).

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
- For kernels ≤ 11×11, uses MPS direct convolution
- For larger kernels, automatically falls back to FFT convolution
- The kernel is centered on each pixel (like ImageFiltering.jl's `imfilter`)
"""
# Threshold for switching between direct and FFT convolution
# MPS direct convolution is faster for small kernels
const _DIRECT_CONV_THRESHOLD = 11

function imfilter(image::MtlMatrix{T}, kernel::MtlMatrix{T}) where {T <: Union{Float32, Float16}}
    Kh, Kw = size(kernel)

    if Kh <= _DIRECT_CONV_THRESHOLD && Kw <= _DIRECT_CONV_THRESHOLD
        return conv_direct(image, kernel; mode = :same)
    else
        return conv_fft(image, kernel; dims = (1, 2), mode = :same)
    end
end

# ============================================================================
# Unified Convolution API (with automatic algorithm selection)
# ============================================================================
#
# The unified `conv()` function automatically selects the best algorithm:
# - For 2D arrays with small kernels: MPS direct convolution (faster)
# - For 2D arrays with large kernels: FFT convolution
# - For 1D arrays: FFT convolution (no MPS direct 1D support)
# - For N-D arrays: FFT convolution along specified dimensions

"""
    conv(signal::MtlArray, kernel::MtlArray; mode=:full, dims=nothing, algorithm=:auto)

Compute linear convolution of `signal` and `kernel` with automatic algorithm selection.

This is the recommended entry point for convolution operations. It automatically
selects between MPS direct convolution (optimized for small kernels) and FFT-based
convolution (better for large kernels or higher dimensions).

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
- `algorithm`: Algorithm selection
  - `:auto` (default): Automatically select best algorithm
  - `:fft`: Force FFT-based convolution
  - `:direct`: Force MPS direct convolution (2D only, small kernels)

# Returns
MtlArray with the convolution result.

# Algorithm Selection (when `algorithm=:auto`)

For **2D matrices** with `:same` or `:valid` mode:
- Kernels ≤ 11×11: Uses MPS direct convolution (~8x faster for 3×3)
- Larger kernels: Uses FFT convolution

For **1D vectors**, **N-D arrays**, or `:full` mode:
- Always uses FFT convolution

# Examples

```julia
using Metal, Metal.MPSGraphs

# 1D signal processing
signal = MtlVector(randn(Float32, 10000))
kernel = MtlVector(Float32[0.25, 0.5, 0.25])  # Simple smoothing
smoothed = conv(signal, kernel; mode=:same)

# 2D image filtering (auto-selects direct convolution)
image = MtlMatrix(randn(Float32, 512, 512))
sobel_x = MtlMatrix(Float32[-1 0 1; -2 0 2; -1 0 1] ./ 8)
edges = conv(image, sobel_x; mode=:same)

# 2D with large kernel (auto-selects FFT)
large_kernel = MtlMatrix(randn(Float32, 33, 33))
result = conv(image, large_kernel; mode=:same)

# Force specific algorithm
result_fft = conv(image, sobel_x; mode=:same, algorithm=:fft)
result_direct = conv(image, sobel_x; mode=:same, algorithm=:direct)
```

# Performance Tips

1. For repeated convolutions with same sizes, use `plan_conv_fft()` or
   `get_cached_conv_plan()` for even better performance with FFT.

2. For small kernels (3×3, 5×5, 7×7), direct convolution is typically
   8-50x faster than FFT.

3. For large kernels (>15×15), FFT becomes more efficient due to O(n log n)
   vs O(n×m) complexity.

# See Also
- `conv_fft`: Force FFT-based convolution
- `conv_direct`: Force MPS direct convolution (2D only)
- `imfilter`: ImageFiltering.jl-compatible API for 2D filtering
- `xcorr`: Cross-correlation
- `plan_conv_fft`: Pre-computed FFT plan for repeated convolutions
"""
function conv(
        signal::MtlVector{T}, kernel::MtlVector{T};
        mode::Symbol = :full, dims = nothing, algorithm::Symbol = :auto
    ) where {T <: Union{Float32, Float16}}
    # 1D always uses FFT (no MPS direct 1D support)
    if algorithm == :direct
        throw(ArgumentError("Direct convolution not supported for 1D arrays. Use :auto or :fft."))
    end
    return conv_fft(signal, kernel; mode = mode)
end

# Complex 1D
function conv(
        signal::MtlVector{Complex{T}}, kernel::MtlVector{Complex{T}};
        mode::Symbol = :full, dims = nothing, algorithm::Symbol = :auto
    ) where {T <: Union{Float32, Float16}}
    if algorithm == :direct
        throw(ArgumentError("Direct convolution not supported for complex 1D arrays. Use :auto or :fft."))
    end
    return conv_fft(signal, kernel; mode = mode)
end

# 2D with automatic algorithm selection
function conv(
        signal::MtlMatrix{T}, kernel::MtlMatrix{T};
        mode::Symbol = :full, dims = nothing, algorithm::Symbol = :auto
    ) where {T <: Union{Float32, Float16}}
    # Determine dims for FFT (default: both dimensions for 2D)
    conv_dims = dims === nothing ? (1, 2) : (dims isa Int ? (dims,) : Tuple(dims))

    # Check if we should use direct convolution
    Kh, Kw = size(kernel)
    use_direct = false

    if algorithm == :auto
        # Auto-select: use direct for small kernels with :same or :valid mode
        # Direct convolution is only supported when convolving all dimensions
        if conv_dims == (1, 2) && mode != :full
            use_direct = Kh <= _DIRECT_CONV_THRESHOLD && Kw <= _DIRECT_CONV_THRESHOLD
        end
    elseif algorithm == :direct
        # User requested direct convolution
        if mode == :full
            @warn "Direct convolution doesn't support :full mode. Falling back to FFT." maxlog = 1
            use_direct = false
        elseif conv_dims != (1, 2)
            throw(ArgumentError("Direct convolution requires convolving all dimensions (dims=(1,2) or nothing)."))
        else
            use_direct = true
        end
    elseif algorithm == :fft
        use_direct = false
    else
        throw(ArgumentError("Unknown algorithm: $algorithm. Use :auto, :fft, or :direct."))
    end

    if use_direct
        return conv_direct(signal, kernel; mode = mode)
    else
        return conv_fft(signal, kernel; dims = conv_dims, mode = mode)
    end
end

# Complex 2D
function conv(
        signal::MtlMatrix{Complex{T}}, kernel::MtlMatrix{Complex{T}};
        mode::Symbol = :full, dims = nothing, algorithm::Symbol = :auto
    ) where {T <: Union{Float32, Float16}}
    if algorithm == :direct
        throw(ArgumentError("Direct convolution not supported for complex arrays. Use :auto or :fft."))
    end
    conv_dims = dims === nothing ? (1, 2) : (dims isa Int ? (dims,) : Tuple(dims))
    return conv_fft(signal, kernel; dims = conv_dims, mode = mode)
end

# N-D generic (N > 2)
function conv(
        signal::MtlArray{T, N}, kernel::MtlArray{T, N};
        mode::Symbol = :full, dims = nothing, algorithm::Symbol = :auto
    ) where {T <: Union{Float32, Float16}, N}
    # N-D always uses FFT
    if algorithm == :direct && N > 2
        throw(ArgumentError("Direct convolution only supported for 2D arrays. Use :auto or :fft."))
    end
    conv_dims = dims === nothing ? 1 : (dims isa Int ? (dims,) : Tuple(dims))
    return conv_fft(signal, kernel; dims = conv_dims, mode = mode)
end

# Complex N-D
function conv(
        signal::MtlArray{Complex{T}, N}, kernel::MtlArray{Complex{T}, N};
        mode::Symbol = :full, dims = nothing, algorithm::Symbol = :auto
    ) where {T <: Union{Float32, Float16}, N}
    if algorithm == :direct
        throw(ArgumentError("Direct convolution not supported for complex arrays. Use :auto or :fft."))
    end
    conv_dims = dims === nothing ? 1 : (dims isa Int ? (dims,) : Tuple(dims))
    return conv_fft(signal, kernel; dims = conv_dims, mode = mode)
end

# Note: Batched convolution for 4D tensors can be added later if needed.
# The current implementation focuses on 2D images which covers most use cases.
