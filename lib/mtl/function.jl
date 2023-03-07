#
# function enums
#

@cenum MTLFunctionType::NSUInteger begin
    MTLFunctionTypeVertex = 1
    MTLFunctionTypeFragment = 2
    MTLFunctionTypeKernel = 3
end


#
# function descriptor
#

export MTLFunctionDescriptor

@objcwrapper immutable=false MTLFunctionDescriptor <: NSObject

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtFunctionDescriptor}}, obj::MTLFunctionDescriptor) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLFunctionDescriptor(ptr::Ptr{MtFunctionDescriptor}) =
    MTLFunctionDescriptor(reinterpret(id{MTLFunctionDescriptor}, ptr))

function MTLFunctionDescriptor()
    handle = @objc [MTLFunctionDescriptor new]::id{MTLFunctionDescriptor}
    obj = MTLFunctionDescriptor(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(desc::MTLFunctionDescriptor)
    release(desc)
end


## properties

@objcproperties MTLFunctionDescriptor begin
    @autoproperty name::id{NSString} setter=setName
    @autoproperty specializedName::id{NSString} setter=setSpecializedName
end



#
# function
#

export MTLFunction

@objcwrapper immutable=false MTLFunction <: NSObject

# compatibility with cmt
Base.unsafe_convert(T::Type{Ptr{MtFunction}}, obj::MTLFunction) =
    reinterpret(T, Base.unsafe_convert(id, obj))
MTLFunction(ptr::Ptr{MtFunction}) = MTLFunction(reinterpret(id{MTLFunction}, ptr))

# Get a handle to a kernel function in a Metal Library.
function MTLFunction(lib::MTLLibrary, name::String)
    handle = @objc [lib::id{MTLLibrary} newFunctionWithName:name::id{NSString}]::id{MTLFunction}
    handle == nil && throw(KeyError(name))
    obj = MTLFunction(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(fun::MTLFunction)
    release(fun)
end


## properties

@objcproperties MTLFunction begin
    @autoproperty device::id{MTLDevice}
    @autoproperty label::id{NSString} setter=setLabel
    @autoproperty name::id{NSString}
    @autoproperty functionType::MTLFunctionType
end
