export MTLLibrary, MTLLibraryFromFile, MTLLibraryFromData

# @objcwrapper immutable=false MTLLibrary <: NSObject

@objcproperties MTLLibrary begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
    @autoproperty functionNames::id{NSArray} type=Vector{NSString}
end

function MTLLibrary(dev::MTLDevice, src::String,
                    opts::MTLCompileOptions=MTLCompileOptions())
    err = Ref{id{NSError}}(nil)
    handle = @objc [dev::id{MTLDevice} newLibraryWithSource:src::id{NSString}
                                          options:opts::id{MTLCompileOptions}
                                          error:err::Ptr{id{NSError}}]::id{MTLLibrary}
    err[] == nil || throw(NSError(err[]))

    obj = MTLLibrary(handle)
    finalizer(release, obj)
    return obj
end

function MTLLibraryFromFile(dev::MTLDevice, path::String)
    err = Ref{id{NSError}}(nil)
    handle = let
        url = NSFileURL(path)
        @objc [dev::id{MTLDevice} newLibraryWithURL:url::id{NSURL}
                                     error:err::Ptr{id{NSError}}]::id{MTLLibrary}
    end
    err[] == nil || throw(NSError(err[]))

    obj = MTLLibrary(handle)
    finalizer(release, obj)
    return obj
end

function MTLLibraryFromData(dev::MTLDevice, input_data)
    err = Ref{id{NSError}}(nil)
    GC.@preserve input_data begin
        data = dispatch_data(pointer(input_data), sizeof(input_data))
        handle = @objc [dev::id{MTLDevice} newLibraryWithData:data::dispatch_data_t
                                              error:err::Ptr{id{NSError}}]::id{MTLLibrary}
    end
    err[] == nil || throw(NSError(err[]))

    obj = MTLLibrary(handle)
    finalizer(release, obj)
    return obj
end
