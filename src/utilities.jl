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
    for dep in ["Metal_LLVM_Tools_jll"]
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


## capturing traces

function trace_dir()
    root = pwd()
    i = 1
    while true
        path = joinpath(root, "julia_$i.gputrace/")
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

    folder = trace_dir()
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

Analyze Metal/GPU work using Xcode's GPU frame capture capabilities.

!!! note

    Metal frame capture must be enabled by setting the `METAL_FRAME_CAPTURE` environment
    variable to `1` before launching Julia. Furthermore, Xcode is required to viewi and
    interpret the GPU trace output.

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
