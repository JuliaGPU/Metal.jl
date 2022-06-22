export MtlArgumentEncoder, set_buffer!, set_buffers!, set_constant!

const MTLArgumentEncoder = Ptr{MtArgumentEncoder}

mutable struct MtlArgumentEncoder
    handle::MTLArgumentEncoder
end

function MtlArgumentEncoder(fun::MtlFunction, entry::Integer)
    handle = mtNewArgumentEncoderWithBufferIndexFromFunction(fun, entry-1)
    obj = MtlArgumentEncoder(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(enc::MtlArgumentEncoder)
    mtRelease(enc.handle)
end

Base.unsafe_convert(::Type{MTLArgumentEncoder}, enc::MtlArgumentEncoder) = enc.handle

Base.:(==)(a::MtlArgumentEncoder, b::MtlArgumentEncoder) = a.handle == b.handle
Base.hash(fun::MtlArgumentEncoder, h::UInt) = hash(mod.handle, h)


## properties

Base.propertynames(o::MtlArgumentEncoder) = (
    # identification
    #=:device, :label,=#
    # creation
    :encodedLength,
    # alignment
    :alignment,
)

function Base.getproperty(o::MtlArgumentEncoder, f::Symbol)
    if f === :encodedLength
        mtArgumentEncoderLength(o)
    elseif f === :alignment
        mtArgumentEncoderAlignment(o)
    else
        getfield(o, f)
    end
end

Base.sizeof(a::MtlArgumentEncoder) = Int(mtArgumentEncoderLength(a))


## operations

# NOTE: indices aren't 1-based here, because they map onto exact IDs in the metadata

function assign_argument_buffer!(enc::MtlArgumentEncoder, buf::MtlBuffer, offset::Integer=0)
    mtArgumentEncoderSetArgumentBufferWithOffset(enc, buf, offset)
end

function assign_argument_buffer!(enc::MtlArgumentEncoder, buf::MtlBuffer, offset::Integer, element::Integer)
    mtArgumentEncoderSetArgumentBufferWithOffsetForElement(enc, buf, offset, element)
end

set_buffer!(enc::MtlArgumentEncoder, buf::MtlBuffer, offset::Integer, index::Integer) =
    mtArgumentEncoderSetBufferOffsetAtIndex(enc, buf, offset, index)
set_buffers!(enc::MtlArgumentEncoder, bufs::Vector{<:MtlBuffer},
             offsets::Vector{Int}, indices::UnitRange{Int}) =
    mtArgumentEncoderSetBuffersOffsetsWithRange(enc, handle_array(bufs), offsets, indices)

function set_constant!(enc::MtlArgumentEncoder, val, index::Integer)
    dst = Base.bitcast(Ptr{typeof(val)}, mtArgumentEncoderConstantDataAtIndex(enc, index))
    unsafe_store!(dst, val, 1)
    return
end
