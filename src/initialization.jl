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
# Metal 3, but under-reports its capabilities through `supportsFamily` (see `is_virtual`).
#
# Paravirtual GPUs are only supported on macOS 15+: the macOS <15 paravirtual driver does not
# implement the GPU-address-based ("bindless") argument passing Metal.jl requires.
function is_supported(dev)
    is_virtual(dev) && return macos_version() >= v"15"
    return supports_family(dev, MTL.MTLGPUFamilyApple7) &&
           supports_family(dev, MTL.MTLGPUFamilyMetal3)
end

function __init__()
    precompiling = ccall(:jl_generating_output, Cint, ()) != 0
    precompiling && return

    _early_gc[] = nothing
    MTL.submit_hook[] = flush_open_batch

    if !Sys.isapple() || Sys.ARCH != :aarch64
        @error "Metal.jl is only supported on Apple Silicon"
        return
    end

    if macos_version() < v"14"
        @error "Metal.jl requires macOS 14 or later"
        return
    elseif macos_version() >= v"27"
        @warn "Metal.jl has not been tested on macOS 27 or later, you may run into issues."
    end

    @autoreleasepool try
        load_framework("CoreGraphics")
        load_framework("MetalPerformanceShadersGraph")
        ver = MTL.MTLCompileOptions().languageVersion
        @debug "Successfully loaded Metal; targeting v$ver."

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

    # an open batch holds a live command encoder; releasing it from a finalizer
    # without `endEncoding` aborts Metal. end it and drop its uncommitted buffer
    # at exit, without committing or waiting on the GPU.
    atexit() do
        has_active_batched_queues() || return
        try
            @autoreleasepool for bq in active_batched_queues()
                cmdbuf = bq.cmdbuf
                end_encoder!(bq)
                cmdbuf === nothing || reset_open_cmdbuf!(bq, cmdbuf)
            end
        catch err
            @error "Failed to close open batched command queues at exit" exception=(err, catch_backtrace())
        end
    end

    initialization_world[] = Base.get_world_counter()
end

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
