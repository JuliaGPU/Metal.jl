export MTL4CommitOptions

# @objcwrapper immutable=false MTL4CommitOptions <: NSObject

function MTL4CommitOptions()
    handle = @objc [MTL4CommitOptions new]::id{MTL4CommitOptions}
    obj = MTL4CommitOptions(handle)
    finalizer(release, obj)
    return obj
end
function MTL4CommitOptions(f::Base.Callable)
    options = MTL4CommitOptions()
    addFeedbackHandler(f, options)
    return options
end

function _command_buffer4_callback(f)
    # convert the incoming pointer, and discard any return value
    function wrapper(ptr)
        try
            f(ptr == nil ? nothing : MTL4CommitFeedback(ptr))
        catch err
            # we might be on an unmanaged thread here, so display the error
            # (otherwise it may get lost, or worse, crash Julia)
            @error "Command buffer callback encountered an error: " * sprint(showerror, err)
        end
        return
    end
    @objcblock(wrapper, Nothing, (id{MTL4CommitFeedback},))
end

function addFeedbackHandler(f::Base.Callable, options::MTL4CommitOptions)
    block = _command_buffer4_callback(f)
    @objc [options::id{MTL4CommitOptions} addFeedbackHandler:block::id{NSBlock}]::Nothing
end



export MTL4CommandQueue

# @objcwrapper immutable=false MTL4CommandQueue <: NSObject

function MTL4CommandQueue(dev::MTLDevice)
    handle = @objc [dev::id{MTLDevice} newMTL4CommandQueue]::id{MTL4CommandQueue}
    obj = MTL4CommandQueue(handle)
    finalizer(release, obj)
    return obj
end
