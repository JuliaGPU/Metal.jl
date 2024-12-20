#
# kernels
#

@objcwrapper MPSKernel <: NSObject

@objcproperties MPSKernel begin
    @autoproperty options::MPSKernelOptions setter=setOptions
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
end

@autoreleasepool function Base.copy(kernel::K) where {K <: MPSKernel}
    obj = @objc [kernel::MPSKernel copy]::id{MPSKernel}
    K(reinterpret(id{K}, obj))
end

@objcwrapper immutable=false MPSMatrixUnaryKernel <: MPSKernel

@objcproperties MPSMatrixUnaryKernel begin
    @autoproperty sourceMatrixOrigin::id{MTLOrigin} setter=setSourceMatrixOrigin
    @autoproperty resultMatrixOrigin::id{MTLOrigin} setter=setResultMatrixOrigin
    @autoproperty batchStart::NSUInteger setter=setBatchStart
    @autoproperty batchSize::NSUInteger setter=setBatchSize
end


@objcwrapper immutable=false MPSMatrixBinaryKernel <: MPSKernel

@objcproperties MPSMatrixBinaryKernel begin
    @autoproperty primarySourceMatrixOrigin::id{MTLOrigin} setter=setPrimarySourceMatrixOrigin
    @autoproperty secondarySourceMatrixOrigin::id{MTLOrigin} setter=setSecondarySourceMatrixOrigin
    @autoproperty resultMatrixOrigin::id{MTLOrigin} setter=setResultMatrixOrigin
    @autoproperty batchStart::NSUInteger setter=setBatchStart
    @autoproperty batchSize::NSUInteger setter=setBatchSize
end
