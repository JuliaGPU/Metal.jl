"""
    @sync ex

Run expression `ex` and synchronize the GPU afterwards.

See also: [`synchronize`](@ref).
"""
macro sync(code)
    quote
        local ret = $(esc(code))
        synchronize()
        ret
    end
end

function versioninfo(io::IO=stdout)
    println(io, "macOS $(macos_version()), Darwin $(darwin_version())")
    println(io)

    println(io, "Toolchain:")
    println(io, "- Julia: $VERSION")
    println(io, "- LLVM: $(LLVM.version())")
    println(io)

    env = filter(var->startswith(var, "JULIA_METAL") || startswith(var, "MTL"), keys(ENV))
    if !isempty(env)
        println(io, "Environment:")
        for var in env
            println(io, "- $var: $(ENV[var])")
        end
        println(io)
    end

    devs = devices()
    if isempty(devs)
        println(io, "No Metal devices.")
    elseif length(devs) == 1
        println(io, "1 device:")
    else
        println(io, length(devs), " devices:")
    end
    for (i, dev) in enumerate(devs)
        println(io, "- $(dev.name) ($(Base.format_bytes(dev.currentAllocatedSize)) allocated)")
    end

    return
end

"""
    @profile [kwargs...] ex
Profile Metal/GPU work using XCode's GPU frame capture capabilities.
Note: Metal frame capture must be enabled before launching Julia (METAL\\_CAPTURE\\_ENABLED=1)
and XCode is required to view and interpret the GPU trace output.

Several keyword arguments are supported that influence the behavior of `@profile`:
- `dir`: the directory to save the GPU trace folder as. Will append required ".gputrace" \
postfix by default if not explicitly put.
- `capture`: the object to capture GPU work on. Can be a MtlDevice, MtlCommandQueue, or \
MtlCaptureScope. This defaults to the global command queue, and selecting a different \
capture object may result in no GPU commands detected when viewed from Xcode.
- `dest`: the type of GPU frame capture output. Potential values:
    - `MTL.MtCaptureDestinationGPUTraceDocument` for folder output for later viewing/sharing. (default)
    - `MTL.MtCaptureDestinationDeveloperTools` for direct XCode viewing.

Note that when profiling the resulting gputrace folder in Xcode, do so one at a time to \
avoid "no profiling data found" errors.
"""
macro profile(ex...)
    work = ex[end]
    kwargs = ex[1:end-1]
    # Default output directory - generate random path with required folder name ending
    dir = tempname()*"/jl_metal.gputrace/"
    # Default destination type to GPU trace document
    dest = MTL.MtCaptureDestinationGPUTraceDocument
    # Default capture object to global command queue
    capture = global_queue(current_device())

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
