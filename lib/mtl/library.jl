export MTLLibrary, MTLLibraryFromFile, MTLLibraryFromData

# @objcwrapper managed = true MTLLibrary <: NSObject

function MTLLibrary(dev::MTLDevice, src::String,
                    opts::MTLCompileOptions=MTLCompileOptions())
    err = Ref{id{NSError}}(nil)
    lib = @objc [dev::id{MTLDevice} newLibraryWithSource:src::id{NSString}
                                       options:opts::id{MTLCompileOptions}
                                       error:err::Ptr{id{NSError}}]::Union{Nothing,MTLLibrary}
    lib === nothing && throw_error(err[])

    return lib
end

function MTLLibraryFromFile(dev::MTLDevice, path::String)
    err = Ref{id{NSError}}(nil)
    lib = let
        url = NSFileURL(path)
        @objc [dev::id{MTLDevice} newLibraryWithURL:url::id{NSURL}
                                     error:err::Ptr{id{NSError}}]::Union{Nothing,MTLLibrary}
    end
    lib === nothing && throw_error(err[])

    return lib
end

function MTLLibraryFromData(dev::MTLDevice, input_data)
    err = Ref{id{NSError}}(nil)
    lib = GC.@preserve input_data begin
        data = dispatch_data(pointer(input_data), sizeof(input_data))
        @objc [dev::id{MTLDevice} newLibraryWithData:data::dispatch_data_t
                                      error:err::Ptr{id{NSError}}]::Union{Nothing,MTLLibrary}
    end
    lib === nothing && throw_error(err[])

    return lib
end
