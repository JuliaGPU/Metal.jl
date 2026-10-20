export MtlThreadGroupArray

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

    # create the global variable. align and pad it to 4 bytes, so that GPUCompiler can
    # implement 8- and 16-bit atomics on the containing 32-bit word.
    gv_typ = LLVM.ArrayType(eltyp, cld(len * sizeof(T), 4) * 4)
    gv = GlobalVariable(current_module(builder), gv_typ, "threadgroup_memory", AS.ThreadGroup)
    if len > 0
        gv.linkage = LLVM.Linkage.Internal
        gv.initializer = UndefValue(gv_typ)
    end
    gv.alignment = max(Base.datatype_alignment(T), 4)

    ptr = gep!(builder, gv_typ, gv, [ConstantInt(0), ConstantInt(0)])
    bitcast!(builder, ptr, T_ptr)
end
