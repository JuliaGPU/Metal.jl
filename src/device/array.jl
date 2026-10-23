# Contiguous on-device arrays

export MtlDeviceArray, MtlDeviceVector, MtlDeviceMatrix


## element layout

# the size of an array element, including padding. for isbits unions, this can be larger
# than `sizeof`. generated on Julia 1.10, so that it folds to a constant in device code.
@static if VERSION < v"1.11"
    @generated aligned_sizeof(::Type{T}) where {T} = :($(Base.aligned_sizeof(T)))
else
    import Base: aligned_sizeof
end

# the alignment of an array element, which `Base.datatype_alignment` doesn't know for unions
@generated function element_alignment(::Type{T}) where {T}
    Base.isbitsunion(T) ? Base.uniontype_layout(T)[3] : Base.datatype_alignment(T)
end


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
    MtlDeviceArray{T,N,A}(dims, ptr, [maxsize])

Wrap the device pointer `ptr::Core.LLVMPtr{T,A}` in an array of size `dims`, an integer or
a tuple. `T` and `A` follow from the type of `ptr`, and `N` from the length of `dims`; when
given, they have to match.

Arrays of isbits unions (e.g. `Union{Int32,Nothing}`) keep one selector byte per element
past their data, like `Array`: `maxsize` is the distance in bytes from `ptr` to those bytes,
which defaults to the size of the data.
"""
MtlDeviceArray

# NOTE: we can't support the typical `tuple or series of integer` style construction,
#       because we're currently requiring a trailing pointer argument.

struct MtlDeviceArray{T,N,A} <: DenseArray{T,N}
    ptr::Core.LLVMPtr{T,A}
    shape::Dims{N}
    # distance from `ptr` to the selector bytes of an array of isbits unions
    maxsize::Int
    # inner constructors, fully parameterized, exact types (ie. Int not <:Integer)
    MtlDeviceArray{T,N,A}(shape::Dims{N}, ptr::Core.LLVMPtr{T,A},
                          maxsize::Int=prod(shape) * aligned_sizeof(T)) where {T,A,N} =
        new(ptr, shape, maxsize)
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

Base.elsize(::Type{<:MtlDeviceArray{T}}) where {T} = aligned_sizeof(T)

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

# the selector byte of element `i` of an array of isbits unions
@inline typetagdata(x::MtlDeviceArray{<:Any,<:Any,A}, i::Integer) where {A} =
    reinterpret(Core.LLVMPtr{UInt8,A}, x.ptr) + x.maxsize + (i - one(i))


## indexing intrinsics

@inline function arrayref(A::MtlDeviceArray{T}, index::Integer) where {T}
    @boundscheck checkbounds(A, index)
    if Base.isbitsunion(T)
        arrayref_union(A, index)
    else
        unsafe_load(pointer(A), index, Val(element_alignment(T)))
    end
end

# load the element as the member of the union that its selector byte names
@inline @generated function arrayref_union(A::MtlDeviceArray{T,<:Any,AS}, index::Integer) where {T,AS}
    # lacking noreturn, the fallback returns T so that inference doesn't widen the result
    ex = :(Base.llvmcall("unreachable", $T, Tuple{}))
    for (sel, typ) in Iterators.reverse(enumerate(Base.uniontypes(T)))
        ex = quote
            if selector == $(UInt8(sel - 1))
                unsafe_load(reinterpret(Core.LLVMPtr{$typ,AS}, ptr), 1, Val(align))
            else
                $ex
            end
        end
    end

    quote
        selector = unsafe_load(typetagdata(A, index))
        ptr = pointer(A, index)
        align = element_alignment(T)
        $ex
    end
end

@inline function arrayset(A::MtlDeviceArray{T}, x::T, index::Integer) where {T}
    @boundscheck checkbounds(A, index)
    if Base.isbitsunion(T)
        arrayset_union(A, x, index)
    else
        unsafe_store!(pointer(A), x, index, Val(element_alignment(T)))
    end
    return A
end

# store the element as its own type, and record that type in its selector byte
@inline @generated function arrayset_union(A::MtlDeviceArray{T,<:Any,AS}, x::T, index::Integer) where {T,AS}
    sel = findfirst(isequal(x), Base.uniontypes(T))

    quote
        unsafe_store!(typetagdata(A, index), $(UInt8(sel - 1)))
        ptr = reinterpret(Core.LLVMPtr{$x,AS}, pointer(A, index))
        unsafe_store!(ptr, x, 1, Val(element_alignment(T)))
        return
    end
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
    # loads of isbits unions are not marked invariant, for simplicity
    Base.isbitsunion(T) && return arrayref_union(A, index)
    unsafe_invariant_load(pointer(A), index, Val(element_alignment(T)))
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
    return MtlDeviceArray{T,N,A}(osize, a.ptr, a.maxsize)
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
