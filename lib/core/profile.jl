
export @profile, MtlCaptureDescriptor, MtlCaptureManager, startCapture, stopCapture

"""
    @profile [kwargs...] ex

Profile Metal/GPU work using XCode's GPU frame capture capabilities.

Note: Metal frame capture must be enabled before launching Julia (METAL\\_CAPTURE\\_ENABLED=1)
and XCode is required to view and interpret the GPU trace output.

Several keyword arguments are supported that influence the behavior of `@profile`.
- `dir`: the directory to save the GPU trace folder as. Will append required ".gputrace"
by default if not explicitly put.
- `capture`: the object to capture GPU work on. Can be a MtlDevice or MtlCommandQueue.
- `dest`: the type of GPU frame capture output. Potential values:
    - `MTL.MtCaptureDestinationGPUTraceDocument` for folder output for later viewing/sharing. (default)
    - `MTL.MtCaptureDestinationDeveloperTools` for direct XCode viewing.
"""
macro profile(ex...)
    work = ex[end]
    kwargs = ex[1:end-1]
    # Default output directory - generate random path with required folder name ending
    dir = tempname()*"/jl_metal.gputrace/"
    # Default destination type to GPU trace document
    dest = MtCaptureDestinationGPUTraceDocument
    # Default capture object to global command queue
    capture = MtlCommandQueue(device())

    if !isempty(kwargs)
        for kwarg in kwargs
            key,val = kwarg.args
            if key == :dir
                dir = val
            elseif key == :dest
                dest = val
            elseif key == :capture
                capture = val
            else
                throw(ArgumentError("Unsupported keyword argument '$key'"))
            end
        end
    end

    expr = quote
        local result = nothing
        # Start tracking GPU work
        startCapture($capture, $dest; folder=$dir)
        try
            # Execute GPU work and store result
            result = $work
            @info "GPU frame capture saved to $($dir)\n"
        finally
            # Stop tracking
            stopCapture()
        end
        return result
    end

    return esc(expr)
end

### Capture Scope
# TODO: Is it worthwhile to implement this?
const MTLCaptureScope = Ptr{MtCaptureScope}

mutable struct MtlCaptureScope
    handle::MTLCaptureScope
end


### Capture Descriptor

const MTLCaptureDescriptor = Ptr{MtCaptureDescriptor}

"""
    MtlCaptureDescriptor()
    MtlCaptureDescriptor(obj::Union{MtlDevice,MtlCommandQueue},
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
    function MtlCaptureDescriptor(obj::Union{MtlDevice,MtlCommandQueue},
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
        ptr == C_NULL ? nothing : obj_enum_to_jl_typ[desc.cap_obj_type](ptr)
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
            mtCaptureDescriptorCaptureObjectSetQueue(desc.handle, val.handle)
            desc.cap_obj_type = MtCaptureDescriptorCaptureObjectTypeQueue
        elseif isa(val, MtlDevice)
            mtCaptureDescriptorCaptureObjectSetDevice(desc.handle, val.handle)
            desc.cap_obj_type = MtCaptureDescriptorCaptureObjectTypeDevice
        elseif isa(val, MtlCaptureScope)
            mtCaptureDescriptorCaptureObjectSetScope(desc.handle, val.handle)
            desc.cap_obj_type = MtCaptureDescriptorCaptureObjectTypeScope
        else
            throw(ArgumentError("captureObject property should be a MtlCommandQueue, MtlDevice, or MtlCaptureScope."))
        end
    elseif f === :destination
        isa(val, MtCaptureDestination) ||
            throw(ArgumentError("destination property must be a MtlCaptureDestination"))
        mtCaptureDescriptorDestinationSet(desc.handle, val)
    elseif f === :outputFolder
        # TODO: Check that it doesn't already exist and allow for path or other compatible objects
        isa(val, String) ||
            throw(ArgumentError("outputFolder property must be a String"))
        mtCaptureDescriptorOutputURLSet(desc.handle, val)
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
        device()
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
    startCapture(obj::Union{MtlDevice,MtlCommandQueue},
                 destination::MtCaptureDestination=MtCaptureDestinationGPUTraceDocument;
                 folder::String=nothing)

Start GPU frame capture using the default capture object and specifying capture descriptor parameters directly.
"""
function startCapture(obj::Union{MtlDevice,MtlCommandQueue},
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

    _errptr = Ref{MTLError}()
    success = mtStartCaptureWithDescriptor(manager.handle, desc.handle, _errptr)
    success || throw(MtlError(_errptr[]))
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

Base.propertynames(::MtlCaptureManager) = (:supportsTraceXcode, :supportsTraceFile, :isCapturing)

function Base.getproperty(manager::MtlCaptureManager, f::Symbol)
    if f === :supportsTraceXcode
        mtSupportsDestination(manager, MTL.MtCaptureDestinationDeveloperTools)
    elseif f === :supportsTraceFile
        mtSupportsDestination(manager, MTL.MtCaptureDestinationGPUTraceDocument)
    elseif f === :isCapturing
        mtIsCapturing(manager)
    else
        getfield(manager, f)
    end
end

## display

function Base.show(io::IO, capman::MtlCaptureManager)
    print(io, "MtlCaptureManager(...)")
end

function Base.show(io::IO, ::MIME"text/plain", capman::MtlCaptureManager)
    println(io, "MtlCaptureManager:")
    println(io, " is capturing:         ", capman.isCapturing)
    println(io, " supports Xcode trace: ", capman.supportsTraceXcode)
    print(io,   " supports file trace:  ", capman.supportsTraceFile)
end
