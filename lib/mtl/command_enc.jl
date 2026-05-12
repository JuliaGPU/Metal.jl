export endEncoding!

# @objcwrapper immutable=false MTLCommandEncoder <: NSObject

endEncoding!(ce::MTLCommandEncoderLike) =
    @objc [ce::id{MTLCommandEncoder} endEncoding]::Nothing
Base.close(ce::MTLCommandEncoderLike) = endEncoding!(ce)
