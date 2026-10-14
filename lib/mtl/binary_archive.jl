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
    err = Out{NSError}()
    archive = @objc [dev::id{MTLDevice} newBinaryArchiveWithDescriptor:desc::id{MTLBinaryArchiveDescriptor}
                                        error:err::Out{NSError}]::Union{Nothing,MTLBinaryArchive}
    archive === nothing && throw_error(err)

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
    err = Out{NSError}()
    @objc [bin::id{MTLBinaryArchive} addComputePipelineFunctionsWithDescriptor:desc::id{MTLComputePipelineDescriptor}
                                     error:err::Out{NSError}]::Nothing
    err[] === nothing || throw(err[])
end

function Base.write(filename::String, bin::MTLBinaryArchive)
    url = NSFileURL(filename)
    err = Out{NSError}()
    @objc [bin::id{MTLBinaryArchive} serializeToURL:url::id{NSURL}
                                     error:err::Out{NSError}]::Nothing
    err[] === nothing || throw(err[])
end
