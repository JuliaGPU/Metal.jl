"""
    DeviceBuffer{T,A}
A memory address that refers to data of type `T` that is accessible from the GPU. It is the
on-device counterpart of `MtlDAdrv.MtlPtr`, additionally keeping track of the address space
`A` where the data resides (shared, global, constant, etc). This information is used to
provide optimized implementations of operations such as `unsafe_load` and `unsafe_store!.`
"""
DeviceBuffer

# constructors
DeviceBuffer{T,A}(x::Union{Int,UInt,DeviceBuffer,DevicePtr}) where {T,A}            = Base.bitcast(DeviceBuffer{T,A}, x)
DeviceBuffer{T,A}(ptr::MtlBuffer{T})                         where {T,A}            = Base.bitcast(DeviceBuffer{T,A}, ptr.handle)
DeviceBuffer{T}(ptr::MtlBuffer{T})                           where {T}                 = Base.bitcast(DeviceBuffer{T,AS.Device}, ptr.handle)
DeviceBuffer(ptr::MtlBuffer{T})                              where {T}                 = Base.bitcast(DeviceBuffer{T,AS.Device}, ptr.handle)

## conversions
Base.convert(::Type{DeviceBuffer{T,A}}, x::Union{Int,UInt}) where {T,A} = DeviceBuffer{T,A}(x)

# between host and device pointers
Base.convert(::Type{MtlBuffer{T}},      p::DeviceBuffer)  where {T}                   = MtlBuffer{T}(Base.bitcast(MTL.MTLBuffer, p))
Base.convert(::Type{DeviceBuffer{T,A}}, p::MtlBuffer)     where {T,A}                 = Base.bitcast(DeviceBuffer{T,A}, p.handle)
Base.convert(::Type{DeviceBuffer{T}},   p::MtlBuffer)     where {T}                   = Base.bitcast(DeviceBuffer{T,AS.Generic}, p.handle)

# between CPU pointers, for the purpose of working with `ccall`
Base.unsafe_convert(::Type{MTL.MTLBuffer}, x::DeviceBuffer{T}) where {T} = reinterpret(MTL.MTLBuffer, x)
Base.unsafe_convert(::Type{MTL.MTLResource}, x::DeviceBuffer{T}) where {T} = reinterpret(MTL.MTLResource, x)

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

Base.pointer(buf::DeviceBuffer{T,A}) where{T,A} = reinterpret(Core.LLVMPtr{T,A}, buf)
## memory operations


## new set methods
MTL.set_buffer!(cce::MtlArgumentEncoder, buf::DeviceBuffer, offset::Integer, index::Integer) =
    MTL.mtArgumentEncoderSetBufferOffsetAtIndex(cce, buf, offset, index-1)
MTL.set_buffers!(cce::MtlArgumentEncoder, bufs::Vector{<:DeviceBuffer},
             offsets::Vector{Int}, indices::UnitRange{Int}) =
    MTL.mtArgumentSetBuffersOffsetsWithRange(cce, handle_array(bufs), offsets, indices .- 1)

MTL.use!(cce::MtlComputeCommandEncoder, buf::DeviceBuffer, mode::MTL.MtResourceUsage=ReadWriteUsage) =
    MTL.mtComputeCommandEncoderUseResourceUsage(cce, buf, mode)

MTL.use!(cce::MtlComputeCommandEncoder, buf::Vector{DeviceBuffer}, mode::MTL.MtResourceUsage=ReadWriteUsage) =
    MTL.mtComputeCommandEncoderUseResourceCountUsage(cce, handle_array(buf), length(buf), mode)
