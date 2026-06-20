#
# compute pipeline descriptor
#

export MTLComputePipelineDescriptor

# @objcwrapper managed = true MTLComputePipelineDescriptor <: NSObject

function MTLComputePipelineDescriptor()
    return @objc [MTLComputePipelineDescriptor new]::MTLComputePipelineDescriptor
end

#
# compute pipeline state
#

export MTLComputePipelineState

# @objcwrapper managed = true MTLComputePipelineState <: NSObject

function MTLComputePipelineState(dev::MTLDevice, fun::MTLFunction)
    err = Ref{id{NSError}}(nil)
    handle = @objc [dev::id{MTLDevice} newComputePipelineStateWithFunction:fun::id{MTLFunction}
                                       error:err::Ptr{id{NSError}}]::id{MTLComputePipelineState}
    err[] == nil || throw_error(err[])

    return adopt(MTLComputePipelineState, handle)
end

# TODO: MTLComputePipelineState(d::MTLDevice, desc::MTLComputePipelineDescriptor, ...)
