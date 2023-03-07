export MTLBlitCommandEncoder, append_copy!, append_fillbuffer!, append_sync!

@objcwrapper immutable=false MTLBlitCommandEncoder <: MTLCommandEncoder

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtBlitCommandEncoder}}, obj::MTLBlitCommandEncoder) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLBlitCommandEncoder(ptr::Ptr{MtBlitCommandEncoder}) = MTLBlitCommandEncoder(reinterpret(id{MTLBlitCommandEncoder}, ptr))

function MTLBlitCommandEncoder(cmdbuf::MTLCommandBuffer)
    handle = @objc [cmdbuf::id{MTLCommandBuffer} blitCommandEncoder]::id{MTLBlitCommandEncoder}
    obj = MTLBlitCommandEncoder(handle)
    finalizer(unsafe_destroy!, obj)

    # Per Apple's "Basic Memory Management Rules" the above invocation does not imply
    # ownership. To be consistent the name of the function and CF_RETURNS_RETAINED, we
    # explicitly claim ownership with an explicit `retain`
    retain(obj)

    return obj
end

## encode in the Command Encoder
function MTLBlitCommandEncoder(f::Base.Callable, cmdbuf::MTLCommandBuffer)
    encoder = MTLBlitCommandEncoder(cmdbuf)
    f(encoder)
    close(encoder)
    return encoder
end

##
# Copy from device to device
function append_copy!(enc::MTLBlitCommandEncoder, dst::MTLBuffer, doff,
                      src::MTLBuffer, soff, len)
    @objc [enc::id{MTLBlitCommandEncoder} copyFromBuffer:src::id{MTLBuffer}
                                          sourceOffset:soff::Csize_t
                                          toBuffer:dst::id{MTLBuffer}
                                          destinationOffset:doff::Csize_t
                                          size:len::Csize_t]::Nothing
end

function append_fillbuffer!(enc::MTLBlitCommandEncoder, src::MTLBuffer,
                            val::Union{Int8, UInt8}, bytesize, offset=0)
    range = NSRange(offset, bytesize)
    @objc [enc::id{MTLBlitCommandEncoder} fillBuffer:src::id{MTLBuffer}
                                          range:range::NSRange
                                          value:val::UInt8]::Nothing
end

# only for managed resources
function append_sync!(enc::MTLBlitCommandEncoder, src::MTLBuffer)
    @objc [enc::id{MTLBlitCommandEncoder} synchronizeResource:src::id{MTLBuffer}]::Nothing
end
