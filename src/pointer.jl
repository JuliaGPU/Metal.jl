# CUDA pointer types

export MtlPtr, MTL_NULL, PtrOrMtlPtr


#
# CUDA pointer
#

"""
    MtlPtr{T}

A memory address that refers to data of type `T` that is accessible from the GPU. A `CuPtr`
is ABI compatible with regular `Ptr` objects, e.g. it can be used to `ccall` a function that
expects a `Ptr` to GPU memory, but it prevents erroneous conversions between the two.
"""
MtlPtr

if sizeof(Ptr{Cvoid}) == 8
    primitive type MtlPtr{T} 64 end
else
    primitive type MtlPtr{T} 32 end
end

# constructor
MtlPtr{T}(x::Union{Int,UInt,MtlPtr}) where {T} = Base.bitcast(MtlPtr{T}, x)

const CU_NULL = MtlPtr{Cvoid}(0)


## getters

Base.eltype(::Type{<:MtlPtr{T}}) where {T} = T


## conversions

# to and from integers
## pointer to integer
Base.convert(::Type{T}, x::MtlPtr) where {T<:Integer} = T(UInt(x))
## integer to pointer
Base.convert(::Type{MtlPtr{T}}, x::Union{Int,UInt}) where {T} = MtlPtr{T}(x)
Int(x::MtlPtr)  = Base.bitcast(Int, x)
UInt(x::MtlPtr) = Base.bitcast(UInt, x)

# between regular and CUDA pointers
Base.convert(::Type{<:Ptr}, p::MtlPtr) =
    throw(ArgumentError("cannot convert a GPU pointer to a CPU pointer"))

# between CUDA pointers
Base.convert(::Type{MtlPtr{T}}, p::MtlPtr) where {T} = Base.bitcast(MtlPtr{T}, p)

# defer conversions to unsafe_convert
Base.cconvert(::Type{<:MtlPtr}, x) = x

# fallback for unsafe_convert
Base.unsafe_convert(::Type{P}, x::MtlPtr) where {P<:MtlPtr} = convert(P, x)


## limited pointer arithmetic & comparison

Base.isequal(x::MtlPtr, y::MtlPtr) = (x === y)
Base.isless(x::MtlPtr{T}, y::MtlPtr{T}) where {T} = x < y

Base.:(==)(x::MtlPtr, y::MtlPtr) = UInt(x) == UInt(y)
Base.:(<)(x::MtlPtr,  y::MtlPtr) = UInt(x) < UInt(y)
Base.:(-)(x::MtlPtr,  y::MtlPtr) = UInt(x) - UInt(y)

Base.:(+)(x::MtlPtr, y::Integer) = oftype(x, Base.add_ptr(UInt(x), (y % UInt) % UInt))
Base.:(-)(x::MtlPtr, y::Integer) = oftype(x, Base.sub_ptr(UInt(x), (y % UInt) % UInt))
Base.:(+)(x::Integer, y::MtlPtr) = y + x



#
# GPU or CPU pointer
#

"""
    PtrOrMtlPtr{T}

A special pointer type, ABI-compatible with both `Ptr` and `MtlPtr`, for use in `ccall`
expressions to convert values to either a GPU or a CPU type (in that order). This is
required for CUDA APIs which accept pointers that either point to host or device memory.
"""
PtrOrMtlPtr


if sizeof(Ptr{Cvoid}) == 8
    primitive type PtrOrMtlPtr{T} 64 end
else
    primitive type PtrOrMtlPtr{T} 32 end
end

function Base.cconvert(::Type{PtrOrMtlPtr{T}}, val) where {T}
    # `cconvert` is always implemented for both `Ptr` and `MtlPtr`, so pick the first result
    # that has done an actual conversion

    gpu_val = Base.cconvert(MtlPtr{T}, val)
    if gpu_val !== val
        return gpu_val
    end

    cpu_val = Base.cconvert(Ptr{T}, val)
    if cpu_val !== val
        return cpu_val
    end

    return val
end

function Base.unsafe_convert(::Type{PtrOrMtlPtr{T}}, val) where {T}
    # FIXME: this is expensive; optimize using isapplicable?
    ptr = try
        Base.unsafe_convert(Ptr{T}, val)
    catch
        try
            Base.unsafe_convert(MtlPtr{T}, val)
        catch
            throw(ArgumentError("cannot convert to either a CPU or GPU pointer"))
        end
    end
    return Base.bitcast(PtrOrMtlPtr{T}, ptr)
end
