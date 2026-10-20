@public var"@sync", versioninfo

"""
    Metal.@sync ex

Evaluate `ex`, then wait for the GPU work of the current task to finish, with
[`synchronize`](@ref), and return the value of `ex`. Use it, e.g., to time GPU work with
`@time` or `@btime`.
"""
macro sync(code)
    quote
        local ret = $(esc(code))
        synchronize()
        ret
    end
end

"""
    Metal.versioninfo(io::IO=stdout)

Print the versions of macOS, the toolchain and the Metal shading language, AIR and metallib
versions Metal.jl generates code for, the relevant Julia packages, Metal-related environment
variables and preferences, and the available GPUs. Include this when reporting issues.
"""
function versioninfo(io::IO=stdout; verbose=false)
    println(io, "macOS $(macos_version()), Darwin $(darwin_version())")
    println(io)

    println(io, "Toolchain:")
    println(io, "- Julia: $VERSION")
    println(io, "- LLVM: $(LLVM.version())")
    # MSL and AIR versions only use major.minor (patch is always 0); the metallib
    # file-format version carries meaning in its patch field (e.g. 1.2.6 vs 1.2.9).
    mm(v) = "$(v.major).$(v.minor)"
    println(io, "- Metal: $(mm(metal_target())) (MSL), $(mm(air_target())) (AIR), " *
                "$(metallib_target()) (metallib)")
    println(io)

    println(io, "Julia packages:")
    println(io, "- Metal.jl: $(Base.pkgversion(Metal))")
    for name in [:GPUArrays, :GPUCompiler, :KernelInterface, :ObjectiveC,
                 :LLVM, :LLVMDowngrader_jll]
        mod = getfield(Metal, name)
        println(io, "- $(name): $(Base.pkgversion(mod))")
    end
    # KernelAbstractions is an optional dependency
    ka = get(Base.loaded_modules,
             Base.PkgId(Base.UUID("63c18a36-062a-441e-b654-da1e3ab1ce7c"), "KernelAbstractions"),
             nothing)
    ka === nothing || println(io, "- KernelAbstractions: $(Base.pkgversion(ka))")
    println(io)

    env = filter(var->startswith(var, "JULIA_METAL") || startswith(var, "MTL") || startswith(var, "METAL"), keys(ENV))
    if !isempty(env)
        println(io, "Environment:")
        for var in env
            println(io, "- $var: $(ENV[var])")
        end
        println(io)
    end

    prefs = [
        "default_storage" => load_preference(Metal, "default_storage"),
        "label_resources" => load_preference(Metal, "label_resources"),
        "embed_sources" => load_preference(Metal, "embed_sources"),
        "nonblocking_synchronization" => load_preference(Metal, "nonblocking_synchronization"),
        "command_batching" => load_preference(Metal, "command_batching"),
        "command_batching_ops" => load_preference(Metal, "command_batching_ops"),
        "command_batching_bytes" => load_preference(Metal, "command_batching_bytes"),
        "command_batching_inflight" => load_preference(Metal, "command_batching_inflight"),
        "command_api" => load_preference(Metal, "command_api"),
        "precompile" => load_preference(Metal, "precompile"),
    ]
    if any(x->!isnothing(x[2]), prefs)
        println(io, "Preferences:")
        for (key, val) in prefs
            if !isnothing(val)
                println(io, "- $key: $val")
            end
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
    for dev in devs
        cores = num_gpu_cores()
        corestr = "$(cores > 0 ? cores : "?") GPU cores"

        # device capabilities; useful to spot when (e.g. virtualized) devices gain support
        # for a newer feature set than Metal.jl currently assumes.
        caps = String[]
        apple = MTL.highest_apple_family(dev)
        apple === nothing || push!(caps, "Apple$apple")
        metal = MTL.highest_metal_family(dev)
        # render as a feature-set family (e.g. "Metal4"), not to be confused with the
        # shading-language version reported under "Toolchain:" above
        metal === nothing || push!(caps, "Metal$metal family")
        MTL.is_virtual(dev) && push!(caps, "virtualized")
        capstr = isempty(caps) ? "" : "; $(join(caps, ", "))"

        println(io, "- $(dev.name) ($corestr, $(Base.format_bytes(dev.currentAllocatedSize)) allocated$capstr)")
    end

    return
end

const _iokitlib = Symbol("/System/Library/Frameworks/IOKit.framework/IOKit")
const _cflib = Symbol("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation")

function num_gpu_cores()
    @memoize begin
        _num_gpu_cores = Ref{Int64}(0)
        try
            serv_match = @ccall _iokitlib.IOServiceMatching("AGXAccelerator"::Cstring)::Ptr{Cvoid}
            serv = @ccall _iokitlib.IOServiceGetMatchingService(C_NULL::Ptr{Nothing}, serv_match::Ptr{Cvoid})::UInt

            gpuCoreCountNumber = @ccall _iokitlib.IORegistryEntrySearchCFProperty(serv::UInt, "IOService"::Ptr{Cchar}, "gpu-core-count"::id{NSString}, C_NULL::Ptr{Nothing}, UInt32(0)::UInt32)::id{Object}
            gpuCoreCountNumber != nil || error()

            type = @ccall _cflib.CFNumberGetType(gpuCoreCountNumber::id{Object})::Int64
            type == 4 || error()

            success = @ccall _cflib.CFNumberGetValue(gpuCoreCountNumber::id{Object}, type::Int64, _num_gpu_cores::Ptr{Int64})::Bool
            success || error()
        catch
            @warn "Could not determine number of GPU cores; some algorithms may not run optimally."
        end
        _num_gpu_cores[]
    end::Int64
end


## trace names

# Name a trace after the code it records: the kernel launched by `@metal`, or the function
# called, looking through macros such as `Metal.@sync`. Falls back to "julia".
function trace_name(ex)
    if Meta.isexpr(ex, :macrocall)
        return trace_name(ex.args[end])
    elseif Meta.isexpr(ex, :block)
        stmts = filter(x -> !(x isa LineNumberNode), ex.args)
        return length(stmts) == 1 ? trace_name(only(stmts)) : "julia"
    elseif Meta.isexpr(ex, :(=)) && length(ex.args) == 2
        return trace_name(ex.args[2])
    elseif Meta.isexpr(ex, :.=) || (Meta.isexpr(ex, :.) && Meta.isexpr(ex.args[end], :tuple))
        return "broadcast"
    elseif Meta.isexpr(ex, :call)
        f = ex.args[1]
        if Meta.isexpr(f, :.) && f.args[end] isa QuoteNode
            f = f.args[end].value
        end
        if f isa Symbol
            name = replace(String(f), r"[^A-Za-z0-9_!-]" => "")
            isempty(name) || return name
        end
    end
    return "julia"
end

# the first unused `name_N.ext` in the current directory
function trace_path(name::AbstractString, ext::AbstractString)
    i = 1
    while true
        path = joinpath(pwd(), "$(name)_$i.$ext")
        ispath(path) || return path
        i += 1
    end
end

function parse_trace_kwargs(macroname, kwargs)
    pairs = Pair{Symbol,Any}[]
    for kwarg in kwargs
        if !Meta.isexpr(kwarg, :(=))
            throw(ArgumentError("Invalid keyword argument to $macroname: $kwarg"))
        end
        key, value = kwarg.args
        push!(pairs, key => value)
    end
    return pairs
end


## capture macro

function flush_capture_object!(object)
    if applicable(raw_queue, object)
        flush!(object)
    else
        flush_batched_queues!()
    end
    return
end

function check_capture_destination(manager, dest)
    supports_destination(manager, dest) && return
    if dest == MTL.MTLCaptureDestinationGPUTraceDocument
        error("""GPU frame capture is not enabled. Restart Julia with the environment \
                 variable METAL_CAPTURE_ENABLED=1, e.g., `METAL_CAPTURE_ENABLED=1 julia`. \
                 Metal reads it when the process starts, so setting it from within Julia \
                 (`ENV["METAL_CAPTURE_ENABLED"] = "1"`) has no effect.""")
    else
        error("""GPU frame capture to $dest is not supported by this process; capturing \
                 to Xcode directly requires running Julia from Xcode. Use \
                 `dest=MTL.MTLCaptureDestinationGPUTraceDocument` (the default) to save \
                 the capture to a trace file instead.""")
    end
end

function captured(f; name::AbstractString="julia",
                     dest=MTL.MTLCaptureDestinationGPUTraceDocument,
                     object=global_queue(device()), open::Bool=false)
    check_capture_destination(MTLCaptureManager(), dest)

    to_file = dest == MTL.MTLCaptureDestinationGPUTraceDocument
    folder = to_file ? trace_path(name, "gputrace") : nothing
    scope = MTLCaptureScope(object)
    scope.label = name
    flush_capture_object!(object)
    startCapture(scope, dest; folder)
    try
        flush_capture_object!(object)
        beginScope(scope)
        f()
        flush_capture_object!(object)
        endScope(scope)
        synchronize()
    finally
        stopCapture()
    end

    to_file || return nothing
    if open
        @info "GPU frame capture saved to $folder; opening it in Xcode"
        run(`open $folder`)
    else
        @info "GPU frame capture saved to $folder; open the resulting trace in Xcode"
    end
    return folder
end

@public var"@capture"

"""
    Metal.@capture [kwargs...] ex

Analyze GPU work using Metal's GPU frame capture capabilities.

Running under `Metal.@capture` generates a replayable trace of the GPU work performed by the
given expression. The resulting trace can be opened in Xcode, and offers detailed
information about the GPU work, and how to improve the performance of individual operations.
For a higher-level overview of the GPU work, use [`Metal.@profile`](@ref) instead.

The trace is saved in the current directory as `NAME_N.gputrace`, where `NAME` defaults to
the name of the kernel launched by `@metal` (or of the function called) in `ex`, and `N`
is the first number that does not overwrite an existing trace. The path of the trace is
returned.

!!! note

    Metal frame capture must be enabled by setting the `METAL_CAPTURE_ENABLED`
    environment variable to `1` before launching Julia. Setting it from within Julia does
    not work, as Metal reads it when the process starts.

A trace includes every Metal library and pipeline the process has created so far, not only
those used by `ex`. Xcode lists the ones that `ex` does not use as unused resources.

Several keyword arguments are supported that influence the behavior of `Metal.@capture`:

- `name`: the base name of the trace file, instead of the one derived from `ex`.
- `open`: open the trace in Xcode when the capture finishes (default: `false`).
- `object`: the object to capture GPU work on. Can be a MTLDevice, MTLCommandQueue, or
   MTLCaptureScope. This defaults to the global command queue, and selecting a different
   capture object may result in no GPU commands detected when viewed from Xcode.
- `dest`: the type of GPU frame capture output. Potential values:
   - `MTL.MTLCaptureDestinationGPUTraceDocument` for folder output for later
     viewing/sharing. (default)
   - `MTL.MTLCaptureDestinationDeveloperTools` for direct Xcode viewing, which requires
     running Julia from Xcode.

When profiling the resulting gputrace folder in Xcode, do so one at a time to avoid "no
profiling data found" errors.

See [Debugging and profiling with Xcode and Instruments](@ref) for what the trace shows of
Julia code.
"""
macro capture(ex...)
    work = ex[end]
    kwargs = parse_trace_kwargs("Metal.@capture", ex[1:end-1])
    any(kw -> first(kw) === :name, kwargs) || push!(kwargs, :name => trace_name(work))
    kwargs = [Expr(:kw, key, esc(value)) for (key, value) in kwargs]

    quote
        $captured(; $(kwargs...)) do
            $(esc(work))
        end
    end
end


## external profiler (Instruments)
## COV_EXCL_START

# Instruments only enables the dynamic tracing signposts of subsystems that an instrument
# asks for, so recordings add the one from `OS.instruments_package`. It is built once per
# session (in about half a second), so that it always matches the loaded ObjectiveC.jl.
const signposts_instrument = Ref{Tuple{String,String}}()
const signposts_instrument_lock = ReentrantLock()
function signposts_instrument_package()
    @lock signposts_instrument_lock begin
        if !isassigned(signposts_instrument)
            signposts_instrument[] = OS.instruments_package(["org.juliagpu.metal"])
        end
        signposts_instrument[]
    end
end

function profiled(f; name::AbstractString="julia", template::AbstractString="Metal System Trace",
                  open::Bool=false)
    # check if xctrace is available
    if !success(`xctrace version`)
        error("xctrace is not available; please install Xcode first")
    end

    # build the xctrace invocation. templates generally lack the generic signpost
    # instrument, which records the signposts of the user's own code.
    notification_name = "julia.metal.profile"
    path = trace_path(name, "trace")
    cmd = `xctrace record --quiet --no-prompt --template $template --output $path
                          --notify-tracing-started $notification_name --attach $(getpid())
                          --instrument os_signpost`
    package = try
        signposts_instrument_package()
    catch err
        @warn "Could not build the Instruments package for Metal.jl's signposts; kernel launches will be missing from the trace" exception=(err, catch_backtrace())
        nothing
    end
    if package !== nothing
        package_path, instrument = package
        cmd = `$cmd --package $package_path --instrument $instrument`
    end

    # listen for the notification indicating tracing was started
    tracing_started = Ref(false)
    center = darwin_notify_center()
    observer = CFNotificationObserver() do center, name, object, info
        tracing_started[] = true
    end
    add_observer!(center, observer; name=notification_name)

    # start xctrace
    xctrace = run(cmd, devnull, stdout, stderr; wait=false)
    try
        # wait until the tracing has started
        t0 = time()
        while !tracing_started[]
            run_loop(1; return_after_source_handled=true)
            if !process_running(xctrace)
                error("xctrace failed to start recording (exit code $(xctrace.exitcode))")
            elseif time() - t0 > 30
                kill(xctrace)
                error("xctrace failed to start recording within 30 seconds")
            end
        end

        # run the user code
        try
            f()
            synchronize()
        finally
            kill(xctrace, Base.SIGINT)
            wait(xctrace)
        end
    finally
        remove_observer!(center, observer)
    end
    if !success(xctrace) || !ispath(path)
        error("xctrace failed to save the recording (exit code $(xctrace.exitcode))")
    end

    if open
        @info "System trace saved to $path; opening it in Instruments"
        run(`open $path`)
    else
        @info "System trace saved to $path; open the resulting trace in Instruments"
    end
    return path
end

## COV_EXCL_STOP

# NOTE: the `Metal.@profile` and `Metal.@bprofile` macros are defined in `profiling.jl`.
#       `external=true` routes to `profiled()` above; the default is the integrated profiler.
