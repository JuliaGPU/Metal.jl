# FFT operations using MPSGraph
# Implements AbstractFFTs.jl interface for MtlArray

using AbstractFFTs
import LinearAlgebra: mul!

export plan_fft, plan_ifft, plan_bfft, plan_rfft, plan_irfft, plan_brfft

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
# Real FFT Plan Types
# ============================================================================

"""
    MtlRFFTPlan{T,K,N} <: AbstractFFTs.Plan{T}

GPU Real FFT plan for Metal using MPSGraph's realToHermiteanFFTWithTensor.

For rfft: Real input → Complex output with size n÷2+1 in the last transformed dimension.
For irfft/brfft: Complex input → Real output.

# Type Parameters
- `T`: Element type of the *input* (Float32 for rfft, ComplexF32 for irfft)
- `K`: Direction type (Forward for rfft, Inverse for irfft, Backward for brfft)
- `N`: Number of dimensions

# Fields
- `sz`: Size of the input array
- `osz`: Size of the output array
- `region`: Dimensions along which to perform FFT (normalized to Tuple)
"""
struct MtlRFFTPlan{T,K<:FFTDirection,N} <: AbstractFFTs.Plan{T}
    sz::NTuple{N,Int}   # input size
    osz::NTuple{N,Int}  # output size
    region::Tuple{Vararg{Int}}
end

# Constructor for rfft (real → complex)
function MtlRFFTPlan{T,Forward}(sz::NTuple{N,Int}, region) where {T<:Real,N}
    normalized_region = region isa Integer ? (Int(region),) : Tuple(Int.(region))
    for r in normalized_region
        1 <= r <= N || throw(ArgumentError("Invalid FFT dimension $r for array with $N dimensions"))
    end
    # Output size: FIRST transformed dimension becomes n÷2+1 (FFTW convention)
    first_dim = minimum(normalized_region)
    osz = ntuple(i -> i == first_dim ? sz[i] ÷ 2 + 1 : sz[i], N)
    MtlRFFTPlan{T,Forward,N}(sz, osz, normalized_region)
end

# Constructor for irfft/brfft (complex → real)
function MtlRFFTPlan{T,K}(sz::NTuple{N,Int}, d::Int, region) where {T<:Complex,K<:Union{Inverse,Backward},N}
    normalized_region = region isa Integer ? (Int(region),) : Tuple(Int.(region))
    for r in normalized_region
        1 <= r <= N || throw(ArgumentError("Invalid FFT dimension $r for array with $N dimensions"))
    end
    # Output size: FIRST transformed dimension is d (the original real size) - FFTW convention
    first_dim = minimum(normalized_region)
    osz = ntuple(i -> i == first_dim ? d : sz[i], N)
    MtlRFFTPlan{T,K,N}(sz, osz, normalized_region)
end

# ============================================================================
# Real FFT AbstractFFTs Interface
# ============================================================================

function AbstractFFTs.plan_rfft(x::MtlArray{T,N}, region; kwargs...) where {T<:Real,N}
    T == Float32 || throw(ArgumentError("Metal rfft only supports Float32, got $T"))
    MtlRFFTPlan{T,Forward}(size(x), region)
end

function AbstractFFTs.plan_rfft(x::MtlArray{T,N}; kwargs...) where {T<:Real,N}
    plan_rfft(x, 1:N; kwargs...)
end

function AbstractFFTs.plan_irfft(x::MtlArray{T,N}, d::Int, region; kwargs...) where {T<:Complex,N}
    T == ComplexF32 || throw(ArgumentError("Metal irfft only supports ComplexF32, got $T"))
    MtlRFFTPlan{T,Inverse}(size(x), d, region)
end

function AbstractFFTs.plan_irfft(x::MtlArray{T,N}, d::Int; kwargs...) where {T<:Complex,N}
    plan_irfft(x, d, 1:N; kwargs...)
end

function AbstractFFTs.plan_brfft(x::MtlArray{T,N}, d::Int, region; kwargs...) where {T<:Complex,N}
    T == ComplexF32 || throw(ArgumentError("Metal brfft only supports ComplexF32, got $T"))
    MtlRFFTPlan{T,Backward}(size(x), d, region)
end

function AbstractFFTs.plan_brfft(x::MtlArray{T,N}, d::Int; kwargs...) where {T<:Complex,N}
    plan_brfft(x, d, 1:N; kwargs...)
end

# Plan properties for real FFT
Base.size(p::MtlRFFTPlan) = p.sz
AbstractFFTs.fftdims(p::MtlRFFTPlan) = p.region

# ============================================================================
# Real FFT Operation Wrappers
# ============================================================================

"""
    realToHermiteanFFTWithTensor(graph, tensor, axes, descriptor, name="rfft")

Wrap Apple's MPSGraph realToHermiteanFFTWithTensor method.
Input: Real tensor, Output: Complex tensor with size n÷2+1 in last transformed axis.
"""
function realToHermiteanFFTWithTensor(graph::MPSGraph,
                                       tensor::MPSGraphTensor,
                                       axes::NSArray,
                                       descriptor::MPSGraphFFTDescriptor,
                                       name::String="rfft")
    obj = @objc [graph::id{MPSGraph} realToHermiteanFFTWithTensor:tensor::id{MPSGraphTensor}
                                axes:axes::id{NSArray}
                                descriptor:descriptor::id{MPSGraphFFTDescriptor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

"""
    HermiteanToRealFFTWithTensor(graph, tensor, axes, descriptor, name="irfft")

Wrap Apple's MPSGraph HermiteanToRealFFTWithTensor method.
Input: Complex tensor (Hermitian), Output: Real tensor.
"""
function HermiteanToRealFFTWithTensor(graph::MPSGraph,
                                       tensor::MPSGraphTensor,
                                       axes::NSArray,
                                       descriptor::MPSGraphFFTDescriptor,
                                       name::String="irfft")
    obj = @objc [graph::id{MPSGraph} HermiteanToRealFFTWithTensor:tensor::id{MPSGraphTensor}
                                axes:axes::id{NSArray}
                                descriptor:descriptor::id{MPSGraphFFTDescriptor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

# ============================================================================
# Real FFT Plan Execution
# ============================================================================

# rfft: Real → Complex
function Base.:*(p::MtlRFFTPlan{T,Forward,N}, x::MtlArray{T,N}) where {T<:Real,N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    y = MtlArray{Complex{T}}(undef, p.osz)
    mul!(y, p, x)
    return y
end

function mul!(y::MtlArray{Complex{T},N}, p::MtlRFFTPlan{T,Forward,N}, x::MtlArray{T,N}) where {T<:Real,N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    @assert size(y) == p.osz "Output size $(size(y)) does not match expected size $(p.osz)"

    @autoreleasepool begin
        _execute_rfft!(y, x, p.region)
    end

    return y
end

# irfft: Complex → Real (normalized)
function Base.:*(p::MtlRFFTPlan{T,Inverse,N}, x::MtlArray{T,N}) where {T<:Complex,N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    y = MtlArray{real(T)}(undef, p.osz)
    mul!(y, p, x)
    return y
end

function mul!(y::MtlArray{R,N}, p::MtlRFFTPlan{Complex{R},Inverse,N}, x::MtlArray{Complex{R},N}) where {R<:Real,N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    @assert size(y) == p.osz "Output size $(size(y)) does not match expected size $(p.osz)"

    @autoreleasepool begin
        _execute_irfft!(y, x, p.region, p.osz)
    end

    # Apply scaling for irfft: divide by product of output FFT dimension sizes
    scale_factor = R(1 / prod(p.osz[d] for d in p.region))
    y .*= scale_factor

    return y
end

# brfft: Complex → Real (unnormalized)
function Base.:*(p::MtlRFFTPlan{T,Backward,N}, x::MtlArray{T,N}) where {T<:Complex,N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    y = MtlArray{real(T)}(undef, p.osz)
    mul!(y, p, x)
    return y
end

function mul!(y::MtlArray{R,N}, p::MtlRFFTPlan{Complex{R},Backward,N}, x::MtlArray{Complex{R},N}) where {R<:Real,N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    @assert size(y) == p.osz "Output size $(size(y)) does not match expected size $(p.osz)"

    @autoreleasepool begin
        _execute_irfft!(y, x, p.region, p.osz)
    end

    # No scaling for brfft
    return y
end

# ============================================================================
# Real FFT Internal Execution
# ============================================================================

"""
Execute rfft (real to complex) - processes all axes at once using the last axis for the Hermitian output.
"""
function _execute_rfft!(y::MtlArray{Complex{T},N}, x::MtlArray{T,N}, region::Tuple) where {T<:Real,N}
    graph = MPSGraph()

    # Create placeholder for real input
    placeholder = placeholderTensor(graph, size(x), T)

    # Create FFT descriptor
    fft_desc = create_fft_descriptor(inverse=false, scaling=:none)

    # Convert all region axes to Metal axes
    # Julia axis i -> Metal axis (N - i) for N-dimensional array
    metal_axes = NSArray([NSNumber(Int32(N - ax)) for ax in region])

    # Create rfft operation
    fft_result = realToHermiteanFFTWithTensor(graph, placeholder, metal_axes, fft_desc, "rfft")

    # Create feed dictionary
    feeds = NSDictionary(Dict{MPSGraphTensor, MPSGraphTensorData}(
        placeholder => MPSGraphTensorData(x)
    ))

    # Create result dictionary
    results = NSDictionary(Dict{MPSGraphTensor, MPSGraphTensorData}(
        fft_result => MPSGraphTensorData(y)
    ))

    # Execute
    cmdbuf = MPS.MPSCommandBuffer(Metal.global_queue(Metal.device()))
    MPS.encode!(cmdbuf, graph, feeds, results, nil, default_exec_desc())
    Metal.commit!(cmdbuf)
    Metal.wait_completed(cmdbuf)

    return y
end

"""
Execute irfft (complex to real) - Hermitian input to real output.
"""
function _execute_irfft!(y::MtlArray{T,N}, x::MtlArray{Complex{T},N}, region::Tuple,
                          output_size::NTuple{N,Int}) where {T<:Real,N}
    graph = MPSGraph()

    # Create placeholder for complex input
    placeholder = placeholderTensor(graph, size(x), Complex{T})

    # Create FFT descriptor
    # Determine if output should be odd-sized (first transformed dimension per FFTW convention)
    first_dim = minimum(region)
    round_to_odd = isodd(output_size[first_dim])

    fft_desc = create_fft_descriptor(inverse=true, scaling=:none)
    fft_desc.roundToOddHermitean = round_to_odd

    # Convert all region axes to Metal axes
    metal_axes = NSArray([NSNumber(Int32(N - ax)) for ax in region])

    # Create irfft operation
    fft_result = HermiteanToRealFFTWithTensor(graph, placeholder, metal_axes, fft_desc, "irfft")

    # Create feed dictionary
    feeds = NSDictionary(Dict{MPSGraphTensor, MPSGraphTensorData}(
        placeholder => MPSGraphTensorData(x)
    ))

    # Create result dictionary
    results = NSDictionary(Dict{MPSGraphTensor, MPSGraphTensorData}(
        fft_result => MPSGraphTensorData(y)
    ))

    # Execute
    cmdbuf = MPS.MPSCommandBuffer(Metal.global_queue(Metal.device()))
    MPS.encode!(cmdbuf, graph, feeds, results, nil, default_exec_desc())
    Metal.commit!(cmdbuf)
    Metal.wait_completed(cmdbuf)

    return y
end

# ============================================================================
# Convenience Functions (AbstractFFTs will dispatch to these via plans)
# ============================================================================

# These are automatically provided by AbstractFFTs when we implement the plan interface:
# - fft(x, dims) -> plan_fft(x, dims) * x
# - ifft(x, dims) -> plan_ifft(x, dims) * x
# - bfft(x, dims) -> plan_bfft(x, dims) * x
# - rfft(x, dims) -> plan_rfft(x, dims) * x
# - irfft(x, d, dims) -> plan_irfft(x, d, dims) * x
# - brfft(x, d, dims) -> plan_brfft(x, d, dims) * x
