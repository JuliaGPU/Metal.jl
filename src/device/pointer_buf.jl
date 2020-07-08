"""
    DeviceBuffer{T,A}
A memory address that refers to data of type `T` that is accessible from the GPU. It is the
on-device counterpart of `MtlDAdrv.MtlPtr`, additionally keeping track of the address space
`A` where the data resides (shared, global, constant, etc). This information is used to
provide optimized implementations of operations such as `unsafe_load` and `unsafe_store!.`
"""
DeviceBuffer

# constructors
DeviceBuffer{T,A}(x::Union{Int,UInt,DeviceBuffer,DevicePtr}) where {T,A<:AddressSpace} = Base.bitcast(DeviceBuffer{T,A}, x)
DeviceBuffer{T,A}(ptr::MtlBuffer{T})                         where {T,A<:AddressSpace} = Base.bitcast(DeviceBuffer{T,A}, handle(ptr))
DeviceBuffer{T}(ptr::MtlBuffer{T})                           where {T}                 = Base.bitcast(DeviceBuffer{T,AS.Device}, handle(ptr))
DeviceBuffer(ptr::MtlBuffer{T})                              where {T}                 = Base.bitcast(DeviceBuffer{T,AS.Device}, handle(ptr))

## conversions
Base.convert(::Type{DeviceBuffer{T,A}}, x::Union{Int,UInt}) where {T,A<:AddressSpace} = DeviceBuffer{T,A}(x)

# between host and device pointers
Base.convert(::Type{MtlBuffer{T}},      p::DeviceBuffer)  where {T}                   = MtlBuffer{T}(Base.bitcast(Metal.MTLBuffer, p))
Base.convert(::Type{DeviceBuffer{T,A}}, p::MtlBuffer)     where {T,A<:AddressSpace}   = Base.bitcast(DeviceBuffer{T,A}, handle(p))
Base.convert(::Type{DeviceBuffer{T}},   p::MtlBuffer)     where {T}                   = Base.bitcast(DeviceBuffer{T,AS.Generic}, handle(p))

# between CPU pointers, for the purpose of working with `ccall`
Base.unsafe_convert(::Type{Metal.MTLBuffer}, x::DeviceBuffer{T}) where {T} = reinterpret(Metal.MTLBuffer, x)
Base.unsafe_convert(::Type{Metal.MTLResource}, x::DeviceBuffer{T}) where {T} = reinterpret(Metal.MTLResource, x)

# between device pointers
Base.convert(::Type{<:DeviceBuffer}, p::DeviceBuffer)                         = throw(ArgumentError("cannot convert between incompatible device pointer types"))
Base.convert(::Type{DeviceBuffer{T,A}}, p::DeviceBuffer{T,A})   where {T,A}   = p
Base.unsafe_convert(::Type{DeviceBuffer{T,A}}, p::DeviceBuffer) where {T,A}   = Base.bitcast(DeviceBuffer{T,A}, p)
## identical addrspaces
Base.convert(::Type{DeviceBuffer{T,A}}, p::DeviceBuffer{U,A}) where {T,U,A} = Base.unsafe_convert(DeviceBuffer{T,A}, p)
## convert to & from generic
Base.convert(::Type{DeviceBuffer{T,AS.Generic}}, p::DeviceBuffer)               where {T}     = Base.unsafe_convert(DeviceBuffer{T,AS.Generic}, p)
Base.convert(::Type{DeviceBuffer{T,A}},          p::DeviceBuffer{U,AS.Generic}) where {T,U,A} = Base.unsafe_convert(DeviceBuffer{T,A}, p)
Base.convert(::Type{DeviceBuffer{T,AS.Generic}}, p::DeviceBuffer{T,AS.Generic}) where {T}     = p  # avoid ambiguities
## unspecified, preserve source addrspace
Base.convert(::Type{DeviceBuffer{T}}, p::DeviceBuffer{U,A}) where {T,U,A} = Base.unsafe_convert(DeviceBuffer{T,A}, p)

## memory operations

@generated function pointerref(p::DeviceBuffer{T,A}, i::Int, ::Val{align}) where {T,A,align}
    sizeof(T) == 0 && return T.instance
    eltyp = convert(LLVMType, T)

    T_int = convert(LLVMType, Int)
    T_ptr = convert(LLVMType, DevicePtr{T,A})

    T_actual_ptr = LLVM.PointerType(eltyp, convert(Int, A))

    # create a function
    param_types = [T_ptr, T_int]
    llvm_f, _ = create_function(eltyp, param_types)

    # generate IR
    Builder(JuliaContext()) do builder
        entry = BasicBlock(llvm_f, "entry", JuliaContext())
        position!(builder, entry)

        ptr = inttoptr!(builder, parameters(llvm_f)[1], T_actual_ptr)
        ptr = gep!(builder, ptr, [parameters(llvm_f)[2]])
        ld = load!(builder, ptr)

        if A != AS.Generic
            metadata(ld)[LLVM.MD_tbaa] = tbaa_addrspace(A)
        end
        alignment!(ld, align)

        ret!(builder, ld)
    end

    call_function(llvm_f, T, Tuple{DevicePtr{T,A}, Int}, :((p, Int(i-one(i)))))
end

@generated function pointerset(p::DeviceBuffer{T,A}, x::T, i::Int, ::Val{align}) where {T,A,align}
    sizeof(T) == 0 && return
    eltyp = convert(LLVMType, T)

    T_int = convert(LLVMType, Int)
    T_ptr = convert(LLVMType, DevicePtr{T,A})

    T_actual_ptr = LLVM.PointerType(eltyp, convert(Int, A))

    # create a function
    param_types = [T_ptr, eltyp, T_int]
    llvm_f, _ = create_function(LLVM.VoidType(JuliaContext()), param_types)

    # generate IR
    Builder(JuliaContext()) do builder
        entry = BasicBlock(llvm_f, "entry", JuliaContext())
        position!(builder, entry)

        ptr = inttoptr!(builder, parameters(llvm_f)[1], T_actual_ptr)
        ptr = gep!(builder, ptr, [parameters(llvm_f)[3]])
        val = parameters(llvm_f)[2]
        st = store!(builder, val, ptr)

        if A != AS.Generic
            metadata(st)[LLVM.MD_tbaa] = tbaa_addrspace(A)
        end
        alignment!(st, align)

        ret!(builder)
    end

    call_function(llvm_f, Cvoid, Tuple{DevicePtr{T,A}, T, Int},
                  :((p, convert(T,x), Int(i-one(i)))))
end


## new set methods
Metal.set_buffer!(cce::MtlArgumentEncoder, buf::DeviceBuffer, offset::Integer, index::Integer) =
    Metal.mtArgumentEncoderSetBufferOffsetAtIndex(cce, buf, offset, index-1)
Metal.set_buffers!(cce::MtlArgumentEncoder, bufs::Vector{<:DeviceBuffer},
             offsets::Vector{Int}, indices::UnitRange{Int}) =
    Metal.mtArgumentSetBuffersOffsetsWithRange(cce, handle_array(bufs), offsets, indices .- 1)

Metal.use!(cce::MtlComputeCommandEncoder, buf::DeviceBuffer, mode::Metal.MtResourceUsage=ReadWriteUsage) =
    Metal.mtComputeCommandEncoderUseResourceUsage(cce, buf, mode)

Metal.use!(cce::MtlComputeCommandEncoder, buf::Vector{DeviceBuffer}, mode::Metal.MtResourceUsage=ReadWriteUsage) =
    Metal.mtComputeCommandEncoderUseResourceCountUsage(cce, handle_array(buf), length(buf), mode)
