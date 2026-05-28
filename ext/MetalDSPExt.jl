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

# Clear error for unsupported element types (e.g. Float64). The MtlArray methods
# below intercept DSP.conv/xcorr before DSP's generic CPU path, which would hit
# disallowed scalar indexing on the device.
@noinline function _conv_unsupported(u, v)
    throw(
        ArgumentError(
            "Metal convolution supports Float32/Float16 and their Complex types; " *
                "got $(eltype(u)) and $(eltype(v)). Convert first, e.g. with `Float32.(x)`."
        )
    )
end

"""
    DSP.conv(u::MtlArray, v::MtlArray; algorithm = :auto)

Full linear convolution of two `MtlArray`s on the GPU, computed via the FFT
convolution theorem. Convolves over all dimensions, matching `DSP.conv`
semantics. The `algorithm` keyword (`:auto`/`:fft`) is accepted for
compatibility; the FFT path is always used.
"""
function DSP.conv(
        u::MtlArray{T, N}, v::MtlArray{T, N}; algorithm::Symbol = :auto
    ) where {T <: Number, N}
    T <: MtlConvNumber || _conv_unsupported(u, v)
    # `algorithm` accepted for DSP.conv compatibility; the FFT engine is always used.
    return Metal.MPSGraphs.conv(u, v; dims = ntuple(identity, N), mode = :full)
end

"""
    DSP.xcorr(u::MtlVector, v::MtlVector; padmode = :none, scaling = :none)

Cross-correlation of two GPU vectors, conjugating `v` (the DSP/MATLAB
convention). Only `padmode = :none` (the full correlation) and `scaling = :none`
are supported.
"""
function DSP.xcorr(
        u::MtlVector{T}, v::MtlVector{T}; padmode::Symbol = :none, scaling::Symbol = :none
    ) where {T <: Number}
    T <: MtlConvNumber || _conv_unsupported(u, v)
    padmode === :none || throw(ArgumentError("MetalDSPExt supports only padmode = :none"))
    scaling === :none || throw(ArgumentError("MetalDSPExt supports only scaling = :none"))
    return Metal.MPSGraphs.xcorr(u, v; mode = :full)
end

end # module
