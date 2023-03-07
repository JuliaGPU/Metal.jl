export MTLComputeCommandEncoder
export set_function!, set_buffer!, set_bytes!, dispatchThreads!, endEncoding!
export set_buffers!, append_current_function!

@objcwrapper immutable=false MTLComputeCommandEncoder <: MTLCommandEncoder

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtComputeCommandEncoder}}, obj::MTLComputeCommandEncoder) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLComputeCommandEncoder(ptr::Ptr{MtComputeCommandEncoder}) =
    MTLComputeCommandEncoder(reinterpret(id{MTLComputeCommandEncoder}, ptr))

function MTLComputeCommandEncoder(cmdbuf::MTLCommandBuffer;
                                  dispatch_type::Union{Nothing,MtDispatchType} = nothing)
    handle = if isnothing(dispatch_type)
        @objc [cmdbuf::id{MTLCommandBuffer} computeCommandEncoder]::id{MTLComputeCommandEncoder}
    else
        @objc [cmdbuf::id{MTLCommandBuffer} computeCommandEncoderWithDispatchType:dispatch_type::MtDispatchType]::id{MTLComputeCommandEncoder}
    end

    obj = MTLComputeCommandEncoder(handle)
    finalizer(unsafe_destroy!, obj)

    # Per Apple's "Basic Memory Management Rules" the above invocation does not imply
    # ownership. To be consistent the name of the function and CF_RETURNS_RETAINED, we
    # explicitly claim ownership with an explicit `retain`
    retain(obj)

    return obj
end

device(cce::MTLComputeCommandEncoder) = cce.cmdbuf.device

set_function!(cce::MTLComputeCommandEncoder, pip::MtlComputePipelineState) =
    mtComputeCommandEncoderSetComputePipelineState(cce, pip)

set_buffer!(cce::MTLComputeCommandEncoder, buf::MTLBuffer, offset::Integer, index::Integer) =
    mtComputeCommandEncoderSetBufferOffsetAtIndex(cce, buf, offset, index - 1)
#set_bufferoffset!(cce::MTLComputeCommandEncoder, offset::Integer, index::Integer) =
#    mtComputeCommandEncoderBufferSetOffsetAtIndex(cce, offset, index)
set_buffers!(cce::MTLComputeCommandEncoder, bufs::Vector{T},
             offsets::Vector{Int}, indices::UnitRange{Int}) where {T<:MTLBuffer} =
    mtComputeCommandEncoderSetBuffersOffsetsWithRange(cce, handle_array(bufs), offsets, indices .- 1)
#=set_buffers!(cce::MTLComputeCommandEncoder, bufs::Vector{MtlPtr{T}},
             offsets::Vector{Int}, indices::UnitRange{Int}) where {T} =
    mtComputeCommandEncoderSetBuffersOffsetsWithRange(cce, bufs, offsets, indices .- 1)=#

set_bytes!(cce::MTLComputeCommandEncoder, ptr, length::Integer, index::Integer) =
    mtComputeCommandEncoderSetBytesLengthAtIndex(cce, ptr, length, index - 1)

dispatchThreadgroups!(cce::MTLComputeCommandEncoder, gridSize::MtSize, threadGroupSize::MtSize) =
    mtComputeCommandEncoderDispatchThreadgroups_threadsPerThreadgroup(cce, gridSize, threadGroupSize)

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

function append_current_function!(cce::MTLComputeCommandEncoder, gridSize::MtSize, threadGroupSize::MtSize)
    dispatchThreadgroups!(cce, gridSize, threadGroupSize)
end

#### use

function use!(cce::MTLComputeCommandEncoder, buf::MTLBuffer, mode::MtResourceUsage=ReadWriteUsage)
    @objc [cce::id{MTLComputeCommandEncoder} useResource:buf::id{MTLBuffer}
                                             usage:mode::MtResourceUsage]::Nothing
end

function use!(cce::MTLComputeCommandEncoder, buf::Vector{MTLBuffer}, mode::MtResourceUsage=ReadWriteUsage)
    @objc [cce::id{MTLComputeCommandEncoder} useResources:buf::id{MTLBuffer}
                                             count:length(buf)::Csize_t
                                             usage:mode::MtResourceUsage]::Nothing
end
