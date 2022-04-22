# Shared Memory
# Note that Metal doesn't support variable length arrays

export MtlStaticSharedArray

"""
    MtlStaticSharedArray(T::Type, dims) -> MtlDeviceArray{T,N,AS.ThreadGroup}

Get an array of type `T` and dimensions `dims` (either an integer length or tuple shape)
pointing to a statically-allocated piece of shared memory. The type should be statically
inferable and the dimensions should be constant, or an error will be thrown and the
generator function will be called dynamically.
"""
@inline function MtlStaticSharedArray(::Type{T}, dims) where {T}
    len = prod(dims)
    # TODO: Make the maximum threadgroup memory a device property that is assigned via a dictionary from Metal device family
    # Check for overallocation only on from the host-side allocations
    sizeof(T) * len > 32768 && throw(ArgumentError("Too large of shared memory requested. Maximum threadgroup memory size is 32 kB"))
    # NOTE: this relies on const-prop to forward the literal length to the generator.
    #       maybe we should include the size in the type, like StaticArrays does?
    ptr = emit_shmem(T, Val(len))
    MtlDeviceArray(dims, ptr)
end

# TODO: Make these functions more cohesive once argument passing of shared memory is handled
@device_override @inline function MtlStaticSharedArray(::Type{T}, dims) where {T}
    len = prod(dims)
    # No overallocation checking because that's handled by the MtlComputePipelineState object
    # NOTE: this relies on const-prop to forward the literal length to the generator.
    #       maybe we should include the size in the type, like StaticArrays does?
    ptr = emit_shmem(T, Val(len))
    MtlDeviceArray(dims, ptr)
end

# get a pointer to shared memory, with known (static) length
@generated function emit_shmem(::Type{T}, ::Val{len}=Val(0)) where {T,len}
    Context() do ctx
        T_int8 = LLVM.Int8Type(ctx)
        T_ptr = convert(LLVMType, Core.LLVMPtr{T,AS.ThreadGroup}; ctx)

        # create a function
        llvm_f, _ = create_function(T_ptr)

        # determine the array size
        # TODO: assert that T isbitstype || isbitsunion (or it won't have a layout)
        sz = len*sizeof(T)
        if Base.isbitsunion(T)
            sz += len
        end

        # create the global variable
        # NOTE: this variable can't have T as element type, because it may be a boxed type
        #       when we're dealing with a union isbits array (e.g. `Union{Missing,Int}`)
        mod = LLVM.parent(llvm_f)
        gv_typ = LLVM.ArrayType(T_int8, sz)
        gv = GlobalVariable(mod, gv_typ, "shmem", AS.ThreadGroup)

        # static shared memory should be demoted to local variables, whenever possible.
        linkage!(gv, LLVM.API.LLVMInternalLinkage)
        initializer!(gv, null(gv_typ))

        # by requesting a larger-than-datatype alignment, we might be able to vectorize.
        # xxx: Metal threadgroup memory alignment is 16, so use that?
        # TODO: Make the alignment configurable
        align = 1
        if isbitstype(T)
            align = Base.datatype_alignment(T)
        else # if isbitsunion(T)
            for typ in Base.uniontypes(T)
                if typ.layout != C_NULL
                    align = max(align, Base.datatype_alignment(typ))
                end
            end
        end
        alignment!(gv, align)

        # generate IR
        Builder(ctx) do builder
            entry = BasicBlock(llvm_f, "entry"; ctx)
            position!(builder, entry)

            ptr = gep!(builder, gv, [ConstantInt(0; ctx), ConstantInt(0; ctx)])

            untyped_ptr = bitcast!(builder, ptr, T_ptr)

            ret!(builder, untyped_ptr)
        end

        call_function(llvm_f, Core.LLVMPtr{T,AS.ThreadGroup})
    end
end