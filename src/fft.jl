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
import AbstractFFTs: plan_fft, plan_fft!, plan_bfft, plan_bfft!, plan_ifft,
    plan_rfft, plan_brfft, plan_inv, normalization, fft, bfft, ifft, rfft, irfft,
    Plan, ScaledPlan

export plan_fft, plan_ifft, plan_bfft, plan_rfft, plan_irfft, plan_brfft,
       plan_fft!, plan_ifft!, plan_bfft!, plan_inv

# Supported complex types for FFT
const FFTComplex = Union{ComplexF32, ComplexF16}
const FFTReal = Union{Float32, Float16}
const FFTNumber = Union{FFTReal, FFTComplex}

mtlfloat(x) = float(x)
mtlFloat(x::Integer) = Float32(x)
mtlFloat(x::Complex{<:Integer}) = ComplexF32(x)
mtlFloat(::Type{<:Integer}) = Float32
mtlFloat(::Type{Complex{<:Integer}}) = ComplexF32

mtlfftfloat(x) = _mtlfftfloat(mtlfloat(x))
_mtlfftfloat(::Type{T}) where {T<:FFTNumber} = T
_mtlfftfloat(::Type{T}) where {T} = error("type $T not supported")
_mtlfftfloat(x::T) where {T} = _mtlfftfloat(T)(x)

realfloat(x::MtlArray{<:FFTReal}) = x
realfloat(x::MtlArray{T}) where {T<:Real} = copy1(mtlfftfloat(T), x)
realfloat(x::MtlArray{T}) where {T} = error("type $T not supported")

complexfloat(x::MtlArray{<:FFTComplex}) = x
complexfloat(x::MtlArray{T}) where {T<:Complex} = copy1(mtlfftfloat(T), x)
complexfloat(x::MtlArray{T}) where {T<:Real} = copy1(mtlfftfloat(complex(T)), x)
complexfloat(x::MtlArray{T}) where {T} = error("type $T not supported")

function copy1(::Type{T}, x) where T
    y = MtlArray{T}(undef, map(length, axes(x)))
    y .= broadcast(xi->convert(T,xi),x)
end

## plan structure

"""
    MtlFFTPlan{T, S, backward, inplace, N, R} <: AbstractFFTs.Plan{S}

`T` is the output type
`S` is the input ("source") type

`backward` is a boolean flag
`inplace` is a boolean flag

`N` is the number of dimensions

GPU FFT plan for Metal using MPSGraph's fastFourierTransformWithTensor.

"""
mutable struct MtlFFTPlan{T <: FFTNumber, S <: FFTNumber, backward, inplace, N, R} <: Plan{S}
    input_size::NTuple{N, Int}
    output_size::NTuple{N, Int}
    region::NTuple{R, Int}
    pinv::ScaledPlan{T}

    function MtlFFTPlan{T, S, backward, inplace, N, R}(input_size::NTuple{N, Int}, output_size::NTuple{N, Int}, region::NTuple{R, Int}) where {T <: FFTNumber, S <: FFTNumber, backward, inplace, N, R}
        # Validate region
        if any(diff(collect(region)) .< 1)
            throw(ArgumentError("region must be an increasing sequence"))
        end
        if any(region .< 1 .|| region .> N)
            throw(ArgumentError("region can only refer to valid dimensions"))
        end
        backward isa Bool || throw(ArgumentError("FFT backward argument must be a Bool"))
        inplace isa Bool || throw(ArgumentError("FFT inplace argument must be a Bool"))

        return new{T, S, backward, inplace, N, R}(input_size, output_size, region)
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

function Base.show(io::IO, p::MtlFFTPlan{T, S, backward, inplace}) where {T, S, backward, inplace}
    print(io, "MPSGraph FFT ",
          inplace ? "in-place " : "",
          S == T ? "$T " : "$(S)-to-$(T) ",
          backward ? "backward " : "forward ",
          "plan for ")
    showfftdims(io, p.input_size, S)
end

# Plan properties
Base.size(p::MtlFFTPlan) = p.input_size
AbstractFFTs.fftdims(p::MtlFFTPlan) = p.region

## AbstractFFTs Interface Implementation

# promote to a complex floating-point type (out-of-place only),
# so implementations only need Complex{Float} methods
for f in (:fft, :bfft, :ifft)
    pf = Symbol("plan_", f)
    @eval begin
        $f(x::MtlArray{<:Real}, region=1:ndims(x)) = $f(complexfloat(x), region)
        $pf(x::MtlArray{<:Real}, region) = $pf(complexfloat(x), region)
        $f(x::MtlArray{<:Complex{<:Union{Integer,Rational}}}, region=1:ndims(x)) = $f(complexfloat(x), region)
        $pf(x::MtlArray{<:Complex{<:Union{Integer,Rational}}}, region) = $pf(complexfloat(x), region)
    end
end
rfft(x::MtlArray{<:Union{Integer,Rational}}, region=1:ndims(x)) = rfft(realfloat(x), region)
plan_rfft(x::MtlArray{<:Real}, region) = plan_rfft(realfloat(x), region)

function irfft(x::MtlArray{<:Union{Real,Integer,Rational}}, d::Integer, region=1:ndims(x))
    irfft(complexfloat(x), d, region)
end


# forward plans are `plan_fft`, inverse plans are `plan_ifft`, and backward (unnormalized ) plans are `plan_bfft`
# inplace functions have a "!",
for inplace in (true, false), backward in (true, false)
    dir_str = backward ? "b" : ""
    inplace_str = inplace ? "!" : ""
    f = Symbol(:plan_, dir_str, :fft, inplace_str)

    @eval begin
        # untyped `region` argument
        Base.@constprop :aggressive function $f(x::MtlArray{T, N}, region) where {T <: FFTComplex, N}
            R = length(region)
            region = NTuple{R,Int}(region)
            $f(x, region)
        end

        # actually create the MtlFFTPlan
        $f(x::MtlArray{T, N}, region::NTuple{R, Int}) where {T <: FFTComplex, N, R} = MtlFFTPlan{T, T, $backward, $inplace, N, R}(size(x), size(x), region)
    end
end

# out-of-place real-to-complex
Base.@constprop :aggressive function plan_rfft(x::MtlArray{T, N}, region) where {T <: FFTReal, N}
    R = length(region)
    region = NTuple{R,Int}(region)

    plan_rfft(x, region)
end

function plan_rfft(x::MtlArray{T, N}, region::NTuple{R, Int}) where {T <: FFTReal, N, R}
    backward = false
    inplace = false

    xdims = size(x)
    ydims = Base.setindex(xdims, div(xdims[region[1]], 2) + 1, region[1])
    MtlFFTPlan{complex(T), T, backward, inplace, N, R}(size(x), (ydims...,), region)
end

# out-of-place complex-to-real
Base.@constprop :aggressive function plan_brfft(x::MtlArray{T, N}, d::Int, region) where {T <: FFTComplex, N}
    R = length(region)
    region = NTuple{R,Int}(region)

    plan_brfft(x, d, region)
end

function plan_brfft(x::MtlArray{T, N}, d::Int, region::NTuple{R, Int}) where {T <: FFTComplex, N, R}
    backward = true
    inplace = false

    xdims = size(x)
    ydims = Base.setindex(xdims, d, region[1])

    MtlFFTPlan{real(T), T, backward, inplace, N, R}(size(x), ydims, region)
end

function plan_inv(p::MtlFFTPlan{T, S, true, inplace, N, R}) where {T <: FFTNumber, S <: FFTNumber, inplace, N, R}
    ScaledPlan(MtlFFTPlan{S, T, false, inplace, N, R}(p.output_size, p.input_size, p.region),
               normalization(real(T), p.output_size, p.region))
end

function plan_inv(p::MtlFFTPlan{T, S, false, inplace, N, R}) where {T <: FFTNumber, S <: FFTNumber, inplace, N, R}
    ScaledPlan(MtlFFTPlan{S, T, true, inplace, N, R}(p.output_size, p.input_size, p.region),
               normalization(real(S), p.input_size, p.region))
end

## plan execution

function assert_applicable(p::MtlFFTPlan{T, S}, X::MtlArray{S}) where {T, S}
    (size(X) == p.input_size) ||
        throw(ArgumentError("MtlFFT plan applied to wrong-size input"))
end

function assert_applicable(p::MtlFFTPlan{T, S, backward, inplace}, X::MtlArray{S},
                           Y::MtlArray{T}) where {T, S, backward, inplace}
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

function unsafe_execute!(p::MtlFFTPlan{T, S, backward, inplace, N}, x::MtlArray{T, N}, y::MtlArray{T, N}) where {T <: FFTComplex, S <: FFTComplex, N, backward, inplace}
    @autoreleasepool _unsafe_execute!(fastFourierTransformWithTensor, p, x, y)
end

function unsafe_execute!(p::MtlFFTPlan{T, S, backward, inplace, N}, x::MtlArray{S, N}, y::MtlArray{T, N}) where {S <: FFTReal, T <: Complex{S}, N, backward, inplace}
    @autoreleasepool _unsafe_execute!(realToHermiteanFFTWithTensor, p, x, y)
end

function unsafe_execute!(p::MtlFFTPlan{T, S, backward, inplace, N}, x::MtlArray{S, N}, y::MtlArray{T, N}) where {T <: FFTReal, S <: Complex{T}, N, backward, inplace}
    @autoreleasepool _unsafe_execute!(HermiteanToRealFFTWithTensor, p, x, y)
end

@inline function _unsafe_execute!(f, p::MtlFFTPlan{T, S, backward, inplace, N}, x, y) where {T <: FFTNumber, S <: FFTNumber, N, backward, inplace}
    graph = MPSGraph()

    # Create placeholder tensor
    placeholder = placeholderTensor(graph, size(x), S)

    # Create FFT descriptor - never use MPSGraph scaling, we handle it ourselves
    fft_desc = MPSGraphFFTDescriptor(; inverse = backward)

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

function LinearAlgebra.mul!(y::MtlArray{T, N}, p::MtlFFTPlan{T, S, backward, inplace, N}, x::MtlArray{S, N}) where {T, S, backward, inplace, N}
    assert_applicable(p, x, y)

    unsafe_execute!(p, x, y)
    return y
end

function Base.:(*)(p::MtlFFTPlan{T, S, backward, true}, x::MtlArray{S}) where {T, S, backward}
    assert_applicable(p, x)

    unsafe_execute!(p, x, x)
    return x
end
function Base.:(*)(p::MtlFFTPlan{T, S, backward, false}, x::MtlArray{S}) where {T, S, backward}
    assert_applicable(p, x)

    y = MtlArray{T}(undef, p.output_size)
    unsafe_execute!(p, x, y)
    return y
end
