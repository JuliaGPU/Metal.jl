export endEncoding!

abstract type MtlCommandEncoder end

Base.:(==)(a::T, b::T) where {T <: MtlCommandEncoder} = a.handle == b.handle
Base.hash(q::MtlCommandEncoder, h::UInt) = hash(q.handle, h)

function unsafe_destroy!(cce::MtlCommandEncoder)
    mtRelease(cce.handle)
end


## properties

Base.propertynames(::MtlCommandEncoder) = (:device, :label)

function Base.getproperty(o::MtlCommandEncoder, f::Symbol)
    if f === :device
        MtlDevice(mtCommandEncoderDevice(o))
    elseif f === :label
        ptr = mtCommandEncoderLabel(o)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    else
        getfield(o, f)
    end
end

function Base.setproperty!(o::MtlCommandEncoder, f::Symbol, val)
    if f === :label
		mtCommandEncoderLabelSet(o, val)
    else
        setfield!(o, f, val)
    end
end


## encoding

endEncoding!(ce::MtlCommandEncoder) = mtCommandEncoderEndEncoding(ce.handle)
Base.close(ce::MtlCommandEncoder) = endEncoding!(ce)
