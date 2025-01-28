export MTLBlitCommandEncoder, append_copy!, append_fillbuffer!, append_sync!

# @objcwrapper MTLBlitCommandEncoder <: MTLCommandEncoder

function MTLBlitCommandEncoder(cmdbuf::MTLCommandBuffer)
    handle = @objc [cmdbuf::id{MTLCommandBuffer} blitCommandEncoder]::id{MTLBlitCommandEncoder}
    MTLBlitCommandEncoder(handle)
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

for T in (UInt8, Int8)
    @eval begin
        function append_fillbuffer!(enc::MTLBlitCommandEncoder, src::MTLBuffer,
                                    val::$T, bytesize, offset=0)
            range = NSRange(offset, bytesize)
            @objc [enc::id{MTLBlitCommandEncoder} fillBuffer:src::id{MTLBuffer}
                                                  range:range::NSRange
                                                  value:val::$T]::Nothing
            end
    end
end

# only for managed resources
function append_sync!(enc::MTLBlitCommandEncoder, src::MTLBuffer)
    @objc [enc::id{MTLBlitCommandEncoder} synchronizeResource:src::id{MTLBuffer}]::Nothing
end
