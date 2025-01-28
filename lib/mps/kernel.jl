#
# kernels
#

# @objcwrapper MPSKernel <: NSObject

@autoreleasepool function Base.copy(kernel::K) where {K <: MPSKernel}
    obj = @objc [kernel::MPSKernel copy]::id{MPSKernel}
    K(reinterpret(id{K}, obj))
end

# @objcwrapper immutable=false MPSMatrixUnaryKernel <: MPSKernel

# @objcwrapper immutable=false MPSMatrixBinaryKernel <: MPSKernel
