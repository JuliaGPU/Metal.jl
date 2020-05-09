# Contiguous on-device arrays

export MtlDeviceArray, MtlDeviceVector, MtlDeviceMatrix


## construction

# NOTE: we can't support the typical `tuple or series of integer` style construction,
#       because we're currently requiring a trailing pointer argument.

struct MtlDeviceArray{T,N,A} <: AbstractArray{T,N}
    shape::Dims{N}
    ptr::DevicePtr{T,A}

    # inner constructors, fully parameterized, exact types (ie. Int not <:Integer)
    MtlDeviceArray{T,N,A}(shape::Dims{N}, ptr::DevicePtr{T,A}) where {T,A,N} = new(shape,ptr)
end

const MtlDeviceVector = MtlDeviceArray{T,1,A} where {T,A}
const MtlDeviceMatrix = MtlDeviceArray{T,2,A} where {T,A}

# outer constructors, non-parameterized
MtlDeviceArray(dims::NTuple{N,<:Integer}, p::DevicePtr{T,A})                where {T,A,N} = MtlDeviceArray{T,N,A}(dims, p)
MtlDeviceArray(len::Integer,              p::DevicePtr{T,A})                where {T,A}   = MtlDeviceVector{T,A}((len,), p)

# outer constructors, partially parameterized
MtlDeviceArray{T}(dims::NTuple{N,<:Integer},   p::DevicePtr{T,A}) where {T,A,N} = MtlDeviceArray{T,N,A}(dims, p)
MtlDeviceArray{T}(len::Integer,                p::DevicePtr{T,A}) where {T,A}   = MtlDeviceVector{T,A}((len,), p)
MtlDeviceArray{T,N}(dims::NTuple{N,<:Integer}, p::DevicePtr{T,A}) where {T,A,N} = MtlDeviceArray{T,N,A}(dims, p)
MtlDeviceVector{T}(len::Integer,               p::DevicePtr{T,A}) where {T,A}   = MtlDeviceVector{T,A}((len,), p)

# outer constructors, fully parameterized
MtlDeviceArray{T,N,A}(dims::NTuple{N,<:Integer}, p::DevicePtr{T,A}) where {T,A,N} = MtlDeviceArray{T,N,A}(Int.(dims), p)
MtlDeviceVector{T,A}(len::Integer,               p::DevicePtr{T,A}) where {T,A}   = MtlDeviceVector{T,A}((Int(len),), p)


## getters

Base.pointer(a::MtlDeviceArray) = a.ptr
Base.pointer(a::MtlDeviceArray, i::Integer) =
    pointer(a) + (i - 1) * Base.elsize(a)

Base.elsize(::Type{<:MtlDeviceArray{T}}) where {T} = sizeof(T)
Base.size(g::MtlDeviceArray) = g.shape
Base.length(g::MtlDeviceArray) = prod(g.shape)


## conversions

Base.unsafe_convert(::Type{DevicePtr{T,A}}, a::MtlDeviceArray{T,N,A}) where {T,A,N} = pointer(a)


## indexing intrinsics

# NOTE: these intrinsics are now implemented using plain and simple pointer operations;
#       when adding support for isbits union arrays we will need to implement that here.

# TODO: arrays as allocated by the CUDA APIs are 256-byte aligned. we should keep track of
#       this information, because it enables optimizations like Load Store Vectorization
#       (cfr. shared memory and its wider-than-datatype alignment)

@inline function arrayref(A::MtlDeviceArray{T}, index::Int) where {T}
    @boundscheck checkbounds(A, index)
    align = Base.datatype_alignment(T)
    unsafe_load(pointer(A), index, Val(align))
end

@inline function arrayset(A::MtlDeviceArray{T}, x::T, index::Int) where {T}
    @boundscheck checkbounds(A, index)
    align = Base.datatype_alignment(T)
    unsafe_store!(pointer(A), x, index, Val(align))
    return A
end

@inline function const_arrayref(A::MtlDeviceArray{T}, index::Int) where {T}
    @boundscheck checkbounds(A, index)
    align = Base.datatype_alignment(T)
    unsafe_cached_load(pointer(A), index, Val(align))
end


## indexing

Base.@propagate_inbounds Base.getindex(A::MtlDeviceArray{T}, i1::Int) where {T} =
    arrayref(A, i1)
Base.@propagate_inbounds Base.setindex!(A::MtlDeviceArray{T}, x, i1::Int) where {T} =
    arrayset(A, convert(T,x)::T, i1)

Base.IndexStyle(::Type{<:MtlDeviceArray}) = Base.IndexLinear()


## const indexing

"""
    Const(A::oneDeviceArray)

Mark a oneDeviceArray as constant/read-only. The invariant guaranteed is that you will not
modify an oneDeviceArray for the duration of the current kernel.

This API can only be used on devices with compute capability 3.5 or higher.

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
Base.@propagate_inbounds Base.getindex(A::Const, i1::Int) = const_arrayref(A.a, i1)

# deprecated
Base.@propagate_inbounds ldg(A::MtlDeviceArray, i1::Integer) = const_arrayref(A, Int(i1))


## other

Base.show(io::IO, a::MtlDeviceArray) =
    print(io, "$(length(a))-element device array at $(pointer(a))")
Base.show(io::IO, mime::MIME"text/plain", a::MtlDeviceArray) = show(io, a)

@inline function Base.unsafe_view(A::MtlDeviceArray{T}, I::Vararg{Base.ViewIndex,1}) where {T}
    ptr = pointer(A) + (I[1].start-1)*sizeof(T)
    len = I[1].stop - I[1].start + 1
    return oneDeviceArray(len, ptr)
end

@inline function Base.iterate(A::MtlDeviceArray, i=1)
    if (i % UInt) - 1 < length(A)
        (@inbounds A[i], i + 1)
    else
        nothing
    end
end
