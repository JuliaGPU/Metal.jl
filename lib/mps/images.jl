## kernels

# @objcwrapper immutable=false MPSUnaryImageKernel <: MPSKernel

function encode!(cmdbuf::MTLCommandBuffer, kernel::K, sourceTexture::MTLTexture, destinationTexture::MTLTexture) where {K<:MPSUnaryImageKernel}
    @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                     sourceTexture:sourceTexture::id{MTLTexture}
                                     destinationTexture:destinationTexture::id{MTLTexture}]::Nothing
end

# TODO: Implement MPSCopyAllocator to allow blurring (and other things) to be done in-place
# function encode!(cmdbuf::MTLCommandBuffer, kernel::K, inPlaceTexture::MTLTexture, copyAllocator=nothing) where {K<:MPSUnaryImageKernel}
#     @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
#                                      inPlaceTexture:inPlaceTexture::id{MTLTexture}
#                                      fallbackCopyAllocator:copyAllocator::MPSCopyAllocator]::Bool
# end

# @objcwrapper immutable=false MPSBinaryImageKernel <: MPSKernel

## gaussian blur

export MPSImageGaussianBlur, encode!

# @objcwrapper immutable=false MPSImageGaussianBlur <: MPSUnaryImageKernel

function MPSImageGaussianBlur(dev, sigma)
    kernel = @objc [MPSImageGaussianBlur alloc]::id{MPSImageGaussianBlur}
    obj = MPSImageGaussianBlur(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSImageGaussianBlur} initWithDevice:dev::id{MTLDevice}
                                  sigma:sigma::Float32]::id{MPSImageGaussianBlur}
    return obj
end


## image box

export MPSImageBox

# @objcwrapper immutable=false MPSImageBox <: MPSUnaryImageKernel

function MPSImageBox(dev, kernelWidth, kernelHeight)
    kernel = @objc [MPSImageBox alloc]::id{MPSImageBox}
    obj = MPSImageBox(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSImageBox} initWithDevice:dev::id{MTLDevice}
                                kernelWidth:kernelWidth::Int
                                kernelHeight:kernelHeight::Int]::id{MPSImageBox}
    return obj
end


## high-level blurring functionality. Interface subject to change

function blur(image, kernel; pixelFormat=MTL.MTLPixelFormatRGBA8Unorm)
    res = copy(image)

    w,h = size(image)

    alignment = MTL.minimumLinearTextureAlignmentForPixelFormat(device(), pixelFormat)
    preBytesPerRow = sizeof(eltype(image))*w

    rowoffset = alignment - (preBytesPerRow - 1) % alignment - 1
    bytesPerRow = preBytesPerRow + rowoffset

    textDesc1 = MTLTextureDescriptor(pixelFormat, w, h)
    textDesc1.usage = MTL.MTLTextureUsageShaderRead | MTL.MTLTextureUsageShaderWrite
    text1 = MTL.MTLTexture(image.data.rc.obj, textDesc1, 0, bytesPerRow)

    textDesc2 = MTLTextureDescriptor(pixelFormat, w, h)
    textDesc2.usage = MTL.MTLTextureUsageShaderRead | MTL.MTLTextureUsageShaderWrite
    text2 = MTL.MTLTexture(res.data.rc.obj, textDesc2, 0, bytesPerRow)

    cmdbuf = MTLCommandBuffer(global_queue(device()))
    encode!(cmdbuf, kernel, text1, text2)
    commit!(cmdbuf)

    return res
end

function gaussianblur(image; sigma, pixelFormat=MTL.MTLPixelFormatRGBA8Unorm)
    kernel = MPSImageGaussianBlur(device(), sigma)
    return blur(image, kernel; pixelFormat)
end

function boxblur(image, kernelWidth, kernelHeight; pixelFormat=MTL.MTLPixelFormatRGBA8Unorm)
    kernel = MPSImageBox(device(), kernelWidth, kernelHeight)
    return blur(image, kernel; pixelFormat)
end
