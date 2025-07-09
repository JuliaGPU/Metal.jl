export MTL4ComputeCommandEncoder
export set_function!, set_buffer!, set_bytes!, set_texture!, set_sampler_state!
export dispatchThreadgroups!, dispatchThreads!, endEncoding!
export use!, memoryBarrier!, append_copy!, append_fillbuffer!, append_sync!

# @objcwrapper immutable=false MTL4ComputeCommandEncoder <: MTL4CommandEncoder

function MTL4ComputeCommandEncoder(cmdbuf::MTL4CommandBuffer)
    handle = @objc [cmdbuf::id{MTL4CommandBuffer} computeCommandEncoder]::id{MTL4ComputeCommandEncoder}
    obj = MTL4ComputeCommandEncoder(handle)
    # finalizer(release, obj)
    return obj
end


function MTL4ComputeCommandEncoder(f::Base.Callable, cmdbuf::MTL4CommandBuffer, sync=false)
    encoder = MTL4ComputeCommandEncoder(cmdbuf)
    try
        f(encoder)
    finally
        sync && barrierAfterStages!(encoder)
        close(encoder)
    end
end

# Pipeline State
function set_function!(cce::MTL4ComputeCommandEncoder, pipeline::MTLComputePipelineState)
    @objc [cce::id{MTL4ComputeCommandEncoder} setComputePipelineState:pipeline::id{MTLComputePipelineState}]::Nothing
end

function set_argument_table!(cce::MTL4ComputeCommandEncoder, arg_table::MTL4ArgumentTable)
    @objc [cce::id{MTL4ComputeCommandEncoder} setArgumentTable:arg_table::id{MTL4ArgumentTable}]::Nothing
end

# Dispatch Commands
function dispatchThreadgroups!(cce::MTL4ComputeCommandEncoder, gridSize::MTLSize, threadGroupSize::MTLSize)
    @objc [cce::id{MTL4ComputeCommandEncoder} dispatchThreadgroups:gridSize::MTLSize
                                             threadsPerThreadgroup:threadGroupSize::MTLSize]::Nothing
end

function dispatchThreads!(cce::MTL4ComputeCommandEncoder, threadsSize::MTLSize, threadsPerThreadgroup::MTLSize)
    @objc [cce::id{MTL4ComputeCommandEncoder} dispatchThreads:threadsSize::MTLSize
                                             threadsPerThreadgroup:threadsPerThreadgroup::MTLSize]::Nothing
end

# Copy Operations (Blit functionality integrated into compute encoder in Metal 4)
function append_copy!(cce::MTL4ComputeCommandEncoder, dst::MTLBuffer, dstOffset::Integer,
                      src::MTLBuffer, srcOffset::Integer, size::Integer)
    @objc [cce::id{MTL4ComputeCommandEncoder} copyFromBuffer:src::id{MTLBuffer}
                                             sourceOffset:srcOffset::NSUInteger
                                             toBuffer:dst::id{MTLBuffer}
                                             destinationOffset:dstOffset::NSUInteger
                                             size:size::NSUInteger]::Nothing
end

# function append_copy!(cce::MTL4ComputeCommandEncoder, dst::MTLTexture, dstSlice::Integer, dstLevel::Integer, dstOrigin::MTLOrigin,
#                       src::MTLBuffer, srcOffset::Integer, srcBytesPerRow::Integer, srcBytesPerImage::Integer,
#                       size::MTLSize)
#     @objc [cce::id{MTL4ComputeCommandEncoder} copyFromBuffer:src::id{MTLBuffer}
#                                              sourceOffset:srcOffset::NSUInteger
#                                              sourceBytesPerRow:srcBytesPerRow::NSUInteger
#                                              sourceBytesPerImage:srcBytesPerImage::NSUInteger
#                                              sourceSize:size::MTLSize
#                                              toTexture:dst::id{MTLTexture}
#                                              destinationSlice:dstSlice::NSUInteger
#                                              destinationLevel:dstLevel::NSUInteger
#                                              destinationOrigin:dstOrigin::MTLOrigin]::Nothing
# end

# Fill Buffer
function append_fillbuffer!(cce::MTL4ComputeCommandEncoder, buffer::MTLBuffer, range::NSRange, value::UInt8)
    @objc [cce::id{MTL4ComputeCommandEncoder} fillBuffer:buffer::id{MTLBuffer}
                                             range:range::NSRange
                                             value:value::UInt8]::Nothing
end

function append_fillbuffer!(cce::MTL4ComputeCommandEncoder, buffer::MTLBuffer, value::UInt8,
                           byteSize::Integer, offset::Integer=0)
    range = NSRange(offset, byteSize)
    append_fillbuffer!(cce, buffer, range, value)
end

# Convenience dispatch function for encoding
function append_current_function!(cce::MTL4ComputeCommandEncoder, gridSize::MTLSize, threadGroupSize::MTLSize)
    dispatchThreadgroups!(cce, gridSize, threadGroupSize)
end
