#
# compute pipeline descriptor
#

export MTLComputePipelineDescriptor

# @objcwrapper immutable=false MTLComputePipelineDescriptor <: NSObject

function MTLComputePipelineDescriptor()
    handle = @objc [MTLComputePipelineDescriptor new]::id{MTLComputePipelineDescriptor}
    obj = MTLComputePipelineDescriptor(handle)
    finalizer(release, obj)
    return obj
end

#
# compute pipeline state
#

export MTLComputePipelineState

# @objcwrapper immutable=false MTLComputePipelineState <: NSObject

function MTLComputePipelineState(dev::MTLDevice, fun::MTLFunction)
    err = Ref{id{NSError}}(nil)
    handle = @objc [dev::id{MTLDevice} newComputePipelineStateWithFunction:fun::id{MTLFunction}
                                       error:err::Ptr{id{NSError}}]::id{MTLComputePipelineState}
    err[] == nil || throw(NSError(err[]))

    obj = MTLComputePipelineState(handle)
    finalizer(release, obj)
    return obj
end

# TODO: MTLComputePipelineState(d::MTLDevice, desc::MTLComputePipelineDescriptor, ...)
