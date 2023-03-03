#
# compute pipeline descriptor
#

export MtlComputePipelineDescriptor

const MTLComputePipelineDescriptor = Ptr{MtComputePipelineDescriptor}

mutable struct MtlComputePipelineDescriptor
    handle::MTLComputePipelineDescriptor
end

Base.unsafe_convert(::Type{MTLComputePipelineDescriptor}, q::MtlComputePipelineDescriptor) = q.handle

Base.:(==)(a::MtlComputePipelineDescriptor, b::MtlComputePipelineDescriptor) = a.handle == b.handle
Base.hash(lib::MtlComputePipelineDescriptor, h::UInt) = hash(lib.handle, h)

function MtlComputePipelineDescriptor()
    handle = mtNewComputePipelineDescriptor()
    obj = MtlComputePipelineDescriptor(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(desc::MtlComputePipelineDescriptor)
    mtRelease(desc.handle)
end


## properties

Base.propertynames(::MtlComputePipelineDescriptor) = (
    :label, :computeFunction, :threadGroupSizeIsMultipleOfExecutionWidth,
    :maxTotalThreads, :maxCallStackDepth, :supportIndirectCommandBuffers
)

function Base.getproperty(o::MtlComputePipelineDescriptor, f::Symbol)
    if f === :label
        ptr = mtComputePipelineDescriptorLabel(o)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    elseif f === :computeFunction
        ptr = mtComputePipelineDescriptorComputeFunction(o)
        ptr == C_NULL ? nothing : MtlFunction(ptr)
    elseif f === :threadGroupSizeIsMultipleOfThreadExecutionWidth
        mtComputePipelineDescriptorThreadGroupSizeIsMultipleOfThreadExecutionWidth(o)
    elseif f === :maxTotalThreadsPerThreadgroup
        mtComputePipelineDescriptorMaxTotalThreadsPerThreadgroup(o)
    elseif f === :maxCallStackDepth
        mtComputePipelineDescriptorMaxCallStackDepth(o)
    elseif f === :supportIndirectCommandBuffers
        mtComputePipelineDescriptorSupportIndirectCommandBuffers(o)
    else
        getfield(o, f)
    end
end

function Base.setproperty!(o::MtlComputePipelineDescriptor, f::Symbol, val)
    if f === :label
        mtComputePipelineDescriptorLabelSet(o, val)
    elseif f === :computeFunction
        mtComputePipelineDescriptorComputeFunctionSet(o, val)
    elseif f === :threadGroupSizeIsMultipleOfThreadExecutionWidth
        mtComputePipelineDescriptorThreadGroupSizeIsMultipleOfThreadExecutionWidthSet(o, val)
    elseif f === :maxTotalThreadsPerThreadgroup
        mtComputePipelineDescriptorMaxTotalThreadsPerThreadgroupSet(o, val)
    elseif f === :maxCallStackDepth
        mtComputePipelineDescriptorMaxCallStackDepthSet(o, val)
    else
        setfield!(opts, f, val)
    end
end


## display

function Base.show(io::IO, bin::MtlComputePipelineDescriptor)
    print(io, "MtlComputePipelineDescriptor(…)")
end

function Base.show(io::IO, ::MIME"text/plain", q::MtlComputePipelineDescriptor)
    println(io, "MtlComputePipelineDescriptor:")
    println(io, "  label: ", q.label)
    println(io, "  computeFunction: ", q.computeFunction)
    println(io, "  threadGroupSizeIsMultipleOfThreadExecutionWidth: ", q.threadGroupSizeIsMultipleOfThreadExecutionWidth)
    println(io, "  maxTotalThreadsPerThreadgroup: ", q.maxTotalThreadsPerThreadgroup)
    println(io, "  maxCallStackDepth: ", q.maxCallStackDepth)
    println(io, "  supportIndirectCommandBuffers: ", q.supportIndirectCommandBuffers)
end


#
# compute pipeline state
#

export MtlComputePipelineState

const MTLComputePipelineState = Ptr{MtComputePipelineState}

"""
    MtlComputePipelineState(d::MTLDevice, f::MtlFunction)

Create an object that stores information about the execution parameters of a MtlFunction.
"""
mutable struct MtlComputePipelineState
    handle::MTLComputePipelineState
    device::MTLDevice
end

Base.unsafe_convert(::Type{MTLComputePipelineState}, q::MtlComputePipelineState) = q.handle

Base.:(==)(a::MtlComputePipelineState, b::MtlComputePipelineState) = a.handle == b.handle
Base.hash(q::MtlComputePipelineState, h::UInt) = hash(q.handle, h)

function unsafe_destroy!(cce::MtlComputePipelineState)
    mtRelease(cce.handle)
end

function MtlComputePipelineState(d::MTLDevice, f::MtlFunction)
    handle = @mtlthrows _errptr mtNewComputePipelineStateWithFunction(d, f, _errptr)

    obj = MtlComputePipelineState(handle, d)
    finalizer(unsafe_destroy!, obj)
    return obj
end

# TODO: MtlComputePipelineState(d::MTLDevice, desc::MtlComputePipelineDescriptor, ...)


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
        return MTLDevice(mtComputePipelineDevice(o))
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
