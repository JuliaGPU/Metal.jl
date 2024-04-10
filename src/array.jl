# host array

export MtlArray, MtlVector, MtlMatrix, MtlVecOrMat, mtl, is_shared, is_managed, is_private

function hasfieldcount(@nospecialize(dt))
    try
        fieldcount(dt)
    catch
        return false
    end
    return true
end

function contains_eltype(T, X)
    if T === X
      return true
    elseif T isa Union
        for U in Base.uniontypes(T)
            contains_eltype(U, X) && return true
        end
    elseif hasfieldcount(T)
        for U in fieldtypes(T)
            contains_eltype(U, X) && return true
        end
    end
    return false
end

function check_eltype(T)
  Base.allocatedinline(T) || error("MtlArray only supports element types that are stored inline")
  Base.isbitsunion(T) && error("MtlArray does not yet support isbits-union arrays")
  contains_eltype(T, Float64) && error("Metal does not support Float64 values, try using Float32 instead")
  contains_eltype(T, Int128) && error("Metal does not support Int128 values, try using Int64 instead")
  contains_eltype(T, UInt128) && error("Metal does not support UInt128 values, try using UInt64 instead")
end

"""
    MtlArray{T,N,S} <: AbstractGPUArray{T,N}

`N`-dimensional Metal array with storage mode `S` and elements of type `T`.

`S` can be `Private` (default) or `Shared`.
"""
mutable struct MtlArray{T,N,S} <: AbstractGPUArray{T,N}
  data::DataRef{<:MTLBuffer}

  maxsize::Int  # maximum data size; excluding any selector bytes
  offset::Int   # offset of the data in the buffer, in number of elements
  dims::Dims{N}

  function MtlArray{T,N,S}(::UndefInitializer, dims::Dims{N}) where {T,N,S}
      check_eltype(T)
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
      data = DataRef(buf) do buf
          free(buf)
      end

      obj = new{T,N,S}(data, maxsize, 0, dims)
      finalizer(unsafe_free!, obj)
  end

  function MtlArray{T,N}(data::DataRef{<:MTLBuffer}, dims::Dims{N};
                         maxsize::Int=prod(dims) * sizeof(T), offset::Int=0) where {T,N}
      check_eltype(T)
      storagemode = data[].storageMode
      if storagemode == MTL.MTLStorageModeShared
        obj = new{T,N,Shared}(copy(data), maxsize, offset, dims)
      elseif storagemode == MTL.MTLStorageModeManaged
        obj = new{T,N,Managed}(copy(data), maxsize, offset, dims)
      elseif storagemode == MTL.MTLStorageModePrivate
        obj = new{T,N,Private}(copy(data), maxsize, offset, dims)
      elseif storagemode == MTL.MTLStorageModeMemoryless
        obj = new{T,N,Memoryless}(copy(data), maxsize, offset, dims)
      end
      finalizer(unsafe_free!, obj)
  end
end

# Create MtlArray from MTLBuffer
function MtlArray{T,N}(buf::B, dims::Dims{N}; kwargs...) where {B<:MTLBuffer,T,N}
  data = DataRef(buf) do buf
    free(buf)
  end
  return MtlArray{T,N}(data, dims; kwargs...)
end

unsafe_free!(a::MtlArray) = GPUArrays.unsafe_free!(a.data)

device(A::MtlArray) = A.data[].device

storagemode(x::MtlArray) = storagemode(typeof(x))
storagemode(::Type{<:MtlArray{<:Any,<:Any,S}}) where {S} = S

is_shared(a::MtlArray) = storagemode(a) == Shared
is_managed(a::MtlArray) = storagemode(a) == Managed
is_private(a::MtlArray) = storagemode(a) == Private
is_memoryless(a::MtlArray) = storagemode(a) == Memoryless

## convenience constructors

const MtlVector{T,S} = MtlArray{T,1,S}
const MtlMatrix{T,S} = MtlArray{T,2,S}
const MtlVecOrMat{T,S} = Union{MtlVector{T,S},MtlMatrix{T,S}}

# default to private memory
const DefaultStorageMode = let str = @load_preference("default_storage", "Private")
  if str == "Private"
    Private
  elseif str == "Shared"
    Shared
  elseif str == "Managed"
    Managed
  else
    error("unknown default storage mode: $default_storage")
  end
end

MtlArray{T,N}(::UndefInitializer, dims::Dims{N}) where {T,N} =
  MtlArray{T,N,DefaultStorageMode}(undef, dims)

# storage, type and dimensionality specified
MtlArray{T,N,S}(::UndefInitializer, dims::NTuple{N,Integer}) where {T,N,S} =
  MtlArray{T,N,S}(undef, convert(Tuple{Vararg{Int}}, dims))
MtlArray{T,N,S}(::UndefInitializer, dims::Vararg{Integer,N}) where {T,N,S} =
  MtlArray{T,N,S}(undef, convert(Tuple{Vararg{Int}}, dims))

# type and dimensionality specified
MtlArray{T,N}(::UndefInitializer, dims::NTuple{N,Integer}) where {T,N} =
  MtlArray{T,N}(undef, convert(Tuple{Vararg{Int}}, dims))
MtlArray{T,N}(::UndefInitializer, dims::Vararg{Integer,N}) where {T,N} =
  MtlArray{T,N}(undef, convert(Tuple{Vararg{Int}}, dims))

# only type specified
MtlArray{T}(::UndefInitializer, dims::NTuple{N,Integer}) where {T,N} =
  MtlArray{T,N}(undef, convert(Tuple{Vararg{Int}}, dims))
MtlArray{T}(::UndefInitializer, dims::Vararg{Integer,N}) where {T,N} =
    MtlArray{T,N}(undef, convert(Tuple{Vararg{Int}}, dims))

# empty vector constructor
MtlArray{T,1,S}() where {T,S} = MtlArray{T,1,S}(undef, 0)
MtlArray{T,1}() where {T} = MtlArray{T,1}(undef, 0)

Base.similar(a::MtlArray{T,N,S}; storage=S) where {T,N,S} =
  MtlArray{T,N,storage}(undef, size(a))
Base.similar(::MtlArray{T,<:Any,S}, dims::Base.Dims{N}; storage=S) where {T,N,S} =
  MtlArray{T,N,storage}(undef, dims)
Base.similar(::MtlArray{<:Any,<:Any,S}, ::Type{T}, dims::Base.Dims{N}; storage=S) where {T,N,S} =
  MtlArray{T,N,storage}(undef, dims)

function Base.copy(a::MtlArray)
  b = similar(a)
  @inbounds copyto!(b, a)
end


## array interface

Base.elsize(::Type{<:MtlArray{T}}) where {T} = sizeof(T)

Base.size(x::MtlArray) = x.dims
Base.sizeof(x::MtlArray) = Base.elsize(x) * length(x)

@inline function Base.pointer(x::MtlArray{T}, i::Integer=1; storage=Private) where {T}
  PT = if storage == Private
    MtlPtr{T}
  elseif storage == Shared || storage == Managed
    Ptr{T}
  else
    error("unknown memory type")
  end
  Base.unsafe_convert(PT, x) + Base._memory_offset(x, i)
end


function Base.unsafe_convert(::Type{MtlPtr{T}}, x::MtlArray) where {T}
   buf = x.data[]
   MtlPtr{T}(buf, x.offset*Base.elsize(x))
 end

function Base.unsafe_convert(::Type{Ptr{S}}, x::MtlArray{T}) where {S, T}
  if is_private(x)
    throw(ArgumentError("cannot take the CPU address of a $(typeof(x))"))
  end
  synchronize()
  buf = x.data[]
  convert(Ptr{T}, buf) + x.offset*Base.elsize(x)
end


## indexing
function Base.getindex(x::MtlArray{T,N,S}, I::Int) where {T,N,S<:Union{Shared,Managed}}
  @boundscheck checkbounds(x, I)
  unsafe_load(pointer(x, I; storage=S))
end

function Base.setindex!(x::MtlArray{T,N,S}, v, I::Int) where {T,N,S<:Union{Shared,Managed}}
  @boundscheck checkbounds(x, I)
  unsafe_store!(pointer(x, I; storage=S), v)
end


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

Base.unsafe_convert(::Type{MTL.MTLBuffer}, x::MtlArray) = x.data[]


## interop with ObjC libraries

Base.cconvert(::Type{<:id}, x::MtlArray) = x.data[]


## interop with CPU arrays

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
Adapt.adapt_storage(::Type{<:MtlArray{T, N, S}}, xs::AT) where {T, N, S, AT<:AbstractArray} =
 isbitstype(AT) ? xs : convert(MtlArray{T,N,S}, xs)


## opinionated gpu array adaptor

# eagerly converts Float64 to Float32, for compatibility reasons

struct MtlArrayAdaptor{S} end

Adapt.adapt_storage(::MtlArrayAdaptor{S}, xs::AbstractArray{T,N}) where {T,N,S} =
  isbits(xs) ? xs : MtlArray{T,N,S}(xs)

Adapt.adapt_storage(::MtlArrayAdaptor{S}, xs::AbstractArray{T,N}) where {T<:Float64,N,S} =
  isbits(xs) ? xs : MtlArray{Float32,N,S}(xs)

Adapt.adapt_storage(::MtlArrayAdaptor{S}, xs::AbstractArray{T,N}) where {T<:Complex{<:Float64},N,S} =
  isbits(xs) ? xs : MtlArray{ComplexF32,N,S}(xs)

"""
    mtl(A; storage=Private)

`storage` can be `Private` (default) or `Shared`.

Opinionated GPU array adaptor, which may alter the element type `T` of arrays:
* For `T<:AbstractFloat`, it makes a `MtlArray{Float32}` for performance and compatibility
  reasons (except for `Float16`).
* For `T<:Complex{<:AbstractFloat}` it makes a `MtlArray{ComplexF32}`.
* For other `isbitstype(T)`, it makes a `MtlArray{T}`.

By contrast, `MtlArray(A)` never changes the element type.

Uses Adapt.jl to act inside some wrapper structs.

# Examples

```jldoctests
julia> mtl(ones(3)')
1×3 adjoint(::MtlVector{Float32, Private}) with eltype Float32:
 1.0  1.0  1.0

julia> mtl(zeros(1,3); storage=Shared)
1×3 MtlMatrix{Float32, Shared}:
 0.0  0.0  0.0

julia> mtl(1:3)
1:3

julia> MtlArray(1:3)
3-element MtlVector{Int64, Private}:
 1
 2
 3
```
"""
@inline mtl(xs; storage=DefaultStorageMode) = adapt(MtlArrayAdaptor{storage}(), xs)

## utilities

for (fname, felt) in ((:zeros, :zero), (:ones, :one))
  @eval begin
      $fname(::Type{T}, dims::Base.Dims{N}; storage=DefaultStorageMode) where {T,N} = fill!(MtlArray{T,N,storage}(undef, dims), $felt(T))
      $fname(::Type{T}, dims...; storage=DefaultStorageMode) where {T} = fill!(MtlArray{T,length(dims),storage}(undef, dims), $felt(T))
      $fname(dims...; storage=DefaultStorageMode) = fill!(MtlArray{Float32,length(dims),storage}(undef, dims), $felt(Float32))
  end
end

fill(v::T, dims::Base.Dims{N}; storage=DefaultStorageMode) where {T,N} = fill!(MtlArray{T,N,storage}(undef, dims), v)
fill(v::T, dims...; storage=DefaultStorageMode) where T = fill!(MtlArray{T,length(dims),storage}(undef, dims), v)

# optimized implementation of `fill!` for types that are directly supported by fillbuffer
function Base.fill!(A::MtlArray{T}, val) where T <: Union{UInt8,Int8}
  B = convert(T, val)
  unsafe_fill!(device(A), pointer(A), B, length(A))
  A
end


## derived arrays

function GPUArrays.derive(::Type{T}, a::MtlArray, dims::Dims{N}, offset::Int) where {T,N}
  offset = (a.offset * Base.elsize(a)) ÷ sizeof(T) + offset
  MtlArray{T,N}(a.data, dims; a.maxsize, offset)
end


## views

device(a::SubArray) = device(parent(a))

# pointer conversions
function Base.unsafe_convert(::Type{MTL.MTLBuffer}, V::SubArray{T,N,P,<:Tuple{Vararg{Base.RangeIndex}}}) where {T,N,P}
    return Base.unsafe_convert(MTL.MTLBuffer, parent(V)) +
           Base._memory_offset(V.parent, map(first, V.indices)...)
end
function Base.unsafe_convert(::Type{MTL.MTLBuffer}, V::SubArray{T,N,P,<:Tuple{Vararg{Union{Base.RangeIndex,Base.ReshapedUnitRange}}}}) where {T,N,P}
   return Base.unsafe_convert(MTL.MTLBuffer, parent(V)) +
          (Base.first_index(V)-1)*sizeof(T)
end


## PermutedDimsArray

device(a::Base.PermutedDimsArray) = device(parent(a))

Base.unsafe_convert(::Type{MTL.MTLBuffer}, A::PermutedDimsArray) =
    Base.unsafe_convert(MTL.MTLBuffer, parent(A))


## unsafe_wrap

function Base.unsafe_wrap(::Type{<:Array}, arr::MtlArray{T,N}, dims=size(arr); own=false) where {T,N}
  return unsafe_wrap(Array{T,N}, arr.data[], dims; own)
end

function Base.unsafe_wrap(t::Type{<:Array{T}}, buf::MTLBuffer, dims; own=false) where T
    ptr = convert(Ptr{T}, buf)
    return unsafe_wrap(t, ptr, dims; own)
end

function Base.unsafe_wrap(t::Type{<:Array{T}}, ptr::MtlPtr{T}, dims; own=false) where T
    return unsafe_wrap(t, convert(Ptr{T}, ptr), dims; own)
end

function Base.unsafe_wrap(A::Type{<:MtlArray{T,N}}, arr::Array, dims=size(arr);
                          dev=current_device(), kwargs...) where {T,N}
  GC.@preserve arr begin
    buf = MTLBuffer(dev, prod(dims) * sizeof(T), pointer(arr); nocopy=true, kwargs...)
    return A(buf, Dims(dims))
  end
end

## resizing

"""
  resize!(a::MtlVector, n::Integer)

Resize `a` to contain `n` elements. If `n` is smaller than the current collection length,
the first `n` elements will be retained. If `n` is larger, the new elements are not
guaranteed to be initialized.
"""
function Base.resize!(A::MtlVector{T}, n::Integer) where T
  # TODO: add additional space to allow for quicker resizing
  maxsize = n * sizeof(T)
  bufsize = if isbitstype(T)
    maxsize
  else
    # type tag array past the data
    maxsize + n
  end

  # replace the data with a new one. this 'unshares' the array.
  # as a result, we can safely support resizing unowned buffers.
  buf = alloc(device(A), bufsize; storage=storagemode(A))
  ptr = MtlPtr{T}(buf)
  m = min(length(A), n)
  if m > 0
    unsafe_copyto!(device(A), ptr, pointer(A), m)
  end
  new_data = DataRef(buf) do buf
    free(buf)
  end
  unsafe_free!(A)

  A.data = new_data
  A.dims = (n,)
  A.maxsize = maxsize
  A.offset = 0

  A
end
