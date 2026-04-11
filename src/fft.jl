# FFT operations using MPSGraph
# Implements AbstractFFTs.jl interface for MtlArray

using .MPSGraphs: MPSGraph, MPSGraphFFTDescriptor, HermiteanToRealFFTWithTensor, realToHermiteanFFTWithTensor,
                  fastFourierTransformWithTensor, placeholderTensor, MPSGraphTensorData, MPSGraphTensor

@reexport using AbstractFFTs
import AbstractFFTs: plan_fft, plan_fft!, plan_bfft, plan_bfft!, plan_ifft,
    plan_rfft, plan_brfft, plan_inv, normalization, fft, bfft, ifft, rfft, irfft,
    Plan, ScaledPlan

# supported types for FFT using MPSGraphs
const FFTComplex = Union{ComplexF32, ComplexF16}
const FFTReal = Union{Float32, Float16}
const FFTNumber = Union{FFTReal, FFTComplex}

# mtlfloat is like Base.float but converts Integers to Float32 instead
# of to Float64 which is unsupported on all Apple Silicon GPUs
mtlfloat(x) = float(x)
mtlfloat(x::Integer) = Float32(x)
mtlfloat(x::Complex{<:Integer}) = ComplexF32(x)
mtlfloat(::Type{<:Integer}) = Float32
mtlfloat(::Type{<:Complex{<:Integer}}) = ComplexF32

mtlfftfloat(x) = _mtlfftfloat(mtlfloat(x))
_mtlfftfloat(::Type{T}) where {T<:FFTNumber} = T
_mtlfftfloat(::Type{T}) where {T} = error("type $T not supported")
_mtlfftfloat(x::T) where {T} = _mtlfftfloat(T)(x)

realfloat(x::MtlArray{<:FFTReal}) = x
realfloat(x::MtlArray{T}) where {T<:Real} = copy1(mtlfftfloat(T), x)
realfloat(::MtlArray{T}) where {T} = error("type $T not supported")

complexfloat(x::MtlArray{<:FFTComplex}) = x
complexfloat(x::MtlArray{T}) where {T<:Complex} = copy1(mtlfftfloat(T), x)
complexfloat(x::MtlArray{T}) where {T<:Real} = copy1(mtlfftfloat(complex(T)), x)
complexfloat(::MtlArray{T}) where {T} = error("type $T not supported")

function copy1(::Type{T}, x::MtlArray{<:Any, N, S}) where {T, N, S}
    y = MtlArray{T, N, S}(undef, map(length, axes(x)))
    y .= broadcast(xi -> convert(T, xi), x)
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

# plan properties
Base.size(p::MtlFFTPlan) = p.input_size
AbstractFFTs.fftdims(p::MtlFFTPlan) = p.region

## AbstractFFTs interface implementation

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


# forward plans are `plan_fft`, and backward (unnormalized) plans are `plan_bfft`
# inplace functions have a "!", inverse (normalized) plans are handled via plan_inv
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

# Cache key for FFT graphs - includes all structural parameters
struct FFTGraphKey
    input_size::Tuple{Vararg{Int}}
    output_size::Tuple{Vararg{Int}}
    eltype_input::DataType
    eltype_output::DataType
    ndims::Int
    region::Tuple{Vararg{Int}}
    backward::Bool
end
# Build graph key from FFT plan parameters
function FFTGraphKey(p::MtlFFTPlan{T, S, backward, inplace, N, R}) where {T, S, backward, inplace, N, R}
    FFTGraphKey(
        p.input_size, p.output_size,
        S, T,
        N, p.region,
        backward
    )
end

# Cached graph with all tensors needed for execution
struct CachedFFTGraph
    graph::MPSGraph
    placeholder::MPSGraphTensor
    result::MPSGraphTensor
end
function CachedFFTGraph(key::FFTGraphKey)
    graph = MPSGraph()

    # Create symbolic placeholder with the input shape and type
    placeholder = placeholderTensor(graph, key.input_size, key.eltype_input)

    # Create FFT descriptor - don't use MPSGraph scaling, AbstractFFTs handles it for us
    fft_desc = MPSGraphFFTDescriptor(; inverse = key.backward)

    # Convert Julia 1-indexed axis to Metal 0-indexed axis
    # Due to shape reversal in placeholderTensor, we need to compute the correct axis
    # Julia axis i -> Metal axis (N - i) for N-dimensional array
    axes = NSArray([NSNumber(Int(key.ndims - ax)) for ax in key.region])

    # Select the MPSGraph FFT operation based on input/output element types
    fft_fn = if key.eltype_input <: Complex && key.eltype_output <: Complex
        fastFourierTransformWithTensor
    elseif key.eltype_input <: Real && key.eltype_output <: Complex
        realToHermiteanFFTWithTensor
    else # complex input, real output
        HermiteanToRealFFTWithTensor
    end

    # Create FFT operation
    result = fft_fn(graph, placeholder, axes, fft_desc)

    CachedFFTGraph(graph, placeholder, result)
end

# Get or create cached graph
function _get_cached_graph!(graph_cache_lock, graph_cache, key::FFTGraphKey)
    # Fast path: check cache without lock (safe for reads)
    cached = get(graph_cache, key, nothing)
    if cached !== nothing
        return cached
    end

    # Slow path: acquire lock and build graph
    @lock graph_cache_lock get!(graph_cache, key) do
        CachedFFTGraph(key)
    end
end

# Thread-safe graph cache with lock
const _fft_graph_cache = Dict{FFTGraphKey, CachedFFTGraph}()
const _fft_graph_cache_lock = ReentrantLock()

@autoreleasepool function _fft!(p::MtlFFTPlan{T, S, backward, inplace, N}, x, y) where {T <: FFTNumber, S <: FFTNumber, N, backward, inplace}
    # Get or create cached graph
    key = FFTGraphKey(p)
    cached = _get_cached_graph!(_fft_graph_cache_lock, _fft_graph_cache, key)

    # Build feed and result dictionaries with current data
    feeds = Dict{MPSGraphTensor, MPSGraphTensorData}(
        cached.placeholder => MPSGraphTensorData(x)
    )

    resultdict = Dict{MPSGraphTensor, MPSGraphTensorData}(
        cached.result => MPSGraphTensorData(y)
    )

    cmdbuf = MPS.MPSCommandBuffer(global_queue(device()))
    MPS.encode!(cmdbuf, cached.graph, NSDictionary(feeds), NSDictionary(resultdict), nil, MPSGraphs.default_exec_desc())
    commit!(cmdbuf)
    wait_completed(cmdbuf)

    return y
end

## high-level integrations

function LinearAlgebra.mul!(y::MtlArray{T, N}, p::MtlFFTPlan{T, S, backward, inplace, N}, x::MtlArray{S, N}) where {T, S, backward, inplace, N}
    assert_applicable(p, x, y)

    _fft!(p, x, y)
    return y
end

function Base.:(*)(p::MtlFFTPlan{T, S, backward, true}, x::MtlArray{S}) where {T, S, backward}
    assert_applicable(p, x)

    _fft!(p, x, x)
    return x
end
function Base.:(*)(p::MtlFFTPlan{T, S, backward, false}, x::MtlArray{S1, M}) where {T, S, backward, S1, M}
    z = if S1 != S
        # Convert to the expected input type.
        copy1(S, x)
    else
        x
    end
    assert_applicable(p, z)

    y = MtlArray{T, M}(undef, p.output_size)
    _fft!(p, z, y)
    return y
end
