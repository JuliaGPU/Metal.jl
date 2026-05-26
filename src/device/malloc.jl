# dynamic memory allocation
#
# bump-pointer allocator for device code. intentionally minimal: no `free`,
# and once the buffer is exhausted, returns a null pointer.

@inline function malloc(sz::Csize_t)
    buf = kernel_state().malloc_buf
    counter = reinterpret(Core.LLVMPtr{UInt32, AS.Device}, buf)
    aligned = ((sz + Csize_t(7)) & ~Csize_t(7)) % UInt32 # 8-byte aligned
    offset = atomic_fetch_add_explicit(counter, aligned)
    if UInt64(offset) + UInt64(aligned) > MALLOC_BUF_SIZE
        return reinterpret(Ptr{Nothing}, C_NULL)
    end
    return reinterpret(Ptr{Nothing}, buf + offset)
end
