#
# binary archive descriptor
#

export MTLBinaryArchiveDescriptor

# @objcwrapper managed = true MTLBinaryArchiveDescriptor <: NSObject

function MTLBinaryArchiveDescriptor()
    return @objc [MTLBinaryArchiveDescriptor new]::MTLBinaryArchiveDescriptor
end


#
# binary archive
#

export MTLBinaryArchive, add_functions!

# @objcwrapper managed = true MTLBinaryArchive <: NSObject

function MTLBinaryArchive(dev::MTLDevice, desc::MTLBinaryArchiveDescriptor)
    err = Ref{id{NSError}}(nil)
    archive = @objc [dev::id{MTLDevice} newBinaryArchiveWithDescriptor:desc::id{MTLBinaryArchiveDescriptor}
                                        error:err::Ptr{id{NSError}}]::Union{Nothing,MTLBinaryArchive}
    archive === nothing && throw_error(err[])

    return archive
end

# Load an existing archive from a file. A corrupt or incompatible file raises an
# `MTLBinaryArchiveError` (surfaced as an `NSError`), which callers can catch to fall back
# to an empty archive.
function MTLBinaryArchive(dev::MTLDevice, path::String)
    desc = MTLBinaryArchiveDescriptor()
    desc.url = NSFileURL(path)
    return MTLBinaryArchive(dev, desc)
end

function add_functions!(bin::MTLBinaryArchive, desc::MTLComputePipelineDescriptor)
    err = Ref{id{NSError}}(nil)
    @objc [bin::id{MTLBinaryArchive} addComputePipelineFunctionsWithDescriptor:desc::id{MTLComputePipelineDescriptor}
                                     error:err::Ptr{id{NSError}}]::Nothing
    err[] == nil || throw_error(err[])
end

function Base.write(filename::String, bin::MTLBinaryArchive)
    url = NSFileURL(filename)
    err = Ref{id{NSError}}(nil)
    @objc [bin::id{MTLBinaryArchive} serializeToURL:url::id{NSURL}
                                     error:err::Ptr{id{NSError}}]::Nothing
    err[] == nil || throw_error(err[])
end
