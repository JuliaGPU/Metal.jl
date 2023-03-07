#
# compute pipeline descriptor
#

export MTLComputePipelineDescriptor

@objcwrapper immutable=false MTLComputePipelineDescriptor <: NSObject

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtComputePipelineDescriptor}}, obj::MTLComputePipelineDescriptor) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLComputePipelineDescriptor(ptr::Ptr{MtDevice}) = MTLComputePipelineDescriptor(reinterpret(id{MTLComputePipelineDescriptor}, ptr))

function MTLComputePipelineDescriptor()
    handle = @objc [MTLComputePipelineDescriptor new]::id{MTLComputePipelineDescriptor}
    obj = MTLComputePipelineDescriptor(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(desc::MTLComputePipelineDescriptor)
    release(desc)
end


## properties

@objcproperties MTLComputePipelineDescriptor begin
    # Specifying the Compute Function and Associated Data
    @autoproperty computeFunction::id{MTLFunction} setter=setComputeFunction
    @autoproperty threadGroupSizeIsMultipleOfThreadExecutionWidth::Bool setter=setThreadGroupSizeIsMultipleOfThreadExecutionWidth
    @autoproperty maxTotalThreadsPerThreadgroup::NSUInteger setter=setMaxTotalThreadsPerThreadgroup
    @autoproperty maxCallStackDepth::NSUInteger setter=setMaxCallStackDepth

    # Identifying the Pipeline State Object
    @autoproperty label::id{NSString} setter=setLabel

    # Setting Indirect Command Buffer Support
    @autoproperty supportIndirectCommandBuffers::Bool
end


#
# compute pipeline state
#

export MTLComputePipelineState

@objcwrapper immutable=false MTLComputePipelineState <: NSObject

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtComputePipelineState}}, obj::MTLComputePipelineState) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLComputePipelineState(ptr::Ptr{MtComputePipelineState}) =
    MTLComputePipelineState(reinterpret(id{MTLComputePipelineState}, ptr))

function MTLComputePipelineState(dev::MTLDevice, fun::MTLFunction)
    err = Ref{id{NSError}}(nil)
    handle = @objc [dev::id{MTLDevice} newComputePipelineStateWithFunction:fun::id{MTLFunction}
                                       error:err::Ptr{id{NSError}}]::id{MTLComputePipelineState}
    err[] == nil || throw(NSError(err[]))

    obj = MTLComputePipelineState(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(cce::MTLComputePipelineState)
    release(cce)
end

# TODO: MTLComputePipelineState(d::MTLDevice, desc::MTLComputePipelineDescriptor, ...)


## properties

@objcproperties MTLComputePipelineState begin
    # Identifying Properties
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel

    # Querying Threadgroup Attributes
    @autoproperty maxTotalThreadsPerThreadgroup::NSUInteger
    @autoproperty threadExecutionWidth::NSUInteger
    @autoproperty staticThreadgroupMemoryLength::NSUInteger

    # Querying Indirect Command Buffer Support
    @autoproperty supportIndirectCommandBuffers::Bool
end
