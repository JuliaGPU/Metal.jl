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

`S` can be `Metal.SharedStorage` (default), `Metal.PrivateStorage`. The default
storage mode can be changed by setting `default_storage` in LocalPreferences.toml.

See the Array Programming section of the Metal.jl docs for more details.
"""
mutable struct MtlArray{T,N,S} <: AbstractGPUArray{T,N}
    data::DataRef{Managed}

    maxsize::Int  # maximum data size in bytes; excluding any selector bytes
    offset::Int   # offset of the data in the buffer, in bytes
    dims::Dims{N}

    function MtlArray{T,N,S}(::UndefInitializer, dims::Dims{N}) where {T,N,S}
        check_eltype(T)
        maxsize::Int = prod(dims) * sizeof(T)

        bufsize::Int = Base.isbitsunion(T) ? (maxsize + prod(dims)) : maxsize

        dev = device()
        data = GPUArrays.cached_alloc((MtlArray, dev, bufsize, S)) do
            buf = alloc(dev, bufsize; storage = S)
            DataRef(Managed(buf)) do managed
                free(managed.buffer)
            end
        end
        @label! data[].buffer "MtlArray{$(T),$(N),$(S)}(dims=$dims)"

        obj = new{T,N,S}(data, maxsize, 0, dims)
        finalizer(unsafe_free!, obj)
    end

    function MtlArray{T,N,S}(data::DataRef{Managed}, dims::Dims{N};
                             maxsize::Int=prod(dims) * sizeof(T), offset::Int=0) where {T,N,S}
        check_eltype(T)
        storagemode = convert(MTL.MTLStorageMode, S)
        if storagemode != data[].buffer.storageMode
            error("Storage mode mismatch: expected $S, got $(data[].buffer.storageMode)")
        end
        obj = new{T, N, S}(copy(data), maxsize, offset, dims)
        finalizer(unsafe_free!, obj)
    end
    function MtlArray{T,N}(data::DataRef{Managed}, dims::Dims{N};
                           maxsize::Int=prod(dims) * sizeof(T), offset::Int=0) where {T,N}
        check_eltype(T)
        storagemode = data[].buffer.storageMode
        obj = if storagemode == MTL.MTLStorageModeShared
            new{T,N,SharedStorage}(copy(data), maxsize, offset, dims)
        elseif storagemode == MTL.MTLStorageModeManaged
            @warn "`ManagedStorage` is no longer supported with `MtlArray`s. Instead, use `SharedStorage` or use the Metal api directly from `Metal.MTL`."
            new{T,N,ManagedStorage}(copy(data), maxsize, offset, dims)
        elseif storagemode == MTL.MTLStorageModePrivate
            new{T,N,PrivateStorage}(copy(data), maxsize, offset, dims)
        elseif storagemode == MTL.MTLStorageModeMemoryless
            new{T,N,Memoryless}(copy(data), maxsize, offset, dims)
        end
        finalizer(unsafe_free!, obj)
    end
end

# Create MtlArray from MTLBuffer
function MtlArray{T,N}(buf::B, dims::Dims{N}; kwargs...) where {B<:MTLBuffer,T,N}
    data = DataRef(Managed(buf)) do managed
        free(managed.buffer)
    end
    try
        return MtlArray{T,N}(data, dims; kwargs...)
    finally
        # the array holds its own reference; if constructing it failed, this frees the buffer
        unsafe_free!(data)
    end
end

GPUArrays.storage(a::MtlArray) = a.data

"""
    device(<:MtlArray)

Get the Metal device for an MtlArray.
"""
device(A::MtlArray) = A.data[].buffer.device

storagemode(x::MtlArray) = storagemode(typeof(x))
storagemode(::Type{<:MtlArray{<:Any,<:Any,S}}) where {S} = S

"""
    is_shared(A::MtlArray)::Bool

Returns true if `A` has storage mode [`Metal.SharedStorage`](@ref).

See also [`is_private`](@ref) and [`is_managed`](@ref).
"""
is_shared(A::MtlArray) = storagemode(A) == SharedStorage

"""
    is_managed(A::MtlArray)::Bool

Returns true if `A` has storage mode [`Metal.ManagedStorage`](@ref).

!!! warning
    `ManagedStorage` is no longer supported with `MtlArray`s. Instead, use `SharedStorage` or use the Metal api directly from `Metal.MTL`.

See also [`is_shared`](@ref) and [`is_private`](@ref).
"""
is_managed(A::MtlArray) = storagemode(A) == ManagedStorage # COV_EXCL_LINE

"""
    is_private(A::MtlArray)::Bool

Returns true if `A` has storage mode [`Metal.PrivateStorage`](@ref).

See also [`is_shared`](@ref).
"""
is_private(A::MtlArray) = storagemode(A) == PrivateStorage

is_memoryless(A::MtlArray) = storagemode(A) == Memoryless # COV_EXCL_LINE

## convenience constructors
"""
    MtlVector{T,S} <: AbstractGPUVector{T}

One-dimensional array with elements of type T for use with Apple Metal-compatible GPUs. Alias
for MtlArray{T,1,S}.

See also `Vector`(@ref), and the Array Programming section of the Metal.jl docs for more details.
"""
const MtlVector{T,S} = MtlArray{T,1,S}

"""
    MtlMatrix{T,S} <: AbstractGPUMatrix{T}

Two-dimensional array with elements of type T for use with Apple Metal-compatible GPUs. Alias
for MtlArray{T,2,S}.

See also `Matrix`(@ref), and the Array Programming section of the Metal.jl docs for more details.
"""
const MtlMatrix{T,S} = MtlArray{T,2,S}

"""
    MtlVecOrMat{T,S}

Union type of MtlVector{T,S} and MtlMatrix{T,S} which allows functions to accept either an
MtlMatrix or an MtlVector.

See also `VecOrMat`(@ref) for examples.
"""
const MtlVecOrMat{T,S} = Union{MtlVector{T,S},MtlMatrix{T,S}}

# default to shared memory
const DefaultStorageMode = let str = @load_preference("default_storage", "shared")
    if str == "shared"
        SharedStorage
    elseif str == "private"
        PrivateStorage
    else
        error("unknown default storage mode: $str")
    end
end

@public allowscalar
function allowscalar(allow::Bool)
    if !allow && DefaultStorageMode == SharedStorage
        @warn """Metal.jl uses unified memory by default, so scalar indexing will still be allowed on arrays that use it.
                 To ensure operations run on the GPU, set `default_storage` to "private" in your LocalPreferences.toml,
                 or use `Metal.PrivateStorage` when creating your `MtlArray`s.""" maxlog=1
    end
    GPUArrays.allowscalar(allow)
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

@inline function Base.pointer(x::MtlArray{T}, i::Integer=1; storage=PrivateStorage) where {T}
    PT = if storage == PrivateStorage
        MtlPtr{T}
    elseif storage == SharedStorage
        Ptr{T}
    else
        error("unknown memory type")
    end
    Base.unsafe_convert(PT, x) + Base._memory_offset(x, i)
end


function Base.unsafe_convert(::Type{MtlPtr{T}}, x::MtlArray) where {T}
    MtlPtr{T}(x.data[], x.offset)
end

# accessing memory from the CPU: wait for the GPU to finish using it
function Base.unsafe_convert(::Type{Ptr{S}}, x::MtlArray{T}) where {S,T}
    convert(Ptr{S}, MtlPtr{T}(x.data[], x.offset))
end


## indexing

# arrays in shared memory can be accessed directly by the CPU. this is meant to be fast, as
# it is used to iterate arrays on the CPU, so bypass the checks for scalar iteration and
# only synchronize when the GPU may still be using the array.
@inline function Base.getindex(x::MtlArray{T,N,SharedStorage}, I::Int) where {T,N}
    @boundscheck checkbounds(x, I)
    managed = x.data[]
    maybe_synchronize(managed)
    unsafe_load(convert(Ptr{T}, managed.host_ptr + x.offset), I)
end

@inline function Base.setindex!(x::MtlArray{T,N,SharedStorage}, v, I::Int) where {T,N}
    @boundscheck checkbounds(x, I)
    managed = x.data[]
    maybe_synchronize(managed)
    unsafe_store!(convert(Ptr{T}, managed.host_ptr + x.offset), v, I)
    return x
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
const WrappedMtlArray{T,N} = Union{MtlArray{T,N},WrappedArray{T,N,MtlArray,MtlArray{T,N}}}
const WrappedMtlVector{T} = WrappedMtlArray{T,1}
const WrappedMtlMatrix{T} = WrappedMtlArray{T,2}
const WrappedMtlVecOrMat{T} = Union{WrappedMtlVector{T},WrappedMtlMatrix{T}}


## conversions

Base.convert(::Type{T}, x::T) where T <: MtlArray = x


## interop with C libraries

# passing an array's buffer to Metal (e.g., to encode an MPS kernel) uses it on the GPU.
# the use is registered when the current task submits its next command buffer. note that
# MPS objects wrapping an array (e.g., `MPSMatrix`) only do so when they are constructed.
function Base.unsafe_convert(::Type{MTL.MTLBuffer}, x::MtlArray)
    managed = x.data[]
    push!(pending_ownership(), managed)
    return managed.buffer
end


## interop with ObjC libraries

Base.cconvert(::Type{<:id}, x::MtlArray) = Base.unsafe_convert(MTL.MTLBuffer, x)


## interop with CPU arrays

Base.collect(x::MtlArray{T,N}) where {T,N} = copyto!(Array{T,N}(undef, size(x)), x)


## memory copying

# CPU -> GPU
function Base.copyto!(dest::MtlArray{T}, doffs::Integer, src::Array{T}, soffs::Integer,
                      n::Integer) where T
    (n == 0 || sizeof(T) == 0) && return dest
    @boundscheck checkbounds(dest, doffs)
    @boundscheck checkbounds(dest, doffs + n - 1)
    @boundscheck checkbounds(src, soffs)
    @boundscheck checkbounds(src, soffs + n - 1)
    unsafe_copyto!(device(dest), dest, doffs, src, soffs, n)
    return dest
end

Base.copyto!(dest::MtlArray{T}, src::Array{T}) where {T} =
    copyto!(dest, 1, src, 1, length(src))

# GPU -> CPU
function Base.copyto!(dest::Array{T}, doffs::Integer, src::MtlArray{T}, soffs::Integer,
                      n::Integer) where T
    (n == 0 || sizeof(T) == 0) && return dest
    @boundscheck checkbounds(dest, doffs)
    @boundscheck checkbounds(dest, doffs + n - 1)
    @boundscheck checkbounds(src, soffs)
    @boundscheck checkbounds(src, soffs + n - 1)
    unsafe_copyto!(device(src), dest, doffs, src, soffs, n)
    return dest
end

Base.copyto!(dest::Array{T}, src::MtlArray{T}) where {T} =
    copyto!(dest, 1, src, 1, length(src))

# GPU -> GPU
function Base.copyto!(dest::MtlArray{T}, doffs::Integer, src::MtlArray{T}, soffs::Integer,
                      n::Integer) where T
    (n == 0 || sizeof(T) == 0) && return dest
    @boundscheck checkbounds(dest, doffs)
    @boundscheck checkbounds(dest, doffs + n - 1)
    @boundscheck checkbounds(src, soffs)
    @boundscheck checkbounds(src, soffs + n - 1)
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
    GC.@preserve src dest unsafe_copyto!(dev, pointer(dest, doffs), pointer(src, soffs), n)
    if Base.isbitsunion(T)
        # copy selector bytes
        error("Not implemented")
    end
    return dest
end

# GPU -> CPU
function Base.unsafe_copyto!(dev::MTLDevice, dest::Array{T}, doffs, src::MtlArray{T}, soffs, n) where T
    GC.@preserve src dest unsafe_copyto!(dev, pointer(dest, doffs), pointer(src, soffs), n)
    if Base.isbitsunion(T)
        # copy selector bytes
        error("Not implemented")
    end
    return dest
end

# GPU -> GPU
function Base.unsafe_copyto!(dev::MTLDevice, dest::MtlArray{T}, doffs, src::MtlArray{T}, soffs, n) where T
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
Adapt.adapt_storage(::Type{<:MtlArray{T}}, xs::AT) where {T,AT<:AbstractArray} =
    isbitstype(AT) ? xs : convert(MtlArray{T}, xs)
Adapt.adapt_storage(::Type{<:MtlArray{T,N}}, xs::AT) where {T,N,AT<:AbstractArray} =
    isbitstype(AT) ? xs : convert(MtlArray{T,N}, xs)
Adapt.adapt_storage(::Type{<:MtlArray{T,N,S}}, xs::AT) where {T,N,S,AT<:AbstractArray} =
    isbitstype(AT) ? xs : convert(MtlArray{T,N,S}, xs)


## opinionated gpu array adaptor

# eagerly converts Float64 to Float32, for compatibility reasons

struct MtlArrayAdaptor{S} end

# scalar conversions
Adapt.adapt_storage(::MtlArrayAdaptor, x::Float64) = Float32(x)
Adapt.adapt_storage(::MtlArrayAdaptor, x::Complex{Float64}) = ComplexF32(x)

# AbstractFloat → Float32
Adapt.adapt_storage(::MtlArrayAdaptor{S}, xs::AbstractArray{T,N}) where {T<:AbstractFloat,N,S} =
    isbits(xs) ? xs : MtlArray{Float32,N,S}(xs)

# Float16 — preserve (more specific)
Adapt.adapt_storage(::MtlArrayAdaptor{S}, xs::AbstractArray{T,N}) where {T<:Float16,N,S} =
    isbits(xs) ? xs : MtlArray{T,N,S}(xs)

# Complex{AbstractFloat} → ComplexF32
Adapt.adapt_storage(::MtlArrayAdaptor{S}, xs::AbstractArray{T,N}) where {T<:Complex{<:AbstractFloat},N,S} =
    isbits(xs) ? xs : MtlArray{ComplexF32,N,S}(xs)

# Complex{Float16} — preserve
Adapt.adapt_storage(::MtlArrayAdaptor{S}, xs::AbstractArray{T,N}) where {T<:Complex{Float16},N,S} =
    isbits(xs) ? xs : MtlArray{T,N,S}(xs)

# Generic — descend via adapt to handle composite types
function Adapt.adapt_storage(to::MtlArrayAdaptor{S}, xs::AbstractArray{T,N}) where {T,N,S}
    isbits(xs) && return xs
    adapted = map(x -> adapt(to, x), xs)
    MtlArray{eltype(adapted),N,S}(adapted)
end

"""
    mtl(A; storage=$(DefaultStorageMode))

`storage` can be `Metal.SharedStorage` or `Metal.PrivateStorage`.

Opinionated GPU array adaptor, which may alter the element type `T` of arrays:
* For `T<:AbstractFloat`, it makes a `MtlArray{Float32}` for performance and compatibility
  reasons (except for `Float16`).
* For `T<:Complex{<:AbstractFloat}` it makes a `MtlArray{ComplexF32}`.
* For composite element types (e.g. `SVector{2,Float64}`), Adapt.jl recursively converts
  `Float64` scalars to `Float32` via `adapt_structure`/`adapt_storage` dispatch.
* For other `isbitstype(T)`, it makes a `MtlArray{T}`.

By contrast, `MtlArray(A)` never changes the element type.

Uses Adapt.jl to act inside some wrapper structs.

# Examples

```jldoctest
julia> mtl(ones(3)')
1×3 adjoint(::MtlVector{Float32, Metal.SharedStorage}) with eltype Float32:
 1.0  1.0  1.0

julia> mtl(zeros(1,3); storage=Metal.SharedStorage)
1×3 MtlMatrix{Float32, Metal.SharedStorage}:
 0.0  0.0  0.0

julia> mtl(1:3)
1:3

julia> MtlArray(1:3)
3-element MtlVector{Int64, Metal.SharedStorage}:
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

function GPUArrays.derive(::Type{T}, a::MtlArray{<:Any,<:Any,S}, dims::Dims{N}, offset::Int) where {T,N,S}
    offset = a.offset + offset * sizeof(T)
    MtlArray{T,N,S}(a.data, dims; a.maxsize, offset)
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
           (Base.first_index(V) - 1) * sizeof(T)
end


## PermutedDimsArray

device(a::Base.PermutedDimsArray) = device(parent(a))

Base.unsafe_convert(::Type{MTL.MTLBuffer}, A::PermutedDimsArray) =
    Base.unsafe_convert(MTL.MTLBuffer, parent(A))


## unsafe_wrap

"""
    unsafe_wrap(Array, arr::MtlArray, [dims])

Wrap a Julia `Array` around the memory that backs `arr`, without copying. This is only
possible for arrays with `SharedStorage`, including host memory that was itself wrapped
using `unsafe_wrap(MtlArray, ...)`.

!!! warning

    The returned `Array` does **not** keep `arr` alive. The caller has to keep a reference
    to `arr` for as long as the `Array`, or anything derived from it, is used; otherwise
    the `Array` may end up referring to freed memory.

Wrapping waits for pending GPU operations on `arr`. GPU operations execute asynchronously,
so synchronize again (e.g., using `Metal.synchronize()`) before accessing the returned array
after using `arr` on the GPU.
"""
function Base.unsafe_wrap(
        ::Union{Type{Array}, Type{Array{T}}, Type{Array{T, N}}},
        arr::MtlArray{T, N}, dims = size(arr);
        own::Bool = false
    ) where {T, N}
    return unsafe_wrap(Array{T,N}, pointer(arr), dims; own)
end

function Base.unsafe_wrap(t::Type{<:Array{T}}, buf::MTLBuffer, dims; own=false) where T
    ptr = convert(Ptr{T}, buf)
    return unsafe_wrap(t, ptr, dims; own)
end

function Base.unsafe_wrap(t::Type{<:Array{T}}, ptr::MtlPtr{T}, dims; own=false) where T
    return unsafe_wrap(t, convert(Ptr{T}, ptr), dims; own)
end

# wrap a Metal pointer (e.g. `pointer(vec)`) in an `MtlArray` of the given shape,
# sharing the underlying buffer. This is useful to reinterpret a vector as a
# multi-dimensional array without copying. The resulting array does not own the
# buffer, so the original allocation must be kept alive for as long as it is used.
function Base.unsafe_wrap(::Type{<:MtlArray}, ptr::MtlPtr{T},
                          dims::NTuple{N,<:Integer}) where {T,N}
    # use a non-owning `DataRef` (no finalizer) so we never free a buffer we
    # don't own; the original array remains responsible for the allocation.
    # share the original's managed state so that both are synchronized alike.
    managed = something(ptr.managed, Managed(ptr.buffer))
    data = DataRef(managed)
    return MtlArray{T,N}(data, Dims(dims); offset=convert(Int, ptr.offset))
end
function Base.unsafe_wrap(t::Type{<:MtlArray}, ptr::MtlPtr, dim::Integer)
    return unsafe_wrap(t, ptr, (dim,))
end

"""
    unsafe_wrap(MtlArray, a::Array; [storage/hazard/cache options...])
    unsafe_wrap(MtlArray, ptr::Ptr{T}, dims; ...)
    unsafe_wrap(MtlArray{T,N}, a::Array, [dims]; ...)

Wrap an `MtlArray` around host memory, without copying, so that it can be used on the GPU,
e.g., in kernels or broadcasts. Apple silicon has unified memory, so the GPU operates
directly on the original memory, and changes are visible from both sides.

When wrapping an `Array`, the returned `MtlArray` keeps it alive, until the GPU is done
using it. When wrapping a pointer, the caller has to make sure the memory stays valid for
as long as the `MtlArray` is used. In both cases, the memory must not be freed or
reallocated while it is wrapped (e.g., by calling `resize!` on the original array), and
resizing the wrapper detaches it from the original memory.

GPU operations execute asynchronously, so synchronize (e.g., using `Metal.synchronize()`)
before accessing the original memory on the host.

```julia
a = rand(Float32, 1024)
b = unsafe_wrap(MtlArray, a)
b .= sin.(b)        # executes on the GPU, updating `a`
Metal.synchronize()
```
"""
# the element type, dimensionality and storage mode requested by an `unsafe_wrap` call,
# falling back to defaults for parameters that were not specified
wrap_eltype(::Type{<:MtlArray}, default) = default
wrap_eltype(::Type{<:MtlArray{T}}, default) where {T} = T
wrap_ndims(::Type{<:MtlArray}, default) = default
wrap_ndims(::Type{<:MtlArray{<:Any,N}}, default) where {N} = N
wrap_storage(::Type{<:MtlArray}) = SharedStorage
wrap_storage(::Type{<:MtlArray{<:Any,<:Any,S}}) where {S} = S

function Base.unsafe_wrap(A::Type{<:MtlArray}, arr::Array, dims=size(arr); kwargs...)
    T = wrap_eltype(A, eltype(arr))
    dims = Dims(dims)
    N = wrap_ndims(A, length(dims))
    length(dims) == N ||
        throw(ArgumentError("Cannot wrap memory as a $N-dimensional array with dimensions $dims"))
    isbitstype(T) || throw(ArgumentError("Can only wrap memory containing bits types"))
    nbytes = checked_bytesize(T, dims)
    nbytes <= sizeof(arr) ||
        throw(ArgumentError("Cannot wrap $(sizeof(arr)) bytes of memory as a $(nbytes)-byte MtlArray"))
    return wrap_host_memory(MtlArray{T,N,wrap_storage(A)}, reinterpret(Ptr{T}, pointer(arr)),
                            dims, arr; kwargs...)
end

function Base.unsafe_wrap(A::Type{<:MtlArray}, ptr::Ptr{T}, dims::NTuple{N,<:Integer};
                          kwargs...) where {T,N}
    wrap_eltype(A, T) == T ||
        throw(ArgumentError("Cannot wrap a pointer to $T as an array of $(wrap_eltype(A, T))"))
    wrap_ndims(A, N) == N ||
        throw(ArgumentError("Cannot wrap memory as a $(wrap_ndims(A, N))-dimensional array with dimensions $dims"))
    return wrap_host_memory(MtlArray{T,N,wrap_storage(A)}, ptr, Dims(dims), nothing;
                            kwargs...)
end
Base.unsafe_wrap(t::Type{<:MtlArray}, ptr::Ptr, dim::Integer; kwargs...) =
    unsafe_wrap(t, ptr, (dim,); kwargs...)

function checked_bytesize(::Type{T}, dims::Dims) where {T}
    all(>=(0), dims) || throw(ArgumentError("Invalid dimensions $dims"))
    return Base.checked_mul(foldl(Base.checked_mul, dims; init=1), sizeof(T))
end

# returns an async condition that keeps `owner` alive until it is signalled. we use this
# to keep host memory alive until Metal is done with it, which may be later than when the
# MtlArray is freed (e.g., when a command buffer that uses the buffer is still executing);
# the buffer's deallocator signals that moment.
#
# the callback task roots `owner`, and it is rooted itself while waiting for the condition,
# as libuv keeps the condition alive. Julia also creates it outside of the current
# cancellation scope, so it cannot be cancelled before the condition is signalled.
function root_until_signalled(owner)
    return Base.AsyncCondition() do cond
        GC.@preserve owner close(cond)
    end
end

function wrap_host_memory(::Type{MtlArray{T,N,S}}, ptr::Ptr{T}, dims::Dims{N}, owner;
                          dev::MTLDevice=device(), storage=S, kwargs...) where {T,N,S}
    # the GPU accesses the host memory directly, which requires shared storage
    S === storage === SharedStorage ||
        throw(ArgumentError("Host memory can only be wrapped as an array with SharedStorage"))
    isbitstype(T) || throw(ArgumentError("Can only wrap memory containing bits types"))
    check_eltype(T)
    nbytes = checked_bytesize(T, dims)
    if nbytes == 0
        return MtlArray{T,N,SharedStorage}(undef, dims)
    end
    ptr == C_NULL && throw(ArgumentError("Cannot wrap a NULL pointer"))
    iszero(UInt(ptr) % Base.datatype_alignment(T)) ||
        throw(ArgumentError("Pointer $ptr is not sufficiently aligned for elements of type $T"))

    # Metal can only wrap whole pages of memory, so wrap the pages that contain the
    # requested memory, and use an offset. any other data on those pages is left alone.
    ps = MTL.page_size()
    first_page = UInt(ptr) & ~UInt(ps - 1)
    last_page = Base.checked_add(UInt(ptr), UInt(nbytes - 1)) & ~UInt(ps - 1)
    bufsize = Base.checked_add(Int(last_page - first_page), ps)
    bufsize <= MTL.max_buffer_length(dev) ||
        throw(ArgumentError("Cannot wrap $(Base.format_bytes(nbytes)) of memory; Metal buffers are limited to $(Base.format_bytes(MTL.max_buffer_length(dev)))"))

    buf = if owner === nothing
        MTLBuffer(dev, bufsize, Ptr{Cvoid}(first_page); nocopy=true, storage=SharedStorage,
                  kwargs...)
    else
        cond = root_until_signalled(owner)
        deallocator = nil
        try
            # the block only signals `cond` without running Julia code, so it is safe for
            # Metal to invoke it from any thread, or from a finalizer that frees the buffer.
            deallocator = @objcasyncblock(cond)
            MTLBuffer(dev, bufsize, Ptr{Cvoid}(first_page); nocopy=true, deallocator,
                      storage=SharedStorage, kwargs...)
        catch
            ccall(:uv_async_send, Cint, (Ptr{Cvoid},), cond.handle)
            rethrow()
        finally
            # Metal keeps its own copy of the block
            deallocator === nil || release(deallocator)
        end
    end
    # frees the buffer (which releases the owner) if constructing the array fails
    return MtlArray{T,N}(buf, dims; offset=Int(UInt(ptr) - first_page))
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
    managed = Managed(buf)
    m = min(length(A), n)
    if m > 0
        unsafe_copyto!(device(A), MtlPtr{T}(managed), pointer(A), m)
    end
    new_data = DataRef(managed) do managed
        free(managed.buffer)
    end
    unsafe_free!(A)

    A.data = new_data
    A.dims = (n,)
    A.maxsize = maxsize
    A.offset = 0

    A
end
