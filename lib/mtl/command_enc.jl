export endEncoding!

# @objcwrapper managed = true MTLCommandEncoder <: NSObject

endEncoding!(ce::MTLCommandEncoderLike) =
    @objc [ce::id{MTLCommandEncoder} endEncoding]::Nothing
function Base.close(ce::MTLCommandEncoderLike)
    try
        endEncoding!(ce)
    finally
        Foundation.release(ce)
    end
    return nothing
end
