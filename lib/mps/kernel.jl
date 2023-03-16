#
# kernels
#

@cenum MPSKernelOptions::NSUInteger begin
    MPSKernelOptionsNone = 0
    MPSKernelOptionsSkipAPIValidation = 1 << 0
    MPSKernelOptionsAllowReducedPrecision = 1 << 1
    MPSKernelOptionsDisableInternalTiling = 1 << 2
    MPSKernelOptionsInsertDebugGroups = 1 << 3
    MPSKernelOptionsVerbose = 1 << 4
end


@objcwrapper MPSKernel <: NSObject

@objcproperties MPSKernel begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
    @autoproperty options::MPSKernelOptions setter=setOptions
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
