#
# kernels
#

# @objcwrapper MPSKernel <: NSObject

@autoreleasepool function Base.copy(kernel::MPSKernelLike)
    K = typeof(kernel)
    obj = @objc [kernel::id{MPSKernel} copy]::id{MPSKernel}
    K(reinterpret(id{K}, obj))
end

# @objcwrapper managed = true MPSMatrixUnaryKernel <: MPSKernel

# @objcwrapper managed = true MPSMatrixBinaryKernel <: MPSKernel
