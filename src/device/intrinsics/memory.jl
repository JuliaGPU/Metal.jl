export MtlThreadGroupArray

@inline function MtlThreadGroupArray(::Type{T}, dims) where {T}
    len = prod(dims)
    # NOTE: this relies on const-prop to forward the literal length to the generator.
    #       maybe we should include the size in the type, like StaticArrays does?
    if sizeof(T) >= 4
        ptr = emit_threadgroup_memory(T, Val(len))
        MtlDeviceArray(dims, ptr)
    else
        ptr = emit_threadgroup_memory(UInt32, Val(len))
        arr = MtlDeviceArray(dims, ptr)
        MtlLargerDeviceArray{T,ndims(arr),AS.ThreadGroup}(arr)
    end
end

# get a pointer to threadgroup memory, with known (static) or zero length (dynamic)
@generated function emit_threadgroup_memory(::Type{T}, ::Val{len}=Val(0)) where {T,len}
    Context() do ctx
        eltyp = convert(LLVMType, T; ctx)
        T_ptr = convert(LLVMType, Core.LLVMPtr{T,AS.ThreadGroup}; ctx)

        # create a function
        llvm_f, _ = create_function(T_ptr)

        # create the global variable
        mod = LLVM.parent(llvm_f)
        gv_typ = LLVM.ArrayType(eltyp, len)
        gv = GlobalVariable(mod, gv_typ, "threadgroup_memory", AS.ThreadGroup)
        if len > 0
            linkage!(gv, LLVM.API.LLVMInternalLinkage)
            initializer!(gv, UndefValue(gv_typ))
        end
        alignment!(gv, 16)  # source: Metal Feature Set Tables

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


# shared memory with small types results in miscompilation (Metal.jl#26),
# so we use an array wrapper extending the element size to the minimum known to work.

struct MtlLargerDeviceArray{T,N,A} <: DenseArray{T,N}
    x::MtlDeviceArray{UInt32,N,A}
end

Base.elsize(::Type{<:MtlLargerDeviceArray{T}}) where {T} = sizeof(UInt32)

Base.size(g::MtlLargerDeviceArray) = size(g.x)
Base.sizeof(x::MtlLargerDeviceArray) = Base.elsize(x) * length(x)

Base.pointer(x::MtlLargerDeviceArray{T,<:Any,A}) where {T,A} =
    Base.unsafe_convert(Core.LLVMPtr{T,A}, x)
@inline function Base.pointer(x::MtlLargerDeviceArray{T,<:Any,A}, i::Integer) where {T,A}
    Base.unsafe_convert(Core.LLVMPtr{T,A}, x) + Base._memory_offset(x, i)
end

Base.unsafe_convert(::Type{Core.LLVMPtr{T,A}}, x::MtlLargerDeviceArray{T,<:Any,A}) where {T,A} =
  reinterpret(Core.LLVMPtr{T,A}, Base.unsafe_convert(Core.LLVMPtr{UInt32,A}, x.x))

Base.IndexStyle(::Type{<:Core.LLVMPtr}) = Base.IndexLinear()

Base.@propagate_inbounds Base.getindex(A::MtlLargerDeviceArray{T}, i1::Integer) where {T} =
    arrayref(A, i1)
Base.@propagate_inbounds Base.setindex!(A::MtlLargerDeviceArray{T}, x, i1::Integer) where {T} =
    arrayset(A, convert(T,x)::T, i1)

Base.to_index(::MtlLargerDeviceArray{T}, i::Integer) where {T} = i

Base.@propagate_inbounds Base.getindex(A::MtlLargerDeviceArray{T},
                                       I::Union{Integer, CartesianIndex}...) where {T} =
    A[Base._to_linear_index(A, to_indices(A, I)...)]
Base.@propagate_inbounds Base.setindex!(A::MtlLargerDeviceArray{T}, x,
                                       I::Union{Integer, CartesianIndex}...) where {T} =
    A[Base._to_linear_index(A, to_indices(A, I)...)] = x

@inline function arrayref(A::MtlLargerDeviceArray{T}, index::Integer) where {T}
    @boundscheck checkbounds(A, index)
    align = Base.datatype_alignment(T)
    unsafe_load(pointer(A), index, Val(align))
end

@inline function arrayset(A::MtlLargerDeviceArray{T}, x::T, index::Integer) where {T}
    @boundscheck checkbounds(A, index)
    align = Base.datatype_alignment(T)
    unsafe_store!(pointer(A), x, index, Val(align))
    return A
end
