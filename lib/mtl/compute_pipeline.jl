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
    pipeline = @objc [dev::id{MTLDevice} newComputePipelineStateWithFunction:fun::id{MTLFunction}
                                          error:err::Ptr{id{NSError}}]::Union{Nothing,MTLComputePipelineState}
    pipeline === nothing && throw_error(err[])

    return pipeline
end

# TODO: MTLComputePipelineState(d::MTLDevice, desc::MTLComputePipelineDescriptor, ...)
