#
# capture scope
#

export MTLCaptureScope, beginScope, endScope

"""
    MTLCaptureScope(handle::MTLCaptureScope)
An object that defines custom boundaries for a GPU frame capture.

Use [`beginScope()`](@ref) and [`endScope()`](@ref) to set the boundaries for a capture scope.
"""
MTLCaptureScope

# @objcwrapper MTLCaptureScope <: NSObject

"""
    beginScope(scope::MTLCaptureScope)

Begin recording GPU command information.
"""
function beginScope(scope::MTLCaptureScope)
    @objc [scope::id{MTLCaptureScope} beginScope]::Nothing
end

"""
    endScope(scope::MTLCaptureScope)

Stop recording GPU command information.
"""
function endScope(scope::MTLCaptureScope)
    @objc [scope::id{MTLCaptureScope} endScope]::Nothing
end


#
# capture descriptor
#

export MTLCaptureDescriptor

"""
    MTLCaptureDescriptor()
    MTLCaptureDescriptor(obj::Union{MTLDevice,MTLCommandQueue},
                         destination::MTLCaptureDestination;
                         folder::String=nothing)

Create a GPU frame capture descriptor to alter the parameters of a profiling session.
"""
MTLCaptureDescriptor

# @objcwrapper immutable=false MTLCaptureDescriptor <: NSObject

function MTLCaptureDescriptor()
    handle = @objc [MTLCaptureDescriptor new]::id{MTLCaptureDescriptor}
    obj = MTLCaptureDescriptor(handle)
    finalizer(release, obj)
    return obj
end

# TODO: Add capture state
function MTLCaptureDescriptor(obj::Union{MTLDevice,MTLCommandQueue, MTLCaptureScope},
                              destination::MTLCaptureDestination;
                              folder::String=nothing)
    desc = MTLCaptureDescriptor()
    desc.destination = destination
    desc.captureObject = obj
    if folder !== nothing
        desc.outputURL = NSFileURL(folder)
    end
    return desc
end



#
# capture manager
#

export MTLCaptureManager, startCapture, stopCapture, supports_destination

"""
    MTLCaptureManager <: NSObject

Metal-managed object that handles GPU frame capture support and usage.
Note: There is only one (shared) capture manager per process.
"""
MTLCaptureManager

# @objcwrapper MTLCaptureManager <: NSObject

"""
    MTLCaptureManager()

Return the unique shared GPU frame capture manager for this process.
"""
function MTLCaptureManager()
    # Inexpensive dummy metal command to trigger GPU frame capture enable on Metal's end
    # Without this, two separate capture managers are potentially handled
    # One with capture enabled and one without
    MTLDevice(1)
    handle = @objc [MTLCaptureManager sharedCaptureManager]::id{MTLCaptureManager}
    MTLCaptureManager(handle)
end

"""
    startCapture(obj::Union{MTLDevice,MTLCommandQueue},
                 destination::MTLCaptureDestination=MTLCaptureDestinationGPUTraceDocument;
                 folder::String=nothing)

Start GPU frame capture using the default capture object and specifying capture descriptor parameters directly.
"""
function startCapture(obj::Union{MTLDevice,MTLCommandQueue, MTLCaptureScope},
                      destination::MTLCaptureDestination=MTLCaptureDestinationGPUTraceDocument;
                      folder::String=nothing)
    if destination == MTLCaptureDestinationGPUTraceDocument && folder === nothing
        throw(ArgumentError("Must specify output folder if destination is GPUTraceDocument"))
    end
    startCapture(MTLCaptureManager(), MTLCaptureDescriptor(obj, destination; folder=folder))
end

"""
    startCapture(manager::MTLCaptureManager, desc::MTLCaptureDescriptor)

Start a GPU frame capture session with the given capture manager and descriptor.
"""
function startCapture(manager::MTLCaptureManager, desc::MTLCaptureDescriptor)
    # Check not already capturing
    manager.isCapturing && throw(error("Capture manager is already capturing."))

    err = Ref{id{NSError}}(nil)
    success = @objc [manager::id{MTLCaptureManager} startCaptureWithDescriptor:desc::id{MTLCaptureDescriptor}
                                                    error:err::Ptr{id{NSError}}]::Bool
    success || throw(NSError(err[]))
    return
end

"""
    stopCapture(manager::MTLCaptureManager=MTLCaptureManager())
Stop GPU frame capture.
"""
function stopCapture(manager::MTLCaptureManager=MTLCaptureManager())
    @objc [manager::id{MTLCaptureManager} stopCapture]::Nothing
end

function supports_destination(manager::MTLCaptureManager, destination::MTLCaptureDestination)
    @objc [manager::id{MTLCaptureManager} supportsDestination:destination::MTLCaptureDestination]::Bool
end
