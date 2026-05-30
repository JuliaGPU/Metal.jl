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

struct ExceptionInfo_st
    # whether an exception has been encountered (0 -> 1)
    status::Int32
    # whether a lane has claimed the mailbox (0 -> 1), so only one writes a coherent record
    output_lock::Int32
    # the position of the faulting lane
    thread::NTuple{3, UInt32}
    threadgroup::NTuple{3, UInt32}

    ExceptionInfo_st() = new(0, 0, (0, 0, 0), (0, 0, 0))
end

# field byte offsets, computed once on the host and spliced into device code as constants
const EXCEPTION_STATUS_OFFSET      = Int(fieldoffset(ExceptionInfo_st, 1))
const EXCEPTION_LOCK_OFFSET        = Int(fieldoffset(ExceptionInfo_st, 2))
const EXCEPTION_THREAD_OFFSET      = Int(fieldoffset(ExceptionInfo_st, 3))
const EXCEPTION_THREADGROUP_OFFSET = Int(fieldoffset(ExceptionInfo_st, 4))

# the mailbox is reached through a byte pointer in the kernel state; reinterpret it to the
# requested field type at the given byte offset.
@inline _exception_field(::Type{T}, info, offset) where {T} =
    reinterpret(Core.LLVMPtr{T, AS.Device},
                reinterpret(Core.LLVMPtr{UInt8, AS.Device}, info) + offset)

# claim the mailbox for the calling lane, recording its position. returns `true` to the
# single lane that wins the claim; any other faulting lane gets `false` and leaves the
# record untouched (no spin, so a divergent threadgroup can't deadlock here).
@inline function lock_output!(info)
    lock_ptr = _exception_field(Int32, info, EXCEPTION_LOCK_OFFSET)
    if atomic_compare_exchange_weak_explicit(lock_ptr, Int32(0), Int32(1)) == Int32(0)
        t  = thread_position_in_threadgroup()
        tg = threadgroup_position_in_grid()
        unsafe_store!(_exception_field(NTuple{3,UInt32}, info, EXCEPTION_THREAD_OFFSET),
                      (t.x, t.y, t.z))
        unsafe_store!(_exception_field(NTuple{3,UInt32}, info, EXCEPTION_THREADGROUP_OFFSET),
                      (tg.x, tg.y, tg.z))
        return true
    end
    return false
end

function signal_exception()
    info = kernel_state().exception_info
    # record our position if we're the first faulting lane to reach the mailbox
    lock_output!(info)
    # raise the host-visible flag so the exception isn't silently swallowed
    atomic_store_explicit(_exception_field(Int32, info, EXCEPTION_STATUS_OFFSET), Int32(1))
    return
end

report_exception(ex) = return

report_oom(sz) = return

report_exception_name(ex) = return

report_exception_frame(idx, func, file, line) = return


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
    # `KernelException`. held as a byte pointer; see `_exception_field`.
    exception_info::Core.LLVMPtr{UInt8, AS.Device}
end

@inline @generated kernel_state() = GPUCompiler.kernel_state_value(KernelState)
