export endEncoding!

@objcwrapper MTLCommandEncoder <: NSObject

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtCommandEncoder}}, obj::MTLCommandEncoder) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLCommandEncoder(ptr::Ptr{MtCommandEncoder}) = MTLCommandEncoder(reinterpret(id{MTLCommandEncoder}, ptr))

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
