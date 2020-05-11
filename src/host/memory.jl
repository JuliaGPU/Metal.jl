# memory operations

# GPU -> GPU
Base.unsafe_copyto!(dev::MtlDevice, dst::MtlBuffer{T}, src::MtlBuffer{T}, N::Integer) where T =
    unsafe_copyto!(dev, dst, 1, src, 1, n)
function Base.unsafe_copyto!(dev::MtlDevice, dst::MtlBuffer{T}, doff, src::MtlBuffer{T}, soff, N::Integer) where T
    cmd = Metal.commit!(global_queue(dev)) do cmdbuf
        MtlBlitCommandEncoder(cmdbuf) do enc
            Metal.append_copy!(enc, dst, doff, src, soff, N * sizeof(T))
        end
    end
    wait(cmd)
end

# GPU -> CPU
Base.unsafe_copyto!(dev::MtlDevice, dst::Ptr{T}, src::MtlBuffer{T}, N::Integer) where T =
    unsafe_copyto!(dev, dst, src, 1, n)
function Base.unsafe_copyto!(dev::MtlDevice, dst::Ptr{T}, src::MtlBuffer{T}, soff::Integer, N::Integer) where T
    # Could be improved by checking storage type:
    # If Shared ->  Copy immediately
    # If Managed -> Sync
    tmp_buf = alloc(T, dev, N, storage=Shared)
    # Copy from GPU to GPU buffer residing in CPU memory
    Base.unsafe_copyto!(dev, tmp_buf, 1, src, soff, N)
    # Copy from GPU Buffer in CPU memory to CPU memory
    Base.unsafe_copyto!(dst, Metal.content(tmp_buf), N)

    #free temp buffer
    free(tmp_buf)
end

# CPU -> GPU
Base.unsafe_copyto!(dev::MtlDevice, dst::MtlBuffer{T}, src::Ptr{T}, N::Integer) where T =
    unsafe_copyto!(dev, dst, 1, src, n)
function Base.unsafe_copyto!(dev::MtlDevice, dst::MtlBuffer{T}, doff::Integer,  src::Ptr{T}, N::Integer) where T
    # Could be improved by checking storage type:
    # Alloc a buffer containing a copy of src-ptr that is managed
    tmp_buf = alloc(T, dev, N, src, storage=Managed)
    # Copy from GPU to GPU buffer residing in CPU memory
    Base.unsafe_copyto!(dev, dst, doff, tmp_buf, 1, N)

    # free temp buffer
    free(tmp_buf)
end

function unsafe_fill!(dev::MtlDevice, ptr::MtlBuffer{T}, value::Union{UInt8,Int8}, N::Integer) where T
    cmd = Metal.commit!(global_queue(dev)) do cmdbuf
        MtlBlitCommandEncoder(cmdbuf) do enc
            Metal.append_fill!(enc, src, value, N * sizeof(T))
        end
    end
    wait(cmd)
end
