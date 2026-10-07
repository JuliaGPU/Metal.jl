# scans: MPSGraph as a fast path for what it supports, GPUArrays' implementation otherwise

# `:auto` uses MPSGraph for large inputs it supports, `:MPSGraph` requires it (erroring on
# unsupported input), and `:native` always uses GPUArrays' implementation
const scan_alg = ScopedValue(:auto)
const mpsgraph_scan_threshold = 64 * 1024

# MPSGraph has no efficient 64-bit-integer cumulative kernel: on the
# `accumulate(+, rand(Int64, 3, 10^6); dims=1)` shape it was ~2.6× slower than Metal's
# former native scan (vs ~0.85× for ≤32-bit ints and floats, which MPSGraph handles
# well), and the slowdown grows as the scanned dimension shrinks. So keep 64-bit
# integers on the generic scan in `:auto`; they remain correct (just slow) and
# available under an explicit `:MPSGraph` request.
mpsgraph_scan_worthwhile(::Type{T}) where {T} = !(T === Int64 || T === UInt64)

# MPSGraph cumulative max/min ignore NaNs while Base accumulate(max/min)
# propagates them, so don't use MPSGraph scan for these operations on
# Float inputs
mpsgraph_scan_operation(::DataType, ::typeof(+)) = :sum
mpsgraph_scan_operation(::DataType, ::typeof(Base.add_sum)) = :sum
mpsgraph_scan_operation(::DataType, ::typeof(*)) = :product
mpsgraph_scan_operation(::DataType, ::typeof(Base.mul_prod)) = :product
mpsgraph_scan_operation(::Type{<:Integer}, ::typeof(min)) = :minimum
mpsgraph_scan_operation(::Type{<:Integer}, ::typeof(max)) = :maximum
mpsgraph_scan_operation(_T, _op) = nothing

function mpsgraph_scan_supported(op, output::MtlArray{T}, input::MtlArray{T},
                            dims::Integer, init::Nothing) where {T}
    mpsgraph_scan_operation(T, op) === nothing && return false
    T <: Union{MPSGraphs.MPSGRAPH_VALID_SCAN_TYPES...} || return false
    axes(output) == axes(input) || return false
    1 <= dims <= ndims(input) || return false
    return output.offset == 0 && input.offset == 0
end

mpsgraph_scan_supported(op, output, input, dims::Integer, init) = false

# Scans with MPSGraph and returns `true`, or returns `false` for GPUArrays to do it
function mpsgraph_scan!(op, output, input, dims::Integer, init)
    alg = scan_alg[]
    supported = mpsgraph_scan_supported(op, output, input, dims, init)
    if alg === :MPSGraph
        supported ||
            throw(ArgumentError("MPSGraph scan does not support this accumulate query"))
    elseif alg === :auto
        supported && mpsgraph_scan_worthwhile(eltype(input)) &&
            length(input) >= mpsgraph_scan_threshold || return false
    elseif alg === :native
        return false
    else
        error(":$alg is not a valid scan algorithm. Options are: `:auto`, `:MPSGraph`, `:native`")
    end
    MPSGraphs.graph_scan!(op, output, input; dim=dims)
    return true
end

for (A, D, I) in ((:WrappedMtlVector, :Nothing, :Nothing), (:WrappedMtlVector, :Nothing, :Some),
                  (:WrappedMtlArray, :Integer, :Nothing), (:WrappedMtlArray, :Integer, :Some))
    GA = A === :WrappedMtlVector ? :(GPUArrays.AnyGPUVector) : :(GPUArrays.AnyGPUArray)
    @eval function Base._accumulate!(op, output::WrappedMtlArray, input::$A, dims::$D, init::$I)
        mpsgraph_scan!(op, output, input, something(dims, 1), init) && return output
        return invoke(Base._accumulate!, Tuple{Any, GPUArrays.AnyGPUArray, $GA, $D, $I},
                      op, output, input, dims, init)
    end
end
