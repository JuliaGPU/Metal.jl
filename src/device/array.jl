# Contiguous on-device arrays

export MtlDeviceArray, MtlDeviceVector, MtlDeviceMatrix


## construction

"""
    MtlDeviceArray{T,N,A} <: DenseArray{T,N}

The array type that kernels see: an `N`-dimensional, column-major array of elements of type
`T` in address space `A` (device memory for the `MtlArray`s passed to a kernel, threadgroup
memory for [`MtlThreadGroupArray`](@ref)s). [`@metal`](@ref) converts `MtlArray` arguments
to it. It supports indexing, iteration and contiguous views, and is only valid inside the
kernel.

    MtlDeviceArray(dims, ptr)
    MtlDeviceArray{T}(dims, ptr)
    MtlDeviceArray{T,N}(dims, ptr)
    MtlDeviceArray{T,N,A}(dims, ptr)

Wrap the device pointer `ptr::Core.LLVMPtr{T,A}` in an array of size `dims`, an integer or
a tuple. `T` and `A` follow from the type of `ptr`, and `N` from the length of `dims`; when
given, they have to match.
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

"""
    MtlDeviceVector{T,A}

One-dimensional [`MtlDeviceArray`](@ref); an alias for `MtlDeviceArray{T,1,A}`.
"""
const MtlDeviceVector = MtlDeviceArray{T,1,A} where {T,A}

"""
    MtlDeviceMatrix{T,A}

Two-dimensional [`MtlDeviceArray`](@ref); an alias for `MtlDeviceArray{T,2,A}`.
"""
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

# a load from memory that is not written for the duration of the kernel. Metal has no
# dedicated instruction for this (MSL's `const device` only changes argument metadata), but
# Apple's back-end does take `!invariant.load` into account.
@inline function unsafe_invariant_load(ptr::Core.LLVMPtr{T}, i::Integer,
                                       ::Val{align}) where {T,align}
    sizeof(T) == 0 && return T.instance
    _unsafe_invariant_load(ptr, Int(i) - 1, Val(align))
end

@llvmgenerated builder function _unsafe_invariant_load(ptr::Core.LLVMPtr{T,A}, i::Int,
                                                       ::Val{align})::T where {T,A,align}
    eltyp = convert(LLVMType, T)
    if supports_typed_pointers(LLVM.context())
        ptr = bitcast!(builder, ptr, LLVM.PointerType(eltyp, A))
    end
    ld = load!(builder, eltyp, inbounds_gep!(builder, eltyp, ptr, [i]); align)
    if A != 0
        ld.metadata[LLVM.MD_tbaa] = tbaa_addrspace(A)
    end
    ld.metadata[LLVM.MD_invariant_load] = MDNode(LLVM.Metadata[])
    ld
end

@inline function const_arrayref(A::MtlDeviceArray{T}, index::Integer) where {T}
    @boundscheck checkbounds(A, index)
    align = Base.datatype_alignment(T)
    unsafe_invariant_load(pointer(A), index, Val(align))
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
    Metal.Const(A::MtlDeviceArray)

Mark a device array as read-only for the duration of the kernel, which lets the compiler
optimize loads from it (e.g., hoist them out of loops). `Base.Experimental.Const(A)` does the
same. This interface is experimental, and might change without deprecation.

!!! warning
    Writing to the underlying memory while the kernel executes, through `A` or another
    array, is undefined behavior, and can produce wrong results.
"""
struct Const{T,N,AS} <: DenseArray{T,N}
    a::MtlDeviceArray{T,N,AS}
end
Base.Experimental.Const(A::MtlDeviceArray) = Const(A)

Base.IndexStyle(::Type{<:Const}) = IndexLinear()
Base.size(C::Const) = size(C.a)
Base.axes(C::Const) = axes(C.a)
Base.@propagate_inbounds Base.getindex(A::Const, i1::Integer) = const_arrayref(A.a, i1)

# as for MtlDeviceArray, preserve the index type and handle ND indices ourselves
Base.to_index(::Const, i::Integer) = i
Base.@propagate_inbounds Base.getindex(A::Const,
                                       I::Union{Integer, CartesianIndex}...) =
    A[Base._to_linear_index(A, to_indices(A, I)...)]


## other

Base.show(io::IO, a::MtlDeviceVector) =
    print(io, "$(length(a))-element device array at $(pointer(a))")
Base.show(io::IO, a::MtlDeviceArray) =
    print(io, "$(join(a.shape, '×')) device array at $(pointer(a))")

Base.show(io::IO, mime::MIME"text/plain", a::MtlDeviceArray) = show(io, a)

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
    err = GPUArrays._reinterpret_exception(T, a)
    err === nothing || throw(err)

    # `T` may require a stronger alignment than `a` was checked for. this is not a bounds
    # check: the alignment that element accesses assume depends on it.
    if Base.datatype_alignment(T) > Base.datatype_alignment(S) && !isempty(a) &&
       UInt(a.ptr) % Base.datatype_alignment(T) != 0
        throw(ArgumentError("cannot reinterpret an array whose pointer is not aligned for the new element type"))
    end

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
