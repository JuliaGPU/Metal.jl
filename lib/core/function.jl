export MtlFunction

const MTLFunction = Ptr{MtFunction}

mutable struct MtlFunction
    handle::MTLFunction
    lib::MtlLibrary

    "Get a handle to a kernel function in a Metal Library."
    function MtlFunction(lib::MtlLibrary, name::String)
        handle = mtNewFunctionWithName(lib, name)
        handle == C_NULL && throw(KeyError(name))
        obj = new(handle, lib)
        finalizer(unsafe_destroy!, obj)
        return obj
    end
end 

function unsafe_destroy!(fun::MtlFunction)
    mtRelease(fun)
end

Base.unsafe_convert(::Type{MTLFunction}, fun::MtlFunction) = fun.handle

Base.:(==)(a::MtlFunction, b::MtlFunction) = a.handle == b.handle
Base.hash(fun::MtlFunction, h::UInt) = hash(mod.handle, h)

name(l::MtlFunction) = mtFunctionName(l) |> unsafe_string
device(fun::MtlFunction) = MtlDevice(mtFunctionDevice(fun))
type(l::MtlFunction) = mtFunctionType(l)
function label(l::MtlFunction)
    ptr = mtFunctionLabel(l)
    return ptr == C_NULL ? "" : unsafe_string(ptr) 
end

function Base.show(io::IO, ::MIME"text/plain", l::MtlFunction)
    println(io, "MtlFunction:")
    println(io, " name    : ", name(l))
    println(io, " type    : ", type(l))
    println(io, " device  : ", device(l))
    print(io, " label   : ", label(l))
end

function Base.show(io::IO, l::MtlFunction)
    print(io, "MtlFunction($(name(l)))")
end
