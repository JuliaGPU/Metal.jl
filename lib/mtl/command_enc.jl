export endEncoding!

# @objcwrapper managed = true MTLCommandEncoder <: NSObject

endEncoding!(ce::MTLCommandEncoderLike) =
    @objc [ce::id{MTLCommandEncoder} endEncoding]::Nothing
function Base.close(ce::MTLCommandEncoderLike)
    try
        endEncoding!(ce)
    finally
        release(ce)
    end
    return nothing
end

# debug groups name the commands encoded between a push and its matching pop in Metal's
# developer tools (e.g. Xcode's GPU frame capture); they nest, but must balance within an
# encoder.
export push_debug_group!, pop_debug_group!

push_debug_group!(ce::MTLCommandEncoderLike, label::Union{String,NSString}) =
    @objc [ce::id{MTLCommandEncoder} pushDebugGroup:label::id{NSString}]::Nothing
pop_debug_group!(ce::MTLCommandEncoderLike) =
    @objc [ce::id{MTLCommandEncoder} popDebugGroup]::Nothing
