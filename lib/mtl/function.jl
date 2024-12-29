#
# function descriptor
#

export MTLFunctionDescriptor

# @objcwrapper immutable=false MTLFunctionDescriptor <: NSObject

@objcproperties MTLFunctionDescriptor begin
    @autoproperty name::id{NSString} setter=setName
    @autoproperty specializedName::id{NSString} setter=setSpecializedName
end

function MTLFunctionDescriptor()
    handle = @objc [MTLFunctionDescriptor new]::id{MTLFunctionDescriptor}
    obj = MTLFunctionDescriptor(handle)
    finalizer(release, obj)
    return obj
end



#
# function
#

export MTLFunction

# @objcwrapper immutable=false MTLFunction <: NSObject

@objcproperties MTLFunction begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
    @autoproperty name::id{NSString}
    @autoproperty functionType::MTLFunctionType
end

# Get a handle to a kernel function in a Metal Library.
function MTLFunction(lib::MTLLibrary, name)
    handle = @objc [lib::id{MTLLibrary} newFunctionWithName:name::id{NSString}]::id{MTLFunction}
    handle == nil && throw(KeyError(name))
    obj = MTLFunction(handle)
    finalizer(release, obj)
    return obj
end
