export MtlLibrary, MtlLibraryFromFile, MtlLibraryFromData, function_names

const MTLLibrary = Ptr{MtLibrary}

"""
    MtlDevice(i::Integer)

Get a handle to a compute device.
"""
mutable struct MtlLibrary
    handle::MTLLibrary
    device::MtlDevice
end

Base.convert(::Type{MTLLibrary}, lib::MtlLibrary) = lib.handle
Base.unsafe_convert(::Type{MTLLibrary}, lib::MtlLibrary) = convert(MTLLibrary, lib.handle)

Base.:(==)(a::MtlLibrary, b::MtlLibrary) = a.handle == b.handle
Base.hash(lib::MtlLibrary, h::UInt) = hash(lib.handle, h)

## Properties
device(l::MtlLibrary) = l.device
function label(l::MtlLibrary)
    ptr = mtLibraryLabel(l)
    return ptr == C_NULL ? "" : unsafe_string(ptr)
end

function MtlLibrary(device::MtlDevice, src::String, opts::MtlCompileOptions)
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
    lib.handle !== C_NULL && mtRelease(lib)
end

function Base.show(io::IO, l::MtlLibrary)
    print(io, "MtlLibrary($(l.device))")
end

function Base.show(io::IO, ::MIME"text/plain", l::MtlLibrary)
    println(io, "MtlLibrary:")
    println(io, " device : ", device(l))
    print(io, " label  : ", label(l))
end

function function_names(l::MtlLibrary)
    count = Ref{Csize_t}(0)
    mtLibraryFunctionNames(l, count, C_NULL)
    names = Vector{Cstring}(undef, count[])
    mtLibraryFunctionNames(l, count, names)
    unsafe_string.(names)
end
