export MtlThreadGroupArray

"""
    MtlThreadGroupArray(::Type{T}, dims)

Create an array local to each threadgroup launched during kernel execution.
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

    # create the global variable
    gv_typ = LLVM.ArrayType(eltyp, len * sizeof(T))
    gv = GlobalVariable(current_module(builder), gv_typ, "threadgroup_memory", AS.ThreadGroup)
    if len > 0
        gv.linkage = LLVM.Linkage.Internal
        gv.initializer = UndefValue(gv_typ)
    end
    gv.alignment = Base.datatype_alignment(T)

    ptr = gep!(builder, gv_typ, gv, [ConstantInt(0), ConstantInt(0)])
    bitcast!(builder, ptr, T_ptr)
end
