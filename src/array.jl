# host array

export MtlArray

mutable struct MtlArray{T,N} <: AbstractGPUArray{T,N}
  buffer::MtlBuffer

  maxsize::Int  # maximum data size; excluding any selector bytes
  offset::Int   # offset of the data in the buffer, in number of elements
  dims::Dims{N}

  function MtlArray{T,N}(::UndefInitializer, dims::Dims{N}; storage=Shared) where {T,N}
      Base.allocatedinline(T) || error("MtlArray only supports element types that are stored inline")
      maxsize = prod(dims) * sizeof(T)
      bufsize = if Base.isbitsunion(T)
        # type tag array past the data
        maxsize + prod(dims)
      else
        maxsize
      end

      dev = current_device()
      if bufsize > 0
        buf = alloc(dev, bufsize; storage=storage)
        buf.label = "MtlArray{$(T),$(N)}(dims=$dims)"
      else
        buf = MtlBuffer(C_NULL)
      end

      obj = new(buf, maxsize, 0, dims)
      finalizer(obj) do arr
          free(arr.buffer)
      end
      return obj
  end

  function MtlArray{T,N}(buffer::MtlBuffer, dims::Dims{N};
                         maxsize::Int=prod(dims) * sizeof(T), offset::Int=0) where {T,N}
      Base.allocatedinline(T) || error("MtlArray only supports element types that are stored inline")
      MTL.mtRetain(buffer.handle)
      obj = new{T,N}(buffer, maxsize, offset, dims)
      finalizer(obj) do arr
          free(arr.buffer)
      end
      return obj
  end
end

device(A::MtlArray) = A.buffer.device


## constructors

# type and dimensionality specified, accepting dims as series of Ints
MtlArray{T,N}(::UndefInitializer, dims::Integer...) where {T,N} =
  MtlArray{T,N}(undef, Dims(dims))

# type but not dimensionality specified
MtlArray{T}(::UndefInitializer, dims::Dims{N}) where {T,N} = MtlArray{T,N}(undef, dims)
MtlArray{T}(::UndefInitializer, dims::Integer...) where {T} =
    MtlArray{T}(undef, convert(Tuple{Vararg{Int}}, dims))

# empty vector constructor
MtlArray{T,1}() where {T} = MtlArray{T,1}(undef, 0)

Base.similar(a::MtlArray{T,N}) where {T,N} = MtlArray{T,N}(undef, size(a))
Base.similar(a::MtlArray{T}, dims::Base.Dims{N}) where {T,N} = MtlArray{T,N}(undef, dims)
Base.similar(a::MtlArray, ::Type{T}, dims::Base.Dims{N}) where {T,N} =
  MtlArray{T,N}(undef, dims)

function Base.copy(a::MtlArray{T,N}) where {T,N}
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

Base.unsafe_convert(t::Type{MtlPointer{T}}, x::MtlArray) where {T} =
  MtlPointer{T}(x.buffer, x.offset*Base.elsize(x))


## interop with other arrays

@inline function MtlArray{T,N}(xs::AbstractArray{T,N}) where {T,N}
  A = MtlArray{T,N}(undef, size(xs))
  copyto!(A, xs)
  return A
end

MtlArray{T,N}(xs::AbstractArray{S,N}) where {T,N,S} = MtlArray{T,N}(map(T, xs))

# underspecified constructors
MtlArray{T}(xs::AbstractArray{S,N}) where {T,N,S} = MtlArray{T,N}(xs)
(::Type{MtlArray{T,N} where T})(x::AbstractArray{S,N}) where {S,N} = MtlArray{S,N}(x)
MtlArray(A::AbstractArray{T,N}) where {T,N} = MtlArray{T,N}(A)

# idempotency
MtlArray{T,N}(xs::MtlArray{T,N}) where {T,N} = xs


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


## interop with CPU arrays

Base.unsafe_wrap(t::Type{<:Array}, arr::MtlArray, dims; own=false) = unsafe_wrap(t, arr.buffer, dims; own=own)

# We don't convert isbits types in `adapt`, since they are already
# considered GPU-compatible.

Adapt.adapt_storage(::Type{MtlArray}, xs::AbstractArray) =
  isbits(xs) ? xs : convert(MtlArray, xs)

# if an element type is specified, convert to it
Adapt.adapt_storage(::Type{<:MtlArray{T}}, xs::AbstractArray) where {T} =
  isbits(xs) ? xs : convert(MtlArray{T}, xs)

Adapt.adapt_storage(::Type{Array}, xs::MtlArray) = convert(Array, xs)

Base.collect(x::MtlArray{T,N}) where {T,N} = copyto!(Array{T,N}(undef, size(x)), x)


## memory copying

function Base.copyto!(dest::MtlArray{T}, doffs::Integer, src::Array{T}, soffs::Integer,
                      n::Integer) where T
  n==0 && return dest
  @boundscheck checkbounds(dest, doffs)
  @boundscheck checkbounds(dest, doffs+n-1)
  @boundscheck checkbounds(src, soffs)
  @boundscheck checkbounds(src, soffs+n-1)
  unsafe_copyto!(device(dest), dest, doffs, src, soffs, n)
  return dest
end

Base.copyto!(dest::MtlArray{T}, src::Array{T}) where {T} =
    copyto!(dest, 1, src, 1, length(src))

function Base.copyto!(dest::Array{T}, doffs::Integer, src::MtlArray{T}, soffs::Integer,
                      n::Integer) where T
  n==0 && return dest
  @boundscheck checkbounds(dest, doffs)
  @boundscheck checkbounds(dest, doffs+n-1)
  @boundscheck checkbounds(src, soffs)
  @boundscheck checkbounds(src, soffs+n-1)
  unsafe_copyto!(device(src), dest, doffs, src, soffs, n)
  return dest
end

Base.copyto!(dest::Array{T}, src::MtlArray{T}) where {T} =
    copyto!(dest, 1, src, 1, length(src))

function Base.copyto!(dest::MtlArray{T}, doffs::Integer, src::MtlArray{T}, soffs::Integer,
                      n::Integer) where T
  n==0 && return dest
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

function Base.unsafe_copyto!(dev::MtlDevice, dest::MtlArray{T}, doffs, src::Array{T}, soffs, n) where T
  # these copies are implemented using pure memcpy's, not API calls, so aren't ordered.
  synchronize()

  GC.@preserve src dest unsafe_copyto!(dev, pointer(dest, doffs), pointer(src, soffs), n)
  if Base.isbitsunion(T)
    # copy selector bytes
    error("Not implemented")
  end
  return dest
end

function Base.unsafe_copyto!(dev::MtlDevice, dest::Array{T}, doffs, src::MtlArray{T}, soffs, n) where T
  # these copies are implemented using pure memcpy's, not API calls, so aren't ordered.
  synchronize()

  GC.@preserve src dest unsafe_copyto!(dev, pointer(dest, doffs), pointer(src, soffs), n)
  if Base.isbitsunion(T)
    # copy selector bytes
    error("Not implemented")
  end
  return dest
end

function Base.unsafe_copyto!(dev::MtlDevice, dest::MtlArray{T}, doffs, src::MtlArray{T}, soffs, n) where T
  # these copies are implemented using pure memcpy's, not API calls, so aren't ordered.
  synchronize()

  GC.@preserve src dest unsafe_copyto!(dev, pointer(dest, doffs), pointer(src, soffs), n)
  if Base.isbitsunion(T)
    # copy selector bytes
    error("Not implemented")
  end
  return dest
end


## utilities

zeros(T::Type, dims...) = fill!(MtlArray{T}(undef, dims...), 0)
ones(T::Type, dims...) = fill!(MtlArray{T}(undef, dims...), 1)
zeros(dims...) = zeros(Float32, dims...)
ones(dims...) = Mtls(Float32, dims...)
fill(v, dims...) = fill!(MtlArray{typeof(v)}(undef, dims...), v)
fill(v, dims::Dims) = fill!(MtlArray{typeof(v)}(undef, dims...), v)

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

Base.unsafe_convert(::Type{MTL.MTLBuffer}, A::PermutedDimsArray) where {T} =
    Base.unsafe_convert(MTL.MTLBuffer, parent(A))


## reshape

device(a::Base.ReshapedArray) = device(parent(a))

Base.unsafe_convert(::Type{MTL.MTLBuffer}, a::Base.ReshapedArray{T}) where {T} =
  Base.unsafe_convert(MTL.MTLBuffer, parent(a))


## reinterpret

device(a::Base.ReinterpretArray) = device(parent(a))

Base.unsafe_convert(::Type{MTL.MTLBuffer}, a::Base.ReinterpretArray{T,N,S} where N) where {T,S} =
  MTL.MTLBuffer(Base.unsafe_convert(ZePtr{S}, parent(a)))


## unsafe_wrap

function Base.unsafe_wrap(t::Type{<:Array{T}}, buf::MtlBuffer, dims; own=false) where T
    ptr = convert(Ptr{T}, contents(buf))
    return unsafe_wrap(t, ptr, dims; own)
end

function Base.unsafe_wrap(t::Type{<:Array{T}}, ptr::MtlPointer{T}, dims; own=false) where T
    return unsafe_wrap(t, contents(ptr), dims; own)
end
