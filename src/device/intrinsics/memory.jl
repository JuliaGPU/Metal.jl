export MtlThreadGroupArray, MtlDynamicThreadGroupArray, dynamic_threadgroup_memory_length

"""
    MtlThreadGroupArray(T, dims)

Allocate an array of element type `T` and size `dims` in threadgroup memory, and return it as
an [`MtlDeviceArray`](@ref). Every threadgroup gets its own array, shared by its threads. The
size has to be a compile-time constant (e.g., a literal, or derived from type parameters),
the memory is uninitialized, and a kernel can use at most 32 KiB of threadgroup memory.

Use [`threadgroup_barrier`](@ref) with `Metal.MemoryFlagThreadGroup` between writing the
array and reading what other threads wrote:

```julia
function reverse_kernel(a)
    i = thread_position_in_threadgroup().x
    tmp = MtlThreadGroupArray(Float32, 64)
    tmp[i] = a[i]
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)
    a[i] = tmp[65 - i]
    return
end
```
"""
@inline function MtlThreadGroupArray(::Type{T}, dims) where {T}
    len = prod(dims)
    # NOTE: this relies on const-prop to forward the literal length to the generator.
    #       maybe we should include the size in the type, like StaticArrays does?
    ptr = emit_threadgroup_memory(T, Val(len))
    MtlDeviceArray(dims, ptr)
end

# get a pointer to threadgroup memory, with known (static) or zero length (dynamic)
@llvmgenerated builder function emit_threadgroup_memory(::Type{T}, ::Val{len}=Val(0)
                                                        )::Core.LLVMPtr{T,AS.ThreadGroup} where {T,len}
    # XXX: as long as LLVMPtr is emitted as i8*, it doesn't make sense to type the GV
    eltyp = LLVM.Int8Type()
    T_ptr = convert(LLVMType, Core.LLVMPtr{T,AS.ThreadGroup})

    # arrays of isbits unions keep one selector byte per element past the data
    nbytes = len * aligned_sizeof(T) + (Base.isbitsunion(T) ? len : 0)

    # create the global variable. align and pad it to 4 bytes, so that GPUCompiler can
    # implement 8- and 16-bit atomics on the containing 32-bit word.
    gv_typ = LLVM.ArrayType(eltyp, cld(nbytes, 4) * 4)
    gv = GlobalVariable(current_module(builder), gv_typ, "threadgroup_memory", AS.ThreadGroup)
    if len > 0
        gv.linkage = LLVM.Linkage.Internal
        gv.initializer = UndefValue(gv_typ)
    end
    gv.alignment = max(element_alignment(T), 4)

    ptr = gep!(builder, gv_typ, gv, [ConstantInt(0), ConstantInt(0)])
    bitcast!(builder, ptr, T_ptr)
end


## dynamic threadgroup memory

# Threadgroup memory whose size is chosen by the launch is a parameter of the kernel, like
# MSL's `threadgroup T *ptr [[threadgroup(0)]]`, for which the launch sets a length. This
# intrinsic stands for that parameter: kernels that still call it after optimization get
# the parameter, and the argument metadata describing it, from
# `add_dynamic_threadgroup_memory!`. The requested length travels in the kernel state.

const DYNAMIC_TGMEM_INTRINSIC = "julia.metal.dynamic_threadgroup_memory"
const DYNAMIC_TGMEM_ARGUMENT = "dynamic_threadgroup_memory"

# Metal only takes threadgroup memory lengths that are a multiple of this many bytes, which
# is also how the block is aligned
const DYNAMIC_TGMEM_ALIGNMENT = 16

@device_function @inline dynamic_threadgroup_memory() =
    ccall("extern julia.metal.dynamic_threadgroup_memory", llvmcall,
          Core.LLVMPtr{UInt8,AS.ThreadGroup}, ())

"""
    dynamic_threadgroup_memory_length()::Int

The size in bytes of the threadgroup's block of dynamic threadgroup memory, i.e., what the
kernel was launched with as `threadgroup_memory` (0 by default). See
[`MtlDynamicThreadGroupArray`](@ref).
"""
@device_function @inline dynamic_threadgroup_memory_length() =
    kernel_state().dynamic_tgmem % Int

"""
    MtlDynamicThreadGroupArray(T, dims, offset=0)

An array of element type `T` and size `dims` in the dynamic threadgroup memory of the
threadgroup, starting `offset` bytes into it, as an [`MtlDeviceArray`](@ref). Unlike with
[`MtlThreadGroupArray`](@ref), the size doesn't have to be a compile-time constant.

Every threadgroup gets a single block of dynamic threadgroup memory, shared by its threads,
whose size in bytes is set by the `threadgroup_memory` keyword of the launch (see
[`@metal`](@ref)) and returned by [`dynamic_threadgroup_memory_length`](@ref). Every call
returns an array in that same block, so calls whose byte ranges overlap return arrays that
alias; give the arrays a kernel needs different offsets. The block is separate from the
memory of `MtlThreadGroupArray`s, but counts towards the same limit of 32 KiB per kernel.

The memory is uninitialized, and aligned to 16 bytes. `T` has to be an `isbits` type, and
`offset` a multiple of its alignment. An array that doesn't fit in the block throws a
`BoundsError`, unless bounds checking is disabled with `@inbounds`.

```julia
function reverse_kernel(a)
    i = thread_position_in_threadgroup().x
    n = threads_per_threadgroup().x
    tmp = MtlDynamicThreadGroupArray(Float32, n)
    tmp[i] = a[i]
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)
    a[i] = tmp[n + 1 - i]
    return
end

@metal threads=64 threadgroup_memory=64*sizeof(Float32) reverse_kernel(a)
```
"""
Base.@propagate_inbounds function MtlDynamicThreadGroupArray(::Type{T}, dims::Dims{N},
                                                             offset::Integer=0) where {T,N}
    isbitstype(T) ||
        error("Dynamic threadgroup memory only supports `isbits` element types")
    @boundscheck begin
        # (written with a division, so that a huge array can't overflow the comparison)
        len, invalid = 1, false
        for d in dims
            len, overflow = Base.mul_with_overflow(len, d)
            invalid |= overflow | (d < 0)
        end
        available = dynamic_threadgroup_memory_length() - offset
        if invalid | (offset < 0) | (available < 0) | (len > available ÷ max(sizeof(T), 1))
            throw(BoundsError())
        end
    end
    ptr = reinterpret(Core.LLVMPtr{T,AS.ThreadGroup}, dynamic_threadgroup_memory() + offset)
    MtlDeviceArray{T,N,AS.ThreadGroup}(dims, ptr)
end
Base.@propagate_inbounds MtlDynamicThreadGroupArray(::Type{T}, dims::Tuple{Vararg{Integer}},
                                                    offset::Integer=0) where {T} =
    MtlDynamicThreadGroupArray(T, map(Int, dims), offset)
Base.@propagate_inbounds MtlDynamicThreadGroupArray(::Type{T}, len::Integer,
                                                    offset::Integer=0) where {T} =
    MtlDynamicThreadGroupArray(T, (Int(len),), offset)
