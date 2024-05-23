# memory operations
# TODO: Properly use dispatch capabilities for these functions


## pointer type

# we cannot take a MTLBuffer's handle and work with that as it were a pointer to memory.
# instead, the Metal APIs always take the original handle and an offset parameter.

struct MtlPtr{T}
    buffer::MTLBuffer
    offset::UInt    # in bytes

    function MtlPtr{T}(buffer::MTLBuffer, offset=0) where {T}
        new(buffer, offset)
    end
end

Base.eltype(::Type{<:MtlPtr{T}}) where {T} = T

# limited arithmetic
Base.:(+)(x::MtlPtr{T}, y::Integer) where {T} = MtlPtr{T}(x.buffer, x.offset+y)
Base.:(-)(x::MtlPtr{T}, y::Integer) where {T} = MtlPtr{T}(x.buffer, x.offset-y)
Base.:(+)(x::Integer, y::MtlPtr{T}) where {T} = MtlPtr{T}(x.buffer, y+x.offset)

Base.convert(::Type{Ptr{T}}, ptr::MtlPtr) where {T} =
    convert(Ptr{T}, ptr.buffer) + ptr.offset


## operations

# CPU -> GPU
function Base.unsafe_copyto!(dev::MTLDevice, dst::MtlPtr{T}, src::Ptr{T}, N::Integer;
                             queue::MTLCommandQueue=global_queue(dev), async::Bool=false) where T
    storage_type = dst.buffer.storageMode
    if storage_type == MTL.MTLStorageModePrivate
        # stage through a shared buffer
        nocopy = MTL.can_alloc_nocopy(src, N*sizeof(T))
        tmp_buf = alloc(dev, N*sizeof(T), src; storage=Shared, nocopy)

        # copy to the private buffer
        unsafe_copyto!(dev, MtlPtr{T}(dst.buffer, dst.offset), MtlPtr{T}(tmp_buf, 0), N;
                       queue, async=(nocopy && async))
        free(tmp_buf)
    elseif storage_type == MTL.MTLStorageModeShared
        unsafe_copyto!(convert(Ptr{T}, dst), src, N)
    elseif storage_type == MTL.MTLStorageModeManaged
        unsafe_copyto!(convert(Ptr{T}, dst), src, N)
        MTL.DidModifyRange!(dst.buffer, 1:N)
    end
    return dst
end

# GPU -> CPU
function Base.unsafe_copyto!(dev::MTLDevice, dst::Ptr{T}, src::MtlPtr{T}, N::Integer;
                             queue::MTLCommandQueue=global_queue(dev), async::Bool=false) where T
    storage_type = src.buffer.storageMode
    if storage_type == MTL.MTLStorageModePrivate
        # stage through a shared buffer
        nocopy = MTL.can_alloc_nocopy(dst, N*sizeof(T))
        tmp_buf = if nocopy
            alloc(dev, N*sizeof(T), dst; storage=Shared, nocopy)
        else
            alloc(dev, N*sizeof(T); storage=Shared)
        end
        unsafe_copyto!(dev, MtlPtr{T}(tmp_buf, 0), MtlPtr{T}(src.buffer, src.offset), N;
                       queue, async=(nocopy && async))

        # copy from the shared buffer
        if !nocopy
            unsafe_copyto!(dst, convert(Ptr{T}, tmp_buf), N)
        end
        free(tmp_buf)
    elseif storage_type ==  MTL.MTLStorageModeShared
        unsafe_copyto!(dst, convert(Ptr{T}, src), N)
    elseif storage_type ==  MTL.MTLStorageModeManaged
        unsafe_copyto!(dst, convert(Ptr{T}, src), N)
    end
    return dst
end

# GPU -> GPU
@autoreleasepool function Base.unsafe_copyto!(dev::MTLDevice, dst::MtlPtr{T},
                                              src::MtlPtr{T}, N::Integer;
                                              queue::MTLCommandQueue=global_queue(dev),
                                              async::Bool=false) where T
    cmdbuf = MTLCommandBuffer(queue)
    MTLBlitCommandEncoder(cmdbuf) do enc
        MTL.append_copy!(enc, dst.buffer, dst.offset, src.buffer, src.offset, N * sizeof(T))
    end
    commit!(cmdbuf)
    async || wait_completed(cmdbuf)
end

@autoreleasepool function unsafe_fill!(dev::MTLDevice, ptr::MtlPtr{T},
                                       value::Union{UInt8,Int8}, N::Integer) where T
    cmdbuf = MTLCommandBuffer(global_queue(dev))
    MTLBlitCommandEncoder(cmdbuf) do enc
        MTL.append_fillbuffer!(enc, ptr.buffer, value, N * sizeof(T), ptr.offset)
    end
    commit!(cmdbuf)
    wait_completed(cmdbuf)
end

# TODO: Implement generic fill since mtBlitCommandEncoderFillBuffer is limiting
