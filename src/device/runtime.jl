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

# field byte offsets, computed once on the host and spliced into device code as constants
const EXCEPTION_STATUS_OFFSET      = Int(fieldoffset(ExceptionInfo_st, 1))
const EXCEPTION_LOCK_OFFSET        = Int(fieldoffset(ExceptionInfo_st, 2))
const EXCEPTION_THREAD_OFFSET      = Int(fieldoffset(ExceptionInfo_st, 3))
const EXCEPTION_THREADGROUP_OFFSET = Int(fieldoffset(ExceptionInfo_st, 4))
const EXCEPTION_NAME_OFFSET        = Int(fieldoffset(ExceptionInfo_st, 5))
const EXCEPTION_REASON_OFFSET      = Int(fieldoffset(ExceptionInfo_st, 6))
const EXCEPTION_NUM_FRAMES_OFFSET  = Int(fieldoffset(ExceptionInfo_st, 7))
const EXCEPTION_FRAMES_OFFSET      = Int(fieldoffset(ExceptionInfo_st, 8))
const EXCEPTION_FRAME_SIZE         = Int(sizeof(ExceptionFrame_st))
const EXCEPTION_FRAME_FUNC_OFFSET  = Int(fieldoffset(ExceptionFrame_st, 1))
const EXCEPTION_FRAME_FILE_OFFSET  = Int(fieldoffset(ExceptionFrame_st, 2))
const EXCEPTION_FRAME_LINE_OFFSET  = Int(fieldoffset(ExceptionFrame_st, 3))

# the mailbox is reached through a byte pointer in the kernel state; reinterpret it to the
# requested field type at the given byte offset.
@inline exception_field(::Type{T}, info, offset) where {T} =
    reinterpret(Core.LLVMPtr{T, AS.Device},
                reinterpret(Core.LLVMPtr{UInt8, AS.Device}, info) + offset)

# copy a compile-time string literal into a mailbox buffer (null-terminated, truncated to
# `maxlen`). the bytes are known at compile time, so this unrolls to plain constant stores.
@inline @generated function store_string!(info, ::Val{offset}, ::Val{maxlen},
                                          ::Val{str}) where {offset, maxlen, str}
    bytes = codeunits(String(str))
    n = min(length(bytes), maxlen - 1)
    exprs = Expr[:(base = exception_field(UInt8, info, $offset))]
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
#
# this is also the single switch for how much the unhappy path records. at `-g0` there is no
# payload to write, so the mailbox is never claimed and every caller gets `false`; each throw
# site then collapses to the bare `status` store in `signal_exception`, with no lock,
# position, or string writes. `-g1` (the default) records name/reason/position and `-g2` adds
# frames (GPUCompiler only emits the frame reporters then). the gate reads
# `kernel_debug_level()` — GPUCompiler's per-job debug level resolved to a compile-time
# constant during codegen, NOT the `-g` global — so it is part of the compile cache key and
# stays correct under pkgimage reuse across `-g` and under a per-kernel `@metal debug_level=`
# override, while still folding the cold path away at `-g0`.
#
# a test-and-set via `atomic_exchange_explicit` (rather than compare-exchange) keeps this
# callable from kernel code: cmpxchg boxes its expected value in a `Ref`, which can survive
# as a heap allocation (`gpu_gc_pool_alloc`/`ijl_stored_inline`) when `llvm-alloc-opt` fails
# to promote it to a stack slot in a complex kernel; the IR validator then rejects it.
# exchange takes its operand by value, so there is nothing to promote.
@inline function lock_output!(info)
    kernel_debug_level() < 1 && return false
    lock_ptr = exception_field(Int32, info, EXCEPTION_LOCK_OFFSET)
    t  = thread_position_in_threadgroup()
    tg = threadgroup_position_in_grid()
    if atomic_exchange_explicit(lock_ptr, Int32(1)) == Int32(0)
        # we just claimed it; record our position so later calls recognize us
        unsafe_store!(exception_field(NTuple{3,UInt32}, info, EXCEPTION_THREAD_OFFSET),
                      (t.x, t.y, t.z))
        unsafe_store!(exception_field(NTuple{3,UInt32}, info, EXCEPTION_THREADGROUP_OFFSET),
                      (tg.x, tg.y, tg.z))
        return true
    end
    # already claimed: re-entrant only for the lane that holds it
    held_t  = unsafe_load(exception_field(NTuple{3,UInt32}, info, EXCEPTION_THREAD_OFFSET))
    held_tg = unsafe_load(exception_field(NTuple{3,UInt32}, info, EXCEPTION_THREADGROUP_OFFSET))
    return held_t == (t.x, t.y, t.z) && held_tg == (tg.x, tg.y, tg.z)
end

# copy a null-terminated device C string into a mailbox buffer, truncated to `maxlen`.
@inline function store_cstring!(info, offset, maxlen, src::Ptr{Cchar})
    base = exception_field(UInt8, info, offset)
    i = 0
    while i < maxlen - 1
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
    atomic_store_explicit(exception_field(Int32, info, EXCEPTION_STATUS_OFFSET), Int32(1))
    return
end

# GPUCompiler reports the exception type it deduced (e.g. "bounds error", "type error") at
# debug level 1 (`report_exception`) or >= 2 (`report_exception_name`). record it as the
# type name, unless a quirk's `@gputhrow` already wrote a more precise name (in which case
# the name buffer is non-empty and we leave it alone).
#
# the deduced name arrives as a constant global behind a generic pointer; GPUCompiler's
# interprocedural address-space narrowing iterates to a fixed point, so the delegation
# below still resolves the read to the constant space (needed so Metal's shader validator
# doesn't crash on a generic-space load).
function report_exception(ex)
    info = kernel_state().exception_info
    if lock_output!(info) &&
       unsafe_load(exception_field(UInt8, info, EXCEPTION_NAME_OFFSET)) == 0x00
        store_cstring!(info, EXCEPTION_NAME_OFFSET, EXCEPTION_NAME_LEN, ex)
    end
    return
end
report_exception_name(ex) = report_exception(ex)

report_oom(sz) = return

# GPUCompiler reports each stack frame (recovered from debug info) at debug level >= 2.
function report_exception_frame(idx, func, file, line)
    info = kernel_state().exception_info
    if lock_output!(info) && 1 <= idx <= EXCEPTION_MAX_FRAMES
        frame = EXCEPTION_FRAMES_OFFSET + (Int(idx) - 1) * EXCEPTION_FRAME_SIZE
        store_cstring!(info, frame + EXCEPTION_FRAME_FUNC_OFFSET, EXCEPTION_FUNC_LEN, func)
        store_cstring!(info, frame + EXCEPTION_FRAME_FILE_OFFSET, EXCEPTION_FILE_LEN, file)
        unsafe_store!(exception_field(Int32, info, frame + EXCEPTION_FRAME_LINE_OFFSET),
                      Int32(line))
        unsafe_store!(exception_field(Int32, info, EXCEPTION_NUM_FRAMES_OFFSET), Int32(idx))
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
    # `KernelException`. held as a byte pointer; see `exception_field`.
    exception_info::Core.LLVMPtr{UInt8, AS.Device}
end

@inline @generated kernel_state() = GPUCompiler.kernel_state_value(KernelState)
