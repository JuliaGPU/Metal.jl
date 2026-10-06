# Synchronization
using CEnum

export MemoryFlags, memory_order, thread_scope, atomic_thread_fence,
       threadgroup_barrier, simdgroup_barrier

@enum memory_order::Int32 begin
    memory_order_relaxed = 0
    memory_order_acquire = 2
    memory_order_release = 3
    memory_order_acq_rel = 4
    memory_order_seq_cst = 5
end

@enum thread_scope::Int32 begin
    thread_scope_thread = 0
    thread_scope_threadgroup = 1
    thread_scope_device = 2
    thread_scope_simdgroup = 4
end

"""
    MemoryFlags

Flags to set the memory synchronization behavior of barriers and atomic fences.

Possible values:

    None: Set barriers to only act as an execution barrier and not apply a memory fence.

    Device: Ensure the GPU correctly orders the memory operations to device memory
            for threads in the threadgroup or simdgroup.

    ThreadGroup: Ensure the GPU correctly orders the memory operations to threadgroup
            memory for threads in a threadgroup or simdgroup.

    Texture: Ensure the GPU correctly orders the memory operations to texture memory for
            threads in a threadgroup or simdgroup for a texture with the read_write access qualifier.

    ThreadGroup_ImgBlock: Ensure the GPU correctly orders the memory operations to threadgroup imageblock memory
            for threads in a threadgroup or simdgroup.
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


@device_function @inline threadgroup_barrier(flag=MemoryFlagNone) =
    ccall("extern air.wg.barrier", llvmcall, Cvoid, (Cuint, Cuint, ), flag, UInt32(1))

@device_function @inline simdgroup_barrier(flag=MemoryFlagNone) =
    ccall("extern air.simdgroup.barrier", llvmcall, Cvoid, (Cuint, Cuint, ), flag, UInt32(1))

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
    threadgroup_barrier(flag=MemoryFlagNone)

Synchronize all threads in a threadgroup.

Possible flags that affect the memory synchronization behavior are found in [`MemoryFlags`](@ref)
""" threadgroup_barrier

@doc """
    simdgroup_barrier(flag=MemoryFlagNone)

Synchronize all threads in a SIMD-group.

Possible flags that affect the memory synchronization behavior are found in [`MemoryFlags`](@ref)
""" simdgroup_barrier

@doc """
    atomic_thread_fence(flags, order, scope=thread_scope_device)

Order memory accesses selected by `flags` for threads in `scope`, without an execution
barrier. `flags`, `order`, and `scope` must be compile-time constants. Fences need Metal 3.2;
before Metal 4.1, acquire and release fences are sequentially consistent.
""" atomic_thread_fence
