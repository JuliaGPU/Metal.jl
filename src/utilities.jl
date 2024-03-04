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

    println(io, "Julia packages: ")
    ## get a hold of Pkg without adding a dependency on the package
    Pkg = let
        id = Base.PkgId(Base.UUID("44cfe95a-1eb2-52ea-b672-e2afdf69b78f"), "Pkg")
        Base.loaded_modules[id]
    end
    ## look at the Project.toml to determine our version
    project = Pkg.Operations.read_project(Pkg.Types.projectfile_path(pkgdir(Metal)))
    println(io, "- Metal.jl: $(project.version)")
    ## dependencies
    deps = Pkg.dependencies()
    versions = Dict(map(uuid->deps[uuid].name => deps[uuid].version, collect(keys(deps))))
    for dep in ["LLVMDowngrader_jll"]
        println(io, "- $dep: $(versions[dep])")
    end
    println(io)

    env = filter(var->startswith(var, "JULIA_METAL") || startswith(var, "MTL") || startswith(var, "METAL"), keys(ENV))
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


## capture macro

function capture_dir()
    root = pwd()
    i = 1
    while true
        path = joinpath(root, "julia_$i.gputrace")
        isdir(path) || return path
        i += 1
    end
end

function captured(f; dest=MTL.MTLCaptureDestinationGPUTraceDocument,
                     object=global_queue(current_device()))
    if !haskey(ENV, "METAL_CAPTURE_ENABLED") || ENV["METAL_CAPTURE_ENABLED"] != "1"
        @warn """Environment variable 'METAL_CAPTURE_ENABLED' is not set. In most cases, this
        will need to be set to 1 before launching Julia to enable GPU frame capture."""
    end

    folder = capture_dir()
    startCapture(object, dest; folder)
    try
       f()
    finally
        @info "GPU frame capture saved to $folder; open the resulting trace in Xcode"
        stopCapture()
    end
end

"""
    Metal.@capture [kwargs...] ex

Analyze GPU work using Metal's GPU frame capture capabilities.

Running under `Metal.@capture` generates a replayable trace of the GPU work performed by the
given expression. The resulting trace can be opened in Xcode, and offers detailed
information about the GPU work, and how to improve the performance of individual operations.
For a higher-level overview of the GPU work, use [`Metal.@profile`](@ref) instead.

!!! note

    Metal frame capture must be enabled by setting the `METAL_FRAME_CAPTURE`
    environment variable to `1` before launching Julia.

Several keyword arguments are supported that influence the behavior of `Metal.@capture`:

- `capture`: the object to capture GPU work on. Can be a MTLDevice, MTLCommandQueue, or
   MTLCaptureScope. This defaults to the global command queue, and selecting a different
   capture object may result in no GPU commands detected when viewed from Xcode.
- `dest`: the type of GPU frame capture output. Potential values:
   - `MTL.MTLCaptureDestinationGPUTraceDocument` for folder output for later
     viewing/sharing. (default)
   - `MTL.MTLCaptureDestinationDeveloperTools` for direct XCode viewing.

When profiling the resulting gputrace folder in Xcode, do so one at a time to avoid "no
profiling data found" errors.
"""
macro capture(ex...)
    work = ex[end]
    kwargs = map(ex[1:end-1]) do kwarg
        if !Meta.isexpr(kwarg, :(=))
            throw(ArgumentError("Invalid keyword argument '$kwarg'"))
        end
        key, value = kwarg.args
        Expr(:kw, key, esc(value))
    end

    quote
        $captured(; $(kwargs...)) do
            $(esc(work))
        end
    end
end


## profile macro

function profile_dir()
    root = pwd()
    i = 1
    while true
        path = joinpath(root, "julia_$i.trace")
        isdir(path) || return path
        i += 1
    end
end

function profiled(f)
    # check if xctrace is available
    if !success(`xctrace version`)
        error("xctrace is not available; please install Xcode first")
    end

    # build the xctrace invocation
    notification_name = "julia.metal.profile"
    folder = profile_dir()
    instruments = [
        # relevant instruments taken from `xcrun xctrace list instruments`
        "GPU",

        # CPU
        "Time Profiler",

        "Metal Application",
        "Metal GPU Counters",
        "Metal Resource Events",

        "os_signpost",
    ]
    cmd = `xctrace record`
    for instrument in instruments
        cmd = `$cmd --output $folder --instrument $instrument --notify-tracing-started $notification_name`
    end

    # listen for the notification indicating tracing was started
    tracing_started = Ref(false)
    center = darwin_notify_center()
    observer = CFNotificationObserver() do center, name, object, info
        tracing_started[] = true
    end
    add_observer!(center, observer; name=notification_name)

    # start xctrace
    xctrace = run(`$cmd --attach $(getpid())`, devnull, stdout, stderr; wait=false)
    try
        # wait until the tracing has started
        t0 = time()
        while !tracing_started[]
            run_loop(1; return_after_source_handled=true)
            if time() - t0 > 10
                error("xctrace failed to start")
                break
            end
        end

        # run the user code
        try
            f()
        finally
            kill(xctrace, Base.SIGINT)
            wait(xctrace)
            @info "System trace saved to $folder; open the resulting trace in Instruments"
        end
    finally
        remove_observer!(center, observer)
    end
end

"""
    Metal.@profile [kwargs...] ex

Analyze GPU work using Metal's system trace capabilities.

Running under `Metal.@profile` will use Xcode to record a trace of the GPU work performed by
the given expression. The resulting trace can be opened in the Instruments app, and offers a
high-level overview of the GPU work, and how it was launched from the CPU.
"""
macro profile(ex...)
    code = ex[end]
    kwargs = ex[1:end-1]
    @assert isempty(kwargs)

    quote
        $profiled() do
            $(esc(code))
        end
    end
end
