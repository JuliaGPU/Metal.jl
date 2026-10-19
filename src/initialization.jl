@public functional

# World age captured at __init__ time. Used to invoke the GPU-compiler stack
# in a frozen world to avoid latency from invalidations.
const initialized = Ref{Bool}(false)
const initialization_world = Ref{UInt}(typemax(UInt))

"""
    invoke_frozen(f, args...; kwargs...)

Invoke `f(args...; kwargs...)` in the world age captured at `__init__` time.
"""
@inline function invoke_frozen(f, args...; kwargs...)
    if isempty(kwargs)
        return Base.invoke_in_world(initialization_world[], f, args...)
    end
    kwargs = merge(NamedTuple(), kwargs)
    return Base.invoke_in_world(initialization_world[], Core.kwcall, kwargs, f, args...)
end

function check_functional()
    initialized[] || return false
    try
        is_supported(device())
    catch
        false
    end
end
functional() = @memoize begin
    check_functional()
end::Bool

"""
    Metal.functional()

Report whether Metal.jl can be loaded and used.
"""
functional

# A device is supported if it provides the feature set Metal.jl targets (Apple7 + Metal 3),
# or if it is a paravirtualized GPU. The latter is backed by real Apple Silicon and supports
# Metal 3, but under-reports its capabilities through `supportsFamily` (see `is_virtual`)
function is_supported(dev)
    is_virtual(dev) || supports_family(dev, MTL.MTLGPUFamilyApple7) &&
                          supports_family(dev, MTL.MTLGPUFamilyMetal3)
end

# the default language version depends on the SDK Julia was linked against, so it can be
# newer than the versions we know about. it's only informational: don't throw on it.
function describe_language_version(ver::MTL.MTLLanguageVersion)
    v = get(MTL.language_versions, ver, nothing)
    v === nothing ? "unknown (0x$(string(UInt64(ver); base=16)))" : "v$v"
end

function __init__()
    # buffers freed while generating the package image don't exist in this process. this
    # also applies when precompiling another package, whose workload may allocate.
    Base.@atomic freed_buffers.head = nothing

    init_label_resources!()
    init_log_tracing!()

    precompiling = ccall(:jl_generating_output, Cint, ()) != 0
    precompiling && return

    MTL.submit_hook[] = submit_command_buffer

    if !Sys.isapple() || Sys.ARCH != :aarch64
        @error "Metal.jl is only supported on Apple Silicon"
        return
    end

    if macos_version() < v"15"
        @error "Metal.jl requires macOS 15 or later"
        return
    elseif macos_version() >= v"28"
        @warn "Metal.jl has not been tested on macOS 28 or later, you may run into issues."
    end

    try
        load_framework("CoreGraphics")
        load_framework("MetalPerformanceShadersGraph")
        opts = MTL.MTLCompileOptions()
        ver = @objc [opts::id{MTL.MTLCompileOptions} languageVersion]::MTL.MTLLanguageVersion
        @debug "Successfully loaded Metal; default language version $(describe_language_version(ver))."

        # the preference is fixed at compile time, but support depends on this system
        if COMMAND_API === :metal4
            reason = metal4_unsupported_reason(MTLDevice(1))
            if reason !== nothing
                @error "The `command_api` preference selects the Metal 4 command API, but $reason."
                return
            end
        end

        initialized[] = true
    catch err
        @error "Failed to load Metal" exception=(err,catch_backtrace())
        return
    end

    # ensure that operations executed by the REPL back-end finish before returning,
    # because displaying values happens on a different task
    if isdefined(Base, :active_repl_backend) && !isnothing(Base.active_repl_backend)
        push!(Base.active_repl_backend.ast_transforms, synchronize_metal_tasks)
    end

    atexit(abandon_open_batches)

    initialization_world[] = Base.get_world_counter()
end

# an open batch holds a live command encoder; releasing it from a finalizer
# without `endEncoding` aborts Metal. end it and drop its uncommitted buffer
# at exit, without committing or waiting on the GPU.
function abandon_open_batches()
    has_active_batched_queues() || return
    try
        for bq in active_batched_queues()
            abandon_open_batch!(bq)
        end
    catch err
        @error "Failed to close open batched command queues at exit" exception=(err, catch_backtrace())
    end
end
# compiling this at exit takes longer than running it
precompile(abandon_open_batches, ())

function synchronize_metal_tasks(ex)
    quote
        try
            $(ex)
        finally
            if haskey($task_local_storage(), :MTLDevice) || $has_active_batched_queues()
                $device_synchronize()
            end
        end
    end
end
