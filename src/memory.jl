# memory operations
# TODO: Properly use dispatch capabilities for these functions


## pointer type

# we cannot take a MtlBuffer's handle and work with that as it were a pointer to memory.
# instead, the Metal APIs always take the original handle and an offset parameter.

struct MtlPointer{T}
    buffer::MtlBuffer
    offset::UInt    # in bytes

    function MtlPointer{T}(buffer::MtlBuffer, offset=0) where {T}
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
function Base.unsafe_copyto!(dev::MtlDevice, dst::MtlPointer{T}, src::MtlPointer{T}, N::Integer; 
                             queue::MtlCommandQueue=global_queue(dev)) where T
    cmdbuf = MtlCommandBuffer(queue)
    MtlBlitCommandEncoder(cmdbuf) do enc
        MTL.append_copy!(enc, dst.buffer, dst.offset, src.buffer, src.offset, N * sizeof(T))
    end
    commit!(cmdbuf)
    wait_completed(cmdbuf)
end

# GPU -> CPU
function Base.unsafe_copyto!(dev::MtlDevice, dst::Ptr{T}, src::MtlPointer{T}, N::Integer;
                             queue::MtlCommandQueue=global_queue(dev)) where T
    storage_type = src.buffer.storageMode
    if storage_type ==  MTL.MtStorageModePrivate
        tmp_buf = alloc(T, dev, N, storage=Shared)
        unsafe_copyto!(dev, tmp_buf, 1, src.buffer, src.offset, N, queue=queue)
        unsafe_copyto!(dst, contents(tmp_buf), N)
        free(tmp_buf)
    elseif storage_type ==  MTL.MtStorageModeShared
        unsafe_copyto!(dst, contents(src), N)
    elseif storage_type ==  MTL.MtStorageModeManaged
        unsafe_copyto!(dst, contents(src), N)
    end
    return dst
end

# CPU -> GPU
function Base.unsafe_copyto!(dev::MtlDevice, dst::MtlPointer{T}, src::Ptr{T}, N::Integer;
                             queue::MtlCommandQueue=global_queue(dev)) where T
    storage_type = dst.buffer.storageMode
    if storage_type == MTL.MtStorageModePrivate
        tmp_buf = alloc(T, dev, N, src, storage=Shared)
        unsafe_copyto!(dev, tmp_buf, src, N, queue=queue)
        unsafe_copyto!(dev, dst.buffer, dst.offset, tmp_buf, 1, N, queue=queue)
        free(tmp_buf)
    elseif storage_type == MTL.MtStorageModeShared
        unsafe_copyto!(contents(dst), src, N)
    elseif storage_type == MTL.MtStorageModeManaged
        unsafe_copyto!(contents(dst), src, N)
        MTL.DidModifyRange!(dst, 1:N)
    end
    return dst
end

function unsafe_fill!(dev::MtlDevice, ptr::MtlPointer{T}, value::Union{UInt8,Int8}, N::Integer) where T
    cmdbuf = MtlCommandBuffer(global_queue(dev))
    MtlBlitCommandEncoder(cmdbuf) do enc
        MTL.append_fillbuffer!(enc, ptr.buffer, value, N * sizeof(T), ptr.offset)
    end
    commit!(cmdbuf)
    wait_completed(cmdbuf)
end

# TODO: Implement generic fill since mtBlitCommandEncoderFillBuffer is limiting
