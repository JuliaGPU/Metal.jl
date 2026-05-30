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

# fixed capacities (incl. the null terminator) of the in-mailbox message buffers
const EXCEPTION_NAME_LEN   = 64
const EXCEPTION_REASON_LEN = 192

struct ExceptionInfo_st
    # whether an exception has been encountered (0 -> 1)
    status::Int32
    # whether a lane has claimed the mailbox (0 -> 1), so only one writes a coherent record
    output_lock::Int32
    # the position of the faulting lane
    thread::NTuple{3, UInt32}
    threadgroup::NTuple{3, UInt32}
    # the exception type name and reason, as null-terminated text the host reads back
    name::NTuple{EXCEPTION_NAME_LEN, UInt8}
    reason::NTuple{EXCEPTION_REASON_LEN, UInt8}

    ExceptionInfo_st() = new(0, 0, (0, 0, 0), (0, 0, 0),
                             ntuple(_ -> 0x00, EXCEPTION_NAME_LEN),
                             ntuple(_ -> 0x00, EXCEPTION_REASON_LEN))
end

# field byte offsets, computed once on the host and spliced into device code as constants
const EXCEPTION_STATUS_OFFSET      = Int(fieldoffset(ExceptionInfo_st, 1))
const EXCEPTION_LOCK_OFFSET        = Int(fieldoffset(ExceptionInfo_st, 2))
const EXCEPTION_THREAD_OFFSET      = Int(fieldoffset(ExceptionInfo_st, 3))
const EXCEPTION_THREADGROUP_OFFSET = Int(fieldoffset(ExceptionInfo_st, 4))
const EXCEPTION_NAME_OFFSET        = Int(fieldoffset(ExceptionInfo_st, 5))
const EXCEPTION_REASON_OFFSET      = Int(fieldoffset(ExceptionInfo_st, 6))

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

# claim the mailbox for the calling lane, recording its position. returns `true` to the
# single lane that wins the claim; any other faulting lane gets `false` and leaves the
# record untouched (no spin, so a divergent threadgroup can't deadlock here).
#
# a test-and-set via `atomic_exchange_explicit` (rather than compare-exchange) keeps this
# callable from kernel code: cmpxchg boxes its expected value in a `Ref`, which can survive
# as a heap allocation (`gpu_gc_pool_alloc`/`ijl_stored_inline`) when `llvm-alloc-opt` fails
# to promote it to a stack slot in a complex kernel; the IR validator then rejects it.
# exchange takes its operand by value, so there is nothing to promote.
@inline function lock_output!(info)
    lock_ptr = exception_field(Int32, info, EXCEPTION_LOCK_OFFSET)
    if atomic_exchange_explicit(lock_ptr, Int32(1)) == Int32(0)
        t  = thread_position_in_threadgroup()
        tg = threadgroup_position_in_grid()
        unsafe_store!(exception_field(NTuple{3,UInt32}, info, EXCEPTION_THREAD_OFFSET),
                      (t.x, t.y, t.z))
        unsafe_store!(exception_field(NTuple{3,UInt32}, info, EXCEPTION_THREADGROUP_OFFSET),
                      (tg.x, tg.y, tg.z))
        return true
    end
    return false
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
    # record our position if we're the first faulting lane to reach the mailbox
    lock_output!(info)
    # raise the host-visible flag so the exception isn't silently swallowed
    atomic_store_explicit(exception_field(Int32, info, EXCEPTION_STATUS_OFFSET), Int32(1))
    return
end

# GPUCompiler reports the exception type it deduced (e.g. "bounds error", "type error") at
# debug level >= 1. claim the mailbox and record it as the type name; a quirk's `@gputhrow`
# may already hold the lock with a more precise name and reason, in which case we leave its
# record untouched.
function report_exception(ex)
    info = kernel_state().exception_info
    if lock_output!(info)
        store_cstring!(info, EXCEPTION_NAME_OFFSET, EXCEPTION_NAME_LEN, ex)
    end
    return
end

report_exception_name(ex) = report_exception(ex)

report_oom(sz) = return

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
    # `KernelException`. held as a byte pointer; see `exception_field`.
    exception_info::Core.LLVMPtr{UInt8, AS.Device}
end

@inline @generated kernel_state() = GPUCompiler.kernel_state_value(KernelState)
