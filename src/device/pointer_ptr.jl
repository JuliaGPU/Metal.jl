"""
    DevicePtr{T,A}
A memory address that refers to data of type `T` that is accessible from the GPU. It is the
on-device counterpart of `MtlDAdrv.MtlPtr`, additionally keeping track of the address space
`A` where the data resides (shared, global, constant, etc). This information is used to
provide optimized implementations of operations such as `unsafe_load` and `unsafe_store!.`
"""
DevicePtr

# constructors
DevicePtr{T,A}(x::Union{Int,UInt,DevicePtr}) where {T,A<:AddressSpace} = Base.bitcast(DevicePtr{T,A}, x)
#DevicePtr{T}(ptr::MtlPtr{T}) where {T} = DevicePtr{T,AS.Generic}(ptr)
#DevicePtr(ptr::MtlPtr{T}) where {T} = DevicePtr{T,AS.Generic}(ptr)

## conversions
Base.convert(::Type{DevicePtr{T,A}}, x::Union{Int,UInt}) where {T,A<:AddressSpace} = DevicePtr{T,A}(x)

# between host and device pointers
#Base.convert(::Type{MtlPtr{T}},  p::DevicePtr)  where {T}                 = Base.bitcast(MtlPtr{T}, p)
Base.convert(::Type{MtlBuffer{T}},   p::DevicePtr)  where {T}               = MtlBuffer{T}(Base.bitcast(MTL.MTLBuffer, p))
#Base.convert(::Type{DevicePtr{T,A}}, p::MtlPtr) where {T,A<:AddressSpace}   = Base.bitcast(DevicePtr{T,A}, p)
#Base.convert(::Type{DevicePtr{T}},   p::MtlPtr)   where {T}                 = Base.bitcast(DevicePtr{T,AS.Generic}, p)
#Base.convert(::Type{DevicePtr{T,A}}, p::MtlBuffer) where {T,A<:AddressSpace}   = Base.bitcast(DevicePtr{T,A}, p.handle)
#Base.convert(::Type{DevicePtr{T}},   p::MtlBuffer)   where {T}                 = Base.bitcast(DevicePtr{T,AS.Generic}, p.handle)

# between CPU pointers, for the purpose of working with `ccall`
Base.unsafe_convert(::Type{Ptr{T}}, x::DevicePtr{T}) where {T} = reinterpret(Ptr{T}, x)

# between device pointers
Base.convert(::Type{<:DevicePtr}, p::DevicePtr)                         = throw(ArgumentError("cannot convert between incompatible device pointer types"))
Base.convert(::Type{DevicePtr{T,A}}, p::DevicePtr{T,A})   where {T,A}   = p
Base.unsafe_convert(::Type{DevicePtr{T,A}}, p::DevicePtr) where {T,A}   = Base.bitcast(DevicePtr{T,A}, p)
## identical addrspaces
Base.convert(::Type{DevicePtr{T,A}}, p::DevicePtr{U,A}) where {T,U,A} = Base.unsafe_convert(DevicePtr{T,A}, p)
## convert to & from generic
Base.convert(::Type{DevicePtr{T,AS.Generic}}, p::DevicePtr)               where {T}     = Base.unsafe_convert(DevicePtr{T,AS.Generic}, p)
Base.convert(::Type{DevicePtr{T,A}}, p::DevicePtr{U,AS.Generic})          where {T,U,A} = Base.unsafe_convert(DevicePtr{T,A}, p)
Base.convert(::Type{DevicePtr{T,AS.Generic}}, p::DevicePtr{T,AS.Generic}) where {T}     = p  # avoid ambiguities
## unspecified, preserve source addrspace
Base.convert(::Type{DevicePtr{T}}, p::DevicePtr{U,A}) where {T,U,A} = Base.unsafe_convert(DevicePtr{T,A}, p)

## memory operations

@generated function pointerref(p::DevicePtr{T,A}, i::Int, ::Val{align}) where {T,A,align}
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

@generated function pointerset(p::DevicePtr{T,A}, x::T, i::Int, ::Val{align}) where {T,A,align}
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

# operand types supported by llvm.nvvm.ldg.global
# NOTE: CUDA 8.0 supports more caching modifiers, but those aren't supported by LLVM yet
const LDGTypes = Union{UInt8, UInt16, UInt32, UInt64,
                       Int8, Int16, Int32, Int64,
                       Float32, Float64}


# interface

export unsafe_cached_load

Base.unsafe_load(p::DevicePtr{T}, i::Integer=1, align::Val=Val(1)) where {T} =
    pointerref(p, Int(i), align)

Base.unsafe_store!(p::DevicePtr{T}, x, i::Integer=1, align::Val=Val(1)) where {T} =
    pointerset(p, convert(T, x), Int(i), align)

# NOTE: fall back to normal pointerref for unsupported types. we could be smarter here,
#       e.g. destruct/load/reconstruct, but that's too complicated for what it's worth.
unsafe_cached_load(p::DevicePtr, i::Integer=1, align::Val=Val(1)) =
    pointerref(p, Int(i), align)
