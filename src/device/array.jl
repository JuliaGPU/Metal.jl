# Contiguous on-device arrays

export MtlDeviceArray, MtlDeviceVector, MtlDeviceMatrix


## construction

"""
    MtlDeviceArray(dims, ptr)
    MtlDeviceArray{T}(dims, ptr)
    MtlDeviceArray{T,A}(dims, ptr)
    MtlDeviceArray{T,A,N}(dims, ptr)

Construct an `N`-dimensional dense Metal device array with element type `T` wrapping a
pointer, where `N` is determined from the length of `dims` and `T` is determined from the
type of `ptr`.

`dims` may be a single scalar, or a tuple of integers corresponding to the
lengths in each dimension). If the rank `N` is supplied explicitly as in `Array{T,N}(dims)`,
then it must match the length of `dims`. The same applies to the element type `T`, which
should match the type of the pointer `ptr`.
"""
MtlDeviceArray

# NOTE: we can't support the typical `tuple or series of integer` style construction,
#       because we're Mtlrrently requiring a trailing pointer argument.

struct MtlDeviceArray{T,N,A} <: DenseArray{T,N}
    ptr::Core.LLVMPtr{T,A}
    shape::Dims{N}
    # inner constructors, fully parameterized, exact types (ie. Int not <:Integer)
    MtlDeviceArray{T,N,A}(shape::Dims{N}, ptr::Core.LLVMPtr{T,A}) where {T,A,N} = new(ptr,shape)
end

const MtlDeviceVector = MtlDeviceArray{T,1,A} where {T,A}
const MtlDeviceMatrix = MtlDeviceArray{T,2,A} where {T,A}

# outer constructors, non-parameterized
MtlDeviceArray(dims::NTuple{N,<:Integer}, p::Core.LLVMPtr{T,A})                where {T,A,N} = MtlDeviceArray{T,N,A}(dims, p)
MtlDeviceArray(len::Integer,              p::Core.LLVMPtr{T,A})                where {T,A}   = MtlDeviceVector{T,A}((len,), p)

# outer constructors, partially parameterized
MtlDeviceArray{T}(dims::NTuple{N,<:Integer},   p::Core.LLVMPtr{T,A}) where {T,A,N} = MtlDeviceArray{T,N,A}(dims, p)
MtlDeviceArray{T}(len::Integer,                p::Core.LLVMPtr{T,A}) where {T,A}   = MtlDeviceVector{T,A}((len,), p)
MtlDeviceArray{T,N}(dims::NTuple{N,<:Integer}, p::Core.LLVMPtr{T,A}) where {T,A,N} = MtlDeviceArray{T,N,A}(dims, p)
#MtlDeviceVector{T}(len::Integer,               p::Core.LLVMPtr{T,1}) where {T,A}   = MtlDeviceVector{T,A}((len,), p)

# outer constructors, fully parameterized
MtlDeviceArray{T,N,A}(dims::NTuple{N,<:Integer}, p::Core.LLVMPtr{T,A}) where {T,A,N} = MtlDeviceArray{T,N,A}(Int.(dims), p)
MtlDeviceVector{T,A}(len::Integer,               p::Core.LLVMPtr{T,A}) where {T,A}   = MtlDeviceVector{T,A}((Int(len),), p)
# MtlDeviceVector{T,A}(len::NTuple{N,<:Integer},               p::Core.LLVMPtr{T,1}) where {T,A}   = MtlDeviceVector{T,A}((Int(len),), p)


## getters

Base.pointer(a::MtlDeviceArray) = a.ptr
Base.pointer(a::MtlDeviceArray, i::Integer) = pointer(a) + (i - 1) * Base.elsize(a)

Base.elsize(::Type{<:MtlDeviceArray{T}}) where {T} = sizeof(T)
Base.size(g::MtlDeviceArray) = g.shape
# Testing to fix argument encoding with the trailing , for vectors
Base.size(g::MtlDeviceVector) = length(g)
Base.length(g::MtlDeviceArray) = prod(g.shape)


## conversions

Base.unsafe_convert(::Type{Core.LLVMPtr{T,A}}, a::MtlDeviceArray{T,N,A}) where {T,A,N} = pointer(a)


## indexing intrinsics

# NOTE: these intrinsics are now implemented using plain and simple pointer operations;
#       when adding support for isbits union arrays we will need to implement that here.

# FIXME: Bounscheck

@inline function arrayref(A::MtlDeviceArray{T}, index::Integer) where {T}
    #@boundscheck checkbounds(A, index)
    align = alignment(pointer(A))
    unsafe_load(pointer(A), index, Val(align))
end

@inline function arrayset(A::MtlDeviceArray{T}, x::T, index::Integer) where {T}
    #@boundscheck checkbounds(A, index)
    align = alignment(pointer(A))
    unsafe_store!(pointer(A), x, index, Val(align))
    return A
end

@inline function const_arrayref(A::MtlDeviceArray{T}, index::Integer) where {T}
    @boundscheck checkbounds(A, index)
    align = Base.datatype_alignment(T)
    unsafe_cached_load(pointer(A), index, Val(align))
end


## indexing

Base.@propagate_inbounds Base.getindex(A::MtlDeviceArray{T}, i1::Integer) where {T} =
    arrayref(A, i1)
Base.@propagate_inbounds Base.setindex!(A::MtlDeviceArray{T}, x, i1::Integer) where {T} =
    arrayset(A, convert(T,x)::T, i1)

# preserve the specific integer type when indexing device arrays,
# to avoid extending 32-bit hardware indices to 64-bit.
Base.to_index(::MtlDeviceArray, i::Integer) = i

# Base doesn't like Integer indices, so we need our own ND get and setindex! routines.
# See also: https://github.com/JuliaLang/julia/pull/42289
Base.@propagate_inbounds Base.getindex(A::MtlDeviceArray,
                                       I::Union{Integer, CartesianIndex}...) =
    A[Base._to_linear_index(A, to_indices(A, I)...)]
Base.@propagate_inbounds Base.setindex!(A::MtlDeviceArray, x,
                                        I::Union{Integer, CartesianIndex}...) =
    A[Base._to_linear_index(A, to_indices(A, I)...)] = x

# TODO: Put this in pointer_ptr.jl?
Base.@propagate_inbounds Base.getindex(A::Core.LLVMPtr{T}, i1::Integer) where {T} =
    arrayref(A, i1)
Base.setindex!(A::Core.LLVMPtr{T}, x, i1::Integer) where {T} =
    arrayset(A, convert(T,x)::T, i1)

Base.IndexStyle(::Type{<:Core.LLVMPtr}) = Base.IndexLinear()

@generated function alignment(::Core.LLVMPtr{T}) where {T}
    if Base.isbitsunion(T)
        _, sz, al = Base.uniontype_layout(T)
        al
    else
        Base.datatype_alignment(T)
    end
end

@inline function arrayref(A::Core.LLVMPtr{T,AS}, index::Integer) where {T,AS}
    #@boundscheck checkbounds(A, index)
    align = alignment(A)
    unsafe_load(A, index, Val(align))
end

@inline function arrayset(A::Core.LLVMPtr{T,AS}, x::T, index::Integer) where {T,AS}
    #@boundscheck checkbounds(A, index)
    align = alignment(A)
    unsafe_store!(A, x, index, Val(align))
    return A
end

## const indexing

"""
    Const(A::MtlDeviceArray)

Mark a MtlDeviceArray as constant/read-only and to use the constant address space.
!!! warning
    Experimental API. Subject to change without deprecation.
"""
struct Const{T,N,AS} <: DenseArray{T,N}
    a::MtlDeviceArray{T,N,AS}
end
Base.Experimental.Const(A::MtlDeviceArray) = Const(A)

Base.IndexStyle(::Type{<:Const}) = IndexLinear()
Base.size(C::Const) = size(C.a)
Base.axes(C::Const) = axes(C.a)
Base.@propagate_inbounds Base.getindex(A::Const, i1::Integer) = const_arrayref(A.a, i1)


## other

Base.show(io::IO, a::MtlDeviceVector) =
    print(io, "$(length(a))-element device array at $(pointer(a))")
Base.show(io::IO, a::MtlDeviceArray) =
    print(io, "$(join(a.shape, '×')) device array at $(pointer(a))")

Base.show(io::IO, mime::MIME"text/plain", a::MtlDeviceArray) = show(io, a)

@inline function Base.unsafe_view(A::MtlDeviceVector{T}, I::Vararg{Base.ViewIndex,1}) where {T}
    ptr = pointer(A) + (I[1].start-1)*sizeof(T)
    len = I[1].stop - I[1].start + 1
    return MtlDeviceArray(len, ptr)
end

@inline function Base.iterate(A::MtlDeviceArray, i=1)
    if (i % UInt) - 1 < length(A)
        (@inbounds A[i], i + 1)
    else
        nothing
    end
end
