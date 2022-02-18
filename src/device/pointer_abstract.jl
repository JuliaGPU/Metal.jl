export AS, addrspace
module AS
    const Generic               = 0
    const Device                = 1
    const Constant              = 2
    const ThreadGroup           = 3
    const Thread                = 4
    #struct ThreadGroup_ImgBlock  <: AddressSpace end
end
# abstract type AddressSpace end

# module AS

# import ..AddressSpace

# struct Generic               <: AddressSpace end
# struct Device                <: AddressSpace end
# struct Constant              <: AddressSpace end
# struct ThreadGroup           <: AddressSpace end
# struct Thread                <: AddressSpace end
# #struct ThreadGroup_ImgBlock  <: AddressSpace end

# end

# Base.convert(::Type{Int}, ::Type{AS.Generic})              = 0 # exists?
# Base.convert(::Type{Int}, ::Type{AS.Device})               = 1 # checked
# Base.(::Type{Int}, ::Type{AS.Constant})             = 2 # checked
# Base.convert(::Type{Int}, ::Type{AS.ThreadGroup})          = 3 # checked
# #Base.convert(::Type{Int}, ::Type{AS.ThreadGroup_ImgBlock}) = 4?
# Base.convert(::Type{Int}, ::Type{AS.Thread})               = 5 # 

# tbaa_addrspace(as::Type{<:AddressSpace}) = tbaa_make_child(lowercase(String(as.name.name)))

"""
    AbstractDevicePtr{T,A}
A memory address that refers to data of type `T` that is accessible from the GPU. It has two
concrete implementations, `DevicePtr` and `DeviceBuffer`, which are poth pointers in codegen,
but allow to keep track of how they should be binded when to kernel arguments before
execution.
Additionally keeping track of the address space `A` where the data resides (shared,
global, constant, etc). This information is used to provide optimized implementations
of operations such as `unsafe_load` and `unsafe_store!.`
"""
abstract type AbstractDevicePtr{T,A} <: Ref{T} end

## getters

Base.eltype(::Type{<:AbstractDevicePtr{T}}) where {T} = T

addrspace(x::AbstractDevicePtr) = addrspace(typeof(x))
addrspace(::Type{AbstractDevicePtr{T,A}}) where {T,A} = A

# to and from integers
## pointer to integer
Base.convert(::Type{T}, x::AbstractDevicePtr) where {T<:Integer} = T(UInt(x))
## integer to pointer
Base.Int(x::AbstractDevicePtr)  = Base.bitcast(Int, x)
Base.UInt(x::AbstractDevicePtr) = Base.bitcast(UInt, x)

## limited pointer arithmetic & comparison

isequal(x::AbstractDevicePtr, y::AbstractDevicePtr) = (x === y) && addrspace(x) == addrspace(y)
isless(x::AbstractDevicePtr{T,A}, y::AbstractDevicePtr{T,A}) where {T,A} = x < y

Base.:(==)(x::AbstractDevicePtr, y::AbstractDevicePtr) = UInt(x) == UInt(y) && addrspace(x) == addrspace(y)
Base.:(<)(x::AbstractDevicePtr,  y::AbstractDevicePtr) = UInt(x) < UInt(y)
Base.:(-)(x::AbstractDevicePtr,  y::AbstractDevicePtr) = UInt(x) - UInt(y)

Base.:(+)(x::AbstractDevicePtr, y::Integer) = oftype(x, Base.add_ptr(UInt(x), (y % UInt) % UInt))
Base.:(-)(x::AbstractDevicePtr, y::Integer) = oftype(x, Base.sub_ptr(UInt(x), (y % UInt) % UInt))
Base.:(+)(x::Integer, y::AbstractDevicePtr) = y + x


## interface

export unsafe_cached_load

Base.unsafe_load(p::AbstractDevicePtr{T}, i::Integer=1, align::Val=Val(1)) where {T} =
    pointerref(p, Int(i), align)

Base.unsafe_store!(p::AbstractDevicePtr{T}, x, i::Integer=1, align::Val=Val(1)) where {T} =
    pointerset(p, convert(T, x), Int(i), align)

# NOTE: fall back to normal pointerref for unsupported types. we could be smarter here,
#       e.g. destruct/load/reconstruct, but that's too complicated for what it's worth.
unsafe_cached_load(p::AbstractDevicePtr, i::Integer=1, align::Val=Val(1)) =
    pointerref(p, Int(i), align)

## ## concrete types

#if sizeof(Ptr{Cvoid}) == 8
#    primitive type DevicePtr{T,A} <: Ref{T} 64 end
#else
#    primitive type DevicePtr{T,A} <: Ref{T} 32 end
#end

primitive type DevicePtr{T,A} <: AbstractDevicePtr{T,A} 64 end

primitive type DeviceBuffer{T,A} <: AbstractDevicePtr{T,A} 64 end
