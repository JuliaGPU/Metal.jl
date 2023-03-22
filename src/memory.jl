# memory operations
# TODO: Properly use dispatch capabilities for these functions


## pointer type

# we cannot take a MTLBuffer's handle and work with that as it were a pointer to memory.
# instead, the Metal APIs always take the original handle and an offset parameter.

struct MtlPointer{T}
    buffer::MTLBuffer
    offset::UInt    # in bytes

    function MtlPointer{T}(buffer::MTLBuffer, offset=0) where {T}
        new(buffer, offset)
    end
end

Base.eltype(::Type{<:MtlPointer{T}}) where {T} = T

# limited arithmetic
Base.:(+)(x::MtlPointer{T}, y::Integer) where {T} = MtlPointer{T}(x.buffer, x.offset+y)
Base.:(-)(x::MtlPointer{T}, y::Integer) where {T} = MtlPointer{T}(x.buffer, x.offset-y)
Base.:(+)(x::Integer, y::MtlPointer{T}) where {T} = MtlPointer{T}(x.buffer, y+x.offset)

# XXX: encode as `convert(Ptr)`?
MTL.contents(ptr::MtlPointer{T}) where {T} = convert(Ptr{T}, contents(ptr.buffer)) + ptr.offset


## operations

# GPU -> GPU
function Base.unsafe_copyto!(dev::MTLDevice, dst::MtlPointer{T}, src::MtlPointer{T}, N::Integer;
                             queue::MTLCommandQueue=global_queue(dev), async::Bool=false) where T
    cmdbuf = MTLCommandBuffer(queue)
    MTLBlitCommandEncoder(cmdbuf) do enc
        MTL.append_copy!(enc, dst.buffer, dst.offset, src.buffer, src.offset, N * sizeof(T))
    end
    commit!(cmdbuf)
    async || wait_completed(cmdbuf)
end

# GPU -> CPU
function Base.unsafe_copyto!(dev::MTLDevice, dst::Ptr{T}, src::MtlPointer{T}, N::Integer;
                             queue::MTLCommandQueue=global_queue(dev), async::Bool=false) where T
    storage_type = src.buffer.storageMode
    if storage_type ==  MTL.MTLStorageModePrivate
        tmp_buf = alloc(dev, N*sizeof(T), storage=Shared)
        unsafe_copyto!(dev, MtlPointer{T}(tmp_buf, 0), MtlPointer{T}(src.buffer, src.offset), N; queue, async=false)
        unsafe_copyto!(dst, convert(Ptr{T},contents(tmp_buf)), N)
        free(tmp_buf)
    elseif storage_type ==  MTL.MTLStorageModeShared
        unsafe_copyto!(dst, contents(src), N)
    elseif storage_type ==  MTL.MTLStorageModeManaged
        unsafe_copyto!(dst, contents(src), N)
    end
    return dst
end

# CPU -> GPU
function Base.unsafe_copyto!(dev::MTLDevice, dst::MtlPointer{T}, src::Ptr{T}, N::Integer;
                             queue::MTLCommandQueue=global_queue(dev), async::Bool=false) where T
    storage_type = dst.buffer.storageMode
    if storage_type == MTL.MTLStorageModePrivate
        tmp_buf = alloc(dev, N*sizeof(T), src, storage=Shared) #CPU -> GPU (Shared)
        unsafe_copyto!(dev, MtlPointer{T}(dst.buffer, dst.offset), MtlPointer{T}(tmp_buf, 0), N; queue, async=false) # GPU (Shared) -> GPU (Private)
        free(tmp_buf)
    elseif storage_type == MTL.MTLStorageModeShared
        unsafe_copyto!(contents(dst), src, N)
    elseif storage_type == MTL.MTLStorageModeManaged
        unsafe_copyto!(contents(dst), src, N)
        MTL.DidModifyRange!(dst, 1:N)
    end
    return dst
end

function unsafe_fill!(dev::MTLDevice, ptr::MtlPointer{T}, value::Union{UInt8,Int8}, N::Integer) where T
    cmdbuf = MTLCommandBuffer(global_queue(dev))
    MTLBlitCommandEncoder(cmdbuf) do enc
        MTL.append_fillbuffer!(enc, ptr.buffer, value, N * sizeof(T), ptr.offset)
    end
    commit!(cmdbuf)
    wait_completed(cmdbuf)
end

# TODO: Implement generic fill since mtBlitCommandEncoderFillBuffer is limiting
