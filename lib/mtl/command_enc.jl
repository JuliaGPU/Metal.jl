export endEncoding!

@objcwrapper MTLCommandEncoder <: NSObject

function unsafe_destroy!(cce::MTLCommandEncoder)
    release(cce)
end


## properties

@objcproperties MTLCommandEncoder begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
end


## encoding

endEncoding!(ce::MTLCommandEncoder) = @objc [ce::id{MTLCommandEncoder} endEncoding]::Nothing
Base.close(ce::MTLCommandEncoder) = endEncoding!(ce)
