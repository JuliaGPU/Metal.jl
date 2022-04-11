export MtlLibrary, MtlLibraryFromFile, MtlLibraryFromData

const MTLLibrary = Ptr{MtLibrary}

"""
    MtlDevice(i::Integer)

Get a handle to a compute device.
"""
mutable struct MtlLibrary
    handle::MTLLibrary
    device::MtlDevice
end

Base.unsafe_convert(::Type{MTLLibrary}, lib::MtlLibrary) = lib.handle

Base.:(==)(a::MtlLibrary, b::MtlLibrary) = a.handle == b.handle
Base.hash(lib::MtlLibrary, h::UInt) = hash(lib.handle, h)

function MtlLibrary(device::MtlDevice, src::String, opts::MtlCompileOptions=MtlCompileOptions())
    handle = @mtlthrows _errptr mtNewLibraryWithSource(device, src, opts, _errptr)

    obj = MtlLibrary(handle, device)
    finalizer(unsafe_destroy!, obj)

    return obj
end

function MtlLibraryFromFile(device::MtlDevice, path::String)
    handle = @mtlthrows _errptr mtNewLibraryWithFile(device, path, _errptr)

    obj = MtlLibrary(handle, device)
    finalizer(unsafe_destroy!, obj)

    return obj
end

function MtlLibraryFromData(device::MtlDevice, data)
    GC.@preserve data begin
        handle = @mtlthrows _errptr mtNewLibraryWithData(device, pointer(data), sizeof(data), _errptr)
    end

    obj = MtlLibrary(handle, device)
    finalizer(unsafe_destroy!, obj)

    return obj
end

function unsafe_destroy!(lib::MtlLibrary)
    mtRelease(lib.handle)
end


## properties

Base.propertynames(::MtlLibrary) = (:device, :label, :functionNames)

function Base.getproperty(lib::MtlLibrary, f::Symbol)
    if f === :label
        ptr = mtLibraryLabel(lib)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    elseif f === :functionNames
        count = Ref{Csize_t}(0)
        mtLibraryFunctionNames(lib, count, C_NULL)
        names = Vector{Cstring}(undef, count[])
        mtLibraryFunctionNames(lib, count, names)
        unsafe_string.(names)
    else
        getfield(lib, f)
    end
end


## display

function Base.show(io::IO, lib::MtlLibrary)
    print(io, "MtlLibrary($(lib.device))")
end

function Base.show(io::IO, ::MIME"text/plain", lib::MtlLibrary)
    println(io, "MtlLibrary:")
    println(io, " device: ", lib.device)
    print(io,   " label:  ", lib.label)
end
