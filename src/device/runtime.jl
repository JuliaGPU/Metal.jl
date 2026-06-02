# device runtime libraries


## Julia library

# reset the runtime cache from global scope, so that any change triggers recompilation
GPUCompiler.reset_runtime()


## exception mailbox

# device-side exceptions are reported through a host-visible mailbox: an `ExceptionInfo_st`
# living in a shared (CPU+GPU) buffer whose GPU address is handed to each kernel via the
# `KernelState`. a faulting lane claims the mailbox under a single-writer lock, records its
# position (and, eventually, the exception type and reason), and raises `status`; the host
# reads it after synchronizing (`check_exceptions`) and rethrows as a `KernelException`.

# fixed capacities (incl. the null terminator) of the in-mailbox text buffers, and the
# number of stack frames captured at debug level >= 2 (GPUCompiler only reports frames then)
const EXCEPTION_NAME_LEN   = 64
const EXCEPTION_REASON_LEN = 192
const EXCEPTION_FUNC_LEN   = 128
const EXCEPTION_FILE_LEN   = 128
const EXCEPTION_MAX_FRAMES = 16

struct ExceptionFrame_st
    func::NTuple{EXCEPTION_FUNC_LEN, UInt8}
    file::NTuple{EXCEPTION_FILE_LEN, UInt8}
    line::Int32

    ExceptionFrame_st() = new(ntuple(_ -> 0x00, EXCEPTION_FUNC_LEN),
                              ntuple(_ -> 0x00, EXCEPTION_FILE_LEN), 0)
end

struct ExceptionInfo_st
    # whether an exception has been encountered (0 -> 1)
    status::Int32
    # whether a lane has claimed the mailbox (0 -> 1); only the holder writes a record
    output_lock::Int32
    # the position of the faulting lane (also used to recognize the lock holder)
    thread::NTuple{3, UInt32}
    threadgroup::NTuple{3, UInt32}
    # the exception type name and reason, as null-terminated text the host reads back
    name::NTuple{EXCEPTION_NAME_LEN, UInt8}
    reason::NTuple{EXCEPTION_REASON_LEN, UInt8}
    # the device-side stack trace, captured at debug level >= 2
    num_frames::Int32
    frames::NTuple{EXCEPTION_MAX_FRAMES, ExceptionFrame_st}

    ExceptionInfo_st() = new(0, 0, (0, 0, 0), (0, 0, 0),
                             ntuple(_ -> 0x00, EXCEPTION_NAME_LEN),
                             ntuple(_ -> 0x00, EXCEPTION_REASON_LEN),
                             0, ntuple(_ -> ExceptionFrame_st(), EXCEPTION_MAX_FRAMES))
end

# the mailbox is reached through a byte pointer in the kernel state. the accessors below
# return a typed device pointer to a named field, with both the byte offset and the element
# type derived from the struct's layout.
const EXCEPTION_INFO_OFFSETS = NamedTuple{fieldnames(ExceptionInfo_st)}(
    Tuple(Int(fieldoffset(ExceptionInfo_st, i)) for i in 1:fieldcount(ExceptionInfo_st)))
const EXCEPTION_FRAME_OFFSETS = NamedTuple{fieldnames(ExceptionFrame_st)}(
    Tuple(Int(fieldoffset(ExceptionFrame_st, i)) for i in 1:fieldcount(ExceptionFrame_st)))
const EXCEPTION_FRAME_SIZE = sizeof(ExceptionFrame_st)

@inline info_field(info::Core.LLVMPtr{UInt8, AS}, ::Val{field}) where {AS, field} =
    reinterpret(Core.LLVMPtr{fieldtype(ExceptionInfo_st, field), AS},
                info + getfield(EXCEPTION_INFO_OFFSETS, field))
@inline frame_field(frame::Core.LLVMPtr{UInt8, AS}, ::Val{field}) where {AS, field} =
    reinterpret(Core.LLVMPtr{fieldtype(ExceptionFrame_st, field), AS},
                frame + getfield(EXCEPTION_FRAME_OFFSETS, field))

# a byte pointer to the `idx`-th frame (1-based) in the mailbox's frame array. the stride is
# the frame size (also host-derived), so adding the 0-based index walks the array in
# `ExceptionFrame_st`-sized steps (`LLVMPtr` arithmetic is byte-based); the result is handed
# to `frame_field` to reach the frame's own fields.
@inline frame_pointer(info::Core.LLVMPtr{UInt8, AS}, idx) where {AS} =
    info + EXCEPTION_INFO_OFFSETS.frames + (idx - 1) * EXCEPTION_FRAME_SIZE

# copy a compile-time string literal into a fixed-size mailbox text buffer (null-terminated,
# truncated to the buffer's capacity, which is taken from its own type). the bytes are known
# at compile time, so this unrolls to plain constant stores.
@inline @generated function store_string!(dest::Core.LLVMPtr{NTuple{N, UInt8}, AS},
                                          ::Val{str}) where {N, AS, str}
    bytes = codeunits(String(str))
    n = min(length(bytes), N - 1)
    exprs = Expr[:(base = reinterpret(Core.LLVMPtr{UInt8, $AS}, dest))]
    for i in 1:n
        push!(exprs, :(unsafe_store!(base + $(i - 1), $(bytes[i]))))
    end
    push!(exprs, :(unsafe_store!(base + $n, 0x00)))
    push!(exprs, :(return nothing))
    return Expr(:block, exprs...)
end

# claim the mailbox for the calling lane. returns `true` to the single lane that wins the
# claim and, re-entrantly, to that same lane on later calls (recognized by its recorded
# position), so it can go on to write the name, reason, and stack frames. any other faulting
# lane gets `false` and leaves the record untouched (no spin, so a divergent threadgroup
# can't deadlock here).
@inline function lock_output!(info)
    kernel_debug_level() < 1 && return false
    lock_ptr = info_field(info, Val(:output_lock))
    t  = thread_position_in_threadgroup()
    tg = threadgroup_position_in_grid()
    if atomic_exchange_explicit(lock_ptr, Int32(1)) == Int32(0)
        # we just claimed it; record our position so later calls recognize us
        unsafe_store!(info_field(info, Val(:thread)), (t.x, t.y, t.z))
        unsafe_store!(info_field(info, Val(:threadgroup)), (tg.x, tg.y, tg.z))
        return true
    end
    # already claimed: re-entrant only for the lane that holds it
    held_t  = unsafe_load(info_field(info, Val(:thread)))
    held_tg = unsafe_load(info_field(info, Val(:threadgroup)))
    return held_t == (t.x, t.y, t.z) && held_tg == (tg.x, tg.y, tg.z)
end

# copy a null-terminated device C string into a fixed-size mailbox text buffer, truncated to
# the buffer's capacity (taken from its type).
@inline function store_cstring!(dest::Core.LLVMPtr{NTuple{N, UInt8}, AS},
                                src::Ptr{Cchar}) where {N, AS}
    base = reinterpret(Core.LLVMPtr{UInt8, AS}, dest)
    i = 0
    while i < N - 1
        c = unsafe_load(src + i) % UInt8
        c == 0x00 && break
        unsafe_store!(base + i, c)
        i += 1
    end
    unsafe_store!(base + i, 0x00)
    return
end

function signal_exception()
    info = kernel_state().exception_info
    # record our position if we're the first faulting lane to reach the mailbox; at `-g0`
    # `lock_output!` is a no-op (returns `false`), leaving only the status flag below
    lock_output!(info)
    # raise the host-visible flag so the exception isn't silently swallowed
    atomic_store_explicit(info_field(info, Val(:status)), Int32(1))
    return
end

# GPUCompiler reports the exception type it deduced (e.g. "bounds error", "type error") at
# debug level 1 (`report_exception`) or >= 2 (`report_exception_name`). record it as the
# type name, unless a quirk's `@gputhrow` already wrote a more precise name (in which case
# the name buffer is non-empty and we leave it alone).
function report_exception(ex)
    info = kernel_state().exception_info
    name = info_field(info, Val(:name))
    if lock_output!(info) &&
       unsafe_load(reinterpret(Core.LLVMPtr{UInt8, AS.Device}, name)) == 0x00
        store_cstring!(name, ex)
    end
    return
end
report_exception_name(ex) = report_exception(ex)

report_oom(sz) = return

# GPUCompiler reports each stack frame (recovered from debug info) at debug level >= 2.
function report_exception_frame(idx, func, file, line)
    info = kernel_state().exception_info
    if lock_output!(info) && 1 <= idx <= EXCEPTION_MAX_FRAMES
        frame = frame_pointer(info, idx)
        store_cstring!(frame_field(frame, Val(:func)), func)
        store_cstring!(frame_field(frame, Val(:file)), file)
        unsafe_store!(frame_field(frame, Val(:line)), Int32(line))
        unsafe_store!(info_field(info, Val(:num_frames)), Int32(idx))
    end
    return
end


## kernel state

struct KernelState
    random_seed::UInt32

    # bump allocator buffer
    #
    # the first 4 bytes are an atomically-incremented counter; allocations
    # start at offset 4 and continue until the buffer is exhausted.
    malloc_buf::Core.LLVMPtr{UInt8, AS.Device}

    # device-side exception mailbox (`ExceptionInfo_st`)
    #
    # a host+device visible buffer that `signal_exception` fills when a device exception is
    # thrown; the host reads it after synchronizing (`check_exceptions`) and rethrows as a
    # `KernelException`. held as a byte pointer; its fields are reached through `info_field`.
    exception_info::Core.LLVMPtr{UInt8, AS.Device}
end

@inline @generated kernel_state() = GPUCompiler.kernel_state_value(KernelState)
