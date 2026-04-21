export MtlThreadGroupArray, MtlDynamicThreadGroupArray

"""
    MtlThreadGroupArray(::Type{T}, dims)

Create an array local to each threadgroup launched during kernel execution.
"""
@inline function MtlDynamicThreadGroupArray(::Type{T}, dims) where {T}
    # len = prod(dims)
    # NOTE: this relies on const-prop to forward the literal length to the generator.
    #       maybe we should include the size in the type, like StaticArrays does?
    ptr = emit_dynamic_threadgroup_memory(T)
    MtlDeviceArray(dims, ptr)
end

# get a pointer to threadgroup memory, with known (static) or zero length (dynamic)
@generated function emit_dynamic_threadgroup_memory(::Type{T}) where {T}
    Context() do ctx
        T_val = convert(LLVMType, T)
# Define the pointer type: float addrspace(3)*
        # This is the type of the VALUE stored in the global variable.
        T_ptr_at_3 = LLVM.PointerType(T_val, AS.ThreadGroup)

        # Create the function
        llvm_f, _ = create_function(T_ptr_at_3)

        # Create the global variable
        # The global itself resides in addrspace(2) and holds a value of type T_ptr_at_3
        mod = LLVM.parent(llvm_f)
        gv = GlobalVariable(mod, T_ptr_at_3, "dyn_threadgroup_memory", AS.Constant) # 2 = Constant Address Space

        # Set Linkage and Initializer
        linkage!(gv, LLVM.API.LLVMInternalLinkage)
        initializer!(gv, UndefValue(T_ptr_at_3))

        # Set Attributes matching your target IR
        alignment!(gv, 16)
        constant!(gv, true)
        unnamed_addr!(gv, true)
        extinit!(gv, true)

        # Generate IR
        IRBuilder() do builder
            entry = BasicBlock(llvm_f, "entry")
            position!(builder, entry)

            # Since the Global Variable is a pointer-to-pointer (it lives in AS(2) and holds a AS(3) pointer),
            # we must LOAD the value to get the actual pointer to shared memory.
            # Type of gv is: T_ptr_at_3 addrspace(2)*

            val = load!(builder, T_ptr_at_3, gv)

            ret!(builder, val)
        end

        call_function(llvm_f, Core.LLVMPtr{T, AS.ThreadGroup})
        # # XXX: as long as LLVMPtr is emitted as i8*, it doesn't make sense to type the GV
        # eltyp = convert(LLVMType, LLVM.Int8Type())
        # T_ptr = convert(LLVMType, Core.LLVMPtr{T,AS.ThreadGroup})

        # # create a function
        # llvm_f, _ = create_function(T_ptr)

        # # create the global variable
        # mod = LLVM.parent(llvm_f)
        # gv_typ = LLVM.PointerType(eltyp)
        # gv = GlobalVariable(mod, gv_typ, "dyn_threadgroup_memory", AS.ThreadGroup)

        # linkage!(gv, LLVM.API.LLVMInternalLinkage)
        # initializer!(gv, UndefValue(gv_typ))

        # alignment!(gv, 16)  # source: Metal Feature Set Tables

        # # generate IR
        # IRBuilder() do builder
        #     entry = BasicBlock(llvm_f, "entry")
        #     position!(builder, entry)

        #     ptr = gep!(builder, gv_typ, gv, [ConstantInt(0), ConstantInt(0)])

        #     untyped_ptr = bitcast!(builder, ptr, T_ptr)

        #     ret!(builder, untyped_ptr)
        # end

        # call_function(llvm_f, Core.LLVMPtr{T,AS.ThreadGroup})
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
        alignment!(gv, 16)  # source: Metal Feature Set Tables

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
