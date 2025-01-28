#
# binary archive descriptor
#

export MTLBinaryArchiveDescriptor

# @objcwrapper immutable=false MTLBinaryArchiveDescriptor <: NSObject

function MTLBinaryArchiveDescriptor()
    handle = @objc [MTLBinaryArchiveDescriptor new]::id{MTLBinaryArchiveDescriptor}
    obj = MTLBinaryArchiveDescriptor(handle)
    finalizer(release, obj)
    return obj
end


#
# binary archive
#

export MTLBinaryArchive, add_functions!

# @objcwrapper immutable=false MTLBinaryArchive <: NSObject

function MTLBinaryArchive(dev::MTLDevice, desc::MTLBinaryArchiveDescriptor)
    err = Ref{id{NSError}}(nil)
    handle = @objc [dev::id{MTLDevice} newBinaryArchiveWithDescriptor:desc::id{MTLBinaryArchiveDescriptor}
                                       error:err::Ptr{id{NSError}}]::id{MTLBinaryArchive}
    err[] == nil || throw(NSError(err[]))

    obj = MTLBinaryArchive(handle)
    finalizer(release, obj)
    return obj
end

function add_functions!(bin::MTLBinaryArchive, desc::MTLComputePipelineDescriptor)
    err = Ref{id{NSError}}(nil)
    @objc [bin::id{MTLBinaryArchive} addComputePipelineFunctionsWithDescriptor:desc::id{MTLComputePipelineDescriptor}
                                     error:err::Ptr{id{NSError}}]::Nothing
    err[] == nil || throw(NSError(err[]))
end

function Base.write(filename::String, bin::MTLBinaryArchive)
    url = NSFileURL(filename)
    err = Ref{id{NSError}}(nil)
    @objc [bin::id{MTLBinaryArchive} serializeToURL:url::id{NSURL}
                                     error:err::Ptr{id{NSError}}]::Nothing
    err[] == nil || throw(NSError(err[]))
end
