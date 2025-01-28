export endEncoding!

# @objcwrapper immutable=false MTLCommandEncoder <: NSObject

endEncoding!(ce::MTLCommandEncoder) = @objc [ce::id{MTLCommandEncoder} endEncoding]::Nothing
Base.close(ce::MTLCommandEncoder) = endEncoding!(ce)
