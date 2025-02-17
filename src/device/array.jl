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
#       because we're currently requiring a trailing pointer argument.

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


## array interface

Base.elsize(::Type{<:MtlDeviceArray{T}}) where {T} = sizeof(T)

Base.size(g::MtlDeviceArray) = g.shape
Base.sizeof(x::MtlDeviceArray) = Base.elsize(x) * length(x)

Base.pointer(x::MtlDeviceArray{T,<:Any,A}) where {T,A} =
    Base.unsafe_convert(Core.LLVMPtr{T,A}, x)
@inline function Base.pointer(x::MtlDeviceArray{T,<:Any,A}, i::Integer) where {T,A}
    Base.unsafe_convert(Core.LLVMPtr{T,A}, x) + Base._memory_offset(x, i)
end


## conversions

Base.unsafe_convert(::Type{Core.LLVMPtr{T,A}}, x::MtlDeviceArray{T,<:Any,A}) where {T,A} =
    x.ptr


## indexing intrinsics

# NOTE: these intrinsics are now implemented using plain and simple pointer operations;
#       when adding support for isbits union arrays we will need to implement that here.

@inline function arrayref(A::MtlDeviceArray{T}, index::Integer) where {T}
    @boundscheck checkbounds(A, index)
    align = Base.datatype_alignment(T)
    unsafe_load(pointer(A), index, Val(align))
end

@inline function arrayset(A::MtlDeviceArray{T}, x::T, index::Integer) where {T}
    @boundscheck checkbounds(A, index)
    align = Base.datatype_alignment(T)
    unsafe_store!(pointer(A), x, index, Val(align))
    return A
end

@inline function const_arrayref(A::MtlDeviceArray{T}, index::Integer) where {T}
    @boundscheck checkbounds(A, index)
    align = Base.datatype_alignment(T)
    unsafe_cached_load(pointer(A), index, Val(align))
end


## indexing

Base.IndexStyle(::Type{<:MtlDeviceArray}) = Base.IndexLinear()

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
    ptr = pointer(A, I[1].start)
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



## derived arrays

# create a derived device array (reinterpreted or reshaped) that's still a MtlDeviceArray
@inline function _derived_array(::Type{T}, N::Int, a::MtlDeviceArray{T,M,A},
                                osize::Dims) where {T, M, A}
    return MtlDeviceArray{T,N,A}(osize, a.ptr)
end

function Base.reinterpret(::Type{T}, a::MtlDeviceArray{S,N,A}) where {T,S,N,A}
    err = _reinterpret_exception(T, a)
    err === nothing || throw(err)

    if sizeof(T) == sizeof(S) # fast case
        return MtlDeviceArray{T,N,A}(size(a), reinterpret(LLVMPtr{T,A}, a.ptr))
    end

    isize = size(a)
    size1 = div(isize[1]*sizeof(S), sizeof(T))
    osize = tuple(size1, Base.tail(isize)...)
    return MtlDeviceArray{T,N,A}(osize, reinterpret(LLVMPtr{T,A}, a.ptr))
end

function Base.reshape(a::MtlDeviceArray{T,M}, dims::NTuple{N,Int}) where {T,N,M}
    if prod(dims) != length(a)
        throw(DimensionMismatch("new dimensions (argument `dims`) must be consistent with array size (`size(a)`)"))
    end
    if N == M && dims == size(a)
        return a
    end
    _derived_array(T, N, a, dims)
end
