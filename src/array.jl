# host array

export MtlArray, MtlVector, MtlMatrix, MtlVecOrMat, mtl

function hasfieldcount(@nospecialize(dt))
    try
        fieldcount(dt)
    catch
        return false
    end
    return true
end

function contains_double(T)
    if T === Float64
      return true
    elseif T isa Union
        for U in Base.uniontypes(T)
            contains_double(U) && return true
        end
    elseif hasfieldcount(T)
        for U in fieldtypes(T)
            contains_double(U) && return true
        end
    end
    return false
end

mutable struct MtlArray{T,N,S} <: AbstractGPUArray{T,N}
  buffer::MTLBuffer

  maxsize::Int  # maximum data size; excluding any selector bytes
  offset::Int   # offset of the data in the buffer, in number of elements
  dims::Dims{N}

  function MtlArray{T,N,S}(::UndefInitializer, dims::Dims{N}) where {T,N,S}
      Base.allocatedinline(T) || error("MtlArray only supports element types that are stored inline")
      contains_double(T) && @warn "Metal does not support Float64 values, try using Float32 instead" maxlog=1
      maxsize = prod(dims) * sizeof(T)
      bufsize = if Base.isbitsunion(T)
        # type tag array past the data
        maxsize + prod(dims)
      else
        maxsize
      end

      dev = current_device()
      if bufsize == 0
        # Metal doesn't support empty allocations. for simplicity (i.e., the ability to get
        # a pointer, query the buffer's properties, etc), we use a 1-byte buffer instead.
        bufsize = 1
      end
      buf = alloc(dev, bufsize; storage=S)
      buf.label = "MtlArray{$(T),$(N),$(S)}(dims=$dims)"

      obj = new{T,N,S}(buf, maxsize, 0, dims)
      finalizer(obj) do arr
          free(arr.buffer)
      end
      return obj
  end

  function MtlArray{T,N}(buffer::MTLBuffer, dims::Dims{N};
                         maxsize::Int=prod(dims) * sizeof(T), offset::Int=0) where {T,N}
      Base.allocatedinline(T) || error("MtlArray only supports element types that are stored inline")
      retain(buffer)
      S = convert(MTL.MTLResourceOptions, buffer.storageMode)
      obj = new{T,N,S}(buffer, maxsize, offset, dims)
      finalizer(obj) do arr
          free(arr.buffer)
      end
      return obj
  end
end

device(A::MtlArray) = A.buffer.device
storagemode(::MtlArray{T,N,S}) where {T,N,S} = S

## aliases

const MtlVector{T,S} = MtlArray{T,1,S}
const MtlMatrix{T,S} = MtlArray{T,2,S}
const MtlVecOrMat{T,S} = Union{MtlVector{T,S},MtlMatrix{T,S}}

# default to Private memory
const DefaultStorageMode = Private
MtlArray{T,N}(::UndefInitializer, dims::Dims{N}) where {T,N} =
  MtlArray{T,N,DefaultStorageMode}(undef, dims)

## constructors

# type and dimensionality specified, accepting dims as series of Ints
MtlArray{T,N,S}(::UndefInitializer, dims::Integer...) where {T,N,S} =
  MtlArray{T,N,S}(undef, convert(Tuple{Vararg{Int}}, dims))
MtlArray{T,N}(::UndefInitializer, dims::Integer...) where {T,N} =
  MtlArray{T,N}(undef, Dims(dims))

# type but not dimensionality specified
MtlArray{T}(::UndefInitializer, dims::Dims{N}) where {T,N} = MtlArray{T,N}(undef, dims)
MtlArray{T}(::UndefInitializer, dims::Integer...) where {T} =
    MtlArray{T}(undef, convert(Tuple{Vararg{Int}}, dims))

# empty vector constructor
MtlArray{T,1,S}() where {T,S} = MtlArray{T,1,S}(undef, 0)
MtlArray{T,1}() where {T} = MtlArray{T,1}(undef, 0)

Base.similar(a::MtlArray{T,N,S}) where {T,N,S} =
  MtlArray{T,N,S}(undef, size(a))
Base.similar(a::MtlArray{T,<:Any,S}, dims::Base.Dims{N}) where {T,N,S} =
  MtlArray{T,N,S}(undef, dims)
Base.similar(a::MtlArray{<:Any,<:Any,S}, ::Type{T}, dims::Base.Dims{N}) where {T,N,S} =
  MtlArray{T,N,S}(undef, dims)

function Base.copy(a::MtlArray)
  b = similar(a)
  @inbounds copyto!(b, a)
end


## array interface

Base.elsize(::Type{<:MtlArray{T}}) where {T} = sizeof(T)

Base.size(x::MtlArray) = x.dims
Base.sizeof(x::MtlArray) = Base.elsize(x) * length(x)

Base.pointer(x::MtlArray{T}) where {T} = Base.unsafe_convert(MtlPointer{T}, x)
@inline function Base.pointer(x::MtlArray{T}, i::Integer) where T
    Base.unsafe_convert(MtlPointer{T}, x) + Base._memory_offset(x, i)
end

Base.unsafe_convert(::Type{Ptr{S}}, x::MtlArray{T}) where {S, T} =
  throw(ArgumentError("cannot take the CPU address of a $(typeof(x))"))
Base.unsafe_convert(::Type{MtlPointer{T}}, x::MtlArray) where {T} =
  MtlPointer{T}(x.buffer, x.offset*Base.elsize(x))


## interop with other arrays

@inline function MtlArray{T,N}(xs::AbstractArray{T,N}) where {T,N}
  A = MtlArray{T,N}(undef, size(xs))
  @inline copyto!(A, convert(Array{T}, xs))
  return A
end
@inline function MtlArray{T,N,S}(xs::AbstractArray{T,N}) where {T,N,S}
  A = MtlArray{T,N,S}(undef, size(xs))
  @inline copyto!(A, convert(Array{T}, xs))
  return A
end

MtlArray{T,N}(xs::AbstractArray{OT,N}) where {T,N,OT} = MtlArray{T,N}(map(T, xs))
MtlArray{T,N,S}(xs::AbstractArray{OT,N}) where {T,N,S,OT} = MtlArray{T,N,S}(map(T, xs))

# underspecified constructors
MtlArray{T}(xs::AbstractArray{OT,N}) where {T,N,OT} = MtlArray{T,N}(xs)
(::Type{MtlArray{T,N} where T})(x::AbstractArray{OT,N}) where {OT,N} = MtlArray{OT,N}(x)
MtlArray(A::AbstractArray{T,N}) where {T,N} = MtlArray{T,N}(A)

# copy xs to match Array behavior with same storage mode
MtlArray{T,N,S}(xs::MtlArray{T,N,S}) where {T,N,S} = copy(xs)

## derived types

# wrapped arrays: can be used in kernels
const WrappedMtlArray{T,N} = Union{MtlArray{T,N}, WrappedArray{T,N,MtlArray,MtlArray{T,N}}}
const WrappedMtlVector{T} = WrappedMtlArray{T,1}
const WrappedMtlMatrix{T} = WrappedMtlArray{T,2}
const WrappedMtlVecOrMat{T} = Union{WrappedMtlVector{T}, WrappedMtlMatrix{T}}


## conversions

Base.convert(::Type{T}, x::T) where T <: MtlArray = x


## interop with C libraries

Base.unsafe_convert(::Type{<:Ptr}, x::MtlArray) =
  throw(ArgumentError("cannot take the host address of a $(typeof(x))"))

Base.unsafe_convert(t::Type{MTL.MTLBuffer}, x::MtlArray) = x.buffer


## interop with ObjC libraries

Base.cconvert(::Type{<:id}, x::MtlArray) = x.buffer


## interop with CPU arrays

Base.unsafe_wrap(t::Type{<:Array}, arr::MtlArray, dims; own=false) =
  unsafe_wrap(t, arr.buffer, dims; own=own)

Base.collect(x::MtlArray{T,N}) where {T,N} = copyto!(Array{T,N}(undef, size(x)), x)


## memory copying

# CPU -> GPU
function Base.copyto!(dest::MtlArray{T}, doffs::Integer, src::Array{T}, soffs::Integer,
                      n::Integer) where T
  (n==0 || sizeof(T) == 0) && return dest
  @boundscheck checkbounds(dest, doffs)
  @boundscheck checkbounds(dest, doffs+n-1)
  @boundscheck checkbounds(src, soffs)
  @boundscheck checkbounds(src, soffs+n-1)
  unsafe_copyto!(device(dest), dest, doffs, src, soffs, n)
  return dest
end

Base.copyto!(dest::MtlArray{T}, src::Array{T}) where {T} =
    copyto!(dest, 1, src, 1, length(src))

# GPU -> CPU
function Base.copyto!(dest::Array{T}, doffs::Integer, src::MtlArray{T}, soffs::Integer,
                      n::Integer) where T
  (n==0 || sizeof(T) == 0) && return dest
  @boundscheck checkbounds(dest, doffs)
  @boundscheck checkbounds(dest, doffs+n-1)
  @boundscheck checkbounds(src, soffs)
  @boundscheck checkbounds(src, soffs+n-1)
  unsafe_copyto!(device(src), dest, doffs, src, soffs, n)
  return dest
end

Base.copyto!(dest::Array{T}, src::MtlArray{T}) where {T} =
    copyto!(dest, 1, src, 1, length(src))

# GPU -> GPU
function Base.copyto!(dest::MtlArray{T}, doffs::Integer, src::MtlArray{T}, soffs::Integer,
                      n::Integer) where T
  (n==0 || sizeof(T) == 0) && return dest
  @boundscheck checkbounds(dest, doffs)
  @boundscheck checkbounds(dest, doffs+n-1)
  @boundscheck checkbounds(src, soffs)
  @boundscheck checkbounds(src, soffs+n-1)
  # TODO: which device to use here?
  if device(dest) == device(src)
    unsafe_copyto!(device(dest), dest, doffs, src, soffs, n)
  else
    error("Copy between different devices not implemented")
  end
  return dest
end

Base.copyto!(dest::MtlArray{T}, src::MtlArray{T}) where {T} =
    copyto!(dest, 1, src, 1, length(src))

# CPU -> GPU
function Base.unsafe_copyto!(dev::MTLDevice, dest::MtlArray{T}, doffs, src::Array{T}, soffs, n) where T
  # these copies are implemented using pure memcpy's, not API calls, so aren't ordered.
  synchronize()

  GC.@preserve src dest unsafe_copyto!(dev, pointer(dest, doffs), pointer(src, soffs), n)
  if Base.isbitsunion(T)
    # copy selector bytes
    error("Not implemented")
  end
  return dest
end

# GPU -> CPU
function Base.unsafe_copyto!(dev::MTLDevice, dest::Array{T}, doffs, src::MtlArray{T}, soffs, n) where T
  # these copies are implemented using pure memcpy's, not API calls, so aren't ordered.
  synchronize()

  GC.@preserve src dest unsafe_copyto!(dev, pointer(dest, doffs), pointer(src, soffs), n)
  if Base.isbitsunion(T)
    # copy selector bytes
    error("Not implemented")
  end
  return dest
end

# GPU -> GPU
function Base.unsafe_copyto!(dev::MTLDevice, dest::MtlArray{T}, doffs, src::MtlArray{T}, soffs, n) where T
  # these copies are implemented using pure memcpy's, not API calls, so aren't ordered.
  synchronize()

  GC.@preserve src dest unsafe_copyto!(dev, pointer(dest, doffs), pointer(src, soffs), n)
  if Base.isbitsunion(T)
    # copy selector bytes
    error("Not implemented")
  end
  return dest
end


## regular gpu array adaptor

# We don't convert isbits types in `adapt`, since they are already
# considered GPU-compatible.

Adapt.adapt_storage(::Type{MtlArray}, xs::AT) where {AT<:AbstractArray} =
  isbitstype(AT) ? xs : convert(MtlArray, xs)

# if specific type parameters are specified, preserve those
Adapt.adapt_storage(::Type{<:MtlArray{T}}, xs::AT) where {T, AT<:AbstractArray} =
  isbitstype(AT) ? xs : convert(MtlArray{T}, xs)
Adapt.adapt_storage(::Type{<:MtlArray{T, N}}, xs::AT) where {T, N, AT<:AbstractArray} =
  isbitstype(AT) ? xs : convert(MtlArray{T,N}, xs)


## opinionated gpu array adaptor

# eagerly converts Float64 to Float32, for compatibility reasons

struct MtlArrayAdaptor{S} end

Adapt.adapt_storage(::MtlArrayAdaptor{S}, xs::AbstractArray{T,N}) where {T,N,S} =
  isbits(xs) ? xs : MtlArray{T,N,S}(xs)

Adapt.adapt_storage(::MtlArrayAdaptor{S}, xs::AbstractArray{T,N}) where {T<:AbstractFloat,N,S} =
  isbits(xs) ? xs : MtlArray{Float32,N,S}(xs)

Adapt.adapt_storage(::MtlArrayAdaptor{S}, xs::AbstractArray{T,N}) where {T<:Complex{<:AbstractFloat},N,S} =
  isbits(xs) ? xs : MtlArray{ComplexF32,N,S}(xs)

# not for Float16
Adapt.adapt_storage(::MtlArrayAdaptor{S}, xs::AbstractArray{T,N}) where {T<:Float16,N,S} =
  isbits(xs) ? xs : MtlArray{T,N,S}(xs)

"""
    mtl(A)

Opinionated GPU array adaptor, which may alter the element type `T` of arrays:
* For `T<:AbstractFloat`, it makes a `MtlArray{Float32}` for performance and compatibility
  reasons (except for `Float16`).
* For `T<:Complex{<:AbstractFloat}` it makes a `MtlArray{ComplexF32}`.
* For other `isbitstype(T)`, it makes a `MtlArray{T}`.

By contrast, `MtlArray(A)` never changes the element type.

Uses Adapt.jl to act inside some wrapper structs.
"""
@inline mtl(xs; storage=DefaultStorageMode) = adapt(MtlArrayAdaptor{storage}(), xs)

Base.getindex(::typeof(mtl), xs...) = MtlArray([xs...])

## utilities

for (fname, felt) in ((:zeros, :zero), (:ones, :one))
  @eval begin
      $fname(::Type{T}, dims::Base.Dims{N}; storage=DefaultStorageMode) where {T,N} = fill!(MtlArray{T,N,storage}(undef, dims), $felt(T))
      $fname(::Type{T}, dims...; storage=DefaultStorageMode) where {T} = fill!(MtlArray{T,length(dims),storage}(undef, dims), $felt(T))
      $fname(dims...; storage=DefaultStorageMode) = fill!(MtlArray{Float32,length(dims),storage}(undef, dims), $felt(Float32))
  end
end
fill(v, dims...; kwargs...) = fill!(MtlArray{typeof(v)}(undef, dims...; kwargs...), v)
fill(v, dims::Dims; kwargs...) = fill!(MtlArray{typeof(v)}(undef, dims...; kwargs...), v)

# optimized implementation of `fill!` for types that are directly supported by fillbuffer
function Base.fill!(A::MtlArray{T}, val) where T <: Union{UInt8,Int8}
  B = convert(T, val)
  unsafe_fill!(device(A), pointer(A), B, length(A))
  A
end


## views

device(a::SubArray) = device(parent(a))

# we don't really want an array, so don't call `adapt(Array, ...)`,
# but just want MtlArray indices to get downloaded back to the CPU.
# this makes sure we preserve array-like containers, like Base.Slice.
struct BackToCPU end
Adapt.adapt_storage(::BackToCPU, xs::MtlArray) = convert(Array, xs)

@inline function Base.view(A::MtlArray, I::Vararg{Any,N}) where {N}
    J = to_indices(A, I)
    @boundscheck begin
        # Base's boundscheck accesses the indices, so make sure they reside on the CPU.
        # this is expensive, but it's a bounds check after all.
        J_cpu = map(j->adapt(BackToCPU(), j), J)
        checkbounds(A, J_cpu...)
    end
    J_gpu = map(j->adapt(MtlArray, j), J)
    Base.unsafe_view(Base._maybe_reshape_parent(A, Base.index_ndims(J_gpu...)), J_gpu...)
end

# pointer conversions
## contiguous
function Base.unsafe_convert(::Type{MTL.MTLBuffer}, V::SubArray{T,N,P,<:Tuple{Vararg{Base.RangeIndex}}}) where {T,N,P}
    return Base.unsafe_convert(MTL.MTLBuffer, parent(V)) +
           Base._memory_offset(V.parent, map(first, V.indices)...)
end

## reshaped
function Base.unsafe_convert(::Type{MTL.MTLBuffer}, V::SubArray{T,N,P,<:Tuple{Vararg{Union{Base.RangeIndex,Base.ReshapedUnitRange}}}}) where {T,N,P}
   return Base.unsafe_convert(MTL.MTLBuffer, parent(V)) +
          (Base.first_index(V)-1)*sizeof(T)
end


## PermutedDimsArray

device(a::Base.PermutedDimsArray) = device(parent(a))

Base.unsafe_convert(::Type{MTL.MTLBuffer}, A::PermutedDimsArray) =
    Base.unsafe_convert(MTL.MTLBuffer, parent(A))


## reshape

function Base.reshape(a::MtlArray{T,M}, dims::NTuple{N,Int}) where {T,N,M}
  if prod(dims) != length(a)
      throw(DimensionMismatch("new dimensions $(dims) must be consistent with array size $(size(a))"))
  end

  if N == M && dims == size(a)
      return a
  end

  _derived_array(T, N, a, dims)
end

# create a derived array (reinterpreted or reshaped) that's still a MtlArray
@inline function _derived_array(::Type{T}, N::Int, a::MtlArray, osize::Dims) where {T}
  offset = (a.offset * Base.elsize(a)) ÷ sizeof(T)
  MtlArray{T,N}(a.buffer, osize; a.maxsize, offset)
end


## reinterpret

device(a::Base.ReinterpretArray) = device(parent(a))

function Base.reinterpret(::Type{T}, a::MtlArray{S,N}) where {T,S,N}
  err = _reinterpret_exception(T, a)
  err === nothing || throw(err)

  if sizeof(T) == sizeof(S) # for N == 0
    osize = size(a)
  else
    isize = size(a)
    size1 = div(isize[1]*sizeof(S), sizeof(T))
    osize = tuple(size1, Base.tail(isize)...)
  end

  return _derived_array(T, N, a, osize)
end

function _reinterpret_exception(::Type{T}, a::AbstractArray{S,N}) where {T,S,N}
  if !isbitstype(T) || !isbitstype(S)
    return MtlReinterpretBitsTypeError{T,typeof(a)}()
  end
  if N == 0 && sizeof(T) != sizeof(S)
    return MtlReinterpretZeroDimError{T,typeof(a)}()
  end
  if N != 0 && sizeof(S) != sizeof(T)
      ax1 = axes(a)[1]
      dim = length(ax1)
      if Base.rem(dim*sizeof(S),sizeof(T)) != 0
        return MtlReinterpretDivisibilityError{T,typeof(a)}(dim)
      end
      if first(ax1) != 1
        return MtlReinterpretFirstIndexError{T,typeof(a),typeof(ax1)}(ax1)
      end
  end
  return nothing
end

struct MtlReinterpretBitsTypeError{T,A} <: Exception end
function Base.showerror(io::IO, ::MtlReinterpretBitsTypeError{T, <:AbstractArray{S}}) where {T, S}
  print(io, "cannot reinterpret an `$(S)` array to `$(T)`, because not all types are bitstypes")
end

struct MtlReinterpretZeroDimError{T,A} <: Exception end
function Base.showerror(io::IO, ::MtlReinterpretZeroDimError{T, <:AbstractArray{S,N}}) where {T, S, N}
  print(io, "cannot reinterpret a zero-dimensional `$(S)` array to `$(T)` which is of a different size")
end

struct MtlReinterpretDivisibilityError{T,A} <: Exception
  dim::Int
end
function Base.showerror(io::IO, err::MtlReinterpretDivisibilityError{T, <:AbstractArray{S,N}}) where {T, S, N}
  dim = err.dim
  print(io, """
      cannot reinterpret an `$(S)` array to `$(T)` whose first dimension has size `$(dim)`.
      The resulting array would have non-integral first dimension.
      """)
end

struct MtlReinterpretFirstIndexError{T,A,Ax1} <: Exception
  ax1::Ax1
end
function Base.showerror(io::IO, err::MtlReinterpretFirstIndexError{T, <:AbstractArray{S,N}}) where {T, S, N}
  ax1 = err.ax1
  print(io, "cannot reinterpret a `$(S)` array to `$(T)` when the first axis is $ax1. Try reshaping first.")
end


## reinterpret(reshape)

function Base.reinterpret(::typeof(reshape), ::Type{T}, a::MtlArray) where {T}
  N, osize = _base_check_reshape_reinterpret(T, a)
  return _derived_array(T, N, a, osize)
end

# taken from reinterpretarray.jl
# TODO: move these Base definitions out of the ReinterpretArray struct for reuse
function _base_check_reshape_reinterpret(::Type{T}, a::MtlArray{S}) where {T,S}
  isbitstype(T) || throwbits(S, T, T)
  isbitstype(S) || throwbits(S, T, S)
  if sizeof(S) == sizeof(T)
      N = ndims(a)
      osize = size(a)
  elseif sizeof(S) > sizeof(T)
      d, r = divrem(sizeof(S), sizeof(T))
      r == 0 || throwintmult(S, T)
      N = ndims(a) + 1
      osize = (d, size(a)...)
  else
      d, r = divrem(sizeof(T), sizeof(S))
      r == 0 || throwintmult(S, T)
      N = ndims(a) - 1
      N > -1 || throwsize0(S, T, "larger")
      axes(a, 1) == Base.OneTo(sizeof(T) ÷ sizeof(S)) || throwsize1(a, T)
      osize = size(a)[2:end]
  end
  return N, osize
end

@noinline function throwbits(S::Type, T::Type, U::Type)
  throw(ArgumentError("cannot reinterpret `$(S)` as `$(T)`, type `$(U)` is not a bits type"))
end

@noinline function throwintmult(S::Type, T::Type)
  throw(ArgumentError("`reinterpret(reshape, T, a)` requires that one of `sizeof(T)` (got $(sizeof(T))) and `sizeof(eltype(a))` (got $(sizeof(S))) be an integer multiple of the other"))
end

@noinline function throwsize0(S::Type, T::Type, msg)
  throw(ArgumentError("cannot reinterpret a zero-dimensional `$(S)` array to `$(T)` which is of a $msg size"))
end

@noinline function throwsize1(a::AbstractArray, T::Type)
    throw(ArgumentError("`reinterpret(reshape, $T, a)` where `eltype(a)` is $(eltype(a)) requires that `axes(a, 1)` (got $(axes(a, 1))) be equal to 1:$(sizeof(T) ÷ sizeof(eltype(a))) (from the ratio of element sizes)"))
end


## unsafe_wrap

function Base.unsafe_wrap(t::Type{<:Array{T}}, buf::MTLBuffer, dims; own=false) where T
    ptr = convert(Ptr{T}, contents(buf))
    return unsafe_wrap(t, ptr, dims; own)
end

function Base.unsafe_wrap(t::Type{<:Array{T}}, ptr::MtlPointer{T}, dims; own=false) where T
    return unsafe_wrap(t, contents(ptr), dims; own)
end
