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
    mtRelease(fun.handle)
end

Base.unsafe_convert(::Type{MTLFunction}, fun::MtlFunction) = fun.handle

Base.:(==)(a::MtlFunction, b::MtlFunction) = a.handle == b.handle
Base.hash(fun::MtlFunction, h::UInt) = hash(mod.handle, h)


## properties

Base.propertynames(::MtlFunction) = (:device, :label, :name, :functionType)

function Base.getproperty(fun::MtlFunction, f::Symbol)
    if f === :device
        MtlDevice(mtFunctionDevice(fun))
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
