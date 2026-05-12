#
# kernels
#

# @objcwrapper MPSKernel <: NSObject

@objcmethod @autoreleasepool function Base.copy(kernel::KindOf{MPSKernel})
    K = typeof(kernel)
    obj = @objc [kernel::id{MPSKernel} copy]::id{MPSKernel}
    K(reinterpret(id{K}, obj))
end

# @objcwrapper immutable=false MPSMatrixUnaryKernel <: MPSKernel

# @objcwrapper immutable=false MPSMatrixBinaryKernel <: MPSKernel
