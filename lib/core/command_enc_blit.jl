export MtlBlitCommandEncoder, append_copy!, append_fillbuffer!, append_sync!

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
append_copy!(enc::MtlBlitCommandEncoder, dst::MtlBuffer, dst_offset, src::MtlBuffer, src_offset, len) =
    mtBlitCommandEncoderCopyFromBufferToBuffer(enc, src, src_offset-1, dst, dst_offset-1, len)

append_fillbuffer!(enc::MtlBlitCommandEncoder, src::MtlBuffer,
                    val::Union{Int8, UInt8}, range) =
    mtBlitCommandEncoderFillBuffer(enc, src, UnitRange(0:range-1), val)

# only for managed resources
append_sync!(enc::MtlBlitCommandEncoder, src::MtlBuffer) =
    mtBlitCommandencoderSynchronizeResource!(enc, src)
