#
# compute pipeline descriptor
#

export MTL4ComputePipelineDescriptor

# @objcwrapper immutable=false MTL4ComputePipelineDescriptor <: NSObject

function MTL4ComputePipelineDescriptor()
    handle = @objc [MTL4ComputePipelineDescriptor new]::id{MTL4ComputePipelineDescriptor}
    obj = MTL4ComputePipelineDescriptor(handle)
    finalizer(release, obj)
    return obj
end
