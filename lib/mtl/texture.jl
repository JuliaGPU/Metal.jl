export MTLTextureDescriptor, MTLTexture

## bitwise operations lose type information, so allow conversions
Base.convert(::Type{MTLPixelFormat}, x::Integer) = MTLPixelFormat(x)

function minimumLinearTextureAlignmentForPixelFormat(dev, format)
    return @objc [dev::MTLDevice minimumLinearTextureAlignmentForPixelFormat:format::MTLPixelFormat]::NSUInteger
end

## bitwise operations lose type information, so allow conversions
Base.convert(::Type{MTLTextureUsage}, x::Integer) = MTLTextureUsage(x)

# @objcwrapper immutable=false MTLTextureDescriptor <: NSObject

function MTLTextureDescriptor(pixelFormat, width, height, mipmapped=false)
    desc = @objc [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:pixelFormat::MTLPixelFormat
                                          width:width::NSUInteger
                                          height:height::NSUInteger
                                          mipmapped:mipmapped::Bool]::id{MTLTextureDescriptor}
    obj = MTLTextureDescriptor(desc)
    finalizer(release, obj)

    return obj
end

# @objcwrapper immutable=false MTLTexture <: NSObject

function MTLTexture(buffer, descriptor, offset, bytesPerRow)
    texture = @objc [buffer::id{MTLBuffer} newTextureWithDescriptor:descriptor::id{MTLTextureDescriptor}
                                          offset:offset::NSUInteger
                                          bytesPerRow:bytesPerRow::NSUInteger]::id{MTLTexture}
    obj = MTLTexture(texture)
    finalizer(release, obj)

    return obj
end

function MTLTexture(dev, descriptor)
    texture = @objc [dev::id{MTLDevice} newTextureWithDescriptor:descriptor::id{MTLTextureDescriptor}]::id{MTLTexture}
    obj = MTLTexture(texture)
    finalizer(release, obj)

    return obj
end
