#
# function descriptor
#

export MTLFunctionDescriptor

# @objcwrapper managed = true MTLFunctionDescriptor <: NSObject

function MTLFunctionDescriptor()
    return @objc [MTLFunctionDescriptor new]::MTLFunctionDescriptor
end



#
# function
#

export MTLFunction

# @objcwrapper managed = true MTLFunction <: NSObject

# Get a handle to a kernel function in a Metal Library.
function MTLFunction(lib::MTLLibrary, name)
    fun = @objc [lib::id{MTLLibrary} newFunctionWithName:name::id{NSString}]::Union{Nothing,MTLFunction}
    fun === nothing && throw(KeyError(name))
    return fun
end
