# FFT operations using MPSGraph
# Implements AbstractFFTs.jl interface for MtlArray

using AbstractFFTs
import LinearAlgebra: mul!

export plan_fft, plan_ifft, plan_bfft

# ============================================================================
# FFT Direction Enum
# ============================================================================

abstract type FFTDirection end
struct Forward <: FFTDirection end
struct Inverse <: FFTDirection end
struct Backward <: FFTDirection end  # unnormalized inverse

# ============================================================================
# MtlFFTPlan - AbstractFFTs-compatible plan
# ============================================================================

"""
    MtlFFTPlan{T,K,N} <: AbstractFFTs.Plan{T}

GPU FFT plan for Metal using MPSGraph's fastFourierTransformWithTensor.

# Type Parameters
- `T`: Element type (e.g., ComplexF32)
- `K`: Direction type (Forward, Inverse, or Backward)
- `N`: Number of dimensions

# Fields
- `sz`: Size of the input array
- `region`: Dimensions along which to perform FFT (normalized to Tuple)

# Notes
MPSGraph FFT only supports ComplexF32. Other types will error.
"""
struct MtlFFTPlan{T,K<:FFTDirection,N} <: AbstractFFTs.Plan{T}
    sz::NTuple{N,Int}
    region::Tuple{Vararg{Int}}
end

# Convenience constructors
function MtlFFTPlan{T,K}(sz::NTuple{N,Int}, region) where {T,K<:FFTDirection,N}
    # Normalize region to tuple
    normalized_region = region isa Integer ? (Int(region),) : Tuple(Int.(region))
    # Validate region
    for r in normalized_region
        1 <= r <= N || throw(ArgumentError("Invalid FFT dimension $r for array with $N dimensions"))
    end
    MtlFFTPlan{T,K,N}(sz, normalized_region)
end

# ============================================================================
# AbstractFFTs Interface Implementation
# ============================================================================

function AbstractFFTs.plan_fft(x::MtlArray{T,N}, region; kwargs...) where {T<:Complex,N}
    T == ComplexF32 || throw(ArgumentError("Metal FFT only supports ComplexF32, got $T"))
    MtlFFTPlan{T,Forward}(size(x), region)
end

function AbstractFFTs.plan_fft(x::MtlArray{T,N}; kwargs...) where {T<:Complex,N}
    plan_fft(x, 1:N; kwargs...)
end

function AbstractFFTs.plan_ifft(x::MtlArray{T,N}, region; kwargs...) where {T<:Complex,N}
    T == ComplexF32 || throw(ArgumentError("Metal FFT only supports ComplexF32, got $T"))
    MtlFFTPlan{T,Inverse}(size(x), region)
end

function AbstractFFTs.plan_ifft(x::MtlArray{T,N}; kwargs...) where {T<:Complex,N}
    plan_ifft(x, 1:N; kwargs...)
end

function AbstractFFTs.plan_bfft(x::MtlArray{T,N}, region; kwargs...) where {T<:Complex,N}
    T == ComplexF32 || throw(ArgumentError("Metal FFT only supports ComplexF32, got $T"))
    MtlFFTPlan{T,Backward}(size(x), region)
end

function AbstractFFTs.plan_bfft(x::MtlArray{T,N}; kwargs...) where {T<:Complex,N}
    plan_bfft(x, 1:N; kwargs...)
end

# Plan properties
Base.size(p::MtlFFTPlan) = p.sz
AbstractFFTs.fftdims(p::MtlFFTPlan) = p.region

# ============================================================================
# FFT Descriptor Creation
# ============================================================================

"""
    create_fft_descriptor(; inverse=false, scaling=:none)

Create an MPSGraphFFTDescriptor with the specified parameters.
"""
function create_fft_descriptor(; inverse::Bool=false, scaling::Symbol=:none)
    scaling_mode = if scaling == :none
        MPSGraphFFTScalingModeNone
    elseif scaling == :size
        MPSGraphFFTScalingModeSize
    elseif scaling == :unitary
        MPSGraphFFTScalingModeUnitary
    else
        error("Unknown scaling mode: $scaling. Use :none, :size, or :unitary")
    end

    obj = @objc [MPSGraphFFTDescriptor alloc]::id{MPSGraphFFTDescriptor}
    desc = MPSGraphFFTDescriptor(obj)
    desc.inverse = inverse
    desc.scalingMode = scaling_mode
    return desc
end

# ============================================================================
# FFT Operation Wrapper
# ============================================================================

"""
    fastFourierTransformWithTensor(graph, tensor, axes, descriptor, name="fft")

Wrap Apple's MPSGraph fastFourierTransformWithTensor method.
"""
function fastFourierTransformWithTensor(graph::MPSGraph,
                                        tensor::MPSGraphTensor,
                                        axes::NSArray,
                                        descriptor::MPSGraphFFTDescriptor,
                                        name::String="fft")
    obj = @objc [graph::id{MPSGraph} fastFourierTransformWithTensor:tensor::id{MPSGraphTensor}
                                axes:axes::id{NSArray}
                                descriptor:descriptor::id{MPSGraphFFTDescriptor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

# ============================================================================
# Plan Execution
# ============================================================================

function Base.:*(p::MtlFFTPlan{T,K,N}, x::MtlArray{T,N}) where {T,K,N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    y = similar(x)
    mul!(y, p, x)
    return y
end

function mul!(y::MtlArray{T,N}, p::MtlFFTPlan{T,K,N}, x::MtlArray{T,N}) where {T,K,N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    @assert size(y) == size(x) "Output size $(size(y)) does not match input size $(size(x))"

    # Determine if this is an inverse transform
    inverse = K <: Inverse || K <: Backward
    # For Inverse, we need to scale by the total FFT size (product of all FFT dimensions)
    # For Backward (bfft), no scaling
    needs_scaling = K <: Inverse

    @autoreleasepool begin
        _execute_fft!(y, x, p.region, inverse)
    end

    # Apply scaling for ifft: divide by product of FFT dimension sizes
    if needs_scaling
        scale_factor = T(1 / prod(p.sz[d] for d in p.region))
        y .*= scale_factor
    end

    return y
end

"""
Internal FFT execution - processes one axis at a time for multi-axis FFT.
"""
function _execute_fft!(y::MtlArray{T,N}, x::MtlArray{T,N}, region::Tuple,
                       inverse::Bool) where {T,N}
    # For multi-axis FFT, we need to apply sequentially
    # First copy x to y, then transform y in-place through each axis
    if y !== x
        copyto!(y, x)
    end

    for axis in region
        _execute_single_axis_fft!(y, axis, inverse)
    end

    return y
end

"""
Execute FFT along a single axis (no scaling - scaling is handled by caller).
"""
function _execute_single_axis_fft!(buf::MtlArray{T,N}, axis::Int,
                                    inverse::Bool) where {T,N}
    graph = MPSGraph()

    # Create placeholder tensor
    placeholder = placeholderTensor(graph, size(buf), T)

    # Create FFT descriptor - never use MPSGraph scaling, we handle it ourselves
    fft_desc = create_fft_descriptor(inverse=inverse, scaling=:none)

    # Convert Julia 1-indexed axis to Metal 0-indexed axis
    # Due to shape reversal in placeholderTensor, we need to compute the correct axis
    # Julia axis i -> Metal axis (N - i) for N-dimensional array
    metal_axis = N - axis
    axes = NSArray([NSNumber(Int32(metal_axis))])

    # Create FFT operation
    fft_result = fastFourierTransformWithTensor(graph, placeholder, axes, fft_desc, "fft")

    # Create feed dictionary
    feeds = NSDictionary(Dict{MPSGraphTensor, MPSGraphTensorData}(
        placeholder => MPSGraphTensorData(buf)
    ))

    # Create result dictionary (in-place output)
    results = NSDictionary(Dict{MPSGraphTensor, MPSGraphTensorData}(
        fft_result => MPSGraphTensorData(buf)
    ))

    # Execute
    cmdbuf = MPS.MPSCommandBuffer(Metal.global_queue(Metal.device()))
    MPS.encode!(cmdbuf, graph, feeds, results, nil, default_exec_desc())
    Metal.commit!(cmdbuf)
    Metal.wait_completed(cmdbuf)

    return buf
end

# ============================================================================
# Convenience Functions (AbstractFFTs will dispatch to these via plans)
# ============================================================================

# These are automatically provided by AbstractFFTs when we implement the plan interface:
# - fft(x, dims) -> plan_fft(x, dims) * x
# - ifft(x, dims) -> plan_ifft(x, dims) * x
# - bfft(x, dims) -> plan_bfft(x, dims) * x
