module MetalDSPExt

# GPU-accelerated linear convolution and cross-correlation for `MtlArray`s.
#
# Dispatches `DSP.conv` / `DSP.xcorr` to Metal's FFT-based convolution engine
# (`Metal.MPSGraphs`), so `using DSP, Metal; conv(a, b)` runs on the GPU instead
# of falling back to scalar CPU indexing. This mirrors how the FFT support
# extends `AbstractFFTs` rather than introducing a parallel `Metal.conv`.

using Metal
import DSP

# Element types the MPSGraph FFT/convolution engine supports.
const MtlConvNumber = Union{Float32, Float16, ComplexF32, ComplexF16}

"""
    DSP.conv(u::MtlArray, v::MtlArray; algorithm = :auto)

Full linear convolution of two `MtlArray`s on the GPU, computed via the FFT
convolution theorem (with an MPS direct-convolution fast path for small 2-D
kernels). Convolves over all dimensions, matching `DSP.conv` semantics. The
`algorithm` keyword accepts `:auto`, `:fft`, or `:direct`.
"""
function DSP.conv(
        u::MtlArray{T, N}, v::MtlArray{T, N}; algorithm::Symbol = :auto
    ) where {T <: MtlConvNumber, N}
    alg = algorithm in (:fft, :direct) ? algorithm : :auto
    return Metal.MPSGraphs.conv(u, v; dims = ntuple(identity, N), mode = :full, algorithm = alg)
end

"""
    DSP.xcorr(u::MtlVector, v::MtlVector; padmode = :none)

Cross-correlation of two GPU vectors, conjugating `v` (the DSP/MATLAB
convention). Only `padmode = :none` (the full correlation) is supported.
"""
function DSP.xcorr(
        u::MtlVector{T}, v::MtlVector{T}; padmode::Symbol = :none
    ) where {T <: MtlConvNumber}
    padmode === :none || throw(ArgumentError("MetalDSPExt only supports padmode = :none"))
    return Metal.MPSGraphs.xcorr(u, v; mode = :full)
end

end # module
