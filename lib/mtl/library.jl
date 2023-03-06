export MtlLibrary, MtlLibraryFromFile, MtlLibraryFromData

const MTLLibrary = Ptr{MtLibrary}

"""
    MTLDevice(i::Integer)

Get a handle to a compute device.
"""
mutable struct MtlLibrary
    handle::MTLLibrary
    device::MTLDevice
end

Base.unsafe_convert(::Type{MTLLibrary}, lib::MtlLibrary) = lib.handle

Base.:(==)(a::MtlLibrary, b::MtlLibrary) = a.handle == b.handle
Base.hash(lib::MtlLibrary, h::UInt) = hash(lib.handle, h)

function MtlLibrary(device::MTLDevice, src::String, opts::MTLCompileOptions=MTLCompileOptions())
    handle = @mtlthrows _errptr mtNewLibraryWithSource(device, src, opts, _errptr)

    obj = MtlLibrary(handle, device)
    finalizer(unsafe_destroy!, obj)

    return obj
end

function MtlLibraryFromFile(device::MTLDevice, path::String)
    handle = if macos_version() >= v"13"
        @mtlthrows _errptr mtNewLibraryWithURL(device, path, _errptr)
    else
        @mtlthrows _errptr mtNewLibraryWithFile(device, path, _errptr)
    end

    obj = MtlLibrary(handle, device)
    finalizer(unsafe_destroy!, obj)

    return obj
end

function MtlLibraryFromData(device::MTLDevice, data)
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

function Base.setproperty!(lib::MtlLibrary, f::Symbol, val)
    if f === :label
		mtLibraryLabelSet(lib, val)
    else
        setfield!(lib, f, val)
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
