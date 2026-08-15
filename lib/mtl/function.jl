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

# Get a handle to a specialized kernel function, supplying values for its function constants.
# Missing constant values are *not* an error here — the runtime silently leaves the slots
# `undef` — so callers must set every constant the function declares.
function MTLFunction(lib::MTLLibrary, name, constants::MTLFunctionConstantValues)
    err = Ref{id{NSError}}(nil)
    fun = @objc [lib::id{MTLLibrary} newFunctionWithName:name::id{NSString}
                                     constantValues:constants::id{MTLFunctionConstantValues}
                                     error:err::Ptr{id{NSError}}]::Union{Nothing,MTLFunction}
    fun === nothing && throw_error(err[])
    return fun
end


#
# function constant values
#

export MTLFunctionConstantValues

# @objcwrapper MTLFunctionConstantValues <: NSObject

function MTLFunctionConstantValues()
    return @objc [MTLFunctionConstantValues new]::MTLFunctionConstantValues
end

# Set the value of a function constant, addressed either by name (`setConstantValue:type:withName:`)
# or by index (`setConstantValue:type:atIndex:`). `ptr` must point at a live `type`-sized value for
# the duration of the call; the runtime copies it.
function setConstantValue!(fcv::MTLFunctionConstantValues, ptr::Ptr,
                           type::MTLDataType, name::AbstractString)
    @objc [fcv::id{MTLFunctionConstantValues} setConstantValue:ptr::Ptr{Cvoid}
                                              type:type::MTLDataType
                                              withName:name::id{NSString}]::Nothing
    return fcv
end
function setConstantValue!(fcv::MTLFunctionConstantValues, ptr::Ptr,
                           type::MTLDataType, index::Integer)
    @objc [fcv::id{MTLFunctionConstantValues} setConstantValue:ptr::Ptr{Cvoid}
                                              type:type::MTLDataType
                                              atIndex:index::NSUInteger]::Nothing
    return fcv
end

# Convenience: set from a `Ref`, keeping the referent alive across the (copying) call.
function setConstantValue!(fcv::MTLFunctionConstantValues, ref::Ref,
                           type::MTLDataType, key::Union{AbstractString,Integer})
    GC.@preserve ref begin
        setConstantValue!(fcv, Ptr{Cvoid}(Base.unsafe_convert(Ptr{eltype(ref)}, ref)), type, key)
    end
end
