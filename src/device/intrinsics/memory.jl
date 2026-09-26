export MtlThreadGroupArray, MtlDynamicThreadGroupArray

"""
    MtlDynamicThreadGroupArray(::Type{T}, dims, offset::Integer=0)

Create an array in threadgroup memory whose storage is allocated dynamically at
launch time. The combined size of all dynamic allocations (in bytes) must be passed
with the `shmem` keyword argument when launching the kernel,
e.g. `@metal shmem=n*sizeof(Float32) kernel(...)`.

All dynamic arrays in a kernel alias the same allocation, which the single `shmem`
launch argument sizes (see `GPUCompiler.lower_dynamic_threadgroup_memory!`).
Partition it manually with the byte `offset`, e.g.
`MtlDynamicThreadGroupArray(Float32, n)` followed by
`MtlDynamicThreadGroupArray(Int, n, n*sizeof(Float32))`.
This is useful when dealing with a heterogeneous buffer of dynamic threadgroup
memory; in the case of a homogeneous multi-part buffer it is preferred to use `view`.

Dynamic threadgroup memory requires macOS 15 or newer.

See also [`MtlThreadGroupArray`](@ref).
"""
@inline function MtlDynamicThreadGroupArray(::Type{T}, dims::Tuple, offset::Integer) where {T}
    # NOTE: like `MtlThreadGroupArray`, this relies on const-prop to forward the
    #       element type to the generator; the length is provided at launch time.
    #       Every call lowers to the same base pointer (a single implicit kernel
    #       parameter), so `offset` -- in bytes -- partitions the allocation.
    ptr = emit_dynamic_threadgroup_memory(T) + offset
    MtlDeviceArray(dims, ptr)
end
Base.@propagate_inbounds MtlDynamicThreadGroupArray(::Type{T}, len::Integer,
                                                    offset::Integer) where {T} =
    MtlDynamicThreadGroupArray(T, (len,), offset)
# Default argument-generated methods do not propagate inboundsness
Base.@propagate_inbounds MtlDynamicThreadGroupArray(::Type{T}, dims) where {T} =
    MtlDynamicThreadGroupArray(T, dims, 0)

# get a pointer to dynamically-sized threadgroup memory, whose length is
# configured on the host with `setThreadgroupMemoryLength:atIndex:`
@generated function emit_dynamic_threadgroup_memory(::Type{T}) where {T}
    Context() do ctx
        # The type of the VALUE stored in the global variable: a threadgroup pointer.
        T_ptr_at_3 = convert(LLVMType, Core.LLVMPtr{T, AS.ThreadGroup})

        # create a function
        llvm_f, _ = create_function(T_ptr_at_3)

        # create the global variable. The global itself resides in the constant
        # address space and holds the threadgroup pointer, which the Metal
        # runtime initializes at dispatch time (hence `extinit`).
        mod = LLVM.parent(llvm_f)
        gv = GlobalVariable(mod, T_ptr_at_3, "dyn_threadgroup_memory", AS.Constant)

        linkage!(gv, LLVM.API.LLVMInternalLinkage)
        initializer!(gv, UndefValue(T_ptr_at_3))

        # NOTE: this aligns the global itself (an 8-byte pointer), not the
        #       threadgroup allocation, which the runtime aligns to 16 bytes.
        alignment!(gv, 8)
        constant!(gv, true)
        unnamed_addr!(gv, true)
        extinit!(gv, true)

        # generate IR: load the threadgroup pointer from the global
        IRBuilder() do builder
            entry = BasicBlock(llvm_f, "entry")
            position!(builder, entry)

            val = load!(builder, T_ptr_at_3, gv)

            ret!(builder, val)
        end

        call_function(llvm_f, Core.LLVMPtr{T, AS.ThreadGroup})
    end
end


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
@generated function emit_threadgroup_memory(::Type{T}, ::Val{len}=Val(0)) where {T,len}
    Context() do ctx
        # XXX: as long as LLVMPtr is emitted as i8*, it doesn't make sense to type the GV
        eltyp = convert(LLVMType, LLVM.Int8Type())
        T_ptr = convert(LLVMType, Core.LLVMPtr{T,AS.ThreadGroup})

        # create a function
        llvm_f, _ = create_function(T_ptr)

        # create the global variable
        mod = LLVM.parent(llvm_f)
        gv_typ = LLVM.ArrayType(eltyp, len * sizeof(T))
        gv = GlobalVariable(mod, gv_typ, "threadgroup_memory", AS.ThreadGroup)
        if len > 0
            linkage!(gv, LLVM.API.LLVMInternalLinkage)
            initializer!(gv, UndefValue(gv_typ))
        end
        alignment!(gv, Base.datatype_alignment(T))

        # generate IR
        IRBuilder() do builder
            entry = BasicBlock(llvm_f, "entry")
            position!(builder, entry)

            ptr = gep!(builder, gv_typ, gv, [ConstantInt(0), ConstantInt(0)])

            untyped_ptr = bitcast!(builder, ptr, T_ptr)

            ret!(builder, untyped_ptr)
        end

        call_function(llvm_f, Core.LLVMPtr{T,AS.ThreadGroup})
    end
end
