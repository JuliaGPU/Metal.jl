# Synchronization
using CEnum

export MemoryFlags, threadgroup_barrier, simdgroup_barrier

"""
    MemoryFlags

Flags to set the memory synchronization behavior of threadgroup\\_barrier and simdgroup\\_barrier.

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


"""
    threadgroup_barrier(flag::MemoryFlags=MemoryFlagNone)

Synchronize all threads in a threadgroup.

Possible flags that affect the memory synchronization behavior are found in [`MemoryFlags`](@ref)
"""
@inline threadgroup_barrier(flag::MemoryFlags=MemoryFlagNone) =
    ccall("extern air.wg.barrier", llvmcall, Cvoid, (Cuint, Cuint, ), flag, UInt32(1))

"""
    simdgroup_barrier(flag::MemoryFlags=MemoryFlagNone)

Synchronize all threads in a SIMD-group.

Possible flags that affect the memory synchronization behavior are found in [`MemoryFlags`](@ref)
"""
@inline simdgroup_barrier(flag::MemoryFlags=MemoryFlagNone) =
    ccall("extern air.simdgroup.barrier", llvmcall, Cvoid, (Cuint, Cuint, ), flag, UInt32(1))
