# device runtime libraries


## exception mailbox

# device-side exceptions are reported through a host-visible mailbox: an `ExceptionInfo_st`
# living in a shared (CPU+GPU) buffer whose GPU address is handed to each kernel via the
# `KernelState`. the first thread to throw claims the mailbox, records which throw site of
# which kernel threw, and its position, and raises `status`; the host reads it after
# synchronizing (`check_exceptions`), looks up the site, and rethrows as a `KernelException`.

struct ExceptionInfo_st
    # whether an exception has been encountered (0 -> 1), raised once the record is written
    status::Int32
    # whether a thread has claimed the mailbox (0 -> 1); only the holder writes a record
    output_lock::Int32
    # the throw site, see `GPUCompiler.uses_exception_sites`
    site::Int32
    # the table of throw sites of the kernel that threw, see `exception_table_id`
    table::UInt32
    # the position of the thread that threw
    thread::NTuple{3, UInt32}
    threadgroup::NTuple{3, UInt32}

    ExceptionInfo_st() = new(0, 0, 0, 0, (0, 0, 0), (0, 0, 0))
end

# the mailbox is reached through a byte pointer in the kernel state. the accessor below
# returns a typed device pointer to a named field, with both the byte offset and the element
# type derived from the struct's layout.
const EXCEPTION_INFO_OFFSETS = NamedTuple{fieldnames(ExceptionInfo_st)}(
    Tuple(Int(fieldoffset(ExceptionInfo_st, i)) for i in 1:fieldcount(ExceptionInfo_st)))

@inline info_field(info::Core.LLVMPtr{UInt8, AS}, ::Val{field}) where {AS, field} =
    reinterpret(Core.LLVMPtr{fieldtype(ExceptionInfo_st, field), AS},
                info + getfield(EXCEPTION_INFO_OFFSETS, field))

# the thread that threw stops executing after this. GPUCompiler gives every kernel a single
# copy of it, which all of its throw sites branch to.
#
# nothing reachable from it may throw, not even a checked conversion like `Int32(1)`: that
# would form an inference cycle through the throw overlays, which on Julia 1.12+ taints
# Base's conversion methods with the effects of this runtime and keeps everything calling
# them from being evaluated at compile time.
@device_function function exception_site(site::Int32)
    state = kernel_state()
    info = state.exception_info
    # no spin: other threads that throw leave the record alone, so a divergent threadgroup
    # can't deadlock here
    if atomic_exchange_explicit(info_field(info, Val(:output_lock)), 1 % Int32) == 0 % Int32
        t  = thread_position_in_threadgroup()
        tg = threadgroup_position_in_grid()
        unsafe_store!(info_field(info, Val(:site)), site)
        unsafe_store!(info_field(info, Val(:table)), state.exception_table)
        unsafe_store!(info_field(info, Val(:thread)), (t.x, t.y, t.z))
        unsafe_store!(info_field(info, Val(:threadgroup)), (tg.x, tg.y, tg.z))
        atomic_store_explicit(info_field(info, Val(:status)), 1 % Int32)
    end
    return
end

report_oom(sz) = return

# GPUCompiler reports exceptions through these in jobs without a kernel state (see
# `AbstractMetalCompilerParams`), which have no mailbox to report to: the thread that threw
# just stops
signal_exception() = return
report_exception(ex) = return
report_exception_name(ex) = return
report_exception_frame(idx, func, file, line) = return


## kernel state

struct KernelState
    random_seed::UInt32

    # the table of throw sites of the launched kernel, which `exception_site` records along
    # with the site (see `exception_table_id`), or 0 if it has none
    exception_table::UInt32

    # bump allocator buffer
    #
    # the first 4 bytes are an atomically-incremented counter; allocations
    # start at offset 4 and continue until the buffer is exhausted.
    malloc_buf::Core.LLVMPtr{UInt8, AS.Device}

    # device-side exception mailbox (`ExceptionInfo_st`)
    #
    # a host+device visible buffer that `exception_site` fills when a device exception is
    # thrown; the host reads it after synchronizing (`check_exceptions`) and rethrows as a
    # `KernelException`. held as a byte pointer; its fields are reached through `info_field`.
    exception_info::Core.LLVMPtr{UInt8, AS.Device}

    # relocation table
    #
    # the words a relocation-carrying kernel needs (host addresses of interned Symbols, type
    # tags, ...) resolved for this session; GPUCompiler's `:table` lowering reads them from
    # here by index. Read-only, and null for the overwhelmingly common relocation-free kernel
    # — the field is always present so the state layout doesn't depend on what a kernel
    # happens to reference. Never dereferenced on device: the words are only compared.
    reloc_table::Core.LLVMPtr{UInt64, AS.Device}
end

@device_function @inline @generated kernel_state() = GPUCompiler.kernel_state_value(KernelState)
