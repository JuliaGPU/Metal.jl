export MTLComputeCommandEncoder
export set_function!, set_buffer!, set_threadgroup_memory_length!, dispatchThreadgroups!, endEncoding!
export append_current_function!

# @objcwrapper immutable=false MTLComputeCommandEncoder <: MTLCommandEncoder

function MTLComputeCommandEncoder(cmdbuf::MTLCommandBuffer;
                                  dispatch_type::Union{Nothing,MTLDispatchType} = nothing)
    handle = if isnothing(dispatch_type)
        @objc [cmdbuf::id{MTLCommandBuffer} computeCommandEncoder]::id{MTLComputeCommandEncoder}
    else
        @objc [cmdbuf::id{MTLCommandBuffer} computeCommandEncoderWithDispatchType:dispatch_type::MTLDispatchType]::id{MTLComputeCommandEncoder}
    end

    MTLComputeCommandEncoder(handle)
end

function set_function!(cce::MTLComputeCommandEncoder, pip::MTLComputePipelineState)
    @objc [cce::id{MTLComputeCommandEncoder} setComputePipelineState:pip::id{MTLComputePipelineState}]::Nothing
end

function set_buffer!(cce::MTLComputeCommandEncoder, buf::MTLBuffer, offset, index)
    @objc [cce::id{MTLComputeCommandEncoder} setBuffer:buf::id{MTLBuffer}
                                             offset:offset::NSUInteger
                                             atIndex:(index-1)::NSUInteger]::Nothing
end

function set_threadgroup_memory_length!(cce::MTLComputeCommandEncoder, len, index)
    @objc [cce::id{MTLComputeCommandEncoder} setThreadgroupMemoryLength:len::NSUInteger
                                             atIndex:(index-1)::NSUInteger]::Nothing
end

function dispatchThreadgroups!(cce::MTLComputeCommandEncoder, threadgroupsPerGrid, threadsPerThreadgroup)
    @objc [cce::id{MTLComputeCommandEncoder} dispatchThreadgroups:threadgroupsPerGrid::MTLSize
                                             threadsPerThreadgroup:threadsPerThreadgroup::MTLSize]::Nothing
end

function dispatchThreads!(cce::MTLComputeCommandEncoder, threadsPerGrid::MTLSize, threadsPerThreadgroup::MTLSize)
    @objc [cce::id{MTLComputeCommandEncoder} dispatchThreads:threadsPerGrid::MTLSize
                                             threadsPerThreadgroup:threadsPerThreadgroup::MTLSize]::Nothing
end

#####
# encode in the Command Encoder

function MTLComputeCommandEncoder(f::Base.Callable, cmdbuf::MTLCommandBuffer; kwargs...)
    encoder = MTLComputeCommandEncoder(cmdbuf; kwargs...)
    try
        f(encoder)
    finally
        close(encoder)
    end
end

function append_current_function!(cce::MTLComputeCommandEncoder, threadgroupsPerGrid, threadsPerThreadgroup)
    dispatchThreadgroups!(cce, threadgroupsPerGrid, threadsPerThreadgroup)
end

#### use

function use!(cce::MTLComputeCommandEncoder, buf::MTLBuffer, mode::MTLResourceUsage=ReadWriteUsage)
    @objc [cce::id{MTLComputeCommandEncoder} useResource:buf::id{MTLBuffer}
                                             usage:mode::MTLResourceUsage]::Nothing
end

function use!(cce::MTLComputeCommandEncoder, buf::Vector{MTLBuffer}, mode::MTLResourceUsage=ReadWriteUsage)
    @objc [cce::id{MTLComputeCommandEncoder} useResources:buf::id{MTLBuffer}
                                             count:length(buf)::Csize_t
                                             usage:mode::MTLResourceUsage]::Nothing
end
