@enum EncoderKind NoEncoder ComputeEncoder BlitEncoder

const COMMAND_BATCH_MAX_OPS_PREF = @load_preference("command_batch_max_ops", nothing)
const COMMAND_BATCH_MAX_BYTES_PREF = @load_preference("command_batch_max_bytes", nothing)
const COMMAND_MAX_INFLIGHT_PREF = @load_preference("command_max_inflight", nothing)

function positive_int_setting(env, pref, default)
    value = if haskey(ENV, env)
        parsed = tryparse(Int, ENV[env])
        parsed === nothing &&
            error("$env must be a positive integer, got $(repr(ENV[env]))")
        parsed
    elseif pref !== nothing
        pref isa Integer ||
            error("Preference must be a positive integer, got $(repr(pref))")
        Int(pref)
    else
        default
    end

    value > 0 || error("Setting must be a positive integer, got $value")
    return value
end

const COMMAND_BATCH_MAX_OPS =
    positive_int_setting("JULIA_METAL_COMMAND_BATCH_MAX_OPS",
                         COMMAND_BATCH_MAX_OPS_PREF, 64)
const COMMAND_BATCH_MAX_BYTES =
    positive_int_setting("JULIA_METAL_COMMAND_BATCH_MAX_BYTES",
                         COMMAND_BATCH_MAX_BYTES_PREF, 64 * 1024 * 1024)
const COMMAND_MAX_INFLIGHT =
    positive_int_setting("JULIA_METAL_COMMAND_MAX_INFLIGHT",
                         COMMAND_MAX_INFLIGHT_PREF, 3)

struct PendingCommand
    cmdbuf::MTL.MTLCommandBufferLike
    roots::Vector{Any}
end

# Completion handlers run on libdispatch worker threads, where compiling or
# running Julia code can overflow the small foreign stack. Keep command buffers
# alive and drain Julia roots from normal managed threads instead.
mutable struct CommandStream
    queue::MTLCommandQueue
    dev::MTLDevice
    cmdbuf::Union{Nothing,MTLCommandBuffer}
    encoder::Union{Nothing,MTLComputeCommandEncoder,MTLBlitCommandEncoder}
    kind::EncoderKind
    roots::Vector{Any}
    last_pipeline::Union{Nothing,MTLComputePipelineState}
    nops::Int
    nbytes::Int
    pending_ops::Vector{Any}
    cleanups::Vector{PendingCommand}
end

function CommandStream(queue::MTLCommandQueue)
    CommandStream(queue, queue.device, nothing, nothing, NoEncoder,
                  Any[], nothing, 0, 0, Any[], PendingCommand[])
end

const command_streams = IdDict{CommandStream,Nothing}()
const command_streams_lock = ReentrantLock()

@inline command_stream_key(queue::MTLCommandQueue) =
    (:MTLCommandStream, pointer(queue))

function register_stream!(s::CommandStream)
    Base.@lock command_streams_lock begin
        command_streams[s] = nothing
    end
    return
end

function unregister_stream_if_idle!(s::CommandStream)
    (s.cmdbuf === nothing && isempty(s.cleanups)) || return
    Base.@lock command_streams_lock begin
        if s.cmdbuf === nothing && isempty(s.cleanups)
            delete!(command_streams, s)
        end
    end
    return
end

function active_command_streams()
    Base.@lock command_streams_lock collect(keys(command_streams))
end

function command_stream(queue::MTLCommandQueue = global_queue(device()))
    get!(task_local_storage(), command_stream_key(queue)) do
        CommandStream(queue)
    end::CommandStream
end

function current_command_stream(queue::MTLCommandQueue)
    get(task_local_storage(), command_stream_key(queue), nothing)
end

profiling_command_buffers() =
    MTL.profile_hook[] !== nothing || MTL.profile_metadata[] !== nothing

function ensure_cmdbuf!(s::CommandStream)
    cmdbuf = s.cmdbuf
    if cmdbuf === nothing
        cmdbuf = MTLCommandBuffer(s.queue)
        # `commandBuffer` and command encoders are autoreleased. A stream can
        # outlive the surrounding autorelease pool, so hold explicit references
        # while they are open.
        retain(cmdbuf)
        @label! cmdbuf "MTLCommandBuffer(command stream)"
        s.cmdbuf = cmdbuf
        register_stream!(s)
    end
    return cmdbuf::MTLCommandBuffer
end

function end_encoder!(s::CommandStream)
    enc = s.encoder
    enc === nothing && return

    s.encoder = nothing
    s.kind = NoEncoder
    s.last_pipeline = nothing
    try
        close(enc)
    finally
        release(enc)
    end
    return
end

function compute_encoder(s::CommandStream)
    if s.kind == ComputeEncoder
        return s.encoder::MTLComputeCommandEncoder
    end

    end_encoder!(s)
    enc = MTLComputeCommandEncoder(ensure_cmdbuf!(s))
    retain(enc)
    s.encoder = enc
    s.kind = ComputeEncoder
    return enc
end

function blit_encoder(s::CommandStream)
    if s.kind == BlitEncoder
        return s.encoder::MTLBlitCommandEncoder
    end

    end_encoder!(s)
    enc = MTLBlitCommandEncoder(ensure_cmdbuf!(s))
    retain(enc)
    s.encoder = enc
    s.kind = BlitEncoder
    return enc
end

function note_operation!(s::CommandStream, op)
    MTL.profile_metadata[] === nothing && return
    push!(s.pending_ops, op)
    return
end

function register_operations!(s::CommandStream, cmdbuf)
    md = MTL.profile_metadata[]
    md === nothing && return
    for op in s.pending_ops
        MTL.note_operation!(md, cmdbuf, op)
    end
    return
end

function defer_cleanup!(s::CommandStream, cmdbuf::MTL.MTLCommandBufferLike,
                        roots::Vector{Any})
    retain(cmdbuf)
    push!(s.cleanups, PendingCommand(cmdbuf, roots))
    register_stream!(s)
    return
end

defer_cleanup!(queue::MTLCommandQueue, cmdbuf::MTL.MTLCommandBufferLike,
               roots::Vector{Any}) =
    defer_cleanup!(command_stream(queue), cmdbuf, roots)

function drain_cleanups!(s::CommandStream; force::Bool=false)
    n = 0
    for cleanup in s.cleanups
        if !(force || cleanup.cmdbuf.status >= MTL.MTLCommandBufferStatusCompleted)
            break
        end
        n += 1
    end
    n == 0 && return

    completed = s.cleanups[1:n]
    deleteat!(s.cleanups, 1:n)

    for cleanup in completed
        if cleanup.cmdbuf.status == MTL.MTLCommandBufferStatusError
            @error "Command buffer failed" reason=cleanup.cmdbuf.error.localizedDescription
        end
        empty!(cleanup.roots)
        release(cleanup.cmdbuf)
    end

    unregister_stream_if_idle!(s)
    return
end

function drain_cleanups!(queue::MTLCommandQueue; force::Bool=false)
    for s in active_command_streams()
        s.queue === queue || continue
        drain_cleanups!(s; force)
    end
    return
end

function pending_cleanup_count(s::CommandStream)
    return length(s.cleanups)
end

function wait_oldest_cleanup!(s::CommandStream)
    isempty(s.cleanups) && return
    cmdbuf = first(s.cleanups).cmdbuf
    retain(cmdbuf)
    try
        wait_completed(cmdbuf)
    finally
        release(cmdbuf)
    end
    drain_cleanups!(s)
    return
end

function limit_inflight!(s::CommandStream)
    drain_cleanups!(s)
    while pending_cleanup_count(s) >= COMMAND_MAX_INFLIGHT
        wait_oldest_cleanup!(s)
    end
    return
end

function reset_open_cmdbuf!(s::CommandStream, cmdbuf)
    s.cmdbuf = nothing
    s.roots = Any[]
    s.pending_ops = Any[]
    s.nops = 0
    s.nbytes = 0
    release(cmdbuf)
    unregister_stream_if_idle!(s)
    return
end

function flush!(s::CommandStream)
    cmdbuf = s.cmdbuf
    cmdbuf === nothing && return

    end_encoder!(s)
    register_operations!(s, cmdbuf)
    roots = s.roots
    commit!(cmdbuf, s.queue)
    defer_cleanup!(s, cmdbuf, roots)
    reset_open_cmdbuf!(s, cmdbuf)
    limit_inflight!(s)
    return
end

function flush!(queue::MTLCommandQueue = global_queue(device()))
    s = current_command_stream(queue)
    s === nothing || flush!(s)
    return
end

function flush_command_streams!(queue::Union{Nothing,MTLCommandQueue}=nothing)
    for s in active_command_streams()
        queue === nothing || s.queue === queue || continue
        flush!(s)
    end
    return
end

function maybe_autoflush!(s::CommandStream)
    if profiling_command_buffers() ||
       s.nops >= COMMAND_BATCH_MAX_OPS ||
       s.nbytes >= COMMAND_BATCH_MAX_BYTES
        flush!(s)
    end
    return
end

function external_cmdbuf(queue::MTLCommandQueue = global_queue(device()))
    flush!(queue)
    return MTLCommandBuffer(queue)
end

function external_cmdbuf(f::Base.Callable, queue::MTLCommandQueue)
    cmdbuf = external_cmdbuf(queue)
    commit!(f, cmdbuf)
    return cmdbuf
end
