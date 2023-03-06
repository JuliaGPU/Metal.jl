export MtlCaptureDescriptor, MtlCaptureManager, MtlCaptureScope, startCapture, stopCapture,
       beginScope, endScope

### Capture Scope
const MTLCaptureScope = Ptr{MtCaptureScope}

"""
    MtlCaptureScope(handle::MTLCaptureScope)
An object that defines custom boundaries for a GPU frame capture.

Use [`beginScope()`](@ref) and [`endScope()`](@ref) to set the boundaries for a capture scope.
"""
mutable struct MtlCaptureScope
    handle::MTLCaptureScope

    function MtlCaptureScope(handle::MTLCaptureScope)
        obj = new(handle)
        # No finalizer because handled by Metal
        return obj
    end
end

Base.unsafe_convert(::Type{MTLCaptureScope}, scope::MtlCaptureScope) = scope.handle

Base.:(==)(a::MtlCaptureScope, b::MtlCaptureScope) = a.handle == b.handle
Base.hash(scope::MtlCaptureScope, h::UInt) = hash(scope.handle, h)

"""
    beginScope(scope::MtlCaptureScope)
Begin recording GPU command information.
"""
function beginScope(scope::MtlCaptureScope)
    mtBeginScope(scope)
end

"""
    endScope(scope::MtlCaptureScope)
Stop recording GPU command information.
"""
function endScope(scope::MtlCaptureScope)
    mtEndScope(scope)
end

## properties

Base.propertynames(::MtlCaptureScope) = (
    :device, :commandQueue, :label,
)

function Base.getproperty(o::MtlCaptureScope, f::Symbol)
    if f === :device
        MTLDevice(mtCaptureScopeDevice(o))
    elseif f === :commandQueue
        MtlCommandQueue(mtCaptureScopeCommandQueue(o), o.device)
    elseif f === :label
        ptr = mtCaptureScopeLabel(o)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    else
        getfield(o, f)
    end
end

function Base.setproperty!(o::MtlCaptureScope, f::Symbol, val)
    if f === :label
		mtCaptureScopeLabelSet(o, val)
    else
        setfield!(o, f, val)
    end
end

## display

function show(io::IO, ::MIME"text/plain", scope::MtlCaptureScope)
    println(io, "MtlCaptureScope:")
    println(io, " label:  ", scope.label)
    print(io,   " device: ", scope.device)
    print(io,   " command queue: ", scope.commandQueue)
end

### Capture Descriptor

const MTLCaptureDescriptor = Ptr{MtCaptureDescriptor}

"""
    MtlCaptureDescriptor()
    MtlCaptureDescriptor(obj::Union{MTLDevice,MtlCommandQueue},
                         destination::MtCaptureDestination;
                         folder::String=nothing)
Create a GPU frame capture descriptor to alter the parameters of a profiling session.
"""
mutable struct MtlCaptureDescriptor
    handle::MTLCaptureDescriptor
    cap_obj_type::MtCaptureDescriptorCaptureObjectType

    function MtlCaptureDescriptor()
        handle = mtNewCaptureDescriptor()
        obj = new(handle, MtCaptureDescriptorCaptureObjectTypeNull)
        finalizer(unsafe_destroy!, obj)
        return obj
    end

    # TODO: Add capture state
    function MtlCaptureDescriptor(obj::Union{MTLDevice,MtlCommandQueue, MtlCaptureScope},
                                  destination::MtCaptureDestination;
                                  folder::String=nothing)
        desc = MtlCaptureDescriptor()
        desc.destination = destination
        desc.captureObject = obj
        if folder != nothing
            desc.outputFolder = folder
        end
        return desc
    end
end

Base.unsafe_convert(::Type{MTLCaptureDescriptor}, desc::MtlCaptureDescriptor) = desc.handle

Base.:(==)(a::MtlCaptureDescriptor, b::MtlCaptureDescriptor) = a.handle == b.handle
Base.hash(desc::MtlCaptureDescriptor, h::UInt) = hash(desc.handle, h)

function unsafe_destroy!(desc::MtlCaptureDescriptor)
    mtRelease(desc.handle)
end

## properties

# Mapping between capture object types and Julia types
const obj_enum_to_jl_typ = Dict(MtCaptureDescriptorCaptureObjectTypeDevice => MTLDevice,
                                MtCaptureDescriptorCaptureObjectTypeQueue  => MTLCommandQueue,
                                MtCaptureDescriptorCaptureObjectTypeScope  => MTLCaptureScope)

Base.propertynames(::MtlCaptureDescriptor) = (:captureObject, :destination, :outputFolder)

function Base.getproperty(desc::MtlCaptureDescriptor, f::Symbol)
    if f === :captureObject
        ptr = mtCaptureDescriptorCaptureObject(desc)
        ptr == C_NULL && return nothing
        if desc.cap_obj_type == MtCaptureDescriptorCaptureObjectTypeDevice
            # XXX: temporary hack while we migrate away from cmt
            MTLDevice(reinterpret(id{MTLDevice}, ptr))
        else
            obj_enum_to_jl_typ[desc.cap_obj_type](ptr)
        end
    elseif f === :destination
        mtCaptureDescriptorDestination(desc)
    elseif f === :outputFolder
        # TODO: Redo this if users want full NSURL capabilities
        ptr = mtCaptureDescriptorOutputURL(desc)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    else
        getfield(desc, f)
    end
end

function Base.setproperty!(desc::MtlCaptureDescriptor, f::Symbol, val)
    if f === :captureObject
        if isa(val, MtlCommandQueue)
            mtCaptureDescriptorCaptureObjectSetQueue(desc, val)
            desc.cap_obj_type = MtCaptureDescriptorCaptureObjectTypeQueue
        elseif isa(val, MTLDevice)
            mtCaptureDescriptorCaptureObjectSetDevice(desc, val)
            desc.cap_obj_type = MtCaptureDescriptorCaptureObjectTypeDevice
        elseif isa(val, MtlCaptureScope)
            mtCaptureDescriptorCaptureObjectSetScope(desc, val)
            desc.cap_obj_type = MtCaptureDescriptorCaptureObjectTypeScope
        else
            throw(ArgumentError("captureObject property should be a MtlCommandQueue, MTLDevice, or MtlCaptureScope."))
        end
    elseif f === :destination
        isa(val, MtCaptureDestination) ||
            throw(ArgumentError("destination property must be a MtlCaptureDestination"))
        mtCaptureDescriptorDestinationSet(desc, val)
    elseif f === :outputFolder
        # TODO: Check that it doesn't already exist and allow for path or other compatible objects
        isa(val, String) ||
            throw(ArgumentError("outputFolder property must be a String"))
        mtCaptureDescriptorOutputURLSet(desc, val)
    else
        setfield!(desc, f, val)
    end
end

## display

function Base.show(io::IO, desc::MtlCaptureDescriptor)
    print(io, "MtlCaptureDescriptor(...)")
end

function Base.show(io::IO, ::MIME"text/plain", desc::MtlCaptureDescriptor)
    println(io, "MtlCaptureDescriptor:")
    println(io, " capture object:   ", desc.captureObject)
    println(io, " destination:      ", desc.destination)
    print(io,   " output folder:    ", desc.outputFolder)
end

### Capture Manager

const MTLCaptureManager = Ptr{MtCaptureManager}

"""
    struct MtlCaptureManager
Metal-managed object that handles GPU frame capture support and usage.
Note: There is only one (shared) capture manager per process.
"""
struct MtlCaptureManager
    handle::MTLCaptureManager

    """
        MtlCaptureManager()
    Return the unique shared GPU frame capture manager for this process.
    """
    function MtlCaptureManager()
        # Inexpensive dummy metal command to trigger GPU framce capture enable on Metal's end
        # Without this, two separate capture managers are potentially handled
        # One with capture enabled and one without
        MTLDevice(1)
        handle = mtSharedCaptureManager()
        obj = new(handle)
        # No finalizer needed since the manager is handled by Metal
        return obj
    end
end

Base.unsafe_convert(::Type{MTLCaptureManager}, capman::MtlCaptureManager) = capman.handle

Base.:(==)(a::MtlCaptureManager, b::MtlCaptureManager) = a.handle == b.handle
Base.hash(capman::MtlCaptureManager, h::UInt) = hash(capman.handle, h)


"""
    startCapture(obj::Union{MTLDevice,MtlCommandQueue},
                 destination::MtCaptureDestination=MtCaptureDestinationGPUTraceDocument;
                 folder::String=nothing)
Start GPU frame capture using the default capture object and specifying capture descriptor parameters directly.
"""
function startCapture(obj::Union{MTLDevice,MtlCommandQueue, MtlCaptureScope},
                      destination::MtCaptureDestination=MtCaptureDestinationGPUTraceDocument;
                      folder::String=nothing)
    destination == MtCaptureDestinationGPUTraceDocument && folder == nothing &&
        throw(ArgumentError("Must specify output folder if destination is GPUTraceDocument"))
    startCapture(MtlCaptureManager(), MtlCaptureDescriptor(obj, destination; folder=folder))
end

"""
    startCapture(manager::MtlCaptureManager, desc::MtlCaptureDescriptor)
Start a GPU frame capture session with the given capture manager and descriptor.
"""
function startCapture(manager::MtlCaptureManager, desc::MtlCaptureDescriptor)
    # Check not already capturing
    manager.isCapturing && throw(error("Capture manager is already capturing."))
    # Warn users if environment variable isn't set (required in most cases)
    haskey(ENV, "METAL_CAPTURE_ENABLED") ||
        @warn """Environment variable 'METAL_CAPTURE_ENABLED' is not set. In most cases, this
        will need to be set to 1 before launching Julia to enable GPU frame capture."""
    # Error if explicitly disallowed
    haskey(ENV, "METAL_CAPTURE_ENABLED") && ENV["METAL_CAPTURE_ENABLED"] == 0 &&
        throw(error("Metal GPU frame capture explicitly disallowed via environment vairable."))

    # Validate outputFolder
    if desc.destination == MtCaptureDestinationGPUTraceDocument
        dir = desc.outputFolder
        # Append required suffix if not already there
        if !(endswith(dir, ".gputrace"))
            desc.outputFolder = dir * ".gputrace"
        end
        isdir(dir) &&
            throw(ArgumentError("`dir` keyword argument to @profile should not be an existing directory"))
    end

    _errptr = Ref{id{NSError}}(nil)
    success = mtStartCaptureWithDescriptor(manager.handle, desc.handle, _errptr)
    success || throw(NSError(_errptr[]))
    return
end

"""
    stopCapture(manager::MtlCaptureManager=MtlCaptureManager())
Stop GPU frame capture.
"""
function stopCapture(manager::MtlCaptureManager=MtlCaptureManager())
    mtStopCapture(manager)
end

## properties

Base.propertynames(::MtlCaptureManager) = (:supportsTraceXcode,
                                           :supportsTraceFile,
                                           :isCapturing,
                                           :defaultCaptureScope)

function Base.getproperty(manager::MtlCaptureManager, f::Symbol)
    if f === :supportsTraceXcode
        mtSupportsDestination(manager, MTL.MtCaptureDestinationDeveloperTools)
    elseif f === :supportsTraceFile
        mtSupportsDestination(manager, MTL.MtCaptureDestinationGPUTraceDocument)
    elseif f === :isCapturing
        mtIsCapturing(manager)
    elseif f === :defaultCaptureScope
        ptr = mtDefaultCaptureScope(manager)
        ptr == C_NULL ? nothing : MtlCaptureScope(ptr)
    else
        getfield(manager, f)
    end
end

function Base.setproperty!(o::MtlCaptureManager, f::Symbol, val)
    if f === :defaultCaptureScope
        mtDefaultCaptureScopeSet(o, val)
    else
        setfield!(o, f, val)
    end
end

## display

function Base.show(io::IO, capman::MtlCaptureManager)
    print(io, "MtlCaptureManager(...)")
end

function Base.show(io::IO, ::MIME"text/plain", capman::MtlCaptureManager)
    println(io, "MtlCaptureManager:")
    println(io, " is capturing:         ", capman.isCapturing)
    println(io, " default capture scope:         ", capman.defaultCaptureScope)
    println(io, " supports Xcode trace: ", capman.supportsTraceXcode)
    print(io,   " supports file trace:  ", capman.supportsTraceFile)
end
