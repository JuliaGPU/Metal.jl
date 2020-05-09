export 
    MtlComputePipelineState

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
        mtComputePipelineRelease(cce)
    end
end

function MtlComputePipelineState(d::MtlDevice, f::MtlFunction)
    handle = mtNewComputePipelineStateWithFunction(d, f)
    obj = MtlComputePipelineState(handle, d)
    finalizer(unsafe_destroy!, obj)
    return obj
end

device(l::MtlComputePipelineState) = l.device
function label(l::MtlComputePipelineState)
    ptr = mtComputePipelineLabel(l)
    if ptr == C_NULL
        return "" 
    else
        return unsafe_string(ptr) 
    end
end


Base.propertynames(o::MtlComputePipelineState) = 
    (:maxTotalThreadsPerThreadgroup, :threadExecutionWidth, :staticThreadgroupMemoryLength, :device, :label)

function Base.getproperty(o::MtlComputePipelineState, f::Symbol)
    if f === :handle
        return getfield(o, :handle)
    elseif f === :maxTotalThreadsPerThreadgroup
        return mtComputePipelineMaxTotalThreadsPerThreadgroup(o)
    elseif f === :threadExecutionWidth
        return mtComputePipelineThreadExecutionWidth(o)
    elseif f === :staticThreadgroupMemoryLength
        return mtComputePipelineStaticThreadgroupMemoryLength(o)
    elseif f === :device
        return getfield(o, :device)
    elseif f === :label
        return label(o)
    else
        error("MtlComputePipelineState does not have field $f")
    end
end