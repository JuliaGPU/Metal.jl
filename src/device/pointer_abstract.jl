export AS, addrspace
module AS
    const Generic               = 0 # No Generic address space?
    const Device                = 1 # Checked
    const Constant              = 2 # Checked
    const ThreadGroup           = 3 # Checked
    const Thread                = 4 # Ends up same as Device?
    const ThreadGroup_ImgBlock  = 5 # Like ThreadGroup but only accessible from 
    const Ray                   = 6
end

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
