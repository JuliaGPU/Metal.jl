# FFT operations using MPSGraph
# Implements AbstractFFTs.jl interface for MtlArray
#
# Supported types:
#   - ComplexF32 (Complex{Float32}) - full support
#   - ComplexF16 (Complex{Float16}) - full support
#   - Float32 - for rfft/irfft
#   - Float16 - for rfft/irfft
#
# NOT supported (MPSGraph limitation):
#   - ComplexF64 (Complex{Float64}) - Metal does not support double precision FFT
#   - Float64 - Metal does not support double precision FFT
#
# For double precision, use FFTW.jl on CPU or convert to Float32.

using AbstractFFTs
import LinearAlgebra: mul!

export plan_fft, plan_ifft, plan_bfft, plan_rfft, plan_irfft, plan_brfft
export plan_fft!, plan_ifft!, plan_bfft!

# Supported complex types for FFT
const FFTComplexTypes = Union{ComplexF32, ComplexF16}
const FFTRealTypes = Union{Float32, Float16}

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
- `T`: Element type (ComplexF32 or ComplexF16)
- `K`: Direction type (Forward, Inverse, or Backward)
- `N`: Number of dimensions

# Fields
- `sz`: Size of the input array
- `region`: Dimensions along which to perform FFT (normalized to Tuple)

# Supported Types
- `ComplexF32` (Complex{Float32}) - recommended for most use cases
- `ComplexF16` (Complex{Float16}) - lower precision, faster on some hardware

# Not Supported
- `ComplexF64` - Metal/MPSGraph does not support double precision FFT.
  Use FFTW.jl on CPU for double precision.
"""
struct MtlFFTPlan{T, K <: FFTDirection, N} <: AbstractFFTs.Plan{T}
    sz::NTuple{N, Int}
    region::Tuple{Vararg{Int}}
end

# Convenience constructors
function MtlFFTPlan{T, K}(sz::NTuple{N, Int}, region) where {T, K <: FFTDirection, N}
    # Normalize region to tuple
    normalized_region = region isa Integer ? (Int(region),) : Tuple(Int.(region))
    # Validate region
    for r in normalized_region
        1 <= r <= N || throw(ArgumentError("Invalid FFT dimension $r for array with $N dimensions"))
    end
    return MtlFFTPlan{T, K, N}(sz, normalized_region)
end

# ============================================================================
# AbstractFFTs Interface Implementation
# ============================================================================

function _check_fft_type(::Type{T}) where {T <: Complex}
    return T <: FFTComplexTypes || throw(
        ArgumentError(
            "Metal FFT only supports ComplexF32 and ComplexF16, got $T. " *
                "For ComplexF64, use FFTW.jl on CPU."
        )
    )
end

function _check_rfft_type(::Type{T}) where {T <: Real}
    return T <: FFTRealTypes || throw(
        ArgumentError(
            "Metal rfft only supports Float32 and Float16, got $T. " *
                "For Float64, use FFTW.jl on CPU."
        )
    )
end

function AbstractFFTs.plan_fft(x::MtlArray{T, N}, region) where {T <: Complex, N}
    _check_fft_type(T)
    return MtlFFTPlan{T, Forward}(size(x), region)
end

function AbstractFFTs.plan_fft(x::MtlArray{T, N}) where {T <: Complex, N}
    return plan_fft(x, 1:N)
end

function AbstractFFTs.plan_ifft(x::MtlArray{T, N}, region) where {T <: Complex, N}
    _check_fft_type(T)
    return MtlFFTPlan{T, Inverse}(size(x), region)
end

function AbstractFFTs.plan_ifft(x::MtlArray{T, N}) where {T <: Complex, N}
    return plan_ifft(x, 1:N)
end

function AbstractFFTs.plan_bfft(x::MtlArray{T, N}, region) where {T <: Complex, N}
    _check_fft_type(T)
    return MtlFFTPlan{T, Backward}(size(x), region)
end

function AbstractFFTs.plan_bfft(x::MtlArray{T, N}) where {T <: Complex, N}
    return plan_bfft(x, 1:N)
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
function create_fft_descriptor(; inverse::Bool = false, scaling::Symbol = :none)
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
# Plan Execution
# ============================================================================

function Base.:*(p::MtlFFTPlan{T, K, N}, x::MtlArray{T, N}) where {T, K, N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    y = similar(x)
    mul!(y, p, x)
    return y
end

function mul!(y::MtlArray{T, N}, p::MtlFFTPlan{T, K, N}, x::MtlArray{T, N}) where {T, K, N}
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

# ============================================================================
# In-Place FFT Plans
# ============================================================================

"""
    MtlFFTInplacePlan{T,K,N} <: AbstractFFTs.Plan{T}

In-place GPU FFT plan. The input array is modified directly.

Use `plan_fft!`, `plan_ifft!`, or `plan_bfft!` to create these plans.
"""
struct MtlFFTInplacePlan{T, K <: FFTDirection, N} <: AbstractFFTs.Plan{T}
    sz::NTuple{N, Int}
    region::Tuple{Vararg{Int}}
end

function MtlFFTInplacePlan{T, K}(sz::NTuple{N, Int}, region) where {T, K <: FFTDirection, N}
    normalized_region = region isa Integer ? (Int(region),) : Tuple(Int.(region))
    for r in normalized_region
        1 <= r <= N || throw(ArgumentError("Invalid FFT dimension $r for array with $N dimensions"))
    end
    return MtlFFTInplacePlan{T, K, N}(sz, normalized_region)
end

# In-place plan creation
function AbstractFFTs.plan_fft!(x::MtlArray{T, N}, region) where {T <: Complex, N}
    _check_fft_type(T)
    return MtlFFTInplacePlan{T, Forward}(size(x), region)
end

function AbstractFFTs.plan_fft!(x::MtlArray{T, N}) where {T <: Complex, N}
    return plan_fft!(x, 1:N)
end

function AbstractFFTs.plan_ifft!(x::MtlArray{T, N}, region) where {T <: Complex, N}
    _check_fft_type(T)
    return MtlFFTInplacePlan{T, Inverse}(size(x), region)
end

function AbstractFFTs.plan_ifft!(x::MtlArray{T, N}) where {T <: Complex, N}
    return plan_ifft!(x, 1:N)
end

function AbstractFFTs.plan_bfft!(x::MtlArray{T, N}, region) where {T <: Complex, N}
    _check_fft_type(T)
    return MtlFFTInplacePlan{T, Backward}(size(x), region)
end

function AbstractFFTs.plan_bfft!(x::MtlArray{T, N}) where {T <: Complex, N}
    return plan_bfft!(x, 1:N)
end

# Plan properties for in-place plans
Base.size(p::MtlFFTInplacePlan) = p.sz
AbstractFFTs.fftdims(p::MtlFFTInplacePlan) = p.region

# In-place plan execution - modifies input directly
function Base.:*(p::MtlFFTInplacePlan{T, K, N}, x::MtlArray{T, N}) where {T, K, N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    mul!(x, p, x)
    return x
end

function mul!(y::MtlArray{T, N}, p::MtlFFTInplacePlan{T, K, N}, x::MtlArray{T, N}) where {T, K, N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    @assert y === x "In-place plan requires output === input"

    inverse = K <: Inverse || K <: Backward
    needs_scaling = K <: Inverse

    @autoreleasepool begin
        _execute_fft_inplace!(x, p.region, inverse)
    end

    if needs_scaling
        scale_factor = T(1 / prod(p.sz[d] for d in p.region))
        x .*= scale_factor
    end

    return x
end

"""
Execute in-place FFT - input buffer is modified directly.
"""
function _execute_fft_inplace!(buf::MtlArray{T, N}, region::Tuple, inverse::Bool) where {T, N}
    for axis in region
        _execute_single_axis_fft!(buf, axis, inverse)
    end
    return buf
end

# ============================================================================
# FFT Internal Execution
# ============================================================================

"""
Internal FFT execution - processes one axis at a time for multi-axis FFT.
"""
function _execute_fft!(
        y::MtlArray{T, N}, x::MtlArray{T, N}, region::Tuple,
        inverse::Bool
    ) where {T, N}
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
function _execute_single_axis_fft!(
        buf::MtlArray{T, N}, axis::Int,
        inverse::Bool
    ) where {T, N}
    graph = MPSGraph()

    # Create placeholder tensor
    placeholder = placeholderTensor(graph, size(buf), T)

    # Create FFT descriptor - never use MPSGraph scaling, we handle it ourselves
    fft_desc = create_fft_descriptor(inverse = inverse, scaling = :none)

    # Convert Julia 1-indexed axis to Metal 0-indexed axis
    # Due to shape reversal in placeholderTensor, we need to compute the correct axis
    # Julia axis i -> Metal axis (N - i) for N-dimensional array
    metal_axis = N - axis
    axes = NSArray([NSNumber(Int32(metal_axis))])

    # Create FFT operation
    fft_result = fastFourierTransformWithTensor(graph, placeholder, axes, fft_desc, "fft")

    # Create feed dictionary
    feeds = NSDictionary(
        Dict{MPSGraphTensor, MPSGraphTensorData}(
            placeholder => MPSGraphTensorData(buf)
        )
    )

    # Create result dictionary (in-place output)
    results = NSDictionary(
        Dict{MPSGraphTensor, MPSGraphTensorData}(
            fft_result => MPSGraphTensorData(buf)
        )
    )

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

For rfft: Real input → Complex output with size n÷2+1 in the first transformed dimension.
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
struct MtlRFFTPlan{T, K <: FFTDirection, N} <: AbstractFFTs.Plan{T}
    sz::NTuple{N, Int}   # input size
    osz::NTuple{N, Int}  # output size
    region::Tuple{Vararg{Int}}
end

# Constructor for rfft (real → complex)
function MtlRFFTPlan{T, Forward}(sz::NTuple{N, Int}, region) where {T <: Real, N}
    normalized_region = region isa Integer ? (Int(region),) : Tuple(Int.(region))
    for r in normalized_region
        1 <= r <= N || throw(ArgumentError("Invalid FFT dimension $r for array with $N dimensions"))
    end
    # Output size: FIRST transformed dimension becomes n÷2+1 (FFTW convention)
    first_dim = minimum(normalized_region)
    osz = ntuple(i -> i == first_dim ? sz[i] ÷ 2 + 1 : sz[i], N)
    return MtlRFFTPlan{T, Forward, N}(sz, osz, normalized_region)
end

# Constructor for irfft/brfft (complex → real)
function MtlRFFTPlan{T, K}(sz::NTuple{N, Int}, d::Int, region) where {T <: Complex, K <: Union{Inverse, Backward}, N}
    normalized_region = region isa Integer ? (Int(region),) : Tuple(Int.(region))
    for r in normalized_region
        1 <= r <= N || throw(ArgumentError("Invalid FFT dimension $r for array with $N dimensions"))
    end
    # Output size: FIRST transformed dimension is d (the original real size) - FFTW convention
    first_dim = minimum(normalized_region)
    osz = ntuple(i -> i == first_dim ? d : sz[i], N)
    return MtlRFFTPlan{T, K, N}(sz, osz, normalized_region)
end

# ============================================================================
# Real FFT AbstractFFTs Interface
# ============================================================================

function AbstractFFTs.plan_rfft(x::MtlArray{T, N}, region) where {T <: Real, N}
    _check_rfft_type(T)
    return MtlRFFTPlan{T, Forward}(size(x), region)
end

function AbstractFFTs.plan_rfft(x::MtlArray{T, N}) where {T <: Real, N}
    return plan_rfft(x, 1:N)
end

function AbstractFFTs.plan_irfft(x::MtlArray{T, N}, d::Int, region) where {T <: Complex, N}
    _check_fft_type(T)
    return MtlRFFTPlan{T, Inverse}(size(x), d, region)
end

function AbstractFFTs.plan_irfft(x::MtlArray{T, N}, d::Int) where {T <: Complex, N}
    return plan_irfft(x, d, 1:N)
end

function AbstractFFTs.plan_brfft(x::MtlArray{T, N}, d::Int, region) where {T <: Complex, N}
    _check_fft_type(T)
    return MtlRFFTPlan{T, Backward}(size(x), d, region)
end

function AbstractFFTs.plan_brfft(x::MtlArray{T, N}, d::Int) where {T <: Complex, N}
    return plan_brfft(x, d, 1:N)
end

# Plan properties for real FFT
Base.size(p::MtlRFFTPlan) = p.sz
AbstractFFTs.fftdims(p::MtlRFFTPlan) = p.region

# ============================================================================
# Real FFT Plan Execution
# ============================================================================

# rfft: Real → Complex
function Base.:*(p::MtlRFFTPlan{T, Forward, N}, x::MtlArray{T, N}) where {T <: Real, N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    y = MtlArray{Complex{T}}(undef, p.osz)
    mul!(y, p, x)
    return y
end

function mul!(y::MtlArray{Complex{T}, N}, p::MtlRFFTPlan{T, Forward, N}, x::MtlArray{T, N}) where {T <: Real, N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    @assert size(y) == p.osz "Output size $(size(y)) does not match expected size $(p.osz)"

    @autoreleasepool begin
        _execute_rfft!(y, x, p.region)
    end

    return y
end

# irfft: Complex → Real (normalized)
function Base.:*(p::MtlRFFTPlan{T, Inverse, N}, x::MtlArray{T, N}) where {T <: Complex, N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    y = MtlArray{real(T)}(undef, p.osz)
    mul!(y, p, x)
    return y
end

function mul!(y::MtlArray{R, N}, p::MtlRFFTPlan{Complex{R}, Inverse, N}, x::MtlArray{Complex{R}, N}) where {R <: Real, N}
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
function Base.:*(p::MtlRFFTPlan{T, Backward, N}, x::MtlArray{T, N}) where {T <: Complex, N}
    @assert size(x) == p.sz "Input size $(size(x)) does not match plan size $(p.sz)"
    y = MtlArray{real(T)}(undef, p.osz)
    mul!(y, p, x)
    return y
end

function mul!(y::MtlArray{R, N}, p::MtlRFFTPlan{Complex{R}, Backward, N}, x::MtlArray{Complex{R}, N}) where {R <: Real, N}
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
Execute rfft (real to complex) - processes all axes at once.
"""
function _execute_rfft!(y::MtlArray{Complex{T}, N}, x::MtlArray{T, N}, region::Tuple) where {T <: Real, N}
    graph = MPSGraph()

    # Create placeholder for real input
    placeholder = placeholderTensor(graph, size(x), T)

    # Create FFT descriptor
    fft_desc = create_fft_descriptor(inverse = false, scaling = :none)

    # Convert all region axes to Metal axes
    # Julia axis i -> Metal axis (N - i) for N-dimensional array
    metal_axes = NSArray([NSNumber(Int32(N - ax)) for ax in region])

    # Create rfft operation
    fft_result = realToHermiteanFFTWithTensor(graph, placeholder, metal_axes, fft_desc, "rfft")

    # Create feed dictionary
    feeds = NSDictionary(
        Dict{MPSGraphTensor, MPSGraphTensorData}(
            placeholder => MPSGraphTensorData(x)
        )
    )

    # Create result dictionary
    results = NSDictionary(
        Dict{MPSGraphTensor, MPSGraphTensorData}(
            fft_result => MPSGraphTensorData(y)
        )
    )

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
function _execute_irfft!(
        y::MtlArray{T, N}, x::MtlArray{Complex{T}, N}, region::Tuple,
        output_size::NTuple{N, Int}
    ) where {T <: Real, N}
    graph = MPSGraph()

    # Create placeholder for complex input
    placeholder = placeholderTensor(graph, size(x), Complex{T})

    # Create FFT descriptor
    # Determine if output should be odd-sized (first transformed dimension per FFTW convention)
    first_dim = minimum(region)
    round_to_odd = isodd(output_size[first_dim])

    fft_desc = create_fft_descriptor(inverse = true, scaling = :none)
    fft_desc.roundToOddHermitean = round_to_odd

    # Convert all region axes to Metal axes
    metal_axes = NSArray([NSNumber(Int32(N - ax)) for ax in region])

    # Create irfft operation
    fft_result = HermiteanToRealFFTWithTensor(graph, placeholder, metal_axes, fft_desc, "irfft")

    # Create feed dictionary
    feeds = NSDictionary(
        Dict{MPSGraphTensor, MPSGraphTensorData}(
            placeholder => MPSGraphTensorData(x)
        )
    )

    # Create result dictionary
    results = NSDictionary(
        Dict{MPSGraphTensor, MPSGraphTensorData}(
            fft_result => MPSGraphTensorData(y)
        )
    )

    # Execute
    cmdbuf = MPS.MPSCommandBuffer(Metal.global_queue(Metal.device()))
    MPS.encode!(cmdbuf, graph, feeds, results, nil, default_exec_desc())
    Metal.commit!(cmdbuf)
    Metal.wait_completed(cmdbuf)

    return y
end
