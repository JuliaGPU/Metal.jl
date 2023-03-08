export MTLComputeCommandEncoder
export set_function!, set_buffer!, set_bytes!, dispatchThreads!, endEncoding!
export set_buffers!, append_current_function!

@cenum MTLDispatchType::NSUInteger begin
    MTLDispatchTypeSerial = 0
    MTLDispatchTypeConcurrent = 1
end

@objcwrapper immutable=false MTLComputeCommandEncoder <: MTLCommandEncoder

function MTLComputeCommandEncoder(cmdbuf::MTLCommandBuffer;
                                  dispatch_type::Union{Nothing,MTLDispatchType} = nothing)
    handle = if isnothing(dispatch_type)
        @objc [cmdbuf::id{MTLCommandBuffer} computeCommandEncoder]::id{MTLComputeCommandEncoder}
    else
        @objc [cmdbuf::id{MTLCommandBuffer} computeCommandEncoderWithDispatchType:dispatch_type::MTLDispatchType]::id{MTLComputeCommandEncoder}
    end

    obj = MTLComputeCommandEncoder(handle)
    finalizer(release, obj)

    # Per Apple's "Basic Memory Management Rules" the above invocation does not imply
    # ownership. To be consistent the name of the function and CF_RETURNS_RETAINED, we
    # explicitly claim ownership with an explicit `retain`
    retain(obj)

    return obj
end

function set_function!(cce::MTLComputeCommandEncoder, pip::MTLComputePipelineState)
    @objc [cce::id{MTLComputeCommandEncoder} setComputePipelineState:pip::id{MTLComputePipelineState}]::Nothing
end

function set_buffer!(cce::MTLComputeCommandEncoder, buf::MTLBuffer, offset, index)
    @objc [cce::id{MTLComputeCommandEncoder} setBuffer:buf::id{MTLBuffer}
                                             offset:offset::NSUInteger
                                             atIndex:(index-1)::NSUInteger]::Nothing
end

function dispatchThreadgroups!(cce::MTLComputeCommandEncoder, gridSize, threadGroupSize)
    @objc [cce::id{MTLComputeCommandEncoder} dispatchThreadgroups:gridSize::MTLSize
                                             threadsPerThreadgroup:threadGroupSize::MTLSize]::Nothing
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

function append_current_function!(cce::MTLComputeCommandEncoder, gridSize, threadGroupSize)
    dispatchThreadgroups!(cce, gridSize, threadGroupSize)
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
