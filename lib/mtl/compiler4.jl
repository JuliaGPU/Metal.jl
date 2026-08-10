export MTL4Compiler, MTLLibraryFromFile, MTLLibraryFromData


export MTL4CompilerDescriptor

# @objcwrapper immutable=false MTL4CompilerDescriptor <: NSObject

function MTL4PipelinePipelineDataSetSerializerDescriptor()
    handle = @objc [MTL4PipelinePipelineDataSetSerializerDescriptor new]::id{MTL4PipelineDataSetSerializerDescriptor}
    obj = MTL4PipelinePipelineDataSetSerializerDescriptor(handle)
    finalizer(release, obj)
    return obj
end


function MTL4PipelineDataSetSerializer(dev::MTLDevice, desc)
    err = Ref{id{NSError}}(nil)
    handle = @objc [dev::id{MTLDevice} newPipelineDataSetWithDescriptor:desc::id{MTL4PipelineDataSetSerializerDescriptor}
                                          error:err::Ptr{id{NSError}}]::id{MTL4PipelineDataSetSerializer}
    err[] == nil || throw(NSError(err[]))

    obj = MTL4PipelineDataSetSerializer(handle)
    finalizer(release, obj)
    return obj
end

export MTL4CompilerDescriptor

# @objcwrapper immutable=false MTL4CompilerDescriptor <: NSObject

function MTL4CompilerDescriptor()
    handle = @objc [MTL4CompilerDescriptor new]::id{MTL4CompilerDescriptor}
    obj = MTL4CompilerDescriptor(handle)
    finalizer(release, obj)
    return obj
end



# @objcwrapper immutable=false MTL4Compiler <: NSObject

function MTL4Compiler(dev::MTLDevice, desc::MTL4CompilerDescriptor=MTL4CompilerDescriptor())
    err = Ref{id{NSError}}(nil)
    handle = @objc [dev::id{MTLDevice} newCompilerWithDescriptor:desc::id{MTL4CompilerDescriptor}
                                          error:err::Ptr{id{NSError}}]::id{MTL4Compiler}
    err[] == nil || throw(NSError(err[]))

    obj = MTL4Compiler(handle)
    finalizer(release, obj)
    return obj
end

function MTLLibrary(compiler::MTL4Compiler, desc::MTL4LibraryDescriptor)
    err = Ref{id{NSError}}(nil)
    @objc [compiler::id{MTL4Compiler} newLibraryWithDescriptor:desc::id{MTL4LibraryDescriptor}
                                    error:err::Ptr{id{NSError}}]::id{MTLLibrary}
    @show err
                                    err[] == nil || throw(NSError(err[]))

    obj = MTLLibrary(handle)
    finalizer(release, obj)
    return obj
end

function MTLDynamicLibrary(compiler::MTL4Compiler, lib::MTLLibrary)
    err = Ref{id{NSError}}(nil)
    @objc [compiler::id{MTL4Compiler} newDynamicLibrary:lib::id{MTLLibrary}
                                    error:err::Ptr{id{NSError}}]::id{MTLDynamicLibrary}
    err[] == nil || throw(NSError(err[]))

    obj = MTLDynamicLibrary(handle)
    finalizer(release, obj)
    return obj
end

function MTLDynamicLibrary(compiler::MTL4Compiler, path::String)
    err = Ref{id{NSError}}(nil)
    handle = let
        url = NSFileURL(path)
        @objc [compiler::id{MTL4Compiler} newDynamicLibraryWithURL:url::id{MTLLibrary}
                                     error:err::Ptr{id{NSError}}]::id{MTLDynamicLibrary}
    end
    err[] == nil || throw(NSError(err[]))

    obj = MTLDynamicLibrary(handle)
    finalizer(release, obj)
    return obj
end
