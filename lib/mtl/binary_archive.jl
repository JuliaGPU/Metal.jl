#
# binary archive descriptor
#

export MtlBinaryArchiveDescriptor

const MTLBinaryArchiveDescriptor = Ptr{MTL.MtBinaryArchiveDescriptor}

mutable struct MtlBinaryArchiveDescriptor
    handle::MTLBinaryArchiveDescriptor
end

Base.unsafe_convert(::Type{MTLBinaryArchiveDescriptor}, q::MtlBinaryArchiveDescriptor) = q.handle

Base.:(==)(a::MtlBinaryArchiveDescriptor, b::MtlBinaryArchiveDescriptor) = a.handle == b.handle
Base.hash(lib::MtlBinaryArchiveDescriptor, h::UInt) = hash(lib.handle, h)

function MtlBinaryArchiveDescriptor()
    handle = mtNewBinaryArchiveDescriptor()
    obj = MtlBinaryArchiveDescriptor(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(desc::MtlBinaryArchiveDescriptor)
    mtRelease(desc.handle)
end


## properties

Base.propertynames(::MtlBinaryArchiveDescriptor) = (:url,)

function Base.getproperty(opts::MtlBinaryArchiveDescriptor, f::Symbol)
    if f === :url
        ptr = mtBinaryArchiveDescriptorURL(opts)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    else
        getfield(opts, f)
    end
end

function Base.setproperty!(opts::MtlBinaryArchiveDescriptor, f::Symbol, val)
    if f === :url
        mtBinaryArchiveDescriptorURLSet(opts, val)
    else
        setfield!(opts, f, val)
    end
end


## display

function Base.show(io::IO, opts::MtlBinaryArchiveDescriptor)
    print(io, "MtlBinaryArchiveDescriptor(…)")
end

function Base.show(io::IO, ::MIME"text/plain", opts::MtlBinaryArchiveDescriptor)
    println(io, "MtlBinaryArchiveDescriptor:")
    println(io, " url: ", opts.url)
end



#
# binary archive
#

export MtlBinaryArchive, add_functions!

const MTLBinaryArchive = Ptr{MTL.MtBinaryArchive}

mutable struct MtlBinaryArchive
    handle::MTLBinaryArchive
    device::MTLDevice
    desc::MtlBinaryArchiveDescriptor
end

Base.unsafe_convert(::Type{MTLBinaryArchive}, q::MtlBinaryArchive) = q.handle

Base.:(==)(a::MtlBinaryArchive, b::MtlBinaryArchive) = a.handle == b.handle
Base.hash(lib::MtlBinaryArchive, h::UInt) = hash(lib.handle, h)

function MtlBinaryArchive(device::MTLDevice, desc::MtlBinaryArchiveDescriptor)
    handle = @mtlthrows _errptr mtNewBinaryArchiveWithDescriptor(device, desc, _errptr)

    obj = MtlBinaryArchive(handle, device, desc)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(archive::MtlBinaryArchive)
    mtRelease(archive.handle)
end


## properties

Base.propertynames(o::MtlBinaryArchive) = (
    # identification
    :device, :label
)

function Base.getproperty(o::MtlBinaryArchive, f::Symbol)
    if f === :device
        return MTLDevice(mtBinaryArchiveDevice(o))
    elseif f === :label
        ptr = mtBinaryArchiveLabel(o)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    else
        getfield(o, f)
    end
end

function Base.setproperty!(o::MtlBinaryArchive, f::Symbol, val)
    if f === :label
        mtBinaryArchiveLabelSet(o, val)
    else
        setfield!(opts, f, val)
    end
end


## display

function Base.show(io::IO, bin::MtlBinaryArchive)
    print(io, "MtlBinaryArchive(…)")
end

function Base.show(io::IO, ::MIME"text/plain", bin::MtlBinaryArchive)
    println(io, "MtlBinaryArchive:")
    println(io, " label:  ", bin.label)
    println(io, " device: ", bin.device)
end


## operations

function add_functions!(bin::MtlBinaryArchive, desc::MtlComputePipelineDescriptor)
    @mtlthrows _errptr mtBinaryArchiveAddComputePipelineFunctions(bin, desc, _errptr)
end

function Base.write(filename::String, bin::MtlBinaryArchive)
    @mtlthrows _errptr mtBinaryArchiveSerialize(bin, filename, _errptr)
end
