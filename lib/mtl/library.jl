export MTLLibrary, MTLLibraryFromFile, MTLLibraryFromData

@objcwrapper immutable=false MTLLibrary <: NSObject

@objcproperties MTLLibrary begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
    @autoproperty functionNames::id{NSArray} type=Vector{NSString}
end

function MTLLibrary(device::MTLDevice, src::String,
                    opts::MTLCompileOptions=MTLCompileOptions())
    err = Ref{id{NSError}}(nil)
    handle = @objc [device::id{MTLDevice} newLibraryWithSource:src::id{NSString}
                                          options:opts::id{MTLCompileOptions}
                                          error:err::Ptr{id{NSError}}]::id{MTLLibrary}
    err[] == nil || throw(NSError(err[]))

    obj = MTLLibrary(handle)
    finalizer(release, obj)

    return obj
end

function MTLLibraryFromFile(device::MTLDevice, path::String)
    err = Ref{id{NSError}}(nil)
    handle = if macos_version() >= v"13"
        url = NSFileURL(path)
        @objc [device::id{MTLDevice} newLibraryWithURL:url::id{NSURL}
                                     error:err::Ptr{id{NSError}}]::id{MTLLibrary}
    else
        @objc [device::id{MTLDevice} newLibraryWithFile:path::id{NSString}
                                     error:err::Ptr{id{NSError}}]::id{MTLLibrary}
    end
    err[] == nil || throw(NSError(err[]))

    obj = MTLLibrary(handle)
    finalizer(release, obj)

    return obj
end

function MTLLibraryFromData(device::MTLDevice, input_data)
    err = Ref{id{NSError}}(nil)
    GC.@preserve input_data begin
        data = dispatch_data(pointer(input_data), sizeof(input_data))
        handle = @objc [device::id{MTLDevice} newLibraryWithData:data::dispatch_data_t
                                              error:err::Ptr{id{NSError}}]::id{MTLLibrary}
    end
    err[] == nil || throw(NSError(err[]))

    obj = MTLLibrary(handle)
    finalizer(release, obj)

    return obj
end
