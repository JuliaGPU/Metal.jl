# memory operations
# TODO: cmdbuf cleanup - Was running into errors
function sync_gpu_to_cpu!(dev::MtlDevice, buf::MtlBuffer{T}) where T
    cmdbuf = MtlCommandBuffer(global_queue(dev))
    MtlBlitCommandEncoder(cmdbuf) do enc
        MTL.append_sync!(enc, buf)
    end
    commit!(cmdbuf)
    wait_completed(cmdbuf)
end

# GPU -> GPU
Base.unsafe_copyto!(dev::MtlDevice, dst::MtlBuffer{T}, src::MtlBuffer{T}, N::Integer) where T =
    unsafe_copyto!(dev, dst, 1, src, 1, n)
function Base.unsafe_copyto!(dev::MtlDevice, dst::MtlBuffer{T}, doff, src::MtlBuffer{T}, soff, N::Integer) where T
    cmdbuf = MtlCommandBuffer(global_queue(dev))
    MtlBlitCommandEncoder(cmdbuf) do enc
        MTL.append_copy!(enc, dst, doff, src, soff, N * sizeof(T))
    end
    commit!(cmdbuf)
    wait_completed(cmdbuf)
end

# GPU -> CPU
Base.unsafe_copyto!(dev::MtlDevice, dst::Ptr{T}, src::MtlBuffer{T}, N::Integer) where T =
    unsafe_copyto!(dev, dst, src, 1, n)
function Base.unsafe_copyto!(dev::MtlDevice, dst::Ptr{T}, src::MtlBuffer{T}, soff::Integer, N::Integer) where T
    storage_type = src.storageMode
    if storage_type ==  MTL.MtStorageModePrivate
        tmp_buf = alloc(T, dev, N, storage=Shared)
        Base.unsafe_copyto!(dev, tmp_buf, 1, src, soff, N)
        Base.unsafe_copyto!(dst, content(tmp_buf), N)
        free(tmp_buf)
    elseif storage_type ==  MTL.MtStorageModeShared
        Base.unsafe_copyto!(dst, content(src), N)
    elseif storage_type ==  MTL.MtStorageModeManaged
        sync_gpu_to_cpu!(dev, src)
        Base.unsafe_copyto!(dst, content(src), N)
    end
    return dst
end

# CPU -> GPU
Base.unsafe_copyto!(dev::MtlDevice, dst::MtlBuffer{T}, src::Ptr{T}, N::Integer) where T =
    unsafe_copyto!(dev, dst, 1, src, n)
function Base.unsafe_copyto!(dev::MtlDevice, dst::MtlBuffer{T}, doff::Integer,  src::Ptr{T}, N::Integer) where T
    storage_type = dst.storageMode
    if storage_type == MTL.MtStorageModePrivate
        # Alloc a buffer containing a copy of src-ptr that is managed
        tmp_buf = alloc(T, dev, N, src, storage=Shared)
        # Copy from GPU to GPU buffer residing in CPU memory
        Base.unsafe_copyto!(dev, dst, doff, tmp_buf, 1, N)
        free(tmp_buf)
    elseif storage_type == MTL.MtStorageModeShared
        Base.unsafe_copyto!(dev, content(dst)+(doff-1)*sizeof(T), src, N)
    elseif storage_type == MTL.MtStorageModeManaged
        Base.unsafe_copyto!(dev, content(dst)+(doff-1)*sizeof(T), src, N)
        MTL.DidModifyRange!(dst, 1:N)
    end
    return dst
end

function unsafe_fill!(dev::MtlDevice, ptr::MtlBuffer{T}, value::Union{UInt8,Int8}, N::Integer) where T
    cmdbuf = MtlCommandBuffer(global_queue(dev))
    MtlBlitCommandEncoder(cmdbuf) do enc
        MTL.append_fillbuffer!(enc, ptr, value, N * sizeof(T))
    end
    commit!(cmdbuf)
    wait_completed(cmdbuf)
end

# TODO: Implement generic fill since mtBlitCommandEncoderFillBuffer is limiting