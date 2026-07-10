# device runtime libraries


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
    # the position of the faulting lane, recorded at debug level >= 2 (also used to
    # recognize the lock holder for the multi-call -g2 reporting sequence)
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
# at compile time, so this packs them into 64-bit words and stores those.
#
# kept out of line (`:noinline`): this is unhappy-path code, and inlining its stores into
# every kernel that can throw bloats the kernel the Metal shader validator then has to
# compile (see `lock_output!`). storing whole words rather than byte-at-a-time matters for
# the same reason: GPU validation instruments every store, so a `UInt64` store is 8× cheaper
# to validate than eight `UInt8` stores. the mailbox text buffers (`name`, `reason`) are
# 8-byte aligned within `ExceptionInfo_st` and their capacities are multiples of 8, so the
# word stores stay aligned and in bounds; the literal is zero-padded to a word boundary,
# which also writes the null terminator.
@generated function store_string!(dest::Core.LLVMPtr{NTuple{N, UInt8}, AS},
                                  ::Val{str}) where {N, AS, str}
    bytes = collect(codeunits(String(str)))
    n = min(length(bytes), N - 1)
    padded = bytes[1:n]
    push!(padded, 0x00)                              # null terminator
    while length(padded) % sizeof(UInt64) != 0       # zero-pad to a word boundary
        push!(padded, 0x00)
    end
    exprs = Expr[Expr(:meta, :noinline),
                 :(base = reinterpret(Core.LLVMPtr{UInt64, $AS}, dest))]
    for w in 0:(length(padded) ÷ sizeof(UInt64) - 1)
        word = UInt64(0)
        for b in 0:(sizeof(UInt64) - 1)              # little-endian pack
            word |= UInt64(padded[w * sizeof(UInt64) + b + 1]) << (8 * b)
        end
        push!(exprs, :(unsafe_store!(base + $(w * sizeof(UInt64)), $word)))
    end
    push!(exprs, :(return nothing))
    return Expr(:block, exprs...)
end

# claim the mailbox for the calling lane. returns `true` to the lane that wins the claim
# (at `-g2` also re-entrantly to that same lane on later calls, recognized by its recorded
# position), so it can go on to write the name, reason, and stack frames. any other faulting
# lane gets `false` and leaves the record untouched (no spin, so a divergent threadgroup
# can't deadlock here).
#
# the debug-level gate is kept inline so it folds to a compile-time constant: at `-g0` this
# returns `false` unconditionally, and everything it guards (the recording below, plus the
# name/reason/frame stores in callers) becomes dead and is eliminated, leaving the unhappy
# path as just the status flag in `signal_exception`. the actual claim is `@noinline`.
@inline lock_output!(info) = kernel_debug_level() < 1 ? false : claim_output!(info)

# the body of `lock_output!`, kept out of line. with `--check-bounds=yes` every indexing
# operation grows a throw path, and inlining this claim into each one balloons the kernel.
# Apple's shader validator compiles that bloated kernel on every PSO creation and, on the
# macOS 15 CI runner, crashes doing so; the backend then retries, which is what made the
# validation suite time out. one shared, called-into copy keeps each kernel's unhappy path
# to a handful of calls.
@noinline function claim_output!(info)
    lock_ptr = info_field(info, Val(:output_lock))
    if kernel_debug_level() < 2
        # one-shot claim: at `-g1` each lane records everything it has to say (the name
        # and reason) under a single call, so no re-entrancy is needed -- and skipping the
        # position recording keeps the unhappy path down to this single atomic exchange.
        # that frugality is measured, not aesthetic: the position machinery (reading the
        # thread-position kernel inputs, keeping them live into cold code, and the
        # re-entrant comparisons below) is penalized by the M1 (macOS 15) backend in every
        # kernel that can throw, even when no exception is ever thrown -- it alone
        # regressed accumulate by ~50% (JuliaGPU/Metal.jl#796), independently of the
        # other costly construct (see `report_exception`). the lane's position is hence
        # only recorded, and reported, at `-g2`.
        return atomic_exchange_explicit(lock_ptr, Int32(1)) == Int32(0)
    end
    # re-entrant claim: the `-g2` reporting sequence spans multiple calls (the exception
    # name, then each stack frame), so the holder must be able to re-claim, recognized by
    # its recorded position (which doubles as the reported fault location).
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
# the buffer's capacity (taken from its type). kept out of line for the same reason as
# `lock_output!`: it's unhappy-path code that should not bloat every throwing kernel.
@noinline function store_cstring!(dest::Core.LLVMPtr{NTuple{N, UInt8}, AS},
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

# record a compile-time exception name and reason in the mailbox, claiming it first. one
# out-of-line copy serves every `@gputhrow` site of a given exception (see the macro),
# keeping per-site cold code to a single call whose only argument is the mailbox pointer.
@noinline function record_exception!(info, ::Val{name}, ::Val{reason}) where {name, reason}
    if lock_output!(info)
        store_string!(info_field(info, Val(:name)),   Val(name))
        store_string!(info_field(info, Val(:reason)), Val(reason))
    end
    return
end

function signal_exception()
    info = kernel_state().exception_info
    # raise the host-visible flag so the exception isn't silently swallowed. no claiming
    # here: at debug level >= 1 the reporting calls preceding this one (`report_exception`,
    # `@gputhrow`) have already claimed the mailbox and recorded what there is to record,
    # and at `-g0` there is nothing to claim for, keeping this -- the one call present at
    # every throw site regardless of debug level -- free of mailbox traffic.
    atomic_store_explicit(info_field(info, Val(:status)), Int32(1))
    return
end

# GPUCompiler reports the exception type it deduced (e.g. "bounds error", "type error") at
# debug level 1 (`report_exception`) or >= 2 (`report_exception_name`). record it as the
# type name, unless a quirk's `@gputhrow` already wrote a more precise name (in which case
# the name buffer is non-empty and we leave it alone).
#
# recording only happens at debug level >= 2: copying the runtime name string requires
# `store_cstring!`'s data-dependent byte loop, and a loop on the unhappy path is one of the
# constructs the M1 (macOS 15) backend penalizes in every kernel that can throw, even when
# no exception is ever thrown (it alone regressed accumulate by more than 50%; see
# `claim_output!` for the other one). at `-g1` this folds to an empty function, and quirk
# throws -- the common exceptions -- still record their full name and reason through
# `record_exception!`'s loop-free word stores.
function report_exception(ex)
    if kernel_debug_level() >= 2
        info = kernel_state().exception_info
        name = info_field(info, Val(:name))
        if lock_output!(info) &&
           unsafe_load(reinterpret(Core.LLVMPtr{UInt8, AS.Device}, name)) == 0x00
            store_cstring!(name, ex)
        end
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
