export MtlBlitCommandEncoder

const MTLBlitCommandEncoder = Ptr{MtBlitCommandEncoder}

mutable struct MtlBlitCommandEncoder <: MtlCommandEncoder
    handle::MTLBlitCommandEncoder
    cmdbuf::MtlCommandBuffer
end

Base.convert(::Type{MTLBlitCommandEncoder}, e::MtlBlitCommandEncoder) = e.handle
Base.unsafe_convert(::Type{MTLBlitCommandEncoder}, e::MtlBlitCommandEncoder) = convert(MTLBlitCommandEncoder, e.handle)

function MtlBlitCommandEncoder(cmdbuf::MtlCommandBuffer)
    handle = mtNewBlitCommandEncoder(cmdbuf)
    obj = MtlBlitCommandEncoder(handle, cmdbuf)
    #finalizer(unsafe_destroy!, obj)
    return obj
end

## encode in the Command Encoder
function MtlBlitCommandEncoder(f::Base.Callable, cmdbuf::MtlCommandBuffer)
    encoder = MtlBlitCommandEncoder(cmdbuf)
    f(encoder)
    close(encoder)
    return encoder
end

##
# Copy from device to device
append_copy!(enc::MtlBlitCommandEncoder,
             src::Union{MtlPtr,Buffer,MtlBuffer},
             dst::Union{MtlPtr,Buffer,MtlBuffer},
             src_offset, dst_offset, len) =
    mtBlitCommandEncoderCopyFromBufferToBuffer(enc, src, src_offset,
    dst, dst_offset, len)

append_fillbuffer!(enc::MtlBlitCommandEncoder,
                    src::Union{MtlPtr,Buffer,MtlBuffer},
                    val::UInt8, range) =
    mtBlitCommandEncoderFillBuffer(enc, src, range, val)

# only for managed resources
append_sync!(enc::MtlBlitCommandEncoder, src::Union{MtlPtr,Buffer,MtlBuffer}) = 
    mtBlitCommandencoderSynchronizeResource!(enc, src)