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

using .MPSGraphs: MPSGraph, MPSGraphFFTDescriptor, HermiteanToRealFFTWithTensor, realToHermiteanFFTWithTensor,
                  fastFourierTransformWithTensor, placeholderTensor, MPSGraphTensorData, MPSGraphTensor

using AbstractFFTs
import AbstractFFTs: plan_fft, plan_ifft, plan_bfft, plan_rfft, plan_irfft, plan_brfft
import AbstractFFTs: plan_fft!, plan_ifft!, plan_bfft!

export plan_fft, plan_ifft, plan_bfft, plan_rfft, plan_irfft, plan_brfft
export plan_fft!, plan_ifft!, plan_bfft!

# Supported complex types for FFT
const FFTComplex = Union{ComplexF32, ComplexF16}
const FFTReal = Union{Float32, Float16}
const FFTNumber = Union{FFTReal, FFTComplex}

# ============================================================================
# FFT Direction Enum
# ============================================================================

abstract type FFTDirection end
struct Forward <: FFTDirection end
struct Inverse <: FFTDirection end
struct Backward <: FFTDirection end  # unnormalized inverse

## plan structure

"""
    MtlFFTPlan{T, S, K, inplace, N, R} <: AbstractFFTs.Plan{T}

GPU FFT plan for Metal using MPSGraph's fastFourierTransformWithTensor.

"""
struct MtlFFTPlan{T <: FFTNumber, S <: FFTNumber, K <: FFTDirection, inplace, N, R} <: AbstractFFTs.Plan{T}
    input_size::NTuple{N, Int}
    output_size::NTuple{N, Int}
    region::NTuple{R, Int}

    function MtlFFTPlan{T, S, K, inplace, N, R}(input_size::NTuple{N, Int}, output_size::NTuple{N, Int}, region::NTuple{R, Int}) where {T <: FFTNumber, S <: FFTNumber, K <: FFTDirection, inplace, N, R}
        # Validate region
        for r in region
            1 <= r <= N || throw(ArgumentError("Invalid FFT dimension $r for array with $N dimensions"))
        end
        inplace isa Bool || throw(ArgumentError("FFT inplace argument must be a Bool"))

        return new{T, S, K, inplace, N, R}(input_size, output_size, region)
    end
end

function showfftdims(io, sz, T)
    if isempty(sz)
        print(io,"0-dimensional")
    elseif length(sz) == 1
        print(io, sz[1], "-element")
    else
        print(io, join(sz, "×"))
    end
    print(io, " MtlArray of ", T)
end

function Base.show(io::IO, p::MtlFFTPlan{T, S, K, inplace}) where {T, S, K, inplace}
    print(io, "MPSGraph FFT ",
          inplace ? "in-place " : "",
          S == T ? "$T " : "$(S)-to-$(T) ",
          K == Forward ? "forward " : "backward ",
          "plan for ")
    showfftdims(io, p.input_size, S)
end

# Plan properties
Base.size(p::MtlFFTPlan) = p.input_size
AbstractFFTs.fftdims(p::MtlFFTPlan) = p.region

# ============================================================================
# AbstractFFTs Interface Implementation
# ============================================================================

for f in (:plan_fft!, :plan_bfft!, :plan_ifft!, :plan_fft, :plan_bfft, :plan_ifft)
    @eval begin
        Base.@constprop :aggressive function $f(x::MtlArray{T, N}, region) where {T <: FFTComplex, N}
            R = length(region)
            region = NTuple{R,Int}(region)
            $f(x, region)
        end
    end
end

function AbstractFFTs.plan_fft(x::MtlArray{T, N}, region::NTuple{R, Int}) where {T <: FFTComplex, N, R}
    K = Forward
    inplace = false
    return MtlFFTPlan{T, T, K, inplace, N, R}(size(x), size(x), region)
end

function AbstractFFTs.plan_ifft(x::MtlArray{T, N}, region::NTuple{R, Int}) where {T <: FFTComplex, N, R}
    K = Inverse
    inplace = false
    return MtlFFTPlan{T, T, K, inplace, N, R}(size(x), size(x), region)
end

function AbstractFFTs.plan_bfft(x::MtlArray{T, N}, region::NTuple{R, Int}) where {T <: FFTComplex, N, R}
    K = Backward
    inplace = false
    return MtlFFTPlan{T, T, K, inplace, N, R}(size(x), size(x), region)
end

# In-place plan creation
function AbstractFFTs.plan_fft!(x::MtlArray{T, N}, region::NTuple{R, Int}) where {T <: FFTComplex, N, R}
    K = Forward
    inplace = true
    return MtlFFTPlan{T, T, K, inplace, N, R}(size(x), size(x), region)
end

function AbstractFFTs.plan_ifft!(x::MtlArray{T, N}, region::NTuple{R, Int}) where {T <: FFTComplex, N, R}
    K = Inverse
    inplace = true
    return MtlFFTPlan{T, T, K, inplace, N, R}(size(x), size(x), region)
end

function AbstractFFTs.plan_bfft!(x::MtlArray{T, N}, region::NTuple{R, Int}) where {T <: FFTComplex, N, R}
    K = Backward
    inplace = true
    return MtlFFTPlan{T, T, K, inplace, N, R}(size(x), size(x), region)
end

# out-of-place real-to-complex
Base.@constprop :aggressive function AbstractFFTs.plan_rfft(x::MtlArray{T, N}, region) where {T <: FFTReal, N}
    R = length(region)
    region = NTuple{R,Int}(region)
    AbstractFFTs.plan_rfft(x, region)
end

function AbstractFFTs.plan_rfft(x::MtlArray{T, N}, region::NTuple{R, Int}) where {T <: FFTReal, N, R}
    K = Forward
    inplace = false

    sizex = size(x)[1:N]

    xdims = size(x)
    ydims = Base.setindex(xdims, div(xdims[region[1]], 2) + 1, region[1])
    MtlFFTPlan{complex(T), T, K, inplace, N, R}(size(x), (ydims...,), region)
end

Base.@constprop :aggressive function AbstractFFTs.plan_irfft(x::MtlArray{T, N}, d::Int, region) where {T <: FFTComplex, N}
    R = length(region)
    region = NTuple{R,Int}(region)

    AbstractFFTs.plan_irfft(x, d, region)
end

function AbstractFFTs.plan_irfft(x::MtlArray{T, N}, d::Int, region::NTuple{R, Int}) where {T <: FFTComplex, N, R}
    K = Inverse
    inplace = false

    xdims = size(x)
    ydims = Base.setindex(xdims, d, region[1])

    MtlFFTPlan{real(T), T, K, inplace, N, R}(size(x), ydims, region)
end

# out-of-place complex-to-real
Base.@constprop :aggressive function AbstractFFTs.plan_brfft(x::MtlArray{T, N}, d::Int, region) where {T <: FFTComplex, N}
    R = length(region)
    region = NTuple{R,Int}(region)

    plan_brfft(x, d, region)
end

function AbstractFFTs.plan_brfft(x::MtlArray{T, N}, d::Int, region::NTuple{R, Int}) where {T <: FFTComplex, N, R}
    K = Backward
    inplace = false

    xdims = size(x)
    ydims = Base.setindex(xdims, d, region[1])

    MtlFFTPlan{real(T), T, K, inplace, N, R}(size(x), ydims, region)
end

## plan execution

function assert_applicable(p::MtlFFTPlan{T, S}, X::MtlArray{S}) where {T, S}
    (size(X) == p.input_size) ||
        throw(ArgumentError("MtlFFT plan applied to wrong-size input"))
end

function assert_applicable(p::MtlFFTPlan{T, S, K, inplace}, X::MtlArray{S},
                           Y::MtlArray{T}) where {T, S, K, inplace}
    assert_applicable(p, X)
    if size(Y) != p.output_size
        throw(ArgumentError("MtlFFT plan applied to wrong-size output"))
    elseif inplace != (pointer(X) == pointer(Y))
        throw(ArgumentError(string("MtlFFT ",
                                   inplace ? "in-place" : "out-of-place",
                                   " plan applied to ",
                                   inplace ? "out-of-place" : "in-place",
                                   " data")))
    end
end

function unsafe_execute!(p::MtlFFTPlan{T, S, K, inplace, N}, x::MtlArray{T, N}, y::MtlArray{T, N}) where {T <: FFTComplex, S <: FFTComplex, N, K, inplace}
    _unsafe_execute!(fastFourierTransformWithTensor, p, x, y)
end

function unsafe_execute!(p::MtlFFTPlan{T, S, K, inplace, N}, x::MtlArray{S, N}, y::MtlArray{T, N}) where {S <: FFTReal, T <: Complex{S}, N, K, inplace}
    _unsafe_execute!(realToHermiteanFFTWithTensor, p, x, y)
end

function unsafe_execute!(p::MtlFFTPlan{T, S, K, inplace, N}, x::MtlArray{S, N}, y::MtlArray{T, N}) where {T <: FFTReal, S <: Complex{T}, N, K, inplace}
    _unsafe_execute!(HermiteanToRealFFTWithTensor, p, x, y)
end

@inline function _unsafe_execute!(f, p::MtlFFTPlan{T, S, K, inplace, N}, x, y) where {T <: FFTNumber, S <: FFTNumber, N, K, inplace}
    inverse = K <: Inverse || K <: Backward

    graph = MPSGraph()

    # Create placeholder tensor
    placeholder = placeholderTensor(graph, size(x), S)

    # Create FFT descriptor - never use MPSGraph scaling, we handle it ourselves
    fft_desc = MPSGraphFFTDescriptor(; inverse, scalingMode = K <: Inverse ? MPSGraphs.MPSGraphFFTScalingModeSize : MPSGraphs.MPSGraphFFTScalingModeNone)

    # Convert Julia 1-indexed axis to Metal 0-indexed axis
    # Due to shape reversal in placeholderTensor, we need to compute the correct axis
    # Julia axis i -> Metal axis (N - i) for N-dimensional array
    axes = NSArray([NSNumber(Int(N - ax)) for ax in p.region])

    # Create FFT operation
    fft_result = f(graph, placeholder, axes, fft_desc)

    # Create feed dictionary
    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        placeholder => MPSGraphTensorData(x)
    )

    # Create result dictionary (in-place output)
    results = Dict{MPSGraphTensor, MPSGraphTensorData}(
        fft_result => MPSGraphTensorData(y)
    )

    # Execute
    cmdbuf = MPS.MPSCommandBuffer(Metal.global_queue(Metal.device()))
    MPS.encode!(cmdbuf, graph, NSDictionary(feeds), NSDictionary(results), nil, MPSGraphs.default_exec_desc())
    Metal.commit!(cmdbuf)
    Metal.wait_completed(cmdbuf)

    return y
end

## high-level integrations

function LinearAlgebra.mul!(y::MtlArray{T, N}, p::MtlFFTPlan{T, S, K, inplace, N}, x::MtlArray{S, N}) where {T, S, K, inplace, N}
    assert_applicable(p, x, y)

    @autoreleasepool begin
        unsafe_execute!(p, x, y)
    end

    return y
end

function Base.:(*)(p::MtlFFTPlan{T, S, K, true}, x::MtlArray{S}) where {T, S, K}
    # assert_applicable(p, x)
    LinearAlgebra.mul!(x, p, x)
    return x
end
function Base.:(*)(p::MtlFFTPlan{T, S, K, false}, x::MtlArray{S}) where {T, S, K}
    # assert_applicable(p, x)

    y = MtlArray{T}(undef, p.output_size)
    LinearAlgebra.mul!(y, p, x)
    return y
end
