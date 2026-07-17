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


@device_function @inline threadgroup_barrier(flag=MemoryFlagNone) =
    ccall("extern air.wg.barrier", llvmcall, Cvoid, (Cuint, Cuint, ), flag, UInt32(1))

@device_function @inline simdgroup_barrier(flag=MemoryFlagNone) =
    ccall("extern air.simdgroup.barrier", llvmcall, Cvoid, (Cuint, Cuint, ), flag, UInt32(1))

@device_function @inline atomic_thread_fence(flags::Union{MemoryFlags,UInt32},
                                              order::memory_order,
                                              scope::thread_scope=thread_scope_device) =
    atomic_thread_fence(Val(flags), Val(order), Val(scope))

@device_function @inline function atomic_thread_fence(flags::Val{F}, order::Val{O},
                                                       scope::Val{S}) where {F,O,S}
    @static_assert(metal_version() >= sv"3.2",
                   "atomic_thread_fence requires Metal 3.2 or newer.")
    @static_assert(O isa memory_order, "Invalid atomic memory ordering.")
    @static_assert(O === memory_order_relaxed || O === memory_order_seq_cst || metal_version() >= sv"4.1",
                   "Acquire, release, and acquire-release atomic_thread_fence orderings require Metal 4.1 or newer.")
    @static_assert(S isa thread_scope, "Invalid atomic thread scope.")
    @typed_ccall("air.atomic.fence", llvmcall, Nothing, (Int32, Int32, Int32),
                 flags, order, scope)
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
barrier. `flags`, `order`, and `scope` must be compile-time constants.
""" atomic_thread_fence
