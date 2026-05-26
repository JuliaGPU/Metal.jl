# dynamic memory allocation
#
# overrides GPUCompiler's weak `gpu_malloc` stub with a bump-pointer allocator
# backed by a per-device buffer pointed to from `KernelState.malloc_buf`. the
# first 4 bytes of the buffer are an atomically-incremented counter; the host
# initializes it to 4 at buffer creation so the first allocation lands past
# the counter itself.
#
# this is intentionally minimal: there is no `free`, and once the buffer is
# exhausted, subsequent allocations return past-the-end pointers (the dead
# throw-path boxing that motivates this never dereferences the result, so
# this is benign for the current use case).
#
# GPUCompiler picks this up automatically via `runtime_module(::MetalCompilerJob) = Metal`
# and the `compile(:malloc, ...)` registration in GPUCompiler/src/runtime.jl.
@inline function malloc(sz::Csize_t)
    buf = kernel_state().malloc_buf
    counter = reinterpret(Core.LLVMPtr{UInt32, AS.Device}, buf)
    # align allocations up to 8 bytes; use `% UInt32` (not `UInt32(sz)`) so
    # the device code doesn't contain an InexactError throw path
    aligned = ((sz + Csize_t(7)) & ~Csize_t(7)) % UInt32
    offset = atomic_fetch_add_explicit(counter, aligned)
    return reinterpret(Ptr{Nothing}, buf + offset)
end
