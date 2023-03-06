#
# function descriptor
#

export MtlFunctionDescriptor

const MTLFunctionDescriptor = Ptr{MtFunctionDescriptor}

mutable struct MtlFunctionDescriptor
    handle::MTLFunctionDescriptor
end

Base.unsafe_convert(::Type{MTLFunctionDescriptor}, q::MtlFunctionDescriptor) = q.handle

Base.:(==)(a::MtlFunctionDescriptor, b::MtlFunctionDescriptor) = a.handle == b.handle
Base.hash(lib::MtlFunctionDescriptor, h::UInt) = hash(lib.handle, h)

function MtlFunctionDescriptor()
    handle = mtNewFunctionDescriptor()
    obj = MtlFunctionDescriptor(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(desc::MtlFunctionDescriptor)
    mtRelease(desc.handle)
end


## properties

Base.propertynames(::MtlFunctionDescriptor) = (:name, :specializedName)

function Base.getproperty(desc::MtlFunctionDescriptor, f::Symbol)
    if f === :name
        ptr = mtFunctionDescriptorName(desc)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    elseif f === :specializedName
        ptr = mtFunctionDescriptorSpecializedName(desc)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    else
        getfield(desc, f)
    end
end

function Base.setproperty!(desc::MtlFunctionDescriptor, f::Symbol, val)
    if f === :name
        mtFunctionDescriptorNameSet(desc, val)
    elseif f === :specializedName
        mtFunctionDescriptorSpecializedNameSet(desc, val)
    else
        setfield!(desc, f, val)
    end
end


## display

function Base.show(io::IO, ::MIME"text/plain", desc::MtlFunctionDescriptor)
    println(io, "MtlFunctionDescriptor:")
    println(io, " name:   ", desc.name)
    println(io, " specializedName:   ", desc.specializedName)
end

function Base.show(io::IO, desc::MtlFunctionDescriptor)
    print(io, "MtlFunctionDescriptor(...)")
end



#
# function
#

export MtlFunction

const MTLFunction = Ptr{MtFunction}

mutable struct MtlFunction
    handle::MTLFunction

    # roots (can be nothing if the function was created directly from a handle)
    lib::Union{Nothing,MTLLibrary}

    MtlFunction(handle::MTLFunction, lib=nothing) = new(handle, lib)
end

function unsafe_destroy!(fun::MtlFunction)
    mtRelease(fun.handle)
end

Base.unsafe_convert(::Type{MTLFunction}, fun::MtlFunction) = fun.handle

Base.:(==)(a::MtlFunction, b::MtlFunction) = a.handle == b.handle
Base.hash(fun::MtlFunction, h::UInt) = hash(mod.handle, h)

# Get a handle to a kernel function in a Metal Library.
function MtlFunction(lib::MTLLibrary, name::String)
    handle = mtNewFunctionWithName(lib, name)
    handle == C_NULL && throw(KeyError(name))
    obj = MtlFunction(handle, lib)
    finalizer(unsafe_destroy!, obj)
    return obj
end


## properties

Base.propertynames(::MtlFunction) = (:device, :label, :name, :functionType)

function Base.getproperty(fun::MtlFunction, f::Symbol)
    if f === :device
        MTLDevice(mtFunctionDevice(fun))
    elseif f === :label
        ptr = mtFunctionLabel(fun)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    elseif f === :name
        unsafe_string(mtFunctionName(fun))
    elseif f === :functionType
        mtFunctionType(fun)
    else
        getfield(fun, f)
    end
end

function Base.setproperty!(fun::MtlFunction, f::Symbol, val)
    if f === :label
		mtFunctionLabelSet(fun, val)
    else
        setfield!(fun, f, val)
    end
end


## display

function Base.show(io::IO, ::MIME"text/plain", fun::MtlFunction)
    println(io, "MtlFunction:")
    println(io, " name:   ", fun.name)
    println(io, " type:   ", fun.functionType)
    println(io, " device: ", fun.device)
    print(io,   " label:  ", fun.label)
end

function Base.show(io::IO, fun::MtlFunction)
    print(io, "MtlFunction($(fun.name))")
end
