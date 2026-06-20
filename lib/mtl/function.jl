#
# function descriptor
#

export MTLFunctionDescriptor

# @objcwrapper managed = true MTLFunctionDescriptor <: NSObject

function MTLFunctionDescriptor()
    handle = @objc [MTLFunctionDescriptor new]::id{MTLFunctionDescriptor}
    return adopt(MTLFunctionDescriptor, handle)
end



#
# function
#

export MTLFunction

# @objcwrapper managed = true MTLFunction <: NSObject

# Get a handle to a kernel function in a Metal Library.
function MTLFunction(lib::MTLLibrary, name)
    handle = @objc [lib::id{MTLLibrary} newFunctionWithName:name::id{NSString}]::id{MTLFunction}
    handle == nil && throw(KeyError(name))
    return adopt(MTLFunction, handle)
end
