export MtlBlitCommandEncoder, append_copy!, append_fillbuffer!, append_sync!

const MTLBlitCommandEncoder = Ptr{MtBlitCommandEncoder}

mutable struct MtlBlitCommandEncoder <: MtlCommandEncoder
    handle::MTLBlitCommandEncoder
    cmdbuf::MtlCommandBuffer
end

Base.unsafe_convert(::Type{MTLBlitCommandEncoder}, e::MtlBlitCommandEncoder) = e.handle

function MtlBlitCommandEncoder(cmdbuf::MtlCommandBuffer)
    handle = mtNewBlitCommandEncoder(cmdbuf)
    obj = MtlBlitCommandEncoder(handle, cmdbuf)
    finalizer(unsafe_destroy!, obj)
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
append_copy!(enc::MtlBlitCommandEncoder, dst::MTLBuffer, doff, src::MTLBuffer, soff, len) =
    mtBlitCommandEncoderCopyFromBufferToBuffer(enc, src, soff, dst, doff, len)

append_fillbuffer!(enc::MtlBlitCommandEncoder, src::MTLBuffer,
                   val::Union{Int8, UInt8}, bytesize, offset=0) =
    mtBlitCommandEncoderFillBuffer(enc, src, UnitRange(offset:bytesize-1), val)

# only for managed resources
append_sync!(enc::MtlBlitCommandEncoder, src::MTLBuffer) =
    mtBlitCommandencoderSynchronizeResource!(enc, src)
