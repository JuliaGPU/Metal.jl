export MtlComputePipelineState

const MTLComputePipelineState = Ptr{MtComputePipelineState}

mutable struct MtlComputePipelineState
    handle::MTLComputePipelineState
    device::MtlDevice
end

Base.convert(::Type{MTLComputePipelineState}, q::MtlComputePipelineState) = q.handle
Base.unsafe_convert(::Type{MTLComputePipelineState}, q::MtlComputePipelineState) = convert(MTLComputePipelineState, q.handle)

Base.:(==)(a::MtlComputePipelineState, b::MtlComputePipelineState) = a.handle == b.handle
Base.hash(q::MtlComputePipelineState, h::UInt) = hash(q.handle, h)

function unsafe_destroy!(cce::MtlComputePipelineState)
    if cce.handle !== C_NULL
        mtRelease(cce.handle)
    end
end

function MtlComputePipelineState(d::MtlDevice, f::MtlFunction)
    handle = @mtlthrows _errptr mtNewComputePipelineStateWithFunction(d, f, _errptr)

    obj = MtlComputePipelineState(handle, d)
    finalizer(unsafe_destroy!, obj)
    return obj
end


## properties

Base.propertynames(o::MtlComputePipelineState) = (
    # identification
    :device, :label,
    # threadgroup attributes
    :maxTotalThreadsPerThreadgroup, :threadExecutionWidth, :staticThreadgroupMemoryLength,
    #other
    #=supportIndirectCommandBuffers=#
)

function Base.getproperty(o::MtlComputePipelineState, f::Symbol)
    if f === :device
        return MtlDevice(mtComputePipelineDevice(o))
    elseif f === :label
        ptr = mtComputePipelineLabel(o)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    elseif f === :maxTotalThreadsPerThreadgroup
        return Int(mtComputePipelineMaxTotalThreadsPerThreadgroup(o))
    elseif f === :threadExecutionWidth
        return Int(mtComputePipelineThreadExecutionWidth(o))
    elseif f === :staticThreadgroupMemoryLength
        return Int(mtComputePipelineStaticThreadgroupMemoryLength(o))
    else
        getfield(o, f)
    end
end
