# memory operations

# GPU -> GPU
function Base.unsafe_copyto!(dev::MtlDevice, dst::MtlPtr{T},
    src::MtlPtr{T}, N::Integer) where T
    cmd = Metal.commit!(global_queue(dev)) do cmdbuf
        MtlBlitCommandEncoder(cmdbuf) do enc
            Metal.append_copy!(enc, src, dst, 0, 0, N * sizeof(T))
        end
    end
    wait(cmd)
end

# GPU -> CPU
function Base.unsafe_copyto!(dev::MtlDevice, dst::Ptr{T},
    src::MtlPtr{T}, N::Integer) where T
    tmp_buf = alloc(Host, dev, sizeof(T)*N)
    tmp_gpu = convert(MtlPtr{T}, tmp_buf)
    tmp_cpu = convert(Ptr{T}, tmp_buf)
    # Copy from GPU to GPU buffer residing in CPU memory
    Base.unsafe_copyto!(dev, tmp_gpu, src, N)
    # Copy from GPU Buffer in CPU memory to CPU memory
    Base.unsafe_copyto!(dst, tmp_cpu, N)
    #free temp buffer
    free(tmp_buf)
end

function unsafe_fill!(dev::MtlDevice, ptr::Union{Ptr{T},MtlPtr{T}}, value::Union{UInt8,Int8}, N::Integer) where T
    cmd = Metal.commit!(global_queue(dev)) do cmdbuf
        MtlBlitCommandEncoder(cmdbuf) do enc
            Metal.append_fill!(enc, src, value, N * sizeof(T))
        end
    end
    wait(cmd)
end
