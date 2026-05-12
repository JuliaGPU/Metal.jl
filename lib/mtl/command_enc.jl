export endEncoding!

# @objcwrapper immutable=false MTLCommandEncoder <: NSObject

# Polymorphic over MTLCommandEncoder and its subclasses (compute / blit /
# render / etc.) via `KindOf{MTLCommandEncoder}` → `Object{<:MTLCommandEncoderKind}`.
@objcmethod endEncoding!(ce::KindOf{MTLCommandEncoder}) =
    @objc [ce::id{MTLCommandEncoder} endEncoding]::Nothing
@objcmethod Base.close(ce::KindOf{MTLCommandEncoder}) = endEncoding!(ce)
