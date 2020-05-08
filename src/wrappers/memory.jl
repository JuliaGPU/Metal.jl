# Raw memory management

export Mem, attribute, attribute!, memory_type, is_managed

module Mem

using ..MetalCore
using ..MetalCore: @enum_without_prefix, #=CUstream,=# MtlDevice, MtSize, MtlBuffer

#
# untyped buffers
#

abstract type Buffer end

# expected interface:
# - similar()
# - ptr, bytesize and ctx fields
# - convert() to Ptr and MtlPtr

Base.pointer(buf::Buffer) = buf.ptr

Base.sizeof(buf::Buffer) = buf.bytesize

MetalCore.device(buf::Buffer) = device(buf.ctx)

#MetalCore.heap(buf::Buffer) = device(buf.ctx)

# ccall integration
#
# taking the pointer of a buffer means returning the underlying pointer,
# and not the pointer of the buffer object itself.
Base.unsafe_convert(T::Type{<:Union{Ptr,MtlPtr}}, buf::Buffer) = convert(T, buf)

function free(buf::Buffer)
    if pointer(buf) != MTL_NULL
        MetalCore.mtBufferRelease(buf)
    end
end
## device buffer

"""
    Mem.DeviceBuffer
    Mem.Device

A buffer of device memory residing on the GPU. In Metal's language,
a PrivateBuffer
"""
struct DeviceBuffer <: Buffer
    ptr::MtlPtr{Cvoid}
    bytesize::Int
    ctx::MtlDevice
end

Base.similar(buf::DeviceBuffer, ptr::MtlPtr{Cvoid}=pointer(buf),
             bytesize::Int=sizeof(buf), ctx::MtlDevice=buf.ctx) =
    DeviceBuffer(ptr, bytesize, ctx)

Base.convert(::Type{<:Ptr}, buf::DeviceBuffer) =
    throw(ArgumentError("cannot take the CPU address of a GPU buffer"))

Base.convert(::Type{MtlPtr{T}}, buf::DeviceBuffer) where {T} =
    convert(MtlPtr{T}, pointer(buf))


"""
    Mem.alloc(DeviceBuffer, bytesize::Integer; hazard_tracking=MtResource...Default)

Allocate `bytesize` bytes of memory on the device. This memory is only accessible on the
GPU, and requires explicit calls to `unsafe_copyto!`, which wraps `cuMemcpy`,
for access on the CPU.
"""
function alloc(::Type{DeviceBuffer}, dev::MtlDevice, bytesize::Integer;
                hazard_tracking=MtResourceHazardTrackingModeDefault)
    opts = MtResourceStorageModePrivate + hazard_tracking

    ptr = mtDeviceNewBufferWithLength(dev, bytesize, opts)

    return DeviceBuffer(reinterpret(MtlPtr{Cvoid}, ptr),
                        bytesize, dev)
end


## host buffer

"""
    Mem.HostBuffer
    Mem.Host

A buffer of pinned memory on the CPU, accessible on the GPU. Implemented as
a Shared buffer in Metal.
"""
struct HostBuffer <: Buffer
    ptr::MtlPtr{Cvoid}
    bytesize::Int
    ctx::MtlDevice
end

Base.similar(buf::HostBuffer, ptr::Ptr{Cvoid}=pointer(buf), bytesize::Int=sizeof(buf),
             ctx::MtlDevice=buf.ctx) =
    HostBuffer(ptr, bytesize, ctx)

# Access the cpu address of this buffer which is the real storage
Base.convert(::Type{Ptr{T}}, buf::HostBuffer) where {T} =
    convert(Ptr{T}, mtBufferContents(buf))

Base.convert(::Type{MtlPtr{T}}, buf::HostBuffer) where {T} =
    convert(MtlPtr{T}, pointer(buf))


"""
    Mem.alloc(HostBuffer, bytesize::Integer; hazard_tracking=MtResource...Default)
"""
function alloc(::Type{HostBuffer}, dev::MtlDevice, bytesize::Integer;
                hazard_tracking=MtResourceHazardTrackingModeDefault,
                cache_mode=MtResourceCPUCacheModeDefaultCache)

    opts = MtResourceStorageModeShared + hazard_tracking + cache_mode

    ptr = mtDeviceNewBufferWithLength(dev, bytesize, opts)

    return HostBuffer(reinterpret(MtlPtr{Cvoid}, ptr), bytesize, dev)
end

## unified buffer

"""
    Mem.ManagedBuffer
    Mem.Unified

A managed buffer that is accessible on both the CPU and GPU. It is implemented
as a ManagedBuffer in Metal, and keeps a copy of its content on the GPU and
one on the CPU. Every write on the cpu should be followed by a call to
`didmodifyrange!` to inform the gpu that it should update the buffer.

This buffer has the same performance on the gpu as a private buffer.
"""
struct UnifiedBuffer <: Buffer
    ptr::MtlPtr{Cvoid}
    bytesize::Int
    ctx::MtlDevice
end

Base.similar(buf::UnifiedBuffer, ptr::MtlPtr{Cvoid}=pointer(buf),
             bytesize::Int=sizeof(buf), ctx::MtlDevice=buf.ctx) =
    UnifiedBuffer(ptr, bytesize, ctx)

# Access the cpu address of this buffer which is the real storage
Base.convert(::Type{Ptr{T}}, buf::UnifiedBuffer) where {T} =
    convert(Ptr{T}, mtBufferContents(buf))

Base.convert(::Type{MtlPtr{T}}, buf::UnifiedBuffer) where {T} =
    convert(MtlPtr{T}, pointer(buf))

"""
    Mem.alloc(HostBuffer, bytesize::Integer; hazard_tracking=MtResource...Default)
"""
function alloc(::Type{UnifiedBuffer}, dev::MtlDevice, bytesize::Integer;
                hazard_tracking=MtResourceHazardTrackingModeDefault,
                cache_mode=MtResourceCPUCacheModeDefaultCache)

    opts = MtResourceStorageModeManaged + hazard_tracking + cache_mode

    ptr = mtDeviceNewBufferWithLength(dev, bytesize, opts)

    return UnifiedBuffer(reinterpret(MtlPtr{Cvoid}, ptr), bytesize, dev)
end

"""
    didModifyRange!(buf::UnifiedBuffer, range)

Informs the GPU that the CPU has modified a section of the buffer
"""
function didModifyRange!(buf::UnifiedBuffer, range::AbstractRange)
    last(range) > sizeof(buf) && throw(BoundsError(buf, range))
    mtBufferDidModifyRange(buf, range)
end


## convenience aliases

const Device  = DeviceBuffer
const Host    = HostBuffer
const Unified = UnifiedBuffer

end

#
# typed pointers
#

## initialization
#=
"""
    Mem.set!(buf::MtlPtr, value::Union{UInt8,UInt16,UInt32}, len::Integer;
             async::Bool=false, stream::CuStream)

Initialize device memory by copying `val` for `len` times. Executed asynchronously if
`async` is true, in which case a valid `stream` is required.
"""
set!

for T in [UInt8, UInt16, UInt32]
    bits = 8*sizeof(T)
    fn_sync = Symbol("cuMemsetD$(bits)")
    fn_async = Symbol("cuMemsetD$(bits)Async")
    @eval function set!(ptr::MtlPtr{$T}, value::$T, len::Integer;
                        async::Bool=false, stream::Union{Nothing,CuStream}=nothing)
        if async
          stream===nothing &&
              throw(ArgumentError("Asynchronous memory operations require a stream."))
            $(getproperty(CUDAdrv, fn_async))(ptr, value, len, stream)
        else
          stream===nothing ||
              throw(ArgumentError("Synchronous memory operations cannot be issues on a stream."))
            $(getproperty(CUDAdrv, fn_sync))(ptr, value, len)
        end
    end
end


## copy operations

for (f, srcPtrTy, dstPtrTy) in (("cuMemcpyDtoH", MtlPtr, Ptr),
                                ("cuMemcpyHtoD", Ptr,   MtlPtr),
                                ("cuMemcpyDtoD", MtlPtr, MtlPtr),
                               )
    @eval function Base.unsafe_copyto!(dst::$dstPtrTy{T}, src::$srcPtrTy{T}, N::Integer;
                                       stream::Union{Nothing,CuStream}=nothing,
                                       async::Bool=false) where T
        if async
            stream===nothing &&
                throw(ArgumentError("Asynchronous memory operations require a stream."))
            $(getproperty(CUDAdrv, Symbol(f * "Async")))(dst, src, N*sizeof(T), stream)
        else
            stream===nothing ||
                throw(ArgumentError("Synchronous memory operations cannot be issued on a stream."))
            $(getproperty(CUDAdrv, Symbol(f)))(dst, src, N*sizeof(T))
        end
        return dst
    end
end

"""
    unsafe_copy3d!(dst, dstTyp, src, srcTyp, width, height=1, depth=1;
                   dstPos=(1,1,1), dstPitch=0, dstHeight=0,
                   srcPos=(1,1,1), srcPitch=0, srcHeight=0,
                   async=false, stream=nothing)

Perform a 3D memory copy between pointers `src` and `dst`, at respectively position `srcPos`
and `dstPos` (1-indexed). Both pitch and destination can be specified for both the source
and destination; consult the CUDA documentation for more details. This call is executed
asynchronously if `async` is set, in which case `stream` needs to be a valid CuStream.
"""
function unsafe_copy3d!(dst::Union{Ptr{T},MtlPtr{T}}, dstTyp::Type{<:Buffer},
                        src::Union{Ptr{T},MtlPtr{T}}, srcTyp::Type{<:Buffer},
                        width::Integer, height::Integer=1, depth::Integer=1;
                        dstPos::CuDim=(1,1,1), srcPos::CuDim=(1,1,1),
                        dstPitch::Integer=0, dstHeight::Integer=0,
                        srcPitch::Integer=0, srcHeight::Integer=0,
                        async::Bool=false, stream::Union{Nothing,CuStream}=nothing) where T
    srcPos = CUDAdrv.CuDim3(srcPos)
    dstPos = CUDAdrv.CuDim3(dstPos)

    srcMemoryType, srcHost, srcDevice = if srcTyp == Host
        CUDAdrv.CU_MEMORYTYPE_HOST,
        src::Ptr,
        CU_NULL
    elseif srcTyp == Mem.Device
        CUDAdrv.CU_MEMORYTYPE_DEVICE,
        C_NULL,
        src::MtlPtr
    elseif srcTyp == Mem.Unified
        CUDAdrv.CU_MEMORYTYPE_UNIFIED,
        C_NULL,
        reinterpret(MtlPtr{Cvoid}, src)
    end
    srcArray = C_NULL

    dstMemoryType, dstHost, dstDevice = if dstTyp == Host
        CUDAdrv.CU_MEMORYTYPE_HOST,
        dst::Ptr,
        CU_NULL
    elseif dstTyp == Mem.Device
        CUDAdrv.CU_MEMORYTYPE_DEVICE,
        C_NULL,
        dst::MtlPtr
    elseif dstTyp == Mem.Unified
        CUDAdrv.CU_MEMORYTYPE_UNIFIED,
        C_NULL,
        reinterpret(MtlPtr{Cvoid}, dst)
    end
    dstArray = C_NULL

    params_ref = Ref(CUDAdrv.CUDA_MEMCPY3D(
        # source
        srcPos.x-1, srcPos.y-1, srcPos.z-1,
        0, # LOD
        srcMemoryType, srcHost, srcDevice, srcArray,
        C_NULL, # reserved
        srcPitch, srcHeight,
        # destination
        dstPos.x-1, dstPos.y-1, dstPos.z-1,
        0, # LOD
        dstMemoryType, dstHost, dstDevice, dstArray,
        C_NULL, # reserved
        dstPitch, dstHeight,
        # extent
        width*sizeof(T), height, depth
    ))
    if async
        stream===nothing &&
            throw(ArgumentError("Asynchronous memory operations require a stream."))
        CUDAdrv.cuMemcpy3DAsync_v2(params_ref, stream)
    else
        stream===nothing ||
            throw(ArgumentError("Synchronous memory operations cannot be issued on a stream."))
        CUDAdrv.cuMemcpy3D_v2(params_ref)
    end
end


## memory info

function info()
    free_ref = Ref{Csize_t}()
    total_ref = Ref{Csize_t}()
    CUDAdrv.cuMemGetInfo(free_ref, total_ref)
    return convert(Int, free_ref[]), convert(Int, total_ref[])
end

end # module Mem

"""
    available_memory()

Returns the available_memory amount of memory (in bytes), available for allocation by the CUDA context.
"""
available_memory() = Mem.info()[1]

"""
    total_memory()

Returns the total amount of memory (in bytes), available for allocation by the CUDA context.
"""
total_memory() = Mem.info()[2]


## pointer attributes

"""
    attribute(X, ptr::Union{Ptr,MtlPtr}, attr)

Returns attribute `attr` about pointer `ptr`. The type of the returned value depends on the
attribute, and as such must be passed as the `X` parameter.
"""
function attribute(X::Type, ptr::Union{Ptr{T},MtlPtr{T}}, attr::CUpointer_attribute) where {T}
    ptr = reinterpret(MtlPtr{T}, ptr)
    data_ref = Ref{X}()
    cuPointerGetAttribute(data_ref, attr, ptr)
    return data_ref[]
end

"""
    attribute!(ptr::Union{Ptr,MtlPtr}, attr, val)

Sets attribute` attr` on a pointer `ptr` to `val`.
"""
function attribute!(ptr::Union{Ptr{T},MtlPtr{T}}, attr::CUpointer_attribute, val) where {T}
    ptr = reinterpret(MtlPtr{T}, ptr)
    cuPointerSetAttribute(Ref(val), attr, ptr)
    return
end

@enum_without_prefix CUpointer_attribute CU_

# some common attributes

@enum_without_prefix CUmemorytype CU_
memory_type(x) = CUmemorytype(attribute(Cuint, x, POINTER_ATTRIBUTE_MEMORY_TYPE))

is_managed(x) = convert(Bool, attribute(Cuint, x, POINTER_ATTRIBUTE_IS_MANAGED))
=#
