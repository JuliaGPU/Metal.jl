export endEncoding!

abstract type MtlCommandEncoder end

Base.:(==)(a::T, b::T) where {T <: MtlCommandEncoder} = a.handle == b.handle
Base.hash(q::MtlCommandEncoder, h::UInt) = hash(q.handle, h)

function unsafe_destroy!(cce::MtlCommandEncoder)
    if cce.handle !== C_NULL
        mtRelease(cce.handle)
    end
end


endEncoding!(ce::MtlCommandEncoder) = mtCommandEncoderEndEncoding(ce);
Base.close(ce::MtlCommandEncoder) = endEncoding!(ce)
