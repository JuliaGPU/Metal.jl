export endEncoding!

abstract type MtlCommandEncoder end

Base.:(==)(a::T, b::T) where {T <: MtlCommandEncoder} = a.handle == b.handle
Base.hash(q::MtlCommandEncoder, h::UInt) = hash(q.handle, h)

function unsafe_destroy!(cce::MtlCommandEncoder)
    mtRelease(cce.handle)
end

endEncoding!(ce::MtlCommandEncoder) = mtCommandEncoderEndEncoding(ce.handle)
Base.close(ce::MtlCommandEncoder) = endEncoding!(ce)
