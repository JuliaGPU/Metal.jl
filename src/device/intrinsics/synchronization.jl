# Synchronization
using CEnum

export MemoryFlags, memory_order, thread_scope, atomic_thread_fence,
       threadgroup_barrier, simdgroup_barrier
@public memory_order_relaxed, memory_order_acquire, memory_order_release,
        memory_order_acq_rel, memory_order_seq_cst,
        thread_scope_thread, thread_scope_threadgroup, thread_scope_device,
        thread_scope_simdgroup,
        MemoryFlagNone, MemoryFlagDevice, MemoryFlagThreadGroup, MemoryFlagTexture,
        MemoryFlagThreadGroup_ImgBlock

"""
    memory_order

The memory order of an atomic operation, fence or barrier, as in MSL and C++:

- `Metal.memory_order_relaxed`: no ordering of other memory accesses.
- `Metal.memory_order_acquire`: later accesses cannot move before this operation.
- `Metal.memory_order_release`: earlier accesses cannot move after this operation.
- `Metal.memory_order_acq_rel`: both acquire and release.
- `Metal.memory_order_seq_cst`: acquire and release, and a single total order of all
  sequentially consistent operations.

The order has to be a compile-time constant. Before Metal 4.1 (macOS 27), barriers and
ordered fences are always sequentially consistent.
"""
@enum memory_order::Int32 begin
    memory_order_relaxed = 0
    memory_order_acquire = 2
    memory_order_release = 3
    memory_order_acq_rel = 4
    memory_order_seq_cst = 5
end

"""
    thread_scope

The set of threads that a fence or barrier synchronizes with, as in MSL:
`Metal.thread_scope_thread`, `Metal.thread_scope_simdgroup`,
`Metal.thread_scope_threadgroup` or `Metal.thread_scope_device`. The scope has to be a
compile-time constant.
"""
@enum thread_scope::Int32 begin
    thread_scope_thread = 0
    thread_scope_threadgroup = 1
    thread_scope_device = 2
    thread_scope_simdgroup = 4
end

"""
    MemoryFlags

Flags that select the memory a barrier or fence orders accesses to, combined with `|`:

- `Metal.MemoryFlagNone`: no memory; a barrier only synchronizes execution.
- `Metal.MemoryFlagDevice`: device memory, e.g., `MtlArray`s passed to the kernel.
- `Metal.MemoryFlagThreadGroup`: threadgroup memory ([`MtlThreadGroupArray`](@ref)).
- `Metal.MemoryFlagTexture`: texture memory, for textures with read-write access.
- `Metal.MemoryFlagThreadGroup_ImgBlock`: threadgroup imageblock memory.

The barriers default to `MemoryFlagNone`, so to make writes to threadgroup memory visible to
the other threads of the threadgroup, pass `Metal.MemoryFlagThreadGroup`:

```julia
threadgroup_barrier(Metal.MemoryFlagThreadGroup)
```

The flags have to be compile-time constants. See [`mem_flags` in the Metal Shading Language
specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf).
"""
@cenum MemoryFlags::UInt32 begin
    MemoryFlagNone                  = 0
    MemoryFlagDevice                = 1
    MemoryFlagThreadGroup           = 2
    MemoryFlagTexture               = 4
    MemoryFlagThreadGroup_ImgBlock  = 8
end

# The LLVM synchronization scope called `scope`, ordering the memory named by `flags` (by
# default, device and threadgroup memory). LLVM cannot express memory flags (its orderings
# order all memory), so they are part of the scope's name, which GPUCompiler turns back into
# flags: e.g., `device-mem-global` for `MemoryFlagDevice`. Like the memory order, the flags
# have to be a constant.
@inline memory_scope(scope::Val, flags::Union{Nothing,MemoryFlags,UInt32}=nothing) =
    memory_scope(scope, Val(flags))
@generated function memory_scope(::Val{scope}, ::Val{flags}) where {scope, flags}
    valid = flags isa Union{MemoryFlags,UInt32} && UInt32(flags) < 16
    if flags === nothing || valid && UInt32(flags) == UInt32(3)
        name = string(scope)
    elseif valid
        classes = [class for (flag, class) in ((MemoryFlagDevice, "global"),
                                               (MemoryFlagThreadGroup, "local"),
                                               (MemoryFlagTexture, "image"),
                                               (MemoryFlagThreadGroup_ImgBlock, "imageblock"))
                   if UInt32(flags) & UInt32(flag) != 0]
        name = string(scope, "-mem-", isempty(classes) ? "none" : join(classes, '+'))
    else
        return :(@static_assert(false, "Invalid memory flags."))
    end
    return :(UnsafeAtomics.SyncScope($(QuoteNode(Symbol(name)))))
end


@device_function @inline threadgroup_barrier(flags=MemoryFlagNone,
                                             order::memory_order=memory_order_seq_cst,
                                             scope::thread_scope=thread_scope_threadgroup) =
    barrier(Val(:threadgroup), Val(UInt32(flags)), Val(order), Val(scope))
@device_function @inline threadgroup_barrier(flags, scope::thread_scope) =
    threadgroup_barrier(flags, memory_order_seq_cst, scope)

# like in MSL, the scope defaults to the SIMD-group where it can be chosen
@device_function @inline function simdgroup_barrier(flags=MemoryFlagNone,
                                                    order::memory_order=memory_order_seq_cst)
    if metal_version() >= sv"3.2"
        simdgroup_barrier(flags, order, thread_scope_simdgroup)
    else
        simdgroup_barrier(flags, order, thread_scope_threadgroup)
    end
end
@device_function @inline simdgroup_barrier(flags, order::memory_order, scope::thread_scope) =
    barrier(Val(:simdgroup), Val(UInt32(flags)), Val(order), Val(scope))
@device_function @inline simdgroup_barrier(flags, scope::thread_scope) =
    simdgroup_barrier(flags, memory_order_seq_cst, scope)

# barriers are emitted in the form of AIR 2.9, with a memory order, which GPUCompiler drops
# for older targets (and strengthens to sequentially consistent before MSL 4.1)
@device_function @inline function barrier(::Val{group}, ::Val{flags}, ::Val{order},
                                          ::Val{scope}) where {group, flags, order, scope}
    if scope !== thread_scope_threadgroup
        @static_assert(metal_version() >= sv"3.2", "Barrier scopes need Metal 3.2.")
    end
    if group === :threadgroup
        @typed_ccall("air.wg.barrier", llvmcall, Nothing, (Int32, Int32, Int32),
                     Val(flags), Val(order), Val(scope))
    else
        @typed_ccall("air.simdgroup.barrier", llvmcall, Nothing, (Int32, Int32, Int32),
                     Val(flags), Val(order), Val(scope))
    end
    return
end

@device_function @inline atomic_thread_fence(flags::Union{MemoryFlags,UInt32},
                                              order::memory_order,
                                              scope::thread_scope=thread_scope_device) =
    atomic_thread_fence(Val(flags), Val(order), Val(scope))

@device_function @inline function atomic_thread_fence(::Val{flags}, ::Val{order},
                                                       ::Val{scope}) where {flags, order, scope}
    @static_assert(order isa memory_order, "Invalid atomic memory ordering.")
    @static_assert(scope isa thread_scope, "Invalid atomic thread scope.")
    if order === memory_order_relaxed
        # (LLVM has no relaxed fences)
        @typed_ccall("air.atomic.fence", llvmcall, Nothing, (Int32, Int32, Int32),
            Val(flags), Val(order), Val(scope))
    else
        # an LLVM fence, which GPUCompiler lowers (before MSL 4.1, as a sequentially
        # consistent fence)
        llvm_scope = scope === thread_scope_thread ? :singlethread :
                     scope === thread_scope_threadgroup ? :workgroup :
                     scope === thread_scope_simdgroup ? :subgroup : :device
        UnsafeAtomics.fence(llvm_order(Val(order)), memory_scope(Val(llvm_scope), Val(flags)))
    end
    return
end

@doc """
    threadgroup_barrier(flags=Metal.MemoryFlagNone, order=Metal.memory_order_seq_cst,
                        scope=Metal.thread_scope_threadgroup)
    threadgroup_barrier(flags, scope)

Wait until all threads in the threadgroup reach the barrier, and order their accesses to the
memory selected by `flags` (see [`MemoryFlags`](@ref)) with memory order `order` (see
[`memory_order`](@ref)) for the threads in `scope` (see [`thread_scope`](@ref)). Without
`flags`, the barrier only synchronizes execution.

All threads in the threadgroup have to reach the same barrier, so don't call it from a branch
that only some threads take. The arguments have to be compile-time constants.
""" threadgroup_barrier

@doc """
    simdgroup_barrier(flags=Metal.MemoryFlagNone, order=Metal.memory_order_seq_cst,
                      scope=Metal.thread_scope_simdgroup)
    simdgroup_barrier(flags, scope)

Wait until all threads in the SIMD-group reach the barrier, and order their accesses to the
memory selected by `flags` (see [`MemoryFlags`](@ref)) with memory order `order` (see
[`memory_order`](@ref)) for the threads in `scope` (see [`thread_scope`](@ref)). Without
`flags`, the barrier only synchronizes execution. The arguments have to be compile-time
constants.
""" simdgroup_barrier

@doc """
    atomic_thread_fence(flags, order, scope=Metal.thread_scope_device)

Order the current thread's accesses to the memory selected by `flags` (see
[`MemoryFlags`](@ref)) with memory order `order` (see [`memory_order`](@ref)), with respect
to the threads in `scope` (see [`thread_scope`](@ref)). Unlike a barrier, a fence does not
wait for other threads. The arguments have to be compile-time constants.
""" atomic_thread_fence
