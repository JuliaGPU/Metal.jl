export endEncoding!

# @objcwrapper immutable=false MTLCommandEncoder <: NSObject

# @objcproperties MTLCommandEncoder begin
#     @autoproperty device::id{MTLDevice}
#     @autoproperty label::id{NSString} setter=setLabel
# end

endEncoding!(ce::MTLCommandEncoder) = @objc [ce::id{MTLCommandEncoder} endEncoding]::Nothing
Base.close(ce::MTLCommandEncoder) = endEncoding!(ce)
