export MTL4ComputeCommandEncoder
export set_argument_table!, set_threadgroup_memory_length!

# @objcwrapper managed = true MTL4ComputeCommandEncoder <: MTL4CommandEncoder

function MTL4ComputeCommandEncoder(cmdbuf::MTL4CommandBuffer)
    return @objc [cmdbuf::id{MTL4CommandBuffer} computeCommandEncoder]::MTL4ComputeCommandEncoder
end

function MTL4ComputeCommandEncoder(f::Base.Callable, cmdbuf::MTL4CommandBuffer)
    encoder = MTL4ComputeCommandEncoder(cmdbuf)
    try
        f(encoder)
    finally
        close(encoder)
    end
end

## pipeline and argument state

function set_function!(cce::MTL4ComputeCommandEncoder, pipeline::MTLComputePipelineState)
    @objc [cce::id{MTL4ComputeCommandEncoder} setComputePipelineState:pipeline::id{MTLComputePipelineState}]::Nothing
end

function set_argument_table!(cce::MTL4ComputeCommandEncoder, argtab::MTL4ArgumentTable)
    @objc [cce::id{MTL4ComputeCommandEncoder} setArgumentTable:argtab::id{MTL4ArgumentTable}]::Nothing
end

function set_threadgroup_memory_length!(cce::MTL4ComputeCommandEncoder, length::Integer,
                                        index::Integer)
    @objc [cce::id{MTL4ComputeCommandEncoder} setThreadgroupMemoryLength:length::NSUInteger
                                                                 atIndex:(index-1)::NSUInteger]::Nothing
end

"""
    stages(cce::MTL4ComputeCommandEncoder)::MTLStages

The set of pipeline stages this encoder can encode work for; the natural argument for the
`after`/`before` parameters of the barrier functions.
"""
function stages(cce::MTL4ComputeCommandEncoder)
    @objc [cce::id{MTL4ComputeCommandEncoder} stages]::MTLStages
end

## dispatch

function dispatchThreadgroups!(cce::MTL4ComputeCommandEncoder, threadgroupsPerGrid::MTLSize,
                               threadsPerThreadgroup::MTLSize)
    @objc [cce::id{MTL4ComputeCommandEncoder} dispatchThreadgroups:threadgroupsPerGrid::MTLSize
                                              threadsPerThreadgroup:threadsPerThreadgroup::MTLSize]::Nothing
end

function dispatchThreads!(cce::MTL4ComputeCommandEncoder, threadsPerGrid::MTLSize,
                          threadsPerThreadgroup::MTLSize)
    @objc [cce::id{MTL4ComputeCommandEncoder} dispatchThreads:threadsPerGrid::MTLSize
                                         threadsPerThreadgroup:threadsPerThreadgroup::MTLSize]::Nothing
end

function append_current_function!(cce::MTL4ComputeCommandEncoder, threadgroupsPerGrid,
                                  threadsPerThreadgroup)
    dispatchThreadgroups!(cce, threadgroupsPerGrid, threadsPerThreadgroup)
end

## copy and fill
#
# Metal 4 folds the Metal 3 blit encoder's buffer operations into the compute encoder.

function append_copy!(cce::MTL4ComputeCommandEncoder, dst::MTLBuffer, doff,
                      src::MTLBuffer, soff, len)
    @objc [cce::id{MTL4ComputeCommandEncoder} copyFromBuffer:src::id{MTLBuffer}
                                                sourceOffset:soff::NSUInteger
                                                    toBuffer:dst::id{MTLBuffer}
                                           destinationOffset:doff::NSUInteger
                                                        size:len::NSUInteger]::Nothing
end

for T in (UInt8, Int8)
    @eval function append_fillbuffer!(cce::MTL4ComputeCommandEncoder, buf::MTLBuffer,
                                      value::$T, bytesize, offset=0)
        range = NSRange(offset, bytesize)
        @objc [cce::id{MTL4ComputeCommandEncoder} fillBuffer:buf::id{MTLBuffer}
                                                       range:range::NSRange
                                                       value:value::$T]::Nothing
    end
end

function append_fillbuffer!(cce::MTL4ComputeCommandEncoder, buf::MTLBuffer, range::NSRange,
                            value::UInt8)
    @objc [cce::id{MTL4ComputeCommandEncoder} fillBuffer:buf::id{MTLBuffer}
                                                   range:range::NSRange
                                                   value:value::UInt8]::Nothing
end

## residency

function use!(cce::MTL4ComputeCommandEncoder, bufs::Vector{MTLBuffer},
              mode::MTLResourceUsage=ReadWriteUsage)
    @objc [cce::id{MTL4ComputeCommandEncoder} useResources:bufs::id{MTLBuffer}
                                                    count:length(bufs)::NSUInteger
                                                    usage:mode::MTLResourceUsage]::Nothing
end
